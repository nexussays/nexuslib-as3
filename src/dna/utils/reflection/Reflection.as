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

import dna.utils.Parse;
import flash.utils.describeType;
import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedSuperclassName;

/**
 * ...
 * @author	Malachi Griffie <malachi@nexussays.com>
 * @since 7/23/2011 3:34 AM
 */
public class Reflection
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	///store all reflected types to the describeType() call and processing into a TypeInfo instance only ever happens once
	private static const s_reflectedTypes:Dictionary = new Dictionary();
	///store strongly-typed classes that represent metadata on members
	static private const s_registeredMetadataTypes:Dictionary = new Dictionary();
	
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	/**
	 * Returns a Class, given an object instance, a class, or a string formatted as qualified class name
	 * @param	obj
	 * @return
	 */
	public static function getClass(obj:Object):Class
	{
		if(obj == null)
		{
			return null;
		}
		else if(obj is Class)
		{
			return Class(obj);
		}
		else
		{
			var def : Object;
			
			//allow passing in a class name as the argument
			if(obj is String)
			{
				try
				{
					def = getDefinitionByName(String(obj));
				}
				catch(e:ReferenceError)
				{
					//ignore
				}
			}
			
			if(def == null)
			{
				def = getDefinitionByName(flash.utils.getQualifiedClassName(obj));
			}
			
			return Class(def);
		}
	}
	
	/**
	 * Returns Class(getDefinitionByName(getQualifiedSuperclassName(obj)))
	 * @param	obj
	 * @return
	 */
	public static function getSuperClass(obj:Object):Class
	{
		if(obj != null)
		{
			//use getClass to handle parsing string values that are qualified class names
			obj = getClass(obj);
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
	 * getUnqualifiedClassName(SomeClass) => "SomeClass"
	 * getUnqualifiedClassName("com.example.pkg::SomeClass") => "SomeClass"
	 * getUnqualifiedClassName("[class SomeClass]") => "SomeClass"
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
	 * Returns the fully qualified class name of an object. Convenience method that wraps flash.utils.getQualifiedClassName
	 * @param	value	The object for which a fully qualified class name is desired.
	 * @return	A string containing the fully qualified class name.
	 */
	public static function getQualifiedClassName(value:Object):String
	{
		return flash.utils.getQualifiedClassName(value);
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
			potentialSubclass = getSuperClass(potentialSubclass);
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
	public static function getTypeInfo(object:Object):TypeInfo
	{
		var type:Class = getClass(object);
		var reflectedType:TypeInfo = s_reflectedTypes[type];
		if(reflectedType == null)
		{
			var xml:XML = describeType(type);
			
			reflectedType = new TypeInfo(xml.@name, type, Parse.boolean(xml.@isDynamic, false), Parse.boolean(xml.@isFinal, false), xml.factory.metadata.length(), xml.method.length() + xml.factory.method.length(), xml.accessor.length() + xml.factory.accessor.length(), xml.variable.length() + xml.constant.length() + xml.factory.variable.length() + xml.factory.constant.length());
			
			//add constructor
			reflectedType.setConstructor(parseConstructorInfo(xml.factory.constructor[0], reflectedType, true, false));
			
			//add fields
			addMembers(parseFieldInfo, xml.constant, reflectedType, true, true);
			addMembers(parseFieldInfo, xml.variable, reflectedType, true, false);
			addMembers(parseFieldInfo, xml.factory.constant, reflectedType, false, true);
			addMembers(parseFieldInfo, xml.factory.variable, reflectedType, false, false);
			
			//add methods
			addMembers(parseMethodInfo, xml.method, reflectedType, true, false);
			addMembers(parseMethodInfo, xml.factory.method, reflectedType, false, false);
			
			//add properties
			addMembers(parsePropertyInfo, xml.accessor, reflectedType, true, false);
			addMembers(parsePropertyInfo, xml.factory.accessor, reflectedType, false, false);
			
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
	
	/**
	 * Returns true if the provided object is an instance of a primitive class or is a Class object of a primitive type
	 * @param	type
	 * @return
	 */
	public static function isPrimitive(value:Object):Boolean
	{
		//TODO: will need to account for the fact that this goes through the getClass method which parses class names in strings,
		//so if we check if a string is a primitive it will return false if the contents of the string is a class name. Perhaps
		//that is a desired side-effect, and perhaps not
		var type : Class = value is Class ? Class(value) : getClass(value);
		switch(type)
		{
			case int:
			case uint:
			case Number:
			case String:
			case Boolean:
				return true;
			default:
				return false;
		}
	}
	
	/**
	 * Provide a list of classes that extend Metadata and reflected TypeInfo will parse any metadata into strongly-typed classes
	 * @param	types	A vector of classes, each of which must be a subclass of Metadata
	 */
	public static function registerMetadataClasses(types:Vector.<Class>):void
	{
		for each(var type:Class in types)
		{
			if(!classExtendsClass(type, Metadata))
			{
				throw new ArgumentError("Cannot register metadata class \"" + type + "\", it does not extend " + Metadata);
			}
			//TODO: store by class so similarly named metadata in different packages won't conflict
			s_registeredMetadataTypes[Reflection.getUnqualifiedClassName(type)] = type;
		}
	}
	
	//--------------------------------------
	//	PRIVATE CLASS METHODS
	//--------------------------------------
	
	private static function addMembers(method:Function, xmlList:XMLList, typeInfo:TypeInfo, isStatic:Boolean, isConstant:Boolean):void
	{
		for each(var xmlItem:XML in xmlList)
		{
			var member:AbstractMemberInfo = method(xmlItem, typeInfo, isStatic, isConstant);
			if(member != null)
			{
				//add metadata
				for each(var metadataXml:XML in xmlItem.metadata)
				{
					//this is a default matadata tag added by the compiler in a debug build
					if(metadataXml.@name == "__go_to_definition_help")
					{
						member.setPosition(parseInt(metadataXml.arg[0].@value));
					}
					else
					{
						//add metadata info
						var metadataInfo:MetadataInfo = new MetadataInfo(metadataXml.@name);
						for each(var argXml:XML in metadataXml.arg)
						{
							metadataInfo.addValue(argXml.@key, argXml.@value);
						}
						member.addMetadataInfo(metadataInfo);
						
						//see if there is a registered strongly-typed class for this metadata
						for(var name:String in s_registeredMetadataTypes)
						{
							//implemantors of metadata should omit the "Metadata" suffix, it is added here
							if(metadataInfo.name + "Metadata" == name)
							{
								var metadata:Metadata = new s_registeredMetadataTypes[name](metadataInfo);
								member.addMetadataInstance(metadata);
								break;
							}
						}
					}
				}
				
				//add member to typeinfo
				typeInfo.addMember(member);
				
				//trace(member);
			}
		}
	}
	
	static private function parseFieldInfo(xmlItem:XML, typeInfo:TypeInfo, isStatic:Boolean, isConstant:Boolean):FieldInfo
	{
		//TODO: add declaring type info. it will require recursing through all superclass typeinfos
		return new FieldInfo(xmlItem.@name, isStatic, isConstant, getClassForReflection(xmlItem.@type), null, typeInfo, xmlItem.metadata.length());
	}
	
	static private function parseMethodInfo(xmlItem:XML, typeInfo:TypeInfo, isStatic:Boolean, isConstant:Boolean):MethodInfo
	{
		var method:MethodInfo = new MethodInfo(xmlItem.@name, isStatic, getClassForReflection(xmlItem.@returnType), getClassForReflection(xmlItem.@declaredBy), typeInfo, xmlItem.parameter.length(), xmlItem.metadata.length());
		for each(var paramXml:XML in xmlItem.parameter)
		{
			method.addMethodParameter(new MethodParameterInfo(getClassForReflection(paramXml.@type), Parse.integer(paramXml.@index, 1) - 1, Parse.boolean(paramXml.@optional, false)));
		}
		return method;
	}
	
	static private function parseConstructorInfo(xmlItem:XML, typeInfo:TypeInfo, isStatic:Boolean, isConstant:Boolean):MethodInfo
	{
		var method:MethodInfo;
		if(xmlItem != null)
		{
			method = new MethodInfo("_ctor", isStatic, null, typeInfo.declaringType, typeInfo, xmlItem.parameter.length(), xmlItem.metadata.length());
			for each(var paramXml:XML in xmlItem.parameter)
			{
				method.addMethodParameter(new MethodParameterInfo(getClassForReflection(paramXml.@type), Parse.integer(paramXml.@index, 1) - 1, Parse.boolean(paramXml.@optional, false)));
			}
		}
		else
		{
			method = new MethodInfo("_ctor", isStatic, null, typeInfo.declaringType, typeInfo, 0, 0);
		}
		return method;
	}
	
	static private function parsePropertyInfo(xmlItem:XML, typeInfo:TypeInfo, isStatic:Boolean, isConstant:Boolean):PropertyInfo
	{
		var property:PropertyInfo;
		var name:String = xmlItem.@name;
		if(name != "prototype")
		{
			var access:String = String(xmlItem.@access).toLowerCase();
			property = new PropertyInfo(name, isStatic, getClassForReflection(xmlItem.@type), getClassForReflection(xmlItem.@declaredBy), typeInfo, access == "readonly" || access == "readwrite", access == "writeonly" || access == "readwrite", xmlItem.metadata.length());
		}
		else
		{
			typeInfo.properties.fixed = false;
			typeInfo.properties.length--;
			typeInfo.properties.fixed = true;
		}
		return property;
	}
	
	///returns a type for use in the reflection framework
	private static function getClassForReflection(typeName:String):Class
	{
		return typeName == null || typeName == "" || typeName == "void" || typeName == "undefined" ? null : (typeName == "*" ? Object : Class(getDefinitionByName(typeName)));
	}
}
}