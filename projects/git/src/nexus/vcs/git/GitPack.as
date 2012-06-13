/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is nexuslib.
 *
 * The Initial Developer of the Original Code is
 * Malachi Griffie <malachi@nexussays.com>.
 * Portions created by the Initial Developer are Copyright (C) 2011
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** */
package nexus.vcs.git
{
import flash.errors.IllegalOperationError;
import flash.utils.ByteArray;
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
	
	private static const OBJ_COMMIT:int = 1;
	private static const OBJ_TREE:int = 2;
	private static const OBJ_BLOB:int = 3;
	private static const OBJ_TAG:int = 4;
	
	/**
	  n-byte offset (see below) interpreted as a negative
		offset from the type-byte of the header of the
		ofs-delta entry (the size above is the size of
		the delta data that follows).
	  delta data, deflated.

	 offset encoding:
	  n bytes with MSB set in all but the last one.
	  The offset is then the number constructed by
	  concatenating the lower 7 bit of each byte, and
	  for n >= 2 adding 2^7 + 2^14 + ... + 2^(7*(n-1))
	  to the result.
	 */
	private static const OBJ_OFS_DELTA:int = 6;
	
	/**
	  20-byte base object name SHA1 (the size above is the
		size of the delta data that follows).
		  delta data, deflated.
	 */
	//The base object is allowed to be omitted from the packfile, but only in the case of a thin pack being transferred over the network.
	private static const OBJ_REF_DELTA:int = 7;
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_name:String;
	private var m_version:int;
	private var m_hashes:Array;
	private var m_offsets:Array;
	private var m_indexHash:String;
	private var m_packfileHash:String;
	private var m_packBytes:ByteArray;
	private var m_indexObjectCount:int;
	
	private var m_repo : GitManager;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function GitPack(name:String, indexBytes:ByteArray, repo:GitManager)
	{
		m_name = name;
		m_repo = repo;
		
		parsePackfileIndex(indexBytes);
		trace("m_indexObjectCount", m_indexObjectCount, name);
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get name():String
	{
		return m_name;
	}
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	public function hashExists(hashToFind:String):Boolean
	{
		for each(var hashSet:Array in m_hashes)
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
		var ids:Array = getIndexOf(hash);
		if(ids != null)
		{
			if(m_packBytes == null)
			{
				loadPack();
			}
			
			var offset:int = m_offsets[ids[0]][ids[1]];
			//trace("object exists at offset " + offset + " in pack " + m_name);
			m_packBytes.position = offset;
			var byte:int = m_packBytes.readUnsignedByte();
			//n-byte type and length (3-bit type, (n-1)*7+4-bit length)
			var type:int = (byte >> 4) & 0x07; //7 == 0b111, i.e., mask the three type bits
			var size:int = byte & 0x0f; //15 == 0b1111, i.e., mask the other four bits
			var i:int = 0;
			//read bits with msb set
			while((byte & 0x80) != 0)
			{
				byte = m_packBytes.readByte();
				//mask most significant bit and shift over depending on # of iterations (plus the 4 bits from the start)
				size += ((byte & 0x7f) << ((i * 7) + 4));
				++i;
			}
			//trace("offset", offset, "dataOffset", m_packBytes.position, "dataSize", size, "typeCode", type);
			if(type == OBJ_OFS_DELTA || type == OBJ_REF_DELTA)
			{
				//trace("delta", type);
				return null;
			}
			//debug:
			var f:Array = []
			for each(var arr:Array in m_offsets)
			{
				for each(var num:int in arr)
				{
					f.push(num);
				}
			}
			f.sort(Array.NUMERIC);
			var index:int = f.indexOf(offset);
			//trace("next object starts at", f[index + 1], "need to read", f[index + 1] - m_packBytes.position, "bytes");
			var read:int = f[index + 1] - m_packBytes.position;
			//end debug
			var foo:ByteArray = new ByteArray();
			m_packBytes.readBytes(foo, 0, read);
			foo.uncompress();
			if(foo.length != size)
			{
				throw new Error("Object data does not match size " + size + " for object " + hash + " in packfile " + m_name);
			}
			
			switch(type)
			{
				case OBJ_COMMIT:
					return new GitCommit(hash, m_repo, size);
				case OBJ_TREE:
					return new GitTree(hash, m_repo, size);
				case OBJ_BLOB:
					return new GitBlob(hash, m_repo, size);
				case OBJ_TAG:
					return new GitTag(hash, m_repo, size);
				default:
					throw new Error("Delta packed objects ae currently not supported");
			}
		}
		return null;
	}
	
	private function getIndexOf(hash:String):Array
	{
		//get the object id
		for(var i:int = 0; i < m_hashes.length; ++i)
		{
			if(i in m_hashes)
			{
				for(var j:int = 0; j < m_hashes[i].length; ++j)
				{
					if(m_hashes[i][j] == hash)
					{
						return[i, j];
					}
				}
			}
		}
		return null;
	}
	
	public function toString(verbose:Boolean = false):String
	{
		return "[GitPack:" + "]";
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
	private function loadPack():void
	{
		m_packBytes = m_repo.readBytesAtPath("objects/pack/" + name + ".pack");
	}
	
	private function parsePackfileIndex(index:ByteArray):void
	{
		index.position = 0;
		
		//determine if version 2 packfile index
		//A 4-byte magic number '\377tOc' which is an unreasonable fanout[0] value.
		if(index.readInt() == -9154717)
		{
			parsePackfileIndex_v2(index);
		}
		else
		{
			index.position = 0;
			parsePackfileIndex_v1(index);
		}
	}
	
	/**
	 * Parse a pack file
	 * @see	https://github.com/git/git/blob/master/Documentation/technical/pack-format.txt
	 * @param	index
	 * @return
	 */
	private function parsePackfile(index:ByteArray):String
	{
		index.position = 0;
		var debug:String = "";
		
		//4-byte signature: The signature is: {'P', 'A', 'C', 'K'}
		var sig:String = index.readUTFBytes(4);
		if(sig != "PACK")
		{
			throw new ArgumentError("Invalid pack bytes. Signature is incorrect.");
		}
		
		//4-byte version number (network byte order): GIT currently accepts version number 2 or 3 but generates version 2 only.
		var version:int = index.readInt();
		if(version != 2)
		{
			throw new Error("Index version is " + version + " but currently only version 2 is able to be parsed correctly");
		}
		debug += "version: " + version + "\n";
		
		//4-byte number of objects contained in the pack (network byte order)
		var objectCount:int = index.readInt();
		debug += objectCount + " objects in pack\n";
		
		return debug;
	}
	
	private function parsePackfileIndex_v1(index:ByteArray):void
	{
		throw new IllegalOperationError("Not yet able to parse this version of the pack index");
		
		index.position = 0;
		
		var fanoutTable:Array = [];
		for(var x:int = 0; x < 256; ++x)
		{
			fanoutTable[x] = index.readInt();
		}
	}
	
	/**
	 * Parse the pack index file version 2
	 * @param	index	The bytes of this file
	 * @see	https://github.com/git/git/blob/master/Documentation/technical/pack-format.txt
	 * @return
	 */
	private function parsePackfileIndex_v2(index:ByteArray):void
	{
		//A 4-byte version number (= 2)
		m_version = index.readInt();
		if(m_version != 2)
		{
			throw new Error("Error parsing pack-" + m_name + ".idx, magic number indicated version 2 but version number is " + m_version);
		}
		
		var fanout:Array = [];
		//A 256-entry fan-out table just like v1.
		for(var x:int = 0; x < 256; ++x)
		{
			fanout[x] = index.readInt();
		}
		m_indexObjectCount = fanout[255];
		
		var bucketCount:int;
		
		m_hashes = [];
		//A table of sorted 20-byte SHA1 object names. These are packed together without offset values
		//to reduce the cache footprint of the binary search for a specific object name.
		for(x = 0; x < 256; x++)
		{
			if(x == 0)
			{
				bucketCount = fanout[x];
			}
			else
			{
				bucketCount = fanout[x] - fanout[x - 1];
			}
			
			if(bucketCount > 0)
			{
				m_hashes[x] = [];
				for(var i:int = 0; i < bucketCount; ++i)
				{
					m_hashes[x].push(GitUtil.readSHA1FromStream(index));
				}
			}
		}
		
		var crc32:Array = [];
		//A table of 4-byte CRC32 values of the packed object data.
		for(x = 0; x < 256; ++x)
		{
			if(x == 0)
			{
				bucketCount = fanout[x];
			}
			else
			{
				bucketCount = fanout[x] - fanout[x - 1];
			}
			
			if(bucketCount > 0)
			{
				crc32[x] = [];
				for(i = 0; i < bucketCount; ++i)
				{
					crc32[x].push(index.readUnsignedInt());
				}
			}
		}
		
		m_offsets = [];
		var offset64Count:int = 0;
		//A table of 4-byte offset values (in network byte order).
		//These are usually 31-bit pack file offsets, but large offsets are encoded as an index into the next table with the msbit set.
		for(x = 0; x < 256; ++x)
		{
			if(x == 0)
			{
				bucketCount = fanout[x];
			}
			else
			{
				bucketCount = fanout[x] - fanout[x - 1];
			}
			
			if(bucketCount > 0)
			{
				m_offsets[x] = [];
				for(i = 0; i < bucketCount; ++i)
				{
					var offset:int = index.readInt();
					m_offsets[x].push(offset);
					//if the most significant bit is set, we'll need to read a 640bit offset value in the next table
					if(offset < 0)
					{
						offset64Count++;
					}
				}
			}
		}
		
		//A table of 8-byte offset entries (empty for pack files less than 2 GiB).
		//Pack files are organized with heavily used objects toward the front, so most object references should not need to refer to this table.
		if(offset64Count > 0)
		{
			//TODO: figure out what to do with this value
			var offset64Bytes:ByteArray = new ByteArray();
			index.readBytes(offset64Bytes, 0, offset64Count * 8);
		}
		
		//A copy of the 20-byte SHA1 checksum at the end of corresponding packfile.
		m_packfileHash = GitUtil.readSHA1FromStream(index);
		
		//20-byte SHA1-checksum of all of the above.
		m_indexHash = GitUtil.readSHA1FromStream(index);
	}
}

}