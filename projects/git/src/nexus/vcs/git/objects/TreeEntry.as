// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
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