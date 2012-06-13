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

import by.blooddy.crypto.SHA1;
import flash.utils.*;
import nexus.vcs.git.objects.*;

/**
 * Methods for operating on git repositories
 */
public class GitUtil
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	CLASS VARIABLES
	//--------------------------------------
	
	//--------------------------------------
	//	INTERNAL CLASS METHODS
	//--------------------------------------
	
	static public function readSHA1FromStream(bytes:IDataInput):String
	{
		var sha1:String = "";
		var cursor:int = 0;
		while(cursor < 20)
		{
			var val:int = bytes.readUnsignedByte();
			sha1 += (val < 16 ? "0" : "") + val.toString(16);
			++cursor;
		}
		return sha1;
	}
	
	static public function debug_parsePackfileIndex(index:ByteArray):String
	{
		var debug:String = "";
		var fanOutTable:Array = [];
		for(var x:int = 0; x < 256; ++x)
		{
			fanOutTable[x] = index.readInt();
			//version 2 packfile index
			if(x == 0 && fanOutTable[x] == -9154717)
			{
				return debug_parsePackfileIndex_v2(index);
			}
		}
		
		debug += fanOutTable;
		
		return debug;
	}
	
	static public function debug_parsePackfile(index:ByteArray):String
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
		var objectCount : int = index.readInt();
		debug += objectCount + " objects in pack\n";
		
		return debug;
	}
	
	//--------------------------------------
	//	PRIVATE CLASS METHODS
	//--------------------------------------
	
	static private function debug_parsePackfileIndex_v2(index:ByteArray):String
	{
		index.position = 0;
		var debug:String = "";
		
		//A 4-byte magic number '\377tOc' which is an unreasonable fanout[0] value.
		if(index.readInt() != -9154717)
		{
			throw new Error("Packfile index is not version 2, but was provided to the version 2 parser.");
		}
		
		//A 4-byte version number (= 2)
		var version:int = index.readInt();
		debug += "version " + version + "\n";
		
		var fanout:Array = [];
		//A 256-entry fan-out table just like v1.
		for(var x:int = 0; x < 256; ++x)
		{
			fanout[x] = index.readInt();
		}
		
		var bucketCount:int;
		
		var hashes:Array = [];
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
				hashes[x] = [];
				for(var i:int = 0; i < bucketCount; ++i)
				{
					hashes[x].push(GitUtil.readSHA1FromStream(index));
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
		
		var offsets:Array = [];
		var offset64Count : int = 0;
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
				offsets[x] = [];
				for(i = 0; i < bucketCount; ++i)
				{
					var offset : int = index.readInt();
					offsets[x].push(offset);
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
			var offset64Bytes : ByteArray = new ByteArray();
			index.readBytes(offset64Bytes, 0, offset64Count * 8);
		}
		
		//A copy of the 20-byte SHA1 checksum at the end of corresponding packfile.
		var packfileHash : String = GitUtil.readSHA1FromStream(index);
		
		//20-byte SHA1-checksum of all of the above.
		var checksum : String = GitUtil.readSHA1FromStream(index);
		
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
				debug += x + ": " + bucketCount + "\n";
				debug += "hashes: " + hashes[x] + "\n";
				debug += "crc: " + crc32[x] + "\n";
				debug += "offsets: " + offsets[x] + "\n";
			}
		}
		debug += "packfileHash: " + packfileHash + "\n";
		debug += "checksum: " + checksum + "\n";
		return debug;
	}
}

}