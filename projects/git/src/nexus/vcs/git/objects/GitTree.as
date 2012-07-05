// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.vcs.git.objects
{

import flash.utils.ByteArray;
import flash.utils.IDataInput;
import nexus.vcs.git.*;

/**
 *
 */
public class GitTree extends AbstractGitObject
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_entries : Vector.<TreeEntry>;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function GitTree(hash:String, repo:GitRepository)
	{
		super(hash, repo);
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	override public function get type():String { return ObjectType.TREE; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	override public function generateBytes():ByteArray
	{
		return super.generateBytes();
	}
	
	override public function populateContent(content:IDataInput, size:int):void
	{
		super.populateContent(content, size);
		
		m_entries = new Vector.<TreeEntry>();
		//<ascii unix access code> + <space> + <ascii? filename> + <byte\0> + <20-byte hash>
		var buffer : ByteArray = new ByteArray();
		var mode : String;
		var fileName : String;
		while(content.bytesAvailable > 0)
		{
			var byte : int = content.readUnsignedByte();
			//if we don't have the access code yet, this is the space delimiter between it and the filename
			if(byte == 32 && mode == null)
			{
				buffer.position = 0;
				mode = buffer.readUTFBytes(buffer.length);
				buffer.clear();
				continue;
			}
			else if(byte == 0)
			{
				buffer.position = 0;
				fileName = buffer.readUTFBytes(buffer.length);
				buffer.clear();
				
				m_entries.push(new TreeEntry(mode, fileName, GitUtil.readSHA1FromStream(content)));
				mode = null;
				fileName = null;
				
				continue;
			}
			buffer.writeByte(byte);
		}
		buffer.clear();
		buffer = null;
	}
	
	/**
	 * Return a string reprsentation of this object
	 * @param	verbose	If true, the object header is output as well
	 * @return	This object as a string
	 */
	override public function toString(verbose:Boolean=false):String
	{
		if(verbose)
		{
			return "tree " + size + "\n" + m_entries.join("\n");
		}
		return m_entries.join("\n");
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
}

}