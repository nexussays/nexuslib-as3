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

import flash.system.ApplicationDomain;
import flash.utils.*;

import nexus.nexuslib_internal;
import nexus.utils.Parse;

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
	
	//call flash.utils.getQualifiedClassName(Vector) instead of hardcoding the string just in case Adobe ever changes the class or package
	///__AS3__.vec::Vector
	static private const VECTOR_PREFIX:String = flash.utils.getQualifiedClassName(Vector);
	///__AS3__.vec::Vector.<*>
	static private const UNTYPED_VECTOR_CLASSNAME:String = VECTOR_PREFIX + ".<*>";
	///class typed as __AS3__.vec::Vector.<Object>
	static private const OBJECT_VECTOR_CLASS:Class = getDefinitionByName(VECTOR_PREFIX + ".<Object>") as Class;
	
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
	 * Returns a Class of the given object instance or the provided object itself if it is already a Class.
	 * @param	object An object instance or Class
	 * @param	applicationDomain	The application domain in which to look for the class, ApplicationDomain.current is used if none is provided
	 * @throws	ReferenceError	If the class cannot be found in the provided ApplicationDomain (or ApplicationDomain.current if none is provided)
	 * @return	The class for the given object, or null if none can be found
	 */
	public static function getClass(object:Object, applicationDomain:ApplicationDomain = null):Class
	{
		if(object == null)
		{
			return null;
		}
		
		//TODO: do performance testing to see if this caching is actually getting us anything
		//if(obj in s_cachedObjectClasses)
		//{
		//	return Class(s_cachedObjectClasses[obj]);
		//}
		//else
		//{
			var def:Object= getClassByName(flash.utils.getQualifiedClassName(object), applicationDomain);
			//s_cachedObjectClasses[obj] = def;
			return Class(def);
		//}
	}
	
	/**
	 * Returns a class when provided a string formatted as a fully-qualified class name. If no application domain is provided, ApplicationDomain.currentDomain is used.
	 * @param	string	A valid qualified class name.
	 * @param	applicationDomain	The application domain in which to look for the class, ApplicationDomain.current is used if none is provided
	 * @return	The class, or null if none can be found
	 */
	public static function getClassByName(qualifiedName:String, applicationDomain:ApplicationDomain = null):Class
	{
		if(qualifiedName == "void" || qualifiedName == "undefined" || qualifiedName == "null")
		{
			return null;
		}
		else if(qualifiedName == "*" || qualifiedName == "Object")
		{
			return Object;
		}
		else if(qualifiedName == UNTYPED_VECTOR_CLASSNAME)
		{
			//FIXME: See if there is a way to support wildcard types
			return OBJECT_VECTOR_CLASS;
		}
		else
		{
			try
			{
				applicationDomain = applicationDomain || ApplicationDomain.currentDomain;
				while(!applicationDomain.hasDefinition(qualifiedName) && applicationDomain.parentDomain != null)
				{
					applicationDomain = applicationDomain.parentDomain;
				}
				return applicationDomain.getDefinition(qualifiedName) as Class;
			}
			catch(e:ReferenceError)
			{
				//Should we be throwing here?
				//* @throws	ReferenceError	If the class cannot be found in the provided ApplicationDomain (or ApplicationDomain.current if none is provided)
				//e.message = "Cannot find definition for " + qualifiedName + " in the provided application domain or its parent domains, "
					//+ "the class is either not present or not public.";
				//throw e;
			}
			return null;
		}
	}
	
	/**
	 * Returns Class(getDefinitionByName(getQualifiedSuperclassName(obj))) with special handling of Vectors
	 * @param	object			The object whose super class you want to find
	 * @return	The super class of the provided object or null if none can be found.
	 */
	public static function getSuperClass(object:Object, applicationDomain:ApplicationDomain = null):Class
	{
		if(object != null)
		{
			var superClassName:String = getQualifiedSuperclassName(object);
			var parent : Class = getClassByName(superClassName, applicationDomain);
			if(parent != null)
			{
				return parent;
			}
			else if(superClassName.substr(0, VECTOR_PREFIX.length) == VECTOR_PREFIX)
			{
				return OBJECT_VECTOR_CLASS;
			}
		}
		return null;
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
	 * To check if a class implements an interface, get the TypeInfo of the class and check implementedInterfaces.
	 * @param	potentialSubclass
	 * @param	potentialSuperClass
	 * @return
	 */
	public static function classExtendsClass(potentialSubclass:Class, potentialSuperClass:Class, applicationDomain:ApplicationDomain = null):Boolean
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
			try
			{
				potentialSubclass = getSuperClass(potentialSubclass, applicationDomain);
				if(potentialSubclass == potentialSuperClass)
				{
					return true;
				}
			}
			catch(e:ReferenceError)
			{
				return false;
			}
		}
		
		return false;
	}
	
	/**
	 * Return the object type of the provided vector. If the provided value is not a vector
	 * or is untyped, Object is returned.
	 * @param	data
	 * @return	The type of the vector or Object if no type is present in the value provided
	 */
	public static function getVectorType(data:Object, applicationDomain:ApplicationDomain = null):Class
	{
		var typePrefix:String = flash.utils.getQualifiedClassName(data);
		if(typePrefix == UNTYPED_VECTOR_CLASSNAME)
		{
			return Object;
		}
		//parse out class between "__AS3__.vec::Vector.<" and ">"
		return getClassByName(typePrefix.substring(VECTOR_PREFIX.length + 2, typePrefix.length - 1), applicationDomain);
	}
	
	/**
	 * Reflects into the given object and returns a TypeInfo object
	 * @param	obj	The object to reflect
	 * @return	A TypeInfo that represents the given object's Class information
	 */
	public static function getTypeInfo(object:Object, applicationDomain:ApplicationDomain = null):TypeInfo
	{
		applicationDomain = applicationDomain || ApplicationDomain.currentDomain;
		var type:Class = getClass(object, applicationDomain);
		if(type == AbstractMemberInfo || Reflection.classExtendsClass(type, AbstractMemberInfo, applicationDomain))
		{
			throw new ArgumentError("Cannot get TypeInfo of objects that themselves extend AbstractMemberInfo.");
		}
		//var s : int = getTimer();
		if(!(applicationDomain in s_cachedTypeInfoObjects))
		{
			s_cachedTypeInfoObjects[applicationDomain] = new Dictionary();
		}
		var types : Dictionary = s_cachedTypeInfoObjects[applicationDomain];
		var reflectedType:TypeInfo = types[type];
		if(reflectedType == null)
		{
			var xml:XML = describeType(type);
			
			reflectedType = new TypeInfo(xml.@name, applicationDomain, type, Parse.boolean(xml.@isFinal, false), xml.factory.metadata.length(), xml.method.length() + xml.factory.method.length(), xml.accessor.length() + xml.factory.accessor.length(), xml.variable.length() + xml.constant.length() + xml.factory.variable.length() + xml.factory.constant.length());
			addMetadata(reflectedType, xml);
			
			//add constructor
			reflectedType.setConstructor(parseConstructorInfo(xml.factory.constructor[0], reflectedType, applicationDomain, true, false));
			
			//add fields
			//s = getTimer();
			addMembers(parseFieldInfo, xml.constant, reflectedType, applicationDomain, true, true);
			addMembers(parseFieldInfo, xml.variable, reflectedType, applicationDomain, true, false);
			addMembers(parseFieldInfo, xml.factory.constant, reflectedType, applicationDomain, false, true);
			addMembers(parseFieldInfo, xml.factory.variable, reflectedType, applicationDomain, false, false);
			
			//add methods
			addMembers(parseMethodInfo, xml.method, reflectedType, applicationDomain, true, false);
			addMembers(parseMethodInfo, xml.factory.method, reflectedType, applicationDomain, false, false);
			
			//add properties
			addMembers(parsePropertyInfo, xml.accessor, reflectedType, applicationDomain, true, false);
			addMembers(parsePropertyInfo, xml.factory.accessor, reflectedType, applicationDomain, false, false);
			//trace(getTimer() - s);
			
			for each(var extendedClassXml:XML in xml.factory.extendsClass)
			{
				reflectedType.extendedClasses.push(getClassByName(extendedClassXml.@type, applicationDomain));
			}
			//trace(reflectedType.extendedClasses);
			
			for each(var implementedInterfacesXml:XML in xml.factory.implementsInterface)
			{
				reflectedType.implementedInterfaces.push(getClassByName(implementedInterfacesXml.@type, applicationDomain));
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
			
			s_cachedTypeInfoObjects[applicationDomain][type] = reflectedType;
			
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
		return value is int || value == int
			|| value is uint || value == uint
			|| value is Number || value == Number
			|| value is String || value == String
			|| value is Boolean || value == Boolean;
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
		if(value is Dictionary || value == Dictionary || value == Object)
		{
			return true;
		}
		
		try
		{
			return getClass(value, ApplicationDomain.currentDomain) == Object;
		}
		catch(e:ReferenceError)
		{
		}
		return false;
	}
	
	/**
	 * Provide a class which extends Metadata, and reflected TypeInfo will parse any matching metadata into
	 * an instance of the strongly-typed class provided.
	 * @param	type	A class which must be a subclass of Metadata
	 */
	public static function registerMetadataClass(type:Class):void
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
	public static function registerMetadataClasses(types:Vector.<Class>):void
	{
		use namespace nexuslib_internal;
		for each(var type:Class in types)
		{
			Reflection.registerMetadataClass(type);
		}
	}
	
	//--------------------------------------
	//	INTERNAL CLASS METHODS
	//--------------------------------------
	
	/**
	 * Returns the Metadata Class registered for the given instance. Faster than a getClass() lookup and
	 * ensures there are no ApplicationDomain-related issues.
	 * @param	instance
	 * @return
	 */
	nexuslib_internal static function getMetadataClass(instance:Metadata):Class
	{
		return s_registeredMetadataTypes[Reflection.getUnqualifiedClassName(instance)];
	}
	
	//--------------------------------------
	//	PRIVATE CLASS METHODS
	//--------------------------------------
	
	private static function addMembers(method:Function, xmlList:XMLList, typeInfo:TypeInfo, appDomain:ApplicationDomain, isStatic:Boolean, isConstant:Boolean):void
	{
		for each(var xmlItem:XML in xmlList)
		{
			var member:AbstractMemberInfo = method(xmlItem, typeInfo, appDomain, isStatic, isConstant);
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
	
	static private function parseFieldInfo(xmlItem:XML, typeInfo:TypeInfo, appDomain:ApplicationDomain, isStatic:Boolean, isConstant:Boolean):FieldInfo
	{
		//TODO: add declaring type info. it will require recursing through all superclass typeinfos
		return new FieldInfo(xmlItem.@name, isStatic, isConstant, getClassByName(xmlItem.@type, appDomain), null, typeInfo, xmlItem.metadata.length());
	}
	
	static private function parseMethodInfo(xmlItem:XML, typeInfo:TypeInfo, appDomain:ApplicationDomain, isStatic:Boolean, isConstant:Boolean):MethodInfo
	{
		var method:MethodInfo = new MethodInfo(xmlItem.@name, isStatic, getClassByName(xmlItem.@returnType, appDomain), getClassByName(xmlItem.@declaredBy, appDomain), typeInfo, xmlItem.parameter.length(), xmlItem.metadata.length());
		for each(var paramXml:XML in xmlItem.parameter)
		{
			method.addMethodParameter(new MethodParameterInfo(getClassByName(paramXml.@type, appDomain), Parse.integer(paramXml.@index, 1) - 1, Parse.boolean(paramXml.@optional, false)));
		}
		return method;
	}
	
	static private function parseConstructorInfo(xmlItem:XML, typeInfo:TypeInfo, appDomain:ApplicationDomain, isStatic:Boolean, isConstant:Boolean):MethodInfo
	{
		var method:MethodInfo;
		if(xmlItem != null)
		{
			method = new MethodInfo("_ctor", isStatic, null, typeInfo.type, typeInfo, xmlItem.parameter.length(), xmlItem.metadata.length());
			for each(var paramXml:XML in xmlItem.parameter)
			{
				method.addMethodParameter(new MethodParameterInfo(getClassByName(paramXml.@type, appDomain), Parse.integer(paramXml.@index, 1) - 1, Parse.boolean(paramXml.@optional, false)));
			}
		}
		else
		{
			method = new MethodInfo("_ctor", isStatic, null, typeInfo.type, typeInfo, 0, 0);
		}
		return method;
	}
	
	static private function parsePropertyInfo(xmlItem:XML, typeInfo:TypeInfo, appDomain:ApplicationDomain, isStatic:Boolean, isConstant:Boolean):PropertyInfo
	{
		var property:PropertyInfo;
		var name:String = xmlItem.@name;
		if(name != "prototype")
		{
			var access:String = String(xmlItem.@access).toLowerCase();
			property = new PropertyInfo(name, isStatic, getClassByName(xmlItem.@type, appDomain), getClassByName(xmlItem.@declaredBy, appDomain), typeInfo, access == "readonly" || access == "readwrite", access == "writeonly" || access == "readwrite", xmlItem.metadata.length());
		}
		else
		{
			typeInfo.properties.fixed = false;
			typeInfo.properties.length--;
			typeInfo.properties.fixed = true;
		}
		return property;
	}
}
}