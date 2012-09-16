// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.vcs.git
{

import by.blooddy.crypto.SHA1;

import flash.filesystem.*;
import flash.utils.*;

import nexus.vcs.git.objects.*;

public class GitRepository
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_gitDir:File;
	private var m_packfiles:Vector.<GitPack>;
	private var m_refs:Dictionary;
	private var m_objectCache : Dictionary;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function GitRepository(repoDir:String = null)
	{
		if(repoDir != null && repoDir != "")
		{
			changeRepository(repoDir);
		}
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get gitDirectory():File { return m_gitDir; }
	
	public function get directory():File { return m_gitDir != null ? m_gitDir.resolvePath("..") : null; }
	
	/**
	 * Return the hash pointed to by HEAD
	 */
	public function get head():String
	{
		return lookupReference("HEAD", true);
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
	
	public function getObject(hash:String, verifyContents:Boolean = false):AbstractGitObject
	{
		var result:AbstractGitObject;
		
		//resolve references if one was provided
		hash = lookupReference(hash);
		
		if(hash == null)
		{
			throw new ArgumentError("Cannot read object. Provided hash is null.");
		}
		
		//failing on length should be a bit quicker since it skips the regex test (assuming (!) that the length property is a fast lookup)
		if(hash.length != 40 || !/^[a-f0-9]{40}$/.test(hash))
		{
			throw new ArgumentError("Cannot read object. Invalid hash \"" + hash + "\". Provided hash must match /^[a-f0-9]{40}$/");
		}
		
		if(hash in m_objectCache)
		{
			return m_objectCache[hash];
		}
		
		var rawBytes:ByteArray = readBytesAtPath("objects/" + hash.substr(0, 2) + "/" + hash.substr(2, 38));
		if(rawBytes == null)
		{
			//get the object from a pack
			for each(var pack:GitPack in m_packfiles)
			{
				if(pack.containsObject(hash))
				{
					result = pack.getObject(hash);
					break;
				}
			}
		}
		else
		{
			// @see: http://www.kernel.org/pub/software/scm/git/docs/v1.7.3/user-manual.html#object-details
			// The general consistency of an object can always be tested independently of the contents or the type of the object:
			// all objects can be validated by verifying that
			// (a) their hashes match the content of the file and
			// (b) the object successfully inflates to a stream of bytes that forms a sequence of
			// 	   <ascii type without space> + <space> + <ascii decimal size> + <byte\0> + <binary object data>.
			
			rawBytes.uncompress(CompressionAlgorithm.ZLIB);
			
			//verify object contents if needed
			//blooddy uses lowercase chars in the hex string
			if(verifyContents && hash != SHA1.hashBytes(rawBytes))
			{
				rawBytes.clear();
				//TODO: Throw a more detailed error type here (GitVerifyError?)
				throw new Error("Git object content is not consistent with hash " + hash);
			}
			
			rawBytes.position = 0;
			
			var type:String;
			var size:int = -1;
			var contentBytes:ByteArray = new ByteArray();
			
			//read object data
			//<ascii type without space> + <space> + <ascii decimal size> + <byte\0> + <binary object data>.
			var buffer:ByteArray = new ByteArray();
			while(rawBytes.bytesAvailable > 0)
			{
				var byte:int = rawBytes.readUnsignedByte();
				//if we hit a space and don't have the type yet, then we just finished reading the type
				if(byte == 32 && type == null)
				{
					buffer.position = 0;
					type = buffer.readUTFBytes(buffer.length);
					buffer.clear();
					//we don't need to do anything with the space we read in, continue to next byte
					continue;
				}
				//if we hit a null-byte and the size hasn't been set, then we just finished reading the size
				else if(byte == 0 && size == -1)
				{
					buffer.position = 0;
					size = parseInt(buffer.readUTFBytes(buffer.length));
					
					//put remaining content into contentBytes and break
					rawBytes.readBytes(contentBytes, 0, rawBytes.bytesAvailable);
					break;
				}
				//didn't hit a delimiting character, write to the buffer and continue on
				buffer.writeByte(byte);
			}
			
			try
			{
				result = GitUtil.createObjectByType(type, size, hash, contentBytes, this);
				m_objectCache[hash] = result;
			}
			finally
			{
				//don't forget to clean up
				buffer.clear();
				buffer = null;
				rawBytes.clear();
				rawBytes = null;
				contentBytes.clear();
				contentBytes = null;
			}
		}
		
		if(result == null)
		{
			//TODO: Throw a more detailed error type here (ObjectNotFound?)
			throw new Error("No object " + hash + " exists in this repository");
		}
		
		return result;
	}
	
	public function getPackForObject(hash:String):GitPack
	{
		for each(var pack:GitPack in m_packfiles)
		{
			if(pack.containsObject(hash))
			{
				return pack;
			}
		}
		return null;
	}
	
	public function readBytesAtPath(path:String):ByteArray
	{
		var bytes:ByteArray = new ByteArray();
		readBytesAtPathIntoByteArray(path, bytes);
		if(bytes.length == 0)
		{
			bytes = null;
		}
		return bytes;
	}
	
	public function readBytesAtPathIntoByteArray(path:String, bytes:ByteArray):void
	{
		var file:File = m_gitDir.resolvePath(path);
		if(file.exists)
		{
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			fileStream.readBytes(bytes);
			fileStream.close();
		}
	}
	
	public function changeRepository(path:String):void
	{
		//restore the current repo on error
		var oldRepo:File = m_gitDir;
		m_gitDir = null;
		
		if(path != null && path != "")
		{
			try
			{
				m_gitDir = new File(path);
				if(m_gitDir.name != ".git")
				{
					m_gitDir = m_gitDir.resolvePath(".git");
				}
			}
			catch(e:Error)
			{
				m_gitDir = null;
			}
		}
		
		if(m_gitDir == null || !m_gitDir.exists)
		{
			m_gitDir = oldRepo;
			throw new ArgumentError("Invalid directory or not a git repository: " + path);
		}
		
		//
		// initialize repo
		//
		
		m_refs = new Dictionary();
		m_packfiles = new Vector.<GitPack>();
		m_objectCache = new Dictionary();
		
		//parse packfile indexes
		var packFiles:Array = m_gitDir.resolvePath("objects/pack").getDirectoryListing();
		for each(var packfile:File in packFiles)
		{
			if(packfile.extension == "idx")
			{
				m_packfiles.push(new GitPack(packfile.name.replace(".idx", ""), this));
			}
		}
		
		//read packed refs
		var bytes:ByteArray = readBytesAtPath("packed-refs");
		if(bytes != null)
		{
			//TODO: Handle annotated tag pointers (^lines)
			var string:String = bytes.toString();
			var packedRefLines:Array = string.split("\n");
			for each(var line:String in packedRefLines)
			{
				var match:Array = /([^ ]+) ([^\n]+)/.exec(line);
				if(match != null && match.length > 0 && match[1].charAt(0) != "#")
				{
					m_refs[match[2]] = match[1];
				}
			}
		}
		
		//iterate over refs in directory
		var refDirs:Array = m_gitDir.resolvePath("refs").getDirectoryListing();
		while(refDirs.length > 0)
		{
			var file:File = refDirs.pop();
			//follow directories until we find a file
			if(file.isDirectory)
			{
				refDirs = refDirs.concat(file.getDirectoryListing());
			}
			else
			{
				var relativePath:String = m_gitDir.getRelativePath(file);
				m_refs[relativePath] = readBytesAtPath(relativePath).toString().replace(/^\s*|\s*$/g, "");
			}
		}
		
		//now that all refs have been parsed, iterate over them all once more and update any refs that were pointing to
		//other refs (ad infinitum) to now point to the hash
		for(var ref : String in m_refs)
		{
			m_refs[ref] = lookupReference(m_refs[ref], true);
		}
		
		trace("Updated repo path to: " + m_gitDir.nativePath);
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
	/**
	 * Follow a possible reference to get the object it points to. If the provided argument is not a ref, the argument is returned.
	 * @param	ref			The possible reference to follow
	 * @param	downTheRabbitHole	If true and following this ref results in another ref, it will continue following that ref and so on.
	 * Default is true.
	 * @return	The hash the ref argument was pointing to, or the argument itself if it is not actually a reference.
	 */
	private function lookupReference(ref:String, downTheRabbitHole:Boolean = true):String
	{
		if(ref != null)
		{
			//ensure the string is a ref before following it
			if(ref.substr(0, 3) == "ref")
			{
				//parse out the "ref:" prefix if needed and trim whitespace
				ref = ref.replace(/^\s*ref:\s*|\s*$/g, "");
				if(!(ref in m_refs))
				{
					//TODO: Throw a more detailed error type here (GitReferenceError?)
					throw new Error("Cannot find reference \"" + ref + "\" in this repository.");
				}
				
				return downTheRabbitHole ? lookupReference(m_refs[ref], downTheRabbitHole) : m_refs[ref];
			}
			else if(ref == "HEAD")
			{
				//TODO: Provide some degree of caching of HEAD?
				return lookupReference(readBytesAtPath("HEAD").toString(), downTheRabbitHole);
			}
		}
		return ref;
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
	
	//--------------------------------------
	//	TESTING/DEVELOPMENT/DEBUG METHODS
	//--------------------------------------
	
	public function debug_dumpRefs():void
	{
		for(var ref : String in m_refs)
		{
			trace(ref + " " + m_refs[ref]);
		}
	}
	
	public function debug_readFile(path:String, followRefs:Boolean=true):Object
	{
		path = m_gitDir.getRelativePath(new File(path));
		if(/^objects\/[a-f0-9]{2}\/[a-f0-9]{38}$/.test(path))
		{
			return getObject(path.replace(/objects|\//g, ""));
		}
		if(path == "index")
		{
			return parseIndex(readBytesAtPath(path));
		}
		if(/\.idx$/.test(path) || /\.pack$/.test(path))
		{
			var name : String = path.replace(/^objects\/pack\/|\.idx$|\.pack/g, "");
			for each(var pack:GitPack in m_packfiles)
			{
				if(pack.name == name)
				{
					return /\.pack$/.test(path) ? pack.debug_pack() : pack.debug_index();
				}
			}
		}
		if(followRefs && path == "HEAD")
		{
			return this.head;
		}
		if(followRefs && /^ref/.test(path))
		{
			return m_refs[path];
		}
		return readBytesAtPath(path).toString();
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
		
		//hash
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