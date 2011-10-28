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
 * Represents a reflected class, call Reflection.getTypeInfo() to retrieve a TypeInfo object
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	7/23/2011 3:34 AM
 */
public final class TypeInfo extends AbstractMetadataRecipient
{
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_type:Class;
	
	private var m_isDynamic : Boolean;
	private var m_isFinal : Boolean;
	
	private var m_inheritedInterfaces : Vector.<Class>;
	private var m_extendedClasses : Vector.<Class>;
	
	private var m_constructor : MethodInfo;
	
	private var m_methods : Vector.<MethodInfo>;
	private var m_methodsIndex : int;
	
	private var m_properties : Vector.<PropertyInfo>;
	private var m_propertiesIndex : int;
	
	private var m_fields : Vector.<FieldInfo>;
	private var m_fieldsIndex : int;
	
	private var m_allMembers : Vector.<AbstractMemberInfo>;
	private var m_allMembersSortedByName : Vector.<AbstractMemberInfo>;
	private var m_allMembersSortedByPosition : Vector.<AbstractMemberInfo>;
	
	private var m_allMembersByName : Dictionary;
	private var m_allMemberNames : Vector.<String>;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function TypeInfo(name:String, type:Class, isDynamic:Boolean, isFinal:Boolean, metadataCount:int, methodCount:int, propertyCount:int, fieldCount:int)
	{
		super(name, metadataCount);
		
		m_type = type;
		
		m_isDynamic = isDynamic;
		m_isFinal = isFinal;
		
		m_allMembers = new Vector.<AbstractMemberInfo>();
		m_allMemberNames = new Vector.<String>();
		m_allMembersByName = new Dictionary();
		
		m_inheritedInterfaces = new Vector.<Class>();
		m_extendedClasses = new Vector.<Class>();
		
		m_methods = new Vector.<MethodInfo>(methodCount, true);
		m_properties = new Vector.<PropertyInfo>(propertyCount, true);
		m_fields = new Vector.<FieldInfo>(fieldCount, true);
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get type():Class { return m_type; }
	
	public function get isDynamic():Boolean { return m_isDynamic; }
	
	public function get isFinal():Boolean { return m_isFinal; }
	
	public function get implementedInterfaces():Vector.<Class> { return m_inheritedInterfaces; }
	
	public function get extendedClasses():Vector.<Class> { return m_extendedClasses; }
	
	public function get methods():Vector.<MethodInfo> { return m_methods; }
	
	public function get properties():Vector.<PropertyInfo> { return m_properties; }
	
	public function get fields():Vector.<FieldInfo> { return m_fields; }
	
	public function get constructor():MethodInfo { return m_constructor; }
	
	public function get allMembers():Vector.<AbstractMemberInfo> { return m_allMembers; }
	
	/**
	 * Returns members, sorted according to their internal position in the reflected TypeInfo
	 */
	public function get allMembersSortedByPosition():Vector.<AbstractMemberInfo>
	{
		if(m_allMembersSortedByPosition == null)
		{
			m_allMembersSortedByPosition = m_allMembers.sort(positionSort);
		}
		return m_allMembersSortedByPosition;
	}
	
	/**
	 * Returns members, sorted according to their name
	 */
	public function get allMembersSortedByName():Vector.<AbstractMemberInfo>
	{
		if(m_allMembersSortedByName == null)
		{
			m_allMembersSortedByName = m_allMembers.sort(nameSort);
		}
		return m_allMembersSortedByName;
	}
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	public function toString(verbose:Boolean = false):String
	{
		return "[" + m_name + "]";
	}
	
	public function getMemberByName(name:String):AbstractMemberInfo
	{
		return m_allMembersByName[name];
	}
	
	public function getMethodByName(name:String):MethodInfo
	{
		return m_allMembersByName[name] as MethodInfo;
	}
	
	public function getPropertyByName(name:String):PropertyInfo
	{
		return m_allMembersByName[name] as PropertyInfo;
	}
	
	public function getFieldByName(name:String):FieldInfo
	{
		return m_allMembersByName[name] as FieldInfo;
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
				if(fieldsChecked[field.name] != true)
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
		if(l.declaringType == r.declaringType)
		{
			return positionSort(l, r);
		}
		else if(l.reflectedFrom.extendedClasses.indexOf(l.declaringType) < r.reflectedFrom.extendedClasses.indexOf(r.declaringType))
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
	
	internal function setConstructor(constructor:MethodInfo):void
	{
		m_constructor = constructor;
	}
	
	internal function addMember(member:AbstractMemberInfo):void
	{
		if(member is PropertyInfo)
		{
			m_properties[m_propertiesIndex++] = PropertyInfo(member);
		}
		else if(member is FieldInfo)
		{
			m_fields[m_fieldsIndex++] = FieldInfo(member);
		}
		else if(member is MethodInfo)
		{
			m_methods[m_methodsIndex++] = MethodInfo(member);
		}
		else
		{
			throw new ArgumentError("Cannot add unknown member type \"" + member + "\" to this TypeInfo.");
		}
		
		m_allMembers.push(member);
		m_allMemberNames.push(member.name);
		m_allMembersByName[member.name] = member;
	}
}

}