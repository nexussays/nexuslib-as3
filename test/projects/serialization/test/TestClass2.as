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
package test
{

import flash.utils.*;

/**
 * ...
 * @author	Malachi Griffie
 * @since	11/9/2011 12:42 AM
 */
public class TestClass2
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_type:String;
	private var m_x:int;
	private var m_y:int;
	private var m_sub:SubObject;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function TestClass2()
	{
		m_type = "defaultType";
		
		m_sub = new SubObject();
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get sub():SubObject
	{
		return m_sub;
	}
	
	public function set sub(value:SubObject):void
	{
		m_sub = value;
	}
	
	public function get type():String
	{
		return m_type;
	}
	
	public function set type(value:String):void
	{
		m_type = value;
	}
	
	public function get x():int
	{
		return m_x;
	}
	
	public function set x(value:int):void
	{
		m_x = value;
	}
	
	public function get y():int
	{
		return m_y;
	}
	
	public function set y(value:int):void
	{
		m_y = value;
	}

	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------

	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
}

}