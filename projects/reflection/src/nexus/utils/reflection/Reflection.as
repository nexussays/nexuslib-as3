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
import flash.errors.IllegalOperationError;
import flash.system.*;
import flash.utils.*;

import nexus.errors.ClassNotFoundError;
import nexus.nexuslib_internal;
import nexus.utils.Parse;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 */
public final class Reflection
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//TODO: Probably need to do some checking here to make sure this is the domain we want
	/**
	 * Reference this instead of <code>ApplicationDomain.currentDomain</code> as <code>ApplicationDomain.currentDomain</code> creates a new
	 * instance with each call.
	 */
	static public const SYSTEM_DOMAIN : ApplicationDomain = ApplicationDomain.currentDomain;
	
	//call flash.utils.getQualifiedClassName(Vector) instead of hardcoding the string just in case Adobe ever changes the class or package
	///__AS3__.vec::Vector
	static private const VECTOR_PREFIX:String = flash.utils.getQualifiedClassName(Vector);
	///__AS3__.vec::Vector.<*>
	static private const UNTYPEDVECTOR_CLASSNAME_QUALIFIED:String = flash.utils.getQualifiedClassName(Vector.<*>);
	///class typed as __AS3__.vec::Vector.<*>
	static private const UNTYPEDVECTOR_CLASS:Class = Class(Vector.<*>);
	
	///used in applicationDomainsAreEqual to check for equality
	static private const EQUALITYTEST_DOMAINMEMORY:ByteArray = new ByteArray();
	
	///cache all TypeInfo information so parsing in the describeType() call only happens once
	static private const CACHED_TYPEINFO:Dictionary = new Dictionary(true);
	///cache all namespaces by their URI
	static private const CACHED_NAMESPACES:Dictionary = new Dictionary();
	
	///ApplicationDomains can be registered so they don't always have to be provided to Reflection methods
	static private const REGISTERED_APPDOMAINS : Vector.<ApplicationDomain> = new Vector.<ApplicationDomain>();
	
	///store strongly-typed classes that represent metadata on members
	static internal const REGISTERED_METADATA_CLASSES:Dictionary = new Dictionary();
	static internal const REGISTERED_METADATA_NAMES:Dictionary = new Dictionary();
	
	//--------------------------------------
	//	CLASS VARIABLES
	//--------------------------------------
	
	/**
	 * Determines if the Reflection library should throw an error if it doesn't have access to the avmplus describeTypeJson interface or
	 * if it should use flash.utils.describeType in its place and accept any data errors that result.
	 */
	static nexuslib_internal var allowedTypeInfoCreators : int = nexuslib_internal::TYPEINFOCREATOR_NEW;// | nexuslib_internal::TYPEINFOCREATOR_OLD;
	static nexuslib_internal const TYPEINFOCREATOR_NEW : int = 1;
	static nexuslib_internal const TYPEINFOCREATOR_OLD : int = 2;
	
	static private var s_typeInfoCreator : ITypeInfoCreator;
	
	//--------------------------------------
	//	CLASS INITIAlIZER
	//--------------------------------------
	
	{
		CACHED_TYPEINFO[SYSTEM_DOMAIN] = new Dictionary();
		EQUALITYTEST_DOMAINMEMORY.length = ApplicationDomain.MIN_DOMAIN_MEMORY_LENGTH;
	}
	
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	/**
	 * Returns a Class of the given object instance or the provided object itself if it is already a Class.
	 * @param	object An object instance or Class
	 * @param	applicationDomain	The application domain in which to look for the class. ApplicationDomain.current is used if none is provided.
	 * @return	The class for the given object, or null if none can be found
	 * @throws	ClassNotFoundError	If the class cannot be found in the provided ApplicationDomain (or the system ApplicationDomain if none is provided)
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
	 * @throws	ClassNotFoundError	If the class cannot be found in the provided ApplicationDomain (or the system ApplicationDomain if none is provided)
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
		//looking up the class for an untyped vector currently does not work
		else if(qualifiedName == UNTYPEDVECTOR_CLASSNAME_QUALIFIED || qualifiedName == "Vector.<*>")
		{
			return UNTYPEDVECTOR_CLASS;
		}
		
		if(applicationDomain == null)
		{
			applicationDomain = getApplicationDomainOfClassName(qualifiedName);
		}
		else
		{
			//walk up parent app domains while the class is still defined to get the top-most reference
			while(applicationDomain.parentDomain != null && applicationDomain.parentDomain.hasDefinition(qualifiedName))
			{
				applicationDomain = applicationDomain.parentDomain;
			}
		}
		
		try
		{
			var result : Class = applicationDomain.getDefinition(qualifiedName) as Class;
			if(result == null)
			{
				throw new ClassNotFoundError(qualifiedName);
			}
			else
			{
				return result;
			}
		}
		catch(e:ReferenceError)
		{
			throw new ClassNotFoundError(qualifiedName);
		}
		return null;
	}
	
	/**
	 * Gets the super/parent class of the provided object, with the caveat that getSuperClass(Object) == null
	 * @param	object			The object whose super class you want to find
	 * @param	applicationDomain	The application domain in which to look. ApplicationDomain.current is used if none is provided.
	 * @return	The super class of the provided object or null if none can be found.
	 */
	public static function getSuperClass(object:Object, applicationDomain:ApplicationDomain = null):Class
	{
		if(object != null)
		{
			var superClassName:String = getQualifiedSuperclassName(object);
			//superClassName will be null when the provided object argument is a native Object
			if(superClassName != null)
			{
				return getClassByName(superClassName, applicationDomain);
			}
		}
		return null;
	}
	
	/**
	 * Finds the ApplicationDomain the given object blongs to. Any desired ApplicationDomains must be registered first with Reflection.registerApplicationDomain()
	 * @param	object	The object instance or Class to lookup
	 * @return	The ApplicationDomain of the provided Object
	 * @throws	Error	If the object is present in several ApplicationDomains
	 */
	static public function getApplicationDomain(object:Object):ApplicationDomain
	{
		return getApplicationDomainOfClassName(flash.utils.getQualifiedClassName(object));
	}
	
	/**
	 * Finds the ApplicationDomain the given Class name blongs to. Any desired ApplicationDomains must be registered first with Reflection.registerApplicationDomain()
	 * @param	qualifiedName	The class name to lookup
	 * @return	The ApplicationDomain of the provided Object
	 * @throws	Error	If the object is present in several ApplicationDomains
	 */
	static public function getApplicationDomainOfClassName(qualifiedName:String):ApplicationDomain
	{
		if(	qualifiedName == null || qualifiedName == "void" || qualifiedName == "undefined" || qualifiedName == "null"
			|| qualifiedName == "*" || qualifiedName == "Object" || qualifiedName == UNTYPEDVECTOR_CLASSNAME_QUALIFIED
			|| qualifiedName == "Vector.<*>")
		{
			return SYSTEM_DOMAIN;
		}
		
		var applicationDomain : ApplicationDomain;
		for each(var registeredAppDomain : ApplicationDomain in REGISTERED_APPDOMAINS)
		{
			if(registeredAppDomain.hasDefinition(qualifiedName))
			{
				//if an app domain with this definition was found, throw an error because we don't know which reference is desired
				if(applicationDomain != null)
				{
					throw new Error("The desired class \"" + qualifiedName + "\" is found in two different registered ApplicationDomains, an explicit ApplicationDomain must be provided in order to obtain a Class.");
				}
				applicationDomain = registeredAppDomain;
			}
		}
		return applicationDomain || SYSTEM_DOMAIN;
	}
	
	/**
	 * Return the object type of the provided vector. If the provided vector is untyped (<code>Vector.&lt;*&gt;</code>), Object is returned.
	 * If the object is not a vector, null is returned.
	 * @param	vector	The vector instance or Class for which to determine its type
	 * @param	applicationDomain	The application domain in which to look. ApplicationDomain.current is used if none is provided.
	 * @return	The type of the vector or Object if no type is present in the value provided
	 */
	public static function getVectorType(vector:Object, applicationDomain:ApplicationDomain = null):Class
	{
		var typeName:String = flash.utils.getQualifiedClassName(vector);
		
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
			catch(e:ClassNotFoundError)
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
	public static function areApplicationDomainsEqual(applicationDomainOne:ApplicationDomain, applicationDomainTwo:ApplicationDomain):Boolean
	{
		if(applicationDomainOne == null || applicationDomainTwo == null)
		{
			return false;
		}
		
		if(applicationDomainOne == applicationDomainTwo)
		{
			return true;
		}
		
		//Testing ApplicationDomains for equality is difficult since all methods that return ApplicationDomains return new instances
		//for more information, see: http://hg.mozilla.org/tamarin-redux/file/tip/shell/DomainClass.cpp
		
		//The approach in use here to assign a ByteArray to the domainMemory of both application domains and then compare the getters
		//to one another. We can't just compare the domainMemory getters to one another directly, because the by default, each application
		//domain has an instance to the same memory.
		
		//This will cause issues in Flash 11.2 after August 2012 due to new licensing restrictions Adobe is putting in place
		//see the announcement: http://blogs.adobe.com/flashplayer/2011/09/updates-from-the-lab.html
		//see license information: http://www.adobe.com/devnet/flashplayer/articles/premium-features.html
		
		var domainMemoryOne:ByteArray = applicationDomainOne.domainMemory;
		
		//assign a different ByteArray to domainMemory of the first app domain
		applicationDomainOne.domainMemory = EQUALITYTEST_DOMAINMEMORY;
		
		//see if the second app domain is pointing to the same reference
		var result:Boolean = applicationDomainOne.domainMemory == applicationDomainTwo.domainMemory;
		
		//restore the domain memory
		applicationDomainOne.domainMemory = domainMemoryOne;
		
		return result;
	}
	
	/**
	 * Registering an <code>ApplicationDomain</code> will result in it being checked for class references in any Reflection methods that take
	 * an ApplicationDomain as a parameter.
	 * @param	applicationDomain
	 */
	static public function registerApplicationDomain(applicationDomain:ApplicationDomain):void
	{
		if(applicationDomain != null)
		{
			for each(var appDomain : ApplicationDomain in REGISTERED_APPDOMAINS)
			{
				if(Reflection.areApplicationDomainsEqual(applicationDomain, appDomain))
				{
					return;
				}
			}
			REGISTERED_APPDOMAINS.push(applicationDomain);
		}
	}
	
	/**
	 * Reflects into the given object and returns a TypeInfo object
	 * @param	obj	The object to reflect
	 * @return	A TypeInfo that represents the given object's Class information
	 */
	public static function getTypeInfo(object:Object, applicationDomain:ApplicationDomain = null):TypeInfo
	{
		if(object == null)
		{
			return null;
		}
		
		//get the typeinfo creator
		if(s_typeInfoCreator == null)
		{
			use namespace nexuslib_internal;
			if(AVMDescribeType.isAvailable && (allowedTypeInfoCreators & TYPEINFOCREATOR_NEW) == TYPEINFOCREATOR_NEW)
			{
				s_typeInfoCreator = new TypeInfoCreatorJson();
			}
			else if((allowedTypeInfoCreators & TYPEINFOCREATOR_OLD) == TYPEINFOCREATOR_OLD)
			{
				s_typeInfoCreator = new TypeInfoCreatorXml();
			}
			else
			{
				throw new IllegalOperationError("Cannot get type information for object, Flash 10.1 or higher is required. If you believe this message is in error, please see the docs for Reflection.allowedTypeInfoCreators.");
			}
		}
		
		//get proper application domain instance to lookup in the dictionary
		if(applicationDomain == null)
		{
			applicationDomain = getApplicationDomain(object);
		}
		
		//ensure the application domain exists in the cache
		var appDomainExists : Boolean = false;
		for(var appDomainKey : Object in CACHED_TYPEINFO)
		{
			var cachedAppDomain : ApplicationDomain = appDomainKey as ApplicationDomain;
			if(Reflection.areApplicationDomainsEqual(cachedAppDomain, applicationDomain))
			{
				applicationDomain = cachedAppDomain;
				appDomainExists = true;
				break;
			}
		}
		
		if(!appDomainExists)
		{
			CACHED_TYPEINFO[applicationDomain] = new Dictionary();
		}
		
		var type:Class = getClass(object, applicationDomain);
		var reflectedType:TypeInfo = CACHED_TYPEINFO[applicationDomain][type];
		if(reflectedType == null)
		{
			//create and cache TypeInfo for the provided object if it is not present in the cache
			reflectedType = s_typeInfoCreator.create(object, type, applicationDomain);
			CACHED_TYPEINFO[applicationDomain][type] = reflectedType;
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
		catch(e:ClassNotFoundError)
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
		if(!classExtendsClass(type, MetadataInfo))
		{
			throw new ArgumentError("Cannot register metadata class \"" + type + "\", it does not extend " + MetadataInfo);
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
	static internal function getMetadataClass(instance:MetadataInfo):Class
	{
		return REGISTERED_METADATA_CLASSES[Reflection.getQualifiedClassName(instance)];
	}
	
	/**
	 * Retrieves the cached Namespace for the given namespace URI
	 * @param	namespaceUri
	 */
	static internal function getNamespace(namespaceUri:String):Namespace
	{
		var ns : Namespace;
		if(namespaceUri != null)
		{
			ns = CACHED_NAMESPACES[namespaceUri];
			if(ns == null)
			{
				ns = new Namespace(namespaceUri);
				CACHED_NAMESPACES[namespaceUri] = ns;
			}
		}
		return ns;
	}
	
	//--------------------------------------
	//	PRIVATE CLASS METHODS
	//--------------------------------------
}
}