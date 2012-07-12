// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.vcs.git
{

import flash.utils.ByteArray;
import flash.utils.Dictionary;

import nexus.vcs.git.*;
import nexus.vcs.git.objects.*;

/**
 * @see	https://raw.github.com/git/git/master/Documentation/technical/pack-format.txt
 * @see https://github.com/git/git/blob/master/builtin/unpack-objects.c#L422
 * @see https://github.com/jelmer/dulwich/blob/master/dulwich/pack.py#L690
 */
public class GitPack
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	/**
	 * The smallest possible delta size is 4 bytes
	 */
	public static const DELTA_SIZE_MIN : int = 4;
	
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
		
		m_packBytes = new ByteArray();
		
		//read index immediately
		var indexBytes:ByteArray = m_repo.readBytesAtPath("objects/pack/" + m_name + ".idx");
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
		var offset:int = m_index.getOffsetFromHash(hash);
		if(offset != -1)
		{
			//delay reading in of packfile until we try to access an object from it
			loadPackfile();
			
			var packObject : GitPackObject = readOffset(offset);
			return GitUtil.createObjectByType(packObject.type, packObject.size, hash, packObject.bytes, m_repo);
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
		m_packBytes.position = 0;
		return GitUtil.hexDump(m_packBytes);
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
	private function loadPackfile():void
	{
		if(m_packBytes.length == 0)
		{
			m_repo.readBytesAtPathIntoByteArray("objects/pack/" + m_name + ".pack", m_packBytes);
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
			var hash:String = GitUtil.readSHA1FromStream(m_packBytes);
			if(hash != m_index.packfileHash)
			{
				throw new Error("Pack and index report different checksums (" + hash + " vs " + m_index.packfileHash + ") for " + m_name);
			}
		}
	}
	
	private function readOffset(offset:int):GitPackObject
	{
		var packObject : GitPackObject = new GitPackObject();
		
		m_packBytes.position = offset;
		
		//read n-bytes to get object type and (uncompressed) size
		var byte:uint = m_packBytes.readUnsignedByte();
		//3-bit type
		packObject.type = (byte >> 4) & 0x07; //mask the three type bits after we've shifted off the other four
		//(n-1)*7+4-bit length
		var size:int = byte & 0x0f; //mask the other four bits
		//read bytes from header to find size
		//the first byte without the msb set signifies the last byte of the header so make sure the header isn't already over
		if((byte & 128) != 0)
		{
			//can OR this instead of adding since we're shifting by 4 bytes to start with
			size |= readSizeHeader(m_packBytes, 4);
		}
		packObject.size = size;
		
		//read additional header info for delta objects
		if(packObject.type == ObjectType.PACK_OFFSET_DELTA)
		{
			byte = m_packBytes.readUnsignedByte();
			var deltaOffset:uint = byte & 0x7f;
			//the first byte without the msb set signifies the last byte of the delta offset size
			//@see https://github.com/git/git/blob/master/builtin/unpack-objects.c#L365
			while((byte & 128) != 0)
			{
				byte = m_packBytes.readUnsignedByte();
				deltaOffset += 1;
				deltaOffset <<= 7;
				deltaOffset += (byte & 0x7f);
			}
			//delta offset is a negative offset from the start of this object
			deltaOffset = offset - deltaOffset;
			if(deltaOffset <= 0 || deltaOffset >= offset)
			{
				//TODO: better error message
				throw new Error("Offset delta " + (offset - deltaOffset) + " on object " + m_index.getHashFromOffset(offset) + " is out of bounds.");
			}
		}
		//TODO: support reference deltas
		else if(packObject.type == ObjectType.PACK_REFERENCE_DELTA)
		{
			var sha:String = GitUtil.readSHA1FromStream(m_packBytes);
			trace("delta_ref", sha);
			return null;
		}
		
		//find the next sequential offset so we know how much data to read for this object
		var nextOffset:int = m_index.getNextOffset(offset);
		//if the next offset is invalid, then we'll read up to the SHA-1 at the end of the pack
		nextOffset = nextOffset == -1 ? m_packBytes.length - 20 : nextOffset;
		
		//read the number of bytes from our current position to the next offset
		//m_packBytes.position is at the start of the data after we finished reading the header
		m_packBytes.readBytes(packObject.bytes, 0, nextOffset - m_packBytes.position);
		packObject.bytes.uncompress();
		packObject.bytes.position = 0;
		
		if(packObject.type == ObjectType.PACK_OFFSET_DELTA)
		{
			var parent : GitPackObject = readOffset(deltaOffset);
			packObject.bytes = patchDelta(parent.bytes, packObject.bytes);
			packObject.type = parent.type;
		}
		else if(packObject.type == ObjectType.PACK_REFERENCE_DELTA)
		{
			//TODO: support reference deltas
			return null;
		}
		//if object isn't a delta, verify that the size matches what is reported in the header
		else if(packObject.bytes.length != packObject.size)
		{
			//TODO: Throw a more useful error here (GitVerifyError?)
			throw new Error("Object data does not match size " + packObject.size + " for object " + m_index.getHashFromOffset(offset) + " in packfile " + m_name);
		}
		
		return packObject;
	}
	
	//--------------------------------------
	//	PRIVATE CLASS METHODS
	//--------------------------------------
	
	private static function readSizeHeader(bytes:ByteArray, shift:int=0):int
	{
		var size : int = 0;
		do
		{
			var byte : uint = bytes.readUnsignedByte();
			//mask all but msb and shift over depending on # of iterations
			size |= (byte & 0x7f) << shift;
			shift += 7;
		} while((byte & 128) != 0 && bytes.bytesAvailable)
		return size;
	}
	
	/**
	 * Merge a delta and its base
	 * @see	https://github.com/git/git/blob/master/patch-delta.c
	 */
	private static function patchDelta(deltaBase:ByteArray, delta:ByteArray):ByteArray
	{
		if(delta.length < DELTA_SIZE_MIN)
		{
			throw new ArgumentError("Cannot patch object, provided delta is less than the minimum " + DELTA_SIZE_MIN + " bytes");
		}
		
		var baseSize : int = readSizeHeader(delta);
		var finalSize : int = readSizeHeader(delta);
		
		if(baseSize != deltaBase.length)
		{
			throw new Error("Delta base size (" + deltaBase.length + ") differs from size listed in delta (" + baseSize + ")");
		}
		
		var result : ByteArray = new ByteArray();
		while(delta.bytesAvailable)
		{
			var byte : uint = delta.readUnsignedByte();
			if(byte & 0x80)
			{
				var copyOffset : int = 0;
				var copyLength : int = 0;
				
				if(byte & 0x01) copyOffset = delta.readUnsignedByte();
				if(byte & 0x02) copyOffset |= (delta.readUnsignedByte() << 8);
				if(byte & 0x04) copyOffset |= (delta.readUnsignedByte() << 16);
				if(byte & 0x08) copyOffset |= (delta.readUnsignedByte() << 24);
				
				if(byte & 0x10) copyLength = delta.readUnsignedByte();
				if(byte & 0x20) copyLength |= (delta.readUnsignedByte() << 8);
				if(byte & 0x40) copyLength |= (delta.readUnsignedByte() << 16);
				
				if(copyLength == 0)
				{
					//65536
					copyLength = 0x10000;
				}
				
				if( copyOffset + copyLength < copyLength
					//if we're copying beyond the length of the deltaBase
					|| copyOffset + copyLength > baseSize
					//if we're copying more than the entire size of the final object
					|| copyLength > finalSize)
				{
					break;
				}
				
				result.writeBytes(deltaBase, copyOffset, copyLength);
			}
			else if(byte != 0)
			{
				result.writeBytes(delta, delta.position, byte);
				delta.position += byte;
			}
			else
			{
				//TODO: throw a more descriptive error type here?
				throw new Error("Invalid opcode " + byte + " provided in delta");
			}
		}
		
		if(delta.bytesAvailable)
		{
			//TODO: need descriptive error message here, especially considering how unlikely it is
			throw new Error("Problem patching delta");
		}
		
		result.position = 0;
		return result;
	}
}

}