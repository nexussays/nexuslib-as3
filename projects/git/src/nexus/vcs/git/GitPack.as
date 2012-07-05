// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.vcs.git
{
import flash.errors.IllegalOperationError;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import nexus.vcs.git.objects.*;

/**
 * @see	https://raw.github.com/git/git/master/Documentation/technical/pack-format.txt
 * @see https://github.com/jelmer/dulwich/blob/master/dulwich/pack.py#L690
 */
public class GitPack
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_name:String;
	
	private var m_hashes:Dictionary;
	private var m_offsets:Dictionary;
	private var m_offsetsSorted:Vector.<int>;
	private var m_crc32s:Dictionary;
	private var m_fanout:Vector.<int>;
	private var m_indexObjectCount:int;
	
	private var m_indexHash:String;
	private var m_packHash:String;
	
	private var m_packBytes:ByteArray;
	
	private var m_repo:GitRepository;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function GitPack(name:String, index:ByteArray, repo:GitRepository)
	{
		m_name = name;
		m_repo = repo;
		
		index.position = 0;
		//determine if version 2 packfile index
		//A 4-byte magic number '\377tOc' which is an unreasonable fanout[0] value.
		if(index.readInt() == -9154717)
		{
			parseIndex_v2(index);
		}
		else
		{
			//reset position to read full fanout
			index.position = 0;
			parseIndex_v1(index);
		}
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get name():String { return m_name; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	public function hashExists(hashToFind:String):Boolean
	{
		for each(var hashSet:Vector.<String> in m_hashes)
		{
			for each(var hash:String in hashSet)
			{
				//trace(m_name, hash, hashToFind);
				if(hash == hashToFind)
				{
					return true;
				}
			}
		}
		return false;
	}
	
	public function getObject(hash:String):AbstractGitObject
	{
		var offset:int = getOffset(hash);
		if(offset != -1)
		{
			loadPackfile();
			
			m_packBytes.position = offset;
			
			//get object type and (uncompressed) size
			var byte:int = m_packBytes.readUnsignedByte();
			//n-byte type and length (3-bit type, (n-1)*7+4-bit length)
			var type:int = (byte >> 4) & 0x07; //7 == 0b111, i.e., mask the three type bits after we've shifted off the other four
			var size:int = byte & 0x0f; //15 == 0b1111, i.e., mask the other four bits
			var i:int = 0;
			//read bits with msb set, the first byte without th msb set signifies the last byte of the header
			while((byte & 0x80) != 0)
			{
				byte = m_packBytes.readByte();
				//mask most significant bit and shift over depending on # of iterations (plus the 4 bits from the start)
				size += ((byte & 0x7f) << ((i * 7) + 4));
				++i;
			}
			
			//TODO: support pack deltas
			//trace("offset", offset, "dataOffset", m_packBytes.position, "dataSize", size, "typeCode", type);
			if(type == ObjectType.PACK_DELTA_OFFSET || type == ObjectType.PACK_DELTA_REFERENCE)
			{
				//trace("delta", type);
				return null;
			}
			
			//find the next sequential offset so we know how much data to read for this object
			//m_packBytes.position is currntly at the start of the data after we finished reading the header above
			var index:int = m_offsetsSorted.indexOf(offset);
			var bytesToRead:int;
			if(index == m_offsetsSorted.length - 1)
			{
				//read the number of bytes to take us up to the SHA-1 at the end of the pack
				bytesToRead = (m_packBytes.length - 20) - m_packBytes.position;
			}
			else
			{
				//read the number of bytes to take us up to the next offset
				bytesToRead = m_offsetsSorted[index + 1] - m_packBytes.position;
			}
			
			//read in the content from the packfile
			var contentBytes:ByteArray = new ByteArray();
			m_packBytes.readBytes(contentBytes, 0, bytesToRead);
			contentBytes.uncompress();
			contentBytes.position = 0;
			if(contentBytes.length != size)
			{
				throw new Error("Object data does not match size " + size + " for object " + hash + " in packfile " + m_name);
			}
			
			return GitUtil.createObjectByType(type, hash, contentBytes, size, m_repo);
		}
		return null;
	}
	
	public function toString(verbose:Boolean = false):String
	{
		return "[GitPack:" + m_name + "]";
	}
	
	public function debug_index():String
	{
		var debug:String = "";
		//debug += "version " +  + "\n";
		//debug += m_fanout + "\n";
		for(var x:int = 0; x < 256; ++x)
		{
			var bucketCount:int = x == 0 ? m_fanout[x] : m_fanout[x] - m_fanout[x - 1];
			if(bucketCount > 0)
			{
				debug += x + ": " + bucketCount + " (fanout " + m_fanout[x] + ")\n";
				debug += "hashes: " + m_hashes[x] + "\n";
				debug += "crc: " + m_crc32s[x] + "\n";
				debug += "offsets: " + m_offsets[x] + "\n";
			}
		}
		debug += "packfileHash: " + m_packHash + "\n";
		debug += "checksum: " + m_indexHash + "\n";
		return debug;
	}
	
	public function debug_pack():String
	{
		loadPackfile();
		return GitUtil.getHexString(m_packBytes);
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
	private function getOffset(hash:String):int
	{
		for(var key : String in m_hashes)
		{
			for(var i : int = 0; i < m_hashes[key].length; ++i)
			{
				if(m_hashes[key][i] == hash)
				{
					return m_offsets[key][i];
				}
			}
		}
		return -1;
	}
	
	private function loadPackfile():void
	{
		if(m_packBytes == null)
		{
			m_packBytes = m_repo.readBytesAtPath("objects/pack/" + name + ".pack");
			m_packBytes.position = 0;
			
			//4-byte signature: The signature is: {'P', 'A', 'C', 'K'}
			if(m_packBytes.readUTFBytes(4) != "PACK")
			{
				throw new ArgumentError("Invalid pack bytes. Signature is incorrect.");
			}
			
			//4-byte version number (network byte order): GIT currently accepts version number 2 or 3 but generates version 2 only.
			var version:int = m_packBytes.readInt();
			if(version != 2)
			{
				throw new Error("Pack version is " + version + " but currently only version 2 is able to be parsed correctly");
			}
			
			//4-byte number of objects contained in the pack (network byte order)
			var objectCount:int = m_packBytes.readInt();
			if(objectCount != m_indexObjectCount)
			{
				throw new Error("Pack and index report different object counts (" + objectCount + ", " + m_indexObjectCount + ") for " + m_name);
			}
		}
	}
	
	private function parseIndex_v1(index:ByteArray):void
	{
		throw new IllegalOperationError("Not yet able to parse packfile index version 1");
	}
	
	private function parseIndex_v2(index:ByteArray):void
	{
		//A 4-byte version number (= 2)
		var version : int = index.readInt();
		if(version != 2)
		{
			throw new Error("Error parsing pack-" + m_name + ".idx, magic number indicated version 2 but version number is " + version);
		}
		
		//256 4-byte integers. N-th entry of this table records the number of objects in the corresponding pack,
		//the first byte of whose object name is less than or equal to N. This is called the 'first-level fan-out' table.
		m_fanout = new Vector.<int>(256, true);
		for(var x:int = 0; x < 256; ++x)
		{
			m_fanout[x] = index.readInt();
		}
		m_indexObjectCount = m_fanout[255];
		
		var bucketCount:int;
		
		m_hashes = new Dictionary();
		//A table of sorted 20-byte SHA1 object names. These are packed together without offset values
		//to reduce the cache footprint of the binary search for a specific object name.
		for(x = 0; x < 256; x++)
		{
			bucketCount = x == 0 ? m_fanout[x] : m_fanout[x] - m_fanout[x - 1];
			if(bucketCount > 0)
			{
				m_hashes[x] = new Vector.<String>(bucketCount, true);
				for(var i:int = 0; i < bucketCount; ++i)
				{
					m_hashes[x][i] = GitUtil.readSHA1FromStream(index);
				}
			}
		}
		
		m_crc32s = new Dictionary();
		//A table of 4-byte CRC32 values of the packed object data.
		for(x = 0; x < 256; ++x)
		{
			bucketCount = x == 0 ? m_fanout[x] : m_fanout[x] - m_fanout[x - 1];
			if(bucketCount > 0)
			{
				m_crc32s[x] = new Vector.<int>(bucketCount, true);
				for(i = 0; i < bucketCount; ++i)
				{
					m_crc32s[x][i] = index.readUnsignedInt();
				}
			}
		}
		
		m_offsets = new Dictionary();
		m_offsetsSorted = new Vector.<int>();
		var offset64Count:int = 0;
		//A table of 4-byte offset values (in network byte order).
		//These are usually 31-bit pack file offsets, but large offsets are encoded as an index into the next table with the msbit set.
		for(x = 0; x < 256; ++x)
		{
			bucketCount = x == 0 ? m_fanout[x] : m_fanout[x] - m_fanout[x - 1];
			if(bucketCount > 0)
			{
				m_offsets[x] = new Vector.<int>(bucketCount, true);
				for(i = 0; i < bucketCount; ++i)
				{
					var offset:int = index.readInt();
					m_offsets[x][i] = offset;
					m_offsetsSorted.push(offset);
					//if the most significant bit is set, we'll need to read a 64-bit offset value in the next table
					if(offset < 0)
					{
						offset64Count++;
					}
				}
			}
		}
		m_offsetsSorted.sort(compareOffset);
		
		//A table of 8-byte offset entries (empty for pack files less than 2 GiB).
		//Pack files are organized with heavily used objects toward the front, so most object references should not need to refer to this table.
		if(offset64Count > 0)
		{
			//TODO: figure out what to do with this
			var offset64Bytes:ByteArray = new ByteArray();
			index.readBytes(offset64Bytes, 0, offset64Count * 8);
		}
		
		//A copy of the 20-byte SHA1 checksum at the end of corresponding packfile.
		m_packHash = GitUtil.readSHA1FromStream(index);
		
		//20-byte SHA1-checksum of all of the above.
		m_indexHash = GitUtil.readSHA1FromStream(index);
	}
	
	private function compareOffset(l:int, r:int):Number
	{
		return l < r ? -1 : (l > r ? 1 : 0);
	}
}

}