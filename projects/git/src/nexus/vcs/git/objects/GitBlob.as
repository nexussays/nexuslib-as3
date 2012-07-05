// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.vcs.git.objects
{

import flash.utils.*;

import nexus.vcs.git.*;

public class GitBlob extends AbstractGitObject
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_bytes : ByteArray;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function GitBlob(hash:String, repo:GitRepository)
	{
		super(hash, repo);
		m_bytes = new ByteArray();
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	override public function get type():String { return ObjectType.BLOB; }
	
	public function get content():IDataInput { return m_bytes; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	override public function generateBytes():ByteArray
	{
		var result : ByteArray = new ByteArray();
		result.writeUTFBytes(this.type + " " + m_size);
		result.writeByte(0);
		result.writeBytes(m_bytes, 0, m_bytes.length);
		return result;
	}
	
	override public function populateContent(content:IDataInput, size:int):void
	{
		super.populateContent(content, size);
		m_bytes.clear();
		content.readBytes(m_bytes, 0, 0);
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
			return "blob " + size + "\n" + m_bytes.toString();
		}
		return m_bytes.toString();
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
}

}