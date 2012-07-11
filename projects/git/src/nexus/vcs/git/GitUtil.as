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
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	/**
	 * Read 20 bytes from the input stream and return it as a hex-formatted string. The position of the stream will
	 * be moved 20 bytes as a result.
	 * @param	stream	Input stream from which to read.
	 * @return	A 40-charatcer hex-formatted (lowercase) string
	 */
	static public function readSHA1FromStream(stream:IDataInput):String
	{
		var sha1:String = "";
		var cursor:int = 0;
		while(cursor < 20)
		{
			var val:uint = stream.readUnsignedByte();
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
				//TODO: Throw a more specific error type
				throw new Error("Unknown or unsupported git object type \"" + type + "\"");
		}
		result.populateContent(contentBytes, size);
		return result;
	}
	
	/**
	 * Returns the contents of the provided byte stream as a hex-formatted string, with spacing after each group of 2 bytes.
	 * @param	bytes	The byte stream to read from
	 * @param	length	The number of bytes to read, read all bytesAvailable if length == 0
	 */
	static public function hexDump(bytes:IDataInput, length:uint=uint.MAX_VALUE):String
	{
		var debug : String = "";
		var count : int = 1;
		var cursor : uint = length;
		while(bytes.bytesAvailable > 0 && cursor > 0)
		{
			var byte : int = bytes.readUnsignedByte();
			debug += (byte < 16 ? "0" : "") + byte.toString(16);
			if(count % 2 == 0)
			{
				debug += " ";
			}
			++count;
			--cursor;
		}
		return debug;
	}
	
	//--------------------------------------
	//	PRIVATE CLASS METHODS
	//--------------------------------------
	
}

}