// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.vcs.git
{

import by.blooddy.crypto.SHA1;
import flash.errors.IllegalOperationError;
import flash.utils.*;

/**
 * ...
 */
public class GitPackIndex
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_hashesRaw:Dictionary;
	private var m_offsetsRaw:Dictionary;
	private var m_offsetsSorted:Vector.<int>;
	private var m_crc32sRaw:Dictionary;
	private var m_fanout:Vector.<int>;
	private var m_objectCount:int;
	
	private var m_packHash:String;
	
	private var m_name:String;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function GitPackIndex(name:String=null)
	{
		m_name = name;
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get objectCount():int { return m_objectCount; }
	
	public function get packfileHash():String { return m_packHash; }
	
	public function get name():String { return m_name; }
	public function set name(value:String):void
	{
		m_name = value;
	}
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	public function initialize(bytes:ByteArray):void
	{
		bytes.position = 0;
		//determine if version 2 packfile index
		//A 4-byte magic number '\377tOc' which is an unreasonable fanout[0] value.
		if(bytes.readInt() == -9154717)
		{
			parseIndex_v2(bytes);
		}
		else
		{
			//reset position to read full fanout
			bytes.position = 0;
			parseIndex_v1(bytes);
		}
	}
	
	public function containsObject(hashToFind:String):Boolean
	{
		for each(var hashSet:Vector.<String> in m_hashesRaw)
		{
			if(hashSet.indexOf(hashToFind) != -1)
			{
				return true;
			}
		}
		return false;
	}
	
	public function getOffsetFromHash(hash:String):int
	{
		for(var key : String in m_hashesRaw)
		{
			for(var i : int = 0; i < m_hashesRaw[key].length; ++i)
			{
				if(m_hashesRaw[key][i] == hash)
				{
					return m_offsetsRaw[key][i];
				}
			}
		}
		return -1;
	}
	
	public function getHashFromOffset(offset:int):String
	{
		for(var key : String in m_offsetsRaw)
		{
			for(var i : int = 0; i < m_offsetsRaw[key].length; ++i)
			{
				if(m_offsetsRaw[key][i] == offset)
				{
					return m_hashesRaw[key][i];
				}
			}
		}
		return null;
	}
	
	public function getNextOffset(offset:int):int
	{
		//get the index of the current offset
		var index:int = m_offsetsSorted.indexOf(offset);
		//return -1 if the index is the last entry in the offset table
		return index == m_offsetsSorted.length - 1 ? -1 : m_offsetsSorted[index + 1];
	}
	
	public function toString(verbose:Boolean=false):String
	{
		return "[GitPackIndex:" + m_name + ".idx]";
	}
	
	public function debug_index():String
	{
		var debug:String = "";
		for(var x:int = 0; x < 256; ++x)
		{
			var bucketCount:int = x == 0 ? m_fanout[x] : m_fanout[x] - m_fanout[x - 1];
			if(bucketCount > 0)
			{
				debug += (x < 16 ? "0" : "") + x.toString(16) + ":" + bucketCount + " (fanout " + m_fanout[x] + ")\n";
				for(var y:int = 0; y < m_hashesRaw[x].length; ++y)
				{
					debug += m_hashesRaw[x][y] + ":" + m_crc32sRaw[x][y] + ":" + m_offsetsRaw[x][y] + "\n";
				}
			}
		}
		return debug;
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
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
			throw new Error("Error parsing " + m_name + ".idx, magic number indicated version 2 but version number is " + version);
		}
		
		//256 4-byte integers. N-th entry of this table records the number of objects in the corresponding pack,
		//the first byte of whose object name is less than or equal to N. This is called the 'first-level fan-out' table.
		m_fanout = new Vector.<int>(256, true);
		for(var x:int = 0; x < 256; ++x)
		{
			m_fanout[x] = index.readInt();
		}
		m_objectCount = m_fanout[255];
		
		var bucketCount:int;
		
		m_hashesRaw = new Dictionary();
		//A table of sorted 20-byte SHA1 object names. These are packed together without offset values
		//to reduce the cache footprint of the binary search for a specific object name.
		for(x = 0; x < 256; x++)
		{
			bucketCount = x == 0 ? m_fanout[x] : m_fanout[x] - m_fanout[x - 1];
			if(bucketCount > 0)
			{
				m_hashesRaw[x] = new Vector.<String>(bucketCount, true);
				for(var i:int = 0; i < bucketCount; ++i)
				{
					m_hashesRaw[x][i] = GitUtil.readSHA1FromStream(index);
				}
			}
		}
		
		m_crc32sRaw = new Dictionary();
		//A table of 4-byte CRC32 values of the packed object data.
		for(x = 0; x < 256; ++x)
		{
			bucketCount = x == 0 ? m_fanout[x] : m_fanout[x] - m_fanout[x - 1];
			if(bucketCount > 0)
			{
				m_crc32sRaw[x] = new Vector.<uint>(bucketCount, true);
				for(i = 0; i < bucketCount; ++i)
				{
					m_crc32sRaw[x][i] = index.readUnsignedInt();
				}
			}
		}
		
		m_offsetsRaw = new Dictionary();
		m_offsetsSorted = new Vector.<int>();
		var offset64Count:int = 0;
		//A table of 4-byte offset values (in network byte order).
		//These are usually 31-bit pack file offsets, but large offsets are encoded as an index into the next table with the msbit set.
		for(x = 0; x < 256; ++x)
		{
			bucketCount = x == 0 ? m_fanout[x] : m_fanout[x] - m_fanout[x - 1];
			if(bucketCount > 0)
			{
				m_offsetsRaw[x] = new Vector.<int>(bucketCount, true);
				for(i = 0; i < bucketCount; ++i)
				{
					var offset:int = index.readInt();
					m_offsetsRaw[x][i] = offset;
					m_offsetsSorted.push(offset);
					//if the most significant bit is set, we'll need to read a 64-bit offset value in the next table
					if(offset < 0)
					{
						offset64Count++;
					}
				}
			}
		}
		m_offsetsSorted.sort(Array.NUMERIC);
		
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
		var storedHash : String = GitUtil.readSHA1FromStream(index);
		
		//verify index
		var contentBytes : ByteArray = new ByteArray();
		try
		{
			index.position = 0;
			index.readBytes(contentBytes, 0, index.length - 20);
			var generatedHash : String = SHA1.hashBytes(contentBytes);
			if(storedHash != generatedHash)
			{
				throw new Error("Checksum in " + m_name + ".idx (" + storedHash + ") does not match the hash of its contents (" + generatedHash + ")");
			}
		}
		finally
		{
			contentBytes.clear();
			contentBytes = null;
		}
	}
}

}