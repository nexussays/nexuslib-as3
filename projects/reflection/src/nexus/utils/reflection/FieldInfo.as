// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.utils.reflection
{

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 */
public final class FieldInfo extends AbstractFieldInfo
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function FieldInfo(name:String, isStatic:Boolean, type:Class, declaringType:Class, reflectedTypeInfo:TypeInfo, write:Boolean)
	{
		super(name, isStatic, type, declaringType, reflectedTypeInfo, true, write);
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get isConstant():Boolean { return !m_canWrite; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	override public function toString():String
	{
		if(m_typeName == null)
		{
			m_typeName = Reflection.getUnqualifiedClassName(m_type);
		}
		return "[" + (m_isStatic ? "Static" : "") + (m_canWrite ? "Variable" : "Constant") + "|" + m_name + ":" + m_typeName + "]";
	}
}

}