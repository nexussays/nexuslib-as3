﻿/* ***** BEGIN LICENSE BLOCK *****
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

import dna.utils.Parse;
import flash.utils.*;

/**
 * ...
 * @author mgriffie
 * @since 7/23/2011 3:34 AM
 */
public class Reflection
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	///store all reflected types to the describeType() call and processing into a TypeInfo instance only ever happens once
	private static const s_reflectedTypes:Dictionary = new Dictionary();
	
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	/**
	 * Returns Class(getDefinitionByName(getQualifiedClassName(obj)))
	 * @param	obj
	 * @return
	 */
	public static function getClassOfInstance(obj:Object):Class
	{
		return obj == null ? null : Class(getDefinitionByName(getQualifiedClassName(obj)));
	}
	
	/**
	 * Returns Class(getDefinitionByName(getQualifiedSuperclassName(obj)))
	 * @param	obj
	 * @return
	 */
	public static function getSuperClassOfInstance(obj:Object):Class
	{
		if(obj != null)
		{
			try
			{
				return Class(getDefinitionByName(getQualifiedSuperclassName(obj)));
			}
			catch(e:ReferenceError)
			{
				e.message = "Cannot find definition for " + getQualifiedSuperclassName(obj) + ", the class is either not present or not public.";
				throw e;
			}
		}
		return null;
	}
	
	/**
	 * Given a Class or a fully qualified class name, this will return the unqualified class name.
	 * @example	<pre>
	 * parseUnqualifiedClassName(SomeClass) => "SomeClass"
	 * parseUnqualifiedClassName("com.example.pkg::SomeClass") => "SomeClass"
	 * parseUnqualifiedClassName("[class SomeClass]") => "SomeClass"
	 * </pre>
	 * @param	className	The fully qualified class name or Class to parse
	 * @return
	 */
	public static function getUnqualifiedClassName(object:Object):String
	{
		var str:String = String(object + "");
		//parse out class when in format "package.package.package::ClassName"
		str = str.substring(str.lastIndexOf(":") + 1);
		//parse out class when in format "[class ClassName]"
		str = str.substring(str.lastIndexOf(" ") + 1, str.length - 1);
		return str;
	}
	
	/**
	 * Useful if you have the Class object but not an instance of the Class. Returns false if the provided arguments are the same class.
	 * If you need more detail or to check if a class implements an interface
	 * @param	potentialSubclass
	 * @param	potentialSuperClass
	 * @return
	 */
	public static function classExtendsClass(potentialSubclass:Class, potentialSuperClass:Class):Boolean
	{
		//if the two classes are the same instance, one does not extend the other
		if(potentialSubclass == null || potentialSuperClass == null || potentialSubclass == potentialSuperClass)
		{
			return false;
		}
		
		//everything extends Object
		if(potentialSuperClass == Object)
		{
			return true;
		}
		
		while(potentialSubclass != Object)
		{
			potentialSubclass = getSuperClassOfInstance(potentialSubclass);
			if(potentialSubclass == potentialSuperClass)
			{
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Reflects into the given object and returns a TypeInfo object
	 * @param	obj	The object to reflect
	 * @return	A TypeInfo that represents the given object's Class information
	 */
	public static function getTypeInfo(obj:Object):TypeInfo
	{
		var type:Class = obj is Class ? Class(obj) : getClassOfInstance(obj);
		var reflectedType:TypeInfo = s_reflectedTypes[type];
		if(reflectedType == null)
		{
			var xml:XML = describeType(type);
			reflectedType = new TypeInfo(xml.@name, type, Parse.boolean(xml.@isDynamic, false), Parse.boolean(xml.@isFinal, false), xml.factory.metadata.length(), xml.method.length() + xml.factory.method.length(), xml.accessor.length() + xml.factory.accessor.length(), xml.variable.length() + xml.constant.length() + xml.factory.variable.length() + xml.factory.constant.length());
			
			//add fields
			addFields(type, true, true, xml.constant, reflectedType);
			addFields(type, true, false, xml.variable, reflectedType);
			addFields(type, false, true, xml.factory.constant, reflectedType);
			addFields(type, false, false, xml.factory.variable, reflectedType);
			reflectedType.fields.sort(sortMemberInfoOnPosition);
			
			//add methods
			addMethods(type, true, xml.method, reflectedType);
			addMethods(type, false, xml.factory.method, reflectedType);
			reflectedType.methods.sort(sortMemberInfoOnPosition);
			
			//add properties
			addProperties(type, true, xml.accessor, reflectedType);
			addProperties(type, false, xml.factory.accessor, reflectedType);
			reflectedType.properties.sort(sortMemberInfoOnPosition);
			
			for each(var extendedClassXml:XML in xml.factory.extendsClass)
			{
				reflectedType.extendedClasses.push(getClassForReflection(extendedClassXml.@type));
			}
			//trace(reflectedType.extendedClasses);
			
			for each(var implementedInterfacesXml:XML in xml.factory.implementsInterface)
			{
				reflectedType.implementedInterfaces.push(getClassForReflection(implementedInterfacesXml.@type));
			}
			//trace(reflectedType.implementedInterfaces);
			
			s_reflectedTypes[type] = reflectedType;
			
			xml = null;
		}
		return reflectedType;
	}
	
	//--------------------------------------
	//	PRIVATE CLASS METHODS
	//--------------------------------------
	
	private static function addFields(reflectedType:Class, isStatic:Boolean, isConstant:Boolean, xmlList:XMLList, info:TypeInfo):void
	{
		for each(var xmlItem:XML in xmlList)
		{
			var field:FieldInfo = new FieldInfo(xmlItem.@name, isStatic, isConstant, getClassForReflection(xmlItem.@type), reflectedType, reflectedType, xmlItem.metadata.length());
			addMetadata(xmlItem, field);
			info.addField(field);
			//trace(field);
		}
	}
	
	private static function addMethods(reflectedType:Class, isStatic:Boolean, xmlList:XMLList, info:TypeInfo):void
	{
		for each(var xmlItem:XML in xmlList)
		{
			var method:MethodInfo = new MethodInfo(xmlItem.@name, isStatic, getClassForReflection(xmlItem.@returnType), getClassForReflection(xmlItem.@declaredBy), reflectedType, xmlItem.parameter.length(), xmlItem.metadata.length());
			for each(var paramXml:XML in xmlItem.parameter)
			{
				method.addMethodParameter(new MethodParameterInfo(getClassForReflection(paramXml.@type), Parse.integer(paramXml.@index, 1) - 1, Parse.boolean(paramXml.@optional, false)));
			}
			addMetadata(xmlItem, method);
			info.addMethod(method);
			//trace(method);
		}
	}
	
	private static function addProperties(reflectedType:Class, isStatic:Boolean, xmlList:XMLList, info:TypeInfo):void
	{
		for each(var xmlItem:XML in xmlList)
		{
			var name:String = xmlItem.@name;
			if(name != "prototype")
			{
				var access:String = String(xmlItem.@access).toLowerCase();
				var property:PropertyInfo = new PropertyInfo(name, isStatic, getClassForReflection(xmlItem.@type), getClassForReflection(xmlItem.@declaredBy), reflectedType, access == "readonly" || access == "readwrite", access == "writeonly" || access == "readwrite", xmlItem.metadata.length());
				addMetadata(xmlItem, property);
				info.addProperty(property);
				//trace(property);
			}
			else
			{
				info.properties.fixed = false;
				info.properties.length--;
				info.properties.fixed = true;
			}
		}
	}
	
	private static function addMetadata(xml:XML, item:AbstractMemberInfo):void
	{
		for each(var metadataXml:XML in xml.metadata)
		{
			//special-case this metadata tag
			if(metadataXml.@name == "__go_to_definition_help")
			{
				item.setPosition(parseInt(metadataXml.arg[0].@value));
			}
			else
			{
				var metadata:MetadataInfo = new MetadataInfo(metadataXml.@name);
				for each(var argXml:XML in metadataXml.arg)
				{
					metadata.addValue(argXml.@key, argXml.@value);
				}
				item.addMetadata(metadata);
			}
		}
	}
	
	private static function sortMemberInfoOnPosition(l:AbstractMemberInfo, r:AbstractMemberInfo):Number
	{
		return l.position < r.position ? -1 : (r.position < l.position ? 1 : 0);
	}
	
	///returns a type for use in the reflection framework
	private static function getClassForReflection(type:String):Class
	{
		return type == "void" || type == "undefined" ? null : (type == "*" ? Object : Class(getDefinitionByName(type)));
	}
}
}