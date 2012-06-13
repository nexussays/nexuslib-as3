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
import flash.filesystem.*;
import flash.utils.ByteArray;
import flash.utils.CompressionAlgorithm;
import flash.utils.Dictionary;
import nexus.vcs.git.objects.*;

public class GitManager
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_repo : File;
	private var m_packfiles : Vector.<GitPack>;
	private var m_packedRefs : Dictionary;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function GitManager(repoDir:String=null)
	{
		if(repoDir != null && repoDir != "")
		{
			changeRepository(repoDir);
		}
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get repositoryDir():File { return m_repo; }
	
	/**
	 * Return the ref pointed to by HEAD
	 */
	public function get headRef():String
	{
		var content : String = convertBytesToString(readBytesAtPath("HEAD"));
		var ref:Array = content.match(/ref: (.*)/);
		return ref.length == 2 ? ref[1] : null;
	}
	
	/**
	 * Return the SHA-1 pointed to by HEAD
	 */
	public function get head():String
	{
		return getHashFromRef(this.headRef);
	}
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	public function verifyObject(hash:String, bytes:ByteArray):Boolean
	{
		var originalPosition:uint = bytes.position;
		bytes.uncompress(CompressionAlgorithm.ZLIB);
		bytes.position = 0;
		var sha1:String = SHA1.hashBytes(bytes);
		bytes.compress(CompressionAlgorithm.ZLIB);
		bytes.position = originalPosition;
		
		//blooddy library and git both use lowercase a-f chars in the hash
		return hash == sha1;
	}
	
	public function getObject(hash:String, verifyContents:Boolean=false):AbstractGitObject
	{
		var result : AbstractGitObject;
		
		var rawBytes : ByteArray = readBytesForHash(hash);
		if(rawBytes == null)
		{
			result = getObjectFromPack(hash);
			if(result == null)
			{
				throw new Error("No object exists with SHA-1 \"" + hash + "\" in this repository");
			}
			return result;
		}
		
		// @see: http://www.kernel.org/pub/software/scm/git/docs/v1.7.3/user-manual.html#object-details
		// The general consistency of an object can always be tested independently of the contents or the type of the object:
		// all objects can be validated by verifying that
		// (a) their hashes match the content of the file and
		// (b) the object successfully inflates to a stream of bytes that forms a sequence of
		// 	   <ascii type without space> + <space> + <ascii decimal size> + <byte\0> + <binary object data>.
		
		rawBytes.uncompress(CompressionAlgorithm.ZLIB);
		
		//verify object contents if needed. blooddy and git both use lowercase chars in the hex string
		if(verifyContents && hash != SHA1.hashBytes(rawBytes))
		{
			throw new Error("Git object content is not consistent with hash for SHA-1 " + hash);
		}
		
		rawBytes.position = 0;
		
		var type:String;
		var size:int;
		var contentBytes:ByteArray = new ByteArray();
		
		//read object data
		//<ascii type without space> + <space> + <ascii decimal size> + <byte\0> + <binary object data>.
		var buffer:ByteArray = new ByteArray();
		while(rawBytes.bytesAvailable > 0)
		{
			var byte:int = rawBytes.readUnsignedByte();
			if(byte == 32 && type == null)
			{
				buffer.position = 0;
				type = buffer.readUTFBytes(buffer.length);
				buffer.clear();
				continue;
			}
			else if(byte == 0 && size == 0)
			{
				buffer.position = 0;
				size = parseInt(buffer.readUTFBytes(buffer.length));
				buffer.clear();
				buffer = null;
				
				//put remaining content into contentBytes
				rawBytes.readBytes(contentBytes, 0, rawBytes.bytesAvailable);
				
				continue;
			}
			buffer.writeByte(byte);
		}
		
		switch(type)
		{
			case "commit":
				result = new GitCommit(hash, this, size);
				break;
			case "tree":
				result = new GitTree(hash, this, size);
				break;
			case "blob":
				result = new GitBlob(hash, this, size);
				break;
			case "tag":
				result = new GitTag(hash, this, size);
				break;
			default:
				throw new Error("Unknown git object type \"" + type + "\"");
		}
		result.populateContent(contentBytes);
		return result;
	}
	
	public function getObjectPack(hash:String):GitPack
	{
		for each(var pack : GitPack in m_packfiles)
		{
			if(pack.hashExists(hash))
			{
				return pack;
			}
		}
		return null;
	}
	
	public function readBytesAtPath(path:String):ByteArray
	{
		var file:File = m_repo.resolvePath(path);
		if(file.exists)
		{
			var bytes:ByteArray = new ByteArray();
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			fileStream.readBytes(bytes);
			fileStream.close();
		}
		return bytes;
	}
	
	public function readBytesForHash(hash:String):ByteArray
	{
		if(hash == null)
		{
			throw new ArgumentError("Cannot read object. Provided SHA-1 is null");
		}
		
		//strip whitespace and ensure correct length
		hash = hash.replace(/\s*/gm, "");
		if(hash.length != 40)
		{
			throw new ArgumentError("Cannot read object. Invalid SHA-1 \"" + hash + "\"");
		}
		
		return readBytesAtPath("objects/" + hash.substr(0, 2) + "/" + hash.substr(2, 38));
	}
	
	public function getObjectFromPack(hash:String):AbstractGitObject
	{
		for each(var pack : GitPack in m_packfiles)
		{
			if(pack.hashExists(hash))
			{
				return pack.getObject(hash);
			}
		}
		return null;
	}
	
	public function readFile(path:String):Object
	{
		path = m_repo.resolvePath(path).url.replace(m_repo.url + "/", "");
		if(/^objects\/[a-f0-9]{2}\/[a-f0-9]{38}$/.test(path))
		{
			return getObject(path.replace(/objects|\//g, ""));
		}
		if(path == "index")
		{
			return parseIndex(readBytesAtPath(path));
		}
		if(/\.idx$/.test(path))
		{
			return GitUtil.debug_parsePackfileIndex(readBytesAtPath(path));
		}
		if(/\.pack$/.test(path))
		{
			return GitUtil.debug_parsePackfile(readBytesAtPath(path));
		}
		return convertBytesToString(readBytesAtPath(path));
	}
	
	public function changeRepository(path:String):void
	{
		//if there is a current repo, restore it on an error
		if(m_repo != null)
		{
			var oldRepo : File = m_repo;
		}
		m_repo = null;
		
		if(path != null && path != "")
		{
			try
			{
				m_repo = new File(path);
				m_repo = m_repo.resolvePath(".git");
			}
			catch(e:Error)
			{
				m_repo = null;
			}
		}
		
		if(m_repo == null || !m_repo.exists)
		{
			m_repo = oldRepo;
			throw new ArgumentError("Invalid directory \"" + path + "\"");
		}
		
		parsePackFileIndexes();
		parsePackRefs();
		trace("Updated repo path to: " + m_repo.nativePath);
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
	private function convertBytesToString(bytes:ByteArray):String
	{
		bytes.position = 0;
		return bytes.readUTFBytes(bytes.length);
	}
	
	private function parsePackFileIndexes():void
	{
		m_packfiles = new Vector.<GitPack>();
		var packDir : File = m_repo.resolvePath("objects/pack");
		for each(var packfile : File in packDir.getDirectoryListing())
		{
			if(packfile.extension == "idx")
			{
				var packName : String = packfile.name.replace(".idx", "");
				m_packfiles.push(new GitPack(packName, readBytesAtPath("objects/pack/" + packName + ".idx"), this));
			}
		}
	}
	
	private function parsePackRefs():void
	{
		m_packedRefs = new Dictionary();
		var bytes : ByteArray = readBytesAtPath("packed-refs");
		if(bytes != null)
		{
			var string : String = convertBytesToString(bytes);
			var refs : Array = string.split("\n");
			for each(var line : String in refs)
			{
				var match : Array = /([^ ]+) ([^\n]+)/.exec(line);
				if(match != null && match.length > 0 && match[1].charAt(0) != "#")
				{
					m_packedRefs[match[2]] = match[1];
				}
			}
		}
		
		trace("packed-refs");
		for(var key : String in m_packedRefs)
		{
			trace(key, m_packedRefs[key]);
		}
	}
	
	private function getHashFromRef(ref:String):String
	{
		if(ref in m_packedRefs)
		{
			return m_packedRefs[ref];
		}
		return convertBytesToString(readBytesAtPath(ref));
	}
	
	/**
	 * Parse the index file
	 * @see	https://github.com/gitster/git/blob/master/Documentation/technical/index-format.txt
	 * @param	index	The bytes representing the index file
	 */
	private function parseIndex(index:ByteArray):String
	{
		var debug:String = "";
		index.position = 0;
		
		var sig:String = index.readUTFBytes(4);
		if(sig != "DIRC")
		{
			throw new ArgumentError("Invalid index bytes. Signature is incorrect.");
		}
		
		var version:int = index.readInt();
		if(version != 2)
		{
			throw new Error("Index version is " + version + " but currently only version 2 is able to be parsed correctly");
		}
		debug += "version: " + version + "\n";
		
		var entryCount:int = index.readInt();
		debug += entryCount + " entries\n";
		
		var counter:int;
		while(index.bytesAvailable && counter < entryCount)
		{
			var entry:Entry = new Entry(index);
			debug += entry.mode.toString(8) + " " + entry.name + "\n";
			++counter;
		}
		
		//read extensions
		var ext:String = index.readUTFBytes(4);
		debug += "extension " + ext;
		
		return debug;
	}
}
}

internal class Entry
{
	import flash.utils.ByteArray;
	import nexus.vcs.git.GitUtil;
	
	public var mode:int;
	public var name:String;
	
	public function Entry(index:ByteArray)
	{
		//32-bit ctime seconds, the last time a file's metadata changed
		var ctime:int = index.readInt();
		//32-bit ctime nanosecond fractions
		var ctime_nano:int = index.readInt();
		
		//32-bit mtime seconds, the last time a file's data changed
		var mtime:int = index.readInt();
		//32-bit mtime nanosecond fractions
		var mtime_nano:int = index.readInt();
		
		//32-bit dev
		var dev:int = index.readInt();
		
		//32-bit ino
		var ino:int = index.readInt();
		
		mode = index.readInt();
		
		//32-bit uid
		var uid:int = index.readInt();
		
		//32-bit gid
		var gid:int = index.readInt();
		
		//32-bit file size. This is the on-disk size from stat(2), truncated to 32-bit.
		var filesize:int = index.readInt();
		
		//SHA-1
		var sha:String = GitUtil.readSHA1FromStream(index);
		
		var flags:int = index.readShort();
		
		var nameBytes:ByteArray = new ByteArray();
		var byte:int = index.readUnsignedByte();
		while(byte != 0 && index.bytesAvailable)
		{
			nameBytes.writeByte(byte);
			byte = index.readUnsignedByte();
		}
		name = nameBytes.toString();
		
		//waste null bytes
		while(byte == 0 && index.bytesAvailable)
		{
			byte = index.readUnsignedByte();
		}
		
		//back-up if we didn't hit eof
		if(index.bytesAvailable)
		{
			index.position--;
		}
	}
}