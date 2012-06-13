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

public class TreeEntry
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_mode : String;
	private var m_fileName : String;
	private var m_hash : String;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function TreeEntry(mode:String, name:String, hash:String)
	{
		m_mode = mode;
		while(m_mode.length < 6)
		{
			m_mode = "0" + m_mode;
		}
		m_fileName = name;
		m_hash = hash;
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get mode():String { return m_mode; }
	
	public function get fileName():String { return m_fileName; }
	
	public function get hash():String { return m_hash; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	public function toString(verbose:Boolean=false):String
	{
		if(verbose)
		{
			return "[TreeEntry:mode=" + mode + ",filename=" + fileName + ",hash=" + hash + "]";
		}
		return mode + " " + hash + " " + fileName;
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}