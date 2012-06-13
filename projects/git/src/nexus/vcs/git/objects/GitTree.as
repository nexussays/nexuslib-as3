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
	
	public function GitTree(hash:String, repo:GitManager, size:int=-1)
	{
		super(hash, repo, size);
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	override public function get type():String { return "tree"; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	override public function generateBytes():ByteArray
	{
		return super.generateBytes();
	}
	
	override public function populateContent(content:IDataInput, size:int=-1):void
	{
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