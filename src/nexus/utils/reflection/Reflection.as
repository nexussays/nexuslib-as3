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

import avmplus.AVMDescribeType;
import nexus.nexuslib_internal;
import nexus.utils.Parse;

import flash.utils.*;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since 7/23/2011 3:34 AM
 */
public class Reflection
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//call flash.utils.getQualifiedClassName(Vector) instead of hardcoding the string just in case Adobe ever changes the class
	///__AS3__.vec::Vector
	static private const VECTOR_PREFIX:String = flash.utils.getQualifiedClassName(Vector);
	///__AS3__.vec::Vector.<*>
	static private const UNTYPED_VECTOR_CLASSNAME:String = VECTOR_PREFIX + ".<*>";
	
	///cache all TypeInfo information so parsing in the describeType() call only happens once
	static private const s_cachedTypeInfoObjects:Dictionary = new Dictionary();
	///store strongly-typed classes that represent metadata on members
	static private const s_registeredMetadataTypes:Dictionary = new Dictionary();
	///store all calls to getClass() so the lookup is quicker if the same object is provided a second time
	//static private const s_cachedObjectClasses:Dictionary = new Dictionary(true);
	
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
		return getClassFromObject(obj, true);
	}
	
	/**
	 * Returns Class(getDefinitionByName(getQualifiedSuperclassName(obj))) with special handling of Vectors
	 * @param	obj
	 * @throws	ReferenceError	If the super class is not present or accessible, for example if the class is internal or not in this ApplicationDomain.
	 * @return
	 */
	public static function getSuperClass(obj:Object):Class
	{
		if(obj != null)
		{
			//use getClass to handle parsing string values that are qualified class names
			obj = getClass(obj);
			var superClassName:String = getQualifiedSuperclassName(obj);
			try
			{
				return Class(getDefinitionByName(superClassName));
			}
			catch(e:ReferenceError)
			{
				if(superClassName.substr(0, VECTOR_PREFIX.length) == VECTOR_PREFIX)
				{
					return Vector;
				}
				else
				{
					e.message = "Cannot find definition for " + superClassName + ", the class is either not present or not public.";
					throw e;
				}
			}
		}
		return null;
	}
	
	/**
	 * Return the object type of the provided vector. If the provided value is not a vector
	 * or is untyped, Object is returned.
	 * @param	data
	 * @return	The type of the vector or Object if no type is present in the value provided
	 */
	public static function getVectorClass(data:Object):Class
	{
		var type:Class = getClassFromObject(data, false);
		var typePrefix:String = flash.utils.getQualifiedClassName(type);
		//parse out class between "Vector.<" and ">"
		typePrefix = typePrefix.substring(VECTOR_PREFIX.length + 2, typePrefix.length - 1);
		return typePrefix == "*" ? Object : (getClass(typePrefix) || Object);
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
	 * Given a Class, object instance, or a fully qualified class name, this will return the class name without the package names attached.
	 * @example	<pre>
	 * getUnqualifiedClassName(SomeClass) => "SomeClass"
	 * getUnqualifiedClassName(instanceOfSomeClass) => "SomeClass"
	 * getUnqualifiedClassName("com.example.as3::SomeClass") => "SomeClass"
	 * getUnqualifiedClassName("[class SomeClass]") => "SomeClass"
	 * getUnqualifiedClassName("some string value") => "String"
	 * </pre>
	 * @param	object	An object instance, a Class, or a String representing a class name
	 * @return
	 */
	public static function getUnqualifiedClassName(object:Object):String
	{
		var str:String;
		//special handling of strings
		if(object is String
			//allow allow formatted class names to be provided
			&& (String(object).substr(0, 7) == "[class " || String(object).indexOf("::") != -1))
		{
			str = String(object);
		}
		else if(object is Class)
		{
			str = object + "";
		}
		else
		{
			str = flash.utils.getQualifiedClassName(object);
		}
		
		//parse out class when in format "package.package.package::ClassName"
		str = str.substring(str.lastIndexOf(":") + 1);
		
		//parse out class when in format "[class ClassName]"
		var closingBracketIndex:int = str.lastIndexOf("]");
		if(closingBracketIndex != -1)
		{
			str = str.substring(str.lastIndexOf(" ") + 1, closingBracketIndex);
		}
		
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
		if(type == AbstractMemberInfo || Reflection.classExtendsClass(type, AbstractMemberInfo))
		{
			throw new ArgumentError("Cannot get TypeInfo of objects that themselves extend AbstractMemberInfo.");
		}
		//var s : int = getTimer();
		var reflectedType:TypeInfo = s_cachedTypeInfoObjects[type];
		if(reflectedType == null)
		{
			var xml:XML = describeType(type);
			
			reflectedType = new TypeInfo(xml.@name, type, Parse.boolean(xml.@isFinal, false), xml.factory.metadata.length(), xml.method.length() + xml.factory.method.length(), xml.accessor.length() + xml.factory.accessor.length(), xml.variable.length() + xml.constant.length() + xml.factory.variable.length() + xml.factory.constant.length());
			addMetadata(reflectedType, xml);
			
			//add constructor
			reflectedType.setConstructor(parseConstructorInfo(xml.factory.constructor[0], reflectedType, true, false));
			
			//add fields
			//s = getTimer();
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
			//trace(getTimer() - s);
			
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
			
			//isDynamic info is incorrect if doing a describeType of a Class
			if(object is Class && reflectedType.constructor.requiredParametersCount == 0)
			{
				try
				{
					object = new type();
				}
				catch(e:Error)
				{
					
				}
			}
			
			if(!(object is Class))
			{
				reflectedType.setIsDynamic(Parse.boolean(describeType(object).@isDynamic, false));
			}
			
			s_cachedTypeInfoObjects[type] = reflectedType;
			
			xml = null;
		}
		return reflectedType;
	}
	
	/**
	 * Check if the provided object is an instance of a primitive class or is a Class object of a primitive type
	 * @param	value	The object to test
	 * @return	True if the provided object is an instance of a primitive class or is a Class object of a primitive type
	 */
	public static function isPrimitive(value:Object):Boolean
	{
		var type:Class = getClassFromObject(value, false);
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
	 * Check if the provided object is an Array or Vector
	 * @param	value	The object to test
	 * @return	True if the provided object is an Array or Vector
	 */
	public static function isArray(value:Object):Boolean
	{
		if(value is Array || value == Array)
		{
			return true;
		}
		//if it's not an Array, see if it's a vector
		var typePrefix:String = flash.utils.getQualifiedClassName(value).substr(0, VECTOR_PREFIX.length);
		return typePrefix == VECTOR_PREFIX;
	}
	
	/**
	 * Check if the provided object is a Dictionary or native Object
	 * @param	value	The object to test
	 * @return	True if the provided object is a Dictionary or native Object
	 */
	public static function isAssociativeArray(value:Object):Boolean
	{
		return value is Dictionary || value == Dictionary || getClassFromObject(value, false) == Object;
	}
	
	//--------------------------------------
	//	INTERNAL CLASS METHODS
	//--------------------------------------
	
	/**
	 * Provide a class which extends Metadata, and reflected TypeInfo will parse any matching metadata into
	 * an instance of the strongly-typed class provided.
	 * @param	type	A class which must be a subclass of Metadata
	 */
	nexuslib_internal static function registerMetadataClass(type:Class):void
	{
		if(!classExtendsClass(type, Metadata))
		{
			throw new ArgumentError("Cannot register metadata class \"" + type + "\", it does not extend " + Metadata);
		}
		//TODO: store by class so similarly named metadata in different packages won't conflict
		s_registeredMetadataTypes[Reflection.getUnqualifiedClassName(type)] = type;
	}
	
	/**
	 * Provide a list of classes that extend Metadata and reflected TypeInfo will parse any matching metadata into
	 * and instance of the strongly-typed class provided.
	 * @param	types	A vector of classes, each of which must be a subclass of Metadata
	 */
	nexuslib_internal static function registerMetadataClasses(types:Vector.<Class>):void
	{
		use namespace nexuslib_internal;
		for each(var type:Class in types)
		{
			Reflection.registerMetadataClass(type);
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
				addMetadata(member, xmlItem);
				
				//add member to typeinfo
				typeInfo.addMember(member);
				
					//trace(member);
			}
		}
	}
	
	static private function addMetadata(member:AbstractMetadataRecipient, xmlItem:XML):void
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
				for(var registeredMetadataName:String in s_registeredMetadataTypes)
				{
					//implementers of metadata should omit the "Metadata" suffix, it is added here
					if(metadataInfo.name + "Metadata" == registeredMetadataName)
					{
						var metadata:Metadata = new s_registeredMetadataTypes[registeredMetadataName](metadataInfo);
						member.addMetadataInstance(metadata, metadataInfo.name);
						break;
					}
				}
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
			method = new MethodInfo("_ctor", isStatic, null, typeInfo.type, typeInfo, xmlItem.parameter.length(), xmlItem.metadata.length());
			for each(var paramXml:XML in xmlItem.parameter)
			{
				method.addMethodParameter(new MethodParameterInfo(getClassForReflection(paramXml.@type), Parse.integer(paramXml.@index, 1) - 1, Parse.boolean(paramXml.@optional, false)));
			}
		}
		else
		{
			method = new MethodInfo("_ctor", isStatic, null, typeInfo.type, typeInfo, 0, 0);
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
	
	/**
	 * Gets the class of the given object, optionally looking up string values that contain qualified class names
	 * @param	obj			The object to find the class of
	 * @param	castStrings	If true, a string value that contains a valid qualified class name will be cast to that class
	 * @return
	 */
	private static function getClassFromObject(obj:Object, castStrings:Boolean):Class
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
			//TODO: do performance testing to see if this caching is actually getting us anything
			//if(obj in s_cachedObjectClasses)
			//{
			//	return Class(s_cachedObjectClasses[obj]);
			//}
			//else
			//{
				var def:Object;
				//allow passing in a class name as the argument if castStrings is true
				if(castStrings && obj is String)
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
				
				//s_cachedObjectClasses[obj] = def;
				return Class(def);
			//}
		}
	}
	
	/**
	 * Returns a type for use in the reflection framework
	 * @param	typeName
	 * @return
	 */
	private static function getClassForReflection(typeName:String):Class
	{
		if(typeName == "void" || typeName == "undefined")
		{
			return null;
		}
		else if(typeName == UNTYPED_VECTOR_CLASSNAME)
		{
			return Vector;
		}
		else if(typeName == "*" || typeName == "Object")
		{
			return Object;
		}
		else
		{
			return Class(getDefinitionByName(typeName));
		}
	}
}
}