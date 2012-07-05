// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
	//	PUBLIC CLASS METHODS
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
	
	static public function createObjectByType(type:Object, size:int, hash:String, contentBytes:ByteArray, repo:GitRepository):AbstractGitObject
	{
		var result:AbstractGitObject;
		switch(type)
		{
			case ObjectType.COMMIT:
			case ObjectType.PACK_COMMIT:
				result = new GitCommit(hash, repo);
				break;
			case ObjectType.TREE:
			case ObjectType.PACK_TREE:
				result = new GitTree(hash, repo);
				break;
			case ObjectType.BLOB:
			case ObjectType.PACK_BLOB:
				result = new GitBlob(hash, repo);
				break;
			case ObjectType.TAG:
			case ObjectType.PACK_TAG:
				result = new GitTag(hash, repo);
				break;
			default:
				//TODO: Throw a mor specific error type
				throw new Error("Unknown or unsupported git object type \"" + type + "\"");
		}
		result.populateContent(contentBytes, size);
		return result;
	}
	
	/**
	 * Returns the contents of the provided byte stream as a hex-formatted string, with spacing after each group of 2 bytes.
	 * @param	bytes	The byte stream to read from
	 */
	static public function hexDump(bytes:IDataInput):String
	{
		var debug : String = "";
		if(bytes is ByteArray)
		{
			ByteArray(bytes).position = 0;
		}
		var count : int = 1;
		while(bytes.bytesAvailable > 0)
		{
			var byte : int = bytes.readUnsignedByte();
			debug += (byte < 16 ? "0" : "") + byte.toString(16);
			if(count % 2 == 0)
			{
				debug += " ";
			}
			++count;
		}
		return debug;
	}
	
	//--------------------------------------
	//	PRIVATE CLASS METHODS
	//--------------------------------------
	
}

}