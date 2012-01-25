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

import flash.errors.IllegalOperationError;
import flash.utils.*;

import nexus.errors.NotImplementedError;

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
	
	/**
	 * Retrieves this field off of the provided object
	 * @param	instance	An instance of an object that contains this field
	 * @return	The value of this field retrieved from the provided instance
	 * @throws	IllegalOperationError	If this field is write-only
	 * @throws	ArgumentError	If the provided instance object is not in the proper class hierarchy to contain this field
	 */
	public function getValue(instance:Object):Object
	{
		if(!m_canRead)
		{
			throw new IllegalOperationError("Cannot read " + this.toString() + " on " + Reflection.getQualifiedClassName(m_declaringType) + ", it is write-only.");
		}
		
		if(m_declaringType != null && !(instance is m_declaringType))
		{
			throw new ArgumentError("Cannot read " + this.toString() + ", declared on " + Reflection.getQualifiedClassName(m_declaringType) + ", from an object of type " + Reflection.getQualifiedClassName(instance) + ".");
		}
		
		return instance[m_qname];
	}
	
	/**
	 * Assigns this field on the provided object
	 * @param	instance	An instance of an object that contains this field
	 * @throws	IllegalOperationError	If this field is read-only
	 * @throws	ArgumentError	If the provided instance object is not in the proper class hierarchy to contain this field
	 */
	public function setValue(instance:Object, value:Object):void
	{
		if(!m_canWrite)
		{
			throw new IllegalOperationError("Cannot write " + this.toString() + " on " + Reflection.getQualifiedClassName(m_declaringType) + ", it is read-only.");
		}
		
		if(m_declaringType != null && !(instance is m_declaringType))
		{
			throw new ArgumentError("Cannot write " + this.toString() + ", declared on " + Reflection.getQualifiedClassName(m_declaringType) + ", to an object of type " + Reflection.getQualifiedClassName(instance) + ".");
		}
		
		if(value != null && !(value is m_type))
		{
			throw new ArgumentError("Cannot assign " + this.toString() + " a value of type " + Reflection.getQualifiedClassName(value));
		}
		
		instance[m_qname] = value;
	}
	
	public function toString():String
	{
		throw new NotImplementedError();
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
}

}