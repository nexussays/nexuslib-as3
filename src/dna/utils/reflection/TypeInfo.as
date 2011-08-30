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
		super(name, type, type, this, metadataCount);
		
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
	
	/**
	 * Sorts fields, methods, and properties according to their position in the reflected TypeInfo
	 */
	public function sortMembersByPosition():void
	{
		m_fields.sort(positionSort);
		m_methods.sort(positionSort);
		m_properties.sort(positionSort);
	}
	
	/**
	 * Sorts fields, methods, and properties according to their name
	 */
	public function sortMembersByName():void
	{
		m_fields.sort(nameSort);
		m_methods.sort(nameSort);
		m_properties.sort(nameSort);
	}
	
	/**
	 * Warning! This is a very costly sort that needs to get the TypeInfo for the entire inheritance chain. Sorts members according
	 * to the type that declares them
	 */
	public function sortMembersByDeclaringType():void
	{
		//malachi: really need to figure out a way to streamline this method
		var superTypes : Vector.<TypeInfo> = new Vector.<TypeInfo>();
		for each(var superClass : Class in m_extendedClasses)
		{
			superTypes.push(Reflection.getTypeInfo(superClass));
		}
		superTypes.push(this);
		
		var fieldsChecked : Dictionary = new Dictionary(true);
		var fieldsInOrder : Vector.<FieldInfo> = new Vector.<FieldInfo>();
		for each(var superType : TypeInfo in superTypes)
		{
			var superclassFields : Vector.<FieldInfo> = new Vector.<FieldInfo>();
			for each(var field : FieldInfo in superType.fields)
			{
				if(fieldsChecked[field.name] == null)
				{
					for each(var memberField : FieldInfo in m_fields)
					{
						if(memberField.name == field.name)
						{
							superclassFields.push(memberField);
							fieldsChecked[memberField.name] = true;
							break;
						}
					}
				}
			}
			fieldsInOrder = fieldsInOrder.concat(superclassFields.sort(positionSort));
		}
		m_fields = fieldsInOrder;
		
		m_methods.sort(declaringTypeSort);
		m_properties.sort(declaringTypeSort);
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
	private function declaringTypeSort(l:AbstractMemberInfo, r:AbstractMemberInfo):Number
	{
		trace("L", l, l.reflectedType, l.declaringType, l.reflectedTypeInfo.extendedClasses.indexOf(l.declaringType));
		trace("R", r, r.reflectedType, r.declaringType, r.reflectedTypeInfo.extendedClasses.indexOf(r.declaringType));
		if(l.declaringType == r.declaringType)
		{
			return positionSort(l, r);
		}
		else if(l.reflectedTypeInfo.extendedClasses.indexOf(l.declaringType) < r.reflectedTypeInfo.extendedClasses.indexOf(r.declaringType))
		{
			return -1;
		}
		else
		{
			return 1;
		}
	}
	
	private function positionSort(l:AbstractMemberInfo, r:AbstractMemberInfo):Number
	{
		return l.position < r.position ? -1 : (r.position < l.position ? 1 : nameSort(l, r));
	}
	
	private function nameSort(l:AbstractMemberInfo, r:AbstractMemberInfo):Number
	{
		return l.name < r.name ? -1 : (r.name < l.name ? 1 : 0);
	}
	
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