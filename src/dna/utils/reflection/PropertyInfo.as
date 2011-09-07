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
package dna.utils.reflection
{

import flash.utils.*;

/**
 * Represents a property (getter/setter)
 * @author	Malachi Griffie <malachi@nexussays.com>
 * @since	7/23/2011 3:34 AM
 */
public class PropertyInfo extends AbstractFieldInfo
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_canRead : Boolean;
	private var m_canWrite : Boolean;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function PropertyInfo(name:String, isStatic:Boolean, type:Class, declaringType:Class, reflectedTypeInfo:TypeInfo, read:Boolean, write:Boolean, metadataCount:int)
	{
		super(name, isStatic, type, declaringType, reflectedTypeInfo, metadataCount);
		
		m_declaringType = declaringType;
		
		m_canRead = read;
		m_canWrite = write;
		
		if (m_canRead == false && m_canWrite == false)
		{
			throw new ArgumentError("Cannot create PropertyInfo, both canRead and canWrite are set to false");
		}
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get canRead():Boolean { return m_canRead; }
	
	public function get canWrite():Boolean { return m_canWrite; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	public function toString():String
	{
		if(m_typeName == null)
		{
			m_typeName = Reflection.getUnqualifiedClassName(m_type);
		}
		return "[" + (m_isStatic ? "Static" : "") + (m_canRead && m_canWrite ? "ReadWrite" : (m_canRead ? "ReadOnly" : "WriteOnly")) + "Property|" + m_name + ":" + m_typeName + "]";
	}
}

}