/* Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package nexus.utils.reflection
{

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 */
public class MethodParameterInfo
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_type : Class;
	private var m_typeName : String;
	private var m_isOptional : Boolean;
	private var m_position : int;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function MethodParameterInfo(type:Class, pos:int, isOptional:Boolean)
	{
		m_type = type;
		m_position = pos;
		m_isOptional = isOptional;
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	/**
	 * The type of this parameter. If the paramater is untyped, this will return null
	 */
	public function get type():Class { return m_type; }
	
	/**
	 * If the argument is optional to the method, that is, a default value is provided if the argument is not
	 */
	public function get isOptional():Boolean { return m_isOptional; }
	
	/**
	 * The zero-based position of the parameter in the parameter list
	 */
	public function get position():int { return m_position; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	public function toString():String
	{
		if(m_typeName == null)
		{
			m_typeName = Reflection.getUnqualifiedClassName(m_type);
		}
		return m_typeName;
	}
}

}