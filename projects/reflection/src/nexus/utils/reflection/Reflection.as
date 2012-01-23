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
import flash.system.System;
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
	
	//TODO: Probably need to do some checking here to make sure this is the domain we want
	static public const SYSTEM_DOMAIN : ApplicationDomain = ApplicationDomain.currentDomain;
	
	//call flash.utils.getQualifiedClassName(Vector) instead of hardcoding the string just in case Adobe ever changes the class or package
	///__AS3__.vec::Vector
	static private const VECTOR_PREFIX:String = flash.utils.getQualifiedClassName(Vector);
	///__AS3__.vec::Vector.<*>
	static private const UNTYPEDVECTOR_CLASSNAME_QUALIFIED:String = flash.utils.getQualifiedClassName(Vector.<*>);
	///Vector.<*>
	static private const UNTYPEDVECTOR_CLASSNAME_UNQUALIFIED:String = "Vector.<*>";
	///class typed as __AS3__.vec::Vector.<Object>
	static private const OBJECTVECTOR_CLASS:Class = getDefinitionByName(flash.utils.getQualifiedClassName(Vector.<Object>)) as Class;
	
	///cache all TypeInfo information so parsing in the describeType() call only happens once
	static private const CACHED_TYPEINFO:Dictionary = new Dictionary(true);
	///store strongly-typed classes that represent metadata on members
	static private const REGISTERED_METADATA_CLASSES:Dictionary = new Dictionary();
	static private const REGISTERED_METADATA_NAMES:Dictionary = new Dictionary();
	
	static private const s_testDomainMemory:ByteArray = new ByteArray();
	{
		s_testDomainMemory.length = ApplicationDomain.MIN_DOMAIN_MEMORY_LENGTH;
	}
	
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	/**
	 * Returns a Class of the given object instance or the provided object itself if it is already a Class.
	 * @param	object An object instance or Class
	 * @param	applicationDomain	The application domain in which to look for the class. ApplicationDomain.current is used if none is provided.
	 * @return	The class for the given object, or null if none can be found
	 */
	public static function getClass(object:Object, applicationDomain:ApplicationDomain = null):Class
	{
		return object == null ? null : getClassByName(flash.utils.getQualifiedClassName(object), applicationDomain);
	}
	
	/**
	 * Returns a class when provided a string formatted as a fully-qualified class name. If no application domain is provided, the system domain is used.
	 * @param	qualifiedName	A valid qualified class name.
	 * @param	applicationDomain	The application domain in which to look for the class. ApplicationDomain.current is used if none is provided.
	 * @return	The class, or null if none can be found
	 * @throws	ReferenceError	If the class cannot be found in the provided ApplicationDomain (or the system ApplicationDomain if none is provided)
	 */
	public static function getClassByName(qualifiedName:String, applicationDomain:ApplicationDomain = null):Class
	{
		if(qualifiedName == null || qualifiedName == "void" || qualifiedName == "undefined" || qualifiedName == "null")
		{
			return null;
		}
		else if(qualifiedName == "*" || qualifiedName == "Object")
		{
			return Object;
		}
		else if(qualifiedName == UNTYPEDVECTOR_CLASSNAME_QUALIFIED || qualifiedName == UNTYPEDVECTOR_CLASSNAME_UNQUALIFIED)
		{
			//TODO: See if there is a way to support untyped vectors
			return OBJECTVECTOR_CLASS;
		}
		
		try
		{
			applicationDomain = applicationDomain || SYSTEM_DOMAIN;
			//walk up parent app domains while the class is still defined to get the top-most reference
			while(applicationDomain.parentDomain != null && applicationDomain.parentDomain.hasDefinition(qualifiedName))
			{
				applicationDomain = applicationDomain.parentDomain;
			}
			return applicationDomain.getDefinition(qualifiedName) as Class;
		}
		catch(e:ReferenceError)
		{
			e.message = "Cannot find definition for " + qualifiedName + ", the class is either not present in the application domain or is not public.";
			throw e;
		}
		return null;
	}
	
	/**
	 * Returns Class(getDefinitionByName(getQualifiedSuperclassName(obj))) with special handling of Vectors
	 * @param	object			The object whose super class you want to find
	 * @param	applicationDomain	The application domain in which to look. ApplicationDomain.current is used if none is provided.
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
				return OBJECTVECTOR_CLASS;
			}
		}
		return null;
	}
	
	/**
	 * Return the object type of the provided vector. If the provided vector is untyped, Object is returned. If the
	 * object is not a vector, null is returned.
	 * @param	data
	 * @param	applicationDomain	The application domain in which to look. ApplicationDomain.current is used if none is provided.
	 * @return	The type of the vector or Object if no type is present in the value provided
	 */
	public static function getVectorType(object:Object, applicationDomain:ApplicationDomain = null):Class
	{
		var typeName:String = flash.utils.getQualifiedClassName(object);
		if(typeName == UNTYPEDVECTOR_CLASSNAME_QUALIFIED)
		{
			return Object;
		}
		if(typeName.substr(0, VECTOR_PREFIX.length) == VECTOR_PREFIX)
		{
			//parse out class between "__AS3__.vec::Vector.<" and ">"
			return getClassByName(typeName.substring(VECTOR_PREFIX.length + 2, typeName.length - 1), applicationDomain);
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
	 * @example	<listing version="3.0">
	 * getUnqualifiedClassName(SomeClass) => "SomeClass"
	 * getUnqualifiedClassName(instanceOfSomeClass) => "SomeClass"
	 * getUnqualifiedClassName("com.example.as3::SomeClass") => "SomeClass"
	 * getUnqualifiedClassName("[class SomeClass]") => "SomeClass"
	 * getUnqualifiedClassName("some string value") => "String"
	 * </listing>
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
	 * @param	applicationDomain	The application domain in which to look for these classes, ApplicationDomain.current is used if none is provided
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
	 * Checks it two application domains point to the same reference.
	 * @param	applicationDomainOne	One of the <code>ApplicationDomain</code>s to check for equality
	 * @param	applicationDomainTwo	One of the <code>ApplicationDomain</code>s to check for equality
	 * @return	True if the two provided application domains point to the same reference
	 */
	public static function applicationDomainsAreEqual(applicationDomainOne:ApplicationDomain, applicationDomainTwo:ApplicationDomain):Boolean
	{
		if(applicationDomainOne == null || applicationDomainTwo == null)
		{
			return false;
		}
		
		var domainMemoryOne:ByteArray = applicationDomainOne.domainMemory;
		
		//assign a different ByteArray to domainMemory of the first app domain
		applicationDomainOne.domainMemory = s_testDomainMemory;
		
		//see if the second app domain is pointing to the same reference
		var result:Boolean = applicationDomainOne.domainMemory == applicationDomainTwo.domainMemory;
		
		//restore the domain memory
		applicationDomainOne.domainMemory = domainMemoryOne;
		
		return result;
	}
	
	/**
	 * Reflects into the given object and returns a TypeInfo object
	 * @param	obj	The object to reflect
	 * @return	A TypeInfo that represents the given object's Class information
	 */
	public static function getTypeInfo(object:Object, applicationDomain:ApplicationDomain = null):TypeInfo
	{
		applicationDomain = applicationDomain || SYSTEM_DOMAIN;
		var type:Class = getClass(object, applicationDomain);
		
		if(type == AbstractMemberInfo || Reflection.classExtendsClass(type, AbstractMemberInfo, applicationDomain))
		{
			throw new ArgumentError("Cannot get TypeInfo of objects that themselves extend AbstractMemberInfo.");
		}
		
		//var s : int = getTimer();
		if(!(applicationDomain in CACHED_TYPEINFO))
		{
			CACHED_TYPEINFO[applicationDomain] = new Dictionary();
		}
		
		var types : Dictionary = CACHED_TYPEINFO[applicationDomain];
		var reflectedType:TypeInfo = types[type];
		if(reflectedType == null)
		{
			var xml:XML = describeType(type);
			
			reflectedType = new TypeInfo(xml.@name, applicationDomain, type,
				xml.factory.metadata.length(), xml.method.length() + xml.factory.method.length(),
				xml.accessor.length() + xml.factory.accessor.length(),
				xml.variable.length() + xml.constant.length() + xml.factory.variable.length() + xml.factory.constant.length());
				
			addMetadata(reflectedType, xml.factory[0]);
			
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
				//try to instantiate so we can do a describe type of the instance
				try
				{
					object = new type();
				}
				catch(e:Error)
				{
					
				}
			}
			
			//if the object provided was an instance or we were able to create one above
			if(!(object is Class))
			{
				if("disposeXML" in System)
				{
					System["disposeXML"](xml);
				}
				//get the xml info for the instance
				xml = describeType(object);
				reflectedType.setIsDynamic(Parse.boolean(xml.@isDynamic, false));
				reflectedType.setIsFinal(Parse.boolean(xml.@isFinal, false));
			}
			
			CACHED_TYPEINFO[applicationDomain][type] = reflectedType;
			
			if("disposeXML" in System)
			{
				System["disposeXML"](xml);
			}
			xml = null;
		}
		return reflectedType;
	}
	
	/**
	 * Check if the provided object is an instance of a primitive class or is a Class object of a primitive type
	 * @param	value	The object to test
	 * @return	True if the provided object is an instance of a primitive class or is a Class object of a primitive type
	 */
	public static function isScalar(value:Object):Boolean
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
	public static function isArrayType(value:Object):Boolean
	{
		return value is Array || value == Array || isVector(value);
	}
	
	/**
	 * Check if the provided object is a Vector
	 * @param	value	The object to test
	 * @return	True if the provided object is a Vector
	 */
	public static function isVector(value:Object):Boolean
	{
		return flash.utils.getQualifiedClassName(value).substr(0, VECTOR_PREFIX.length) == VECTOR_PREFIX;
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
			return getClass(value, SYSTEM_DOMAIN) == Object;
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
		var name : String = Reflection.getQualifiedClassName(type);
		REGISTERED_METADATA_CLASSES[name] = type;
		REGISTERED_METADATA_NAMES[name] = Reflection.getUnqualifiedClassName(name);
	}
	
	/**
	 * Provide a list of classes that extend Metadata and reflected TypeInfo will parse any matching metadata into
	 * and instance of the strongly-typed class provided.
	 * @param	types	A vector of classes, each of which must be a subclass of Metadata
	 */
	public static function registerMetadataClasses(types:Vector.<Class>):void
	{
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
		return REGISTERED_METADATA_CLASSES[Reflection.getQualifiedClassName(instance)];
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
				for(var qualifiedName:String in REGISTERED_METADATA_CLASSES)
				{
					var unqualifiedName : String = REGISTERED_METADATA_NAMES[qualifiedName]
					//implementers of metadata should omit the "Metadata" suffix, it is added here
					if(	metadataInfo.name == unqualifiedName
						|| metadataInfo.name + "Metadata" == unqualifiedName )
					{
						var metadata:Metadata = new REGISTERED_METADATA_CLASSES[qualifiedName](metadataInfo);
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