/* Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package nexus.utils.reflection
{

import flash.utils.*;

/**
 * Represents a property (getter/setter)
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 */
public final class PropertyInfo extends AbstractFieldInfo
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
	
	public function PropertyInfo(name:String, isStatic:Boolean, type:Class, declaringType:Class, reflectedTypeInfo:TypeInfo, read:Boolean, write:Boolean)
	{
		super(name, isStatic, type, declaringType, reflectedTypeInfo, read, write);
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	override public function toString():String
	{
		if(m_typeName == null)
		{
			m_typeName = Reflection.getUnqualifiedClassName(m_type);
		}
		return "[" + (m_isStatic ? "Static" : "") + (m_canRead && m_canWrite ? "ReadWrite" : (m_canRead ? "ReadOnly" : "WriteOnly")) + "Property|" + m_name + ":" + m_typeName + "]";
	}
}

}