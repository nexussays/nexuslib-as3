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
	
	public function GitBlob(hash:String, repo:GitManager, size:int=-1)
	{
		super(hash, repo, size);
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	override public function get type():String { return "blob"; }
	
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
	
	override public function populateContent(content:IDataInput, size:int=-1):void
	{
		super.populateContent(content, size);
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