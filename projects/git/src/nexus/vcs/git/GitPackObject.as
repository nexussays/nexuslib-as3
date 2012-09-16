// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.vcs.git
{

import flash.utils.ByteArray;

/**
 * ...
 */
public class GitPackObject
{
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_bytes : ByteArray;
	private var m_type : int;
	private var m_size : int;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function GitPackObject()
	{
		m_bytes = new ByteArray();
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get bytes():ByteArray { return m_bytes; }
	public function set bytes(value:ByteArray):void
	{
		m_bytes = value;
	}
	
	public function get type():int { return m_type; }
	public function set type(value:int):void
	{
		m_type = value;
	}
	
	public function get size():int { return m_size;}
	public function set size(value:int):void
	{
		m_size = value;
	}
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
}

}