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
package nexus.utils.reflection
{

import flash.utils.*;


/**
 * Base class for PropertyInfo and FieldInfo
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	9/7/2011 4:50 AM
 */
public class AbstractFieldInfo extends AbstractMemberInfo
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	protected var m_type:Class;
	protected var m_typeName : String;
	
	protected var m_canRead : Boolean;
	protected var m_canWrite : Boolean;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function AbstractFieldInfo(name:String, isStatic:Boolean, type:Class, declaringType:Class, reflectedTypeInfo:TypeInfo, read:Boolean, write:Boolean)
	{
		super(name, isStatic, declaringType, reflectedTypeInfo);
		
		m_type = type;
		
		m_canRead = read;
		m_canWrite = write;
		
		if(m_canRead == false && m_canWrite == false)
		{
			throw new ArgumentError("Cannot create AbstractFieldInfo, both canRead and canWrite are set to false");
		}
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get type():Class { return m_type; }
	
	public function get canRead():Boolean { return m_canRead; }
	
	public function get canWrite():Boolean { return m_canWrite; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
}

}