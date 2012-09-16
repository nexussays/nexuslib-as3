// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
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
	
	private var m_content : ByteArray;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function GitBlob(hash:String, repo:GitRepository)
	{
		super(ObjectType.BLOB, hash, repo);
		m_content = new ByteArray();
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get content():IDataInput { return m_content; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	override public function generateBytes():ByteArray
	{
		var result : ByteArray = new ByteArray();
		result.writeUTFBytes(this.type + " " + m_size);
		result.writeByte(0);
		result.writeBytes(m_content, 0, m_content.length);
		return result;
	}
	
	override public function populateContent(content:IDataInput, size:int):void
	{
		super.populateContent(content, size);
		m_content.clear();
		content.readBytes(m_content, 0, 0);
	}
	
	/**
	 * Return a string reprsentation of this object
	 * @param	verbose	If true, the object header is output as well
	 * @return	This object as a string
	 */
	override public function toString():String
	{
		return m_type + " " + m_size + "\n" + m_content;
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
}

}