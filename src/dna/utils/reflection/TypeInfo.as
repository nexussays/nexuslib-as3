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
 * The Original Code is dna_lib.
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
 * Represents a reflected class, call Reflection.getTypeInfo() to retrieve a TypeInfo object
 * @author mgriffie
 * @since 7/23/2011 3:34 AM
 */
public class TypeInfo extends AbstractMemberInfo
{
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_isDynamic : Boolean;
	private var m_isFinal : Boolean;
	
	private var m_inheritedInterfaces : Vector.<Class>;
	private var m_extendedClasses : Vector.<Class>;
	
	private var m_methods : Vector.<MethodInfo>;
	private var m_methodsIndex : int;
	
	private var m_properties : Vector.<PropertyInfo>;
	private var m_propertiesIndex : int;
	
	private var m_fields : Vector.<FieldInfo>;
	private var m_fieldsIndex : int;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function TypeInfo(name:String, type:Class, isDynamic:Boolean, isFinal:Boolean, metadataCount:int, methodCount:int, propertyCount:int, fieldCount:int)
	{
		super(name, type, type, metadataCount);
		
		m_isDynamic = isDynamic;
		m_isFinal = isFinal;
		
		m_inheritedInterfaces = new Vector.<Class>();
		m_extendedClasses = new Vector.<Class>();
		
		m_methods = new Vector.<MethodInfo>(methodCount, true);
		m_properties = new Vector.<PropertyInfo>(propertyCount, true);
		m_fields = new Vector.<FieldInfo>(fieldCount, true);
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get isDynamic():Boolean { return m_isDynamic; }
	
	public function get isFinal():Boolean { return m_isFinal; }
	
	public function get implementedInterfaces():Vector.<Class> { return m_inheritedInterfaces; }
	
	public function get extendedClasses():Vector.<Class> { return m_extendedClasses; }
	
	public function get methods():Vector.<MethodInfo> { return m_methods; }
	
	public function get properties():Vector.<PropertyInfo> { return m_properties; }
	
	public function get fields():Vector.<FieldInfo> { return m_fields; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	public function toString(verbose:Boolean = false):String
	{
		return "[Type:" + m_name + "]";
	}

	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
	//--------------------------------------
	//	INTERNAL INSTANCE METHODS
	//--------------------------------------
	
	internal function addProperty(property:PropertyInfo):void
	{
		m_properties[m_propertiesIndex++] = property;
	}
	
	internal function addMethod(method:MethodInfo):void
	{
		m_methods[m_methodsIndex++] = method;
	}
	
	internal function addField(field:FieldInfo):void
	{
		m_fields[m_fieldsIndex++] = field;
	}
}

}