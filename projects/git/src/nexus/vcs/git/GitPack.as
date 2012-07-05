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
	private var m_repo:GitRepository;
	private var m_index:GitPackIndex;
	
	private var m_packBytes:ByteArray;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function GitPack(name:String, repo:GitRepository)
	{
		m_name = name;
		m_repo = repo;
		
		//read index immediately
		var indexBytes : ByteArray = m_repo.readBytesAtPath("objects/pack/" + m_name + ".idx");
		m_index = new GitPackIndex(name);
		m_index.initialize(indexBytes);
		indexBytes.clear();
		indexBytes = null;
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get name():String { return m_name; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	public function containsObject(hash:String):Boolean
	{
		return m_index.containsObject(hash);
	}
	
	public function getObject(hash:String):AbstractGitObject
	{
		var offset:int = m_index.getObjectOffset(hash);
		if(offset != -1)
		{
			//delay reading in of packfile until we try to access an object from it
			loadPackfile();
			
			m_packBytes.position = offset;
			
			//read n-bytes to get object type and (uncompressed) size
			var byte:int = m_packBytes.readUnsignedByte();
			//3-bit type
			var type:int = (byte >> 4) & 0x07; //mask the three type bits after we've shifted off the other four
			//(n-1)*7+4-bit length
			var size:int = byte & 0x0f; //mask the other four bits
			var i:int = 0;
			//read bytes from header to find size, the first byte without the msb set signifies the last byte of the header
			while((byte & 128) != 0)
			{
				byte = m_packBytes.readUnsignedByte();
				//mask all but msb and shift over depending on # of iterations (plus the 4 bits from the start)
				size += ((byte & 0x7f) << ((i * 7) + 4));
				++i;
			}
			
			//TODO: support pack deltas
			//trace("offset", offset, "dataOffset", m_packBytes.position, "dataSize", size, "typeCode", type);
			if(type == ObjectType.PACK_DELTA_OFFSET || type == ObjectType.PACK_DELTA_REFERENCE)
			{
				trace("delta", type);
				return null;
			}
			
			//find the next sequential offset so we know how much data to read for this object
			var nextOffset:int = m_index.getNextOffset(offset);
			//if the next offset is invalid, then we'll read up to the SHA-1 at the end of the pack
			nextOffset = nextOffset == -1 ? m_packBytes.length - 20 : nextOffset;
			
			//read in the content from the packfile
			var contentBytes:ByteArray = new ByteArray();
			//read the number of bytes from our current position to the next offset
			//m_packBytes.position is at the start of the data after we finished reading the header above, so
			m_packBytes.readBytes(contentBytes, 0, nextOffset - m_packBytes.position);
			contentBytes.uncompress();
			contentBytes.position = 0;
			if(contentBytes.length != size)
			{
				//TODO: Throw a more useful error here (GitVerifyError?)
				throw new Error("Object data does not match size " + size + " for object " + hash + " in packfile " + m_name);
			}
			
			return GitUtil.createObjectByType(type, size, hash, contentBytes, m_repo);
		}
		return null;
	}
	
	public function toString(verbose:Boolean = false):String
	{
		return "[GitPack:" + m_name + "]";
	}
	
	public function debug_index():String
	{
		return m_index.debug_index();
	}
	
	public function debug_pack():String
	{
		loadPackfile();
		return GitUtil.hexDump(m_packBytes);
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
	private function loadPackfile():void
	{
		if(m_packBytes == null)
		{
			m_packBytes = m_repo.readBytesAtPath("objects/pack/" + m_name + ".pack");
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
			if(objectCount != m_index.objectCount)
			{
				throw new Error("Pack and index report different object counts (" + objectCount + " vs " + m_index.objectCount + ") for " + m_name);
			}
			
			//verify SHA-1 checksum with index
			m_packBytes.position = m_packBytes.length - 20;
			var hash : String = GitUtil.readSHA1FromStream(m_packBytes);
			if(hash != m_index.packfileHash)
			{
				throw new Error("Pack and index report different checksums (" + hash + " vs " + m_index.packfileHash + ") for " + m_name);
			}
		}
	}
}

}