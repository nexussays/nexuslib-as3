// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.utils.reflection
{

import flash.system.*;
import flash.utils.*;

import nexus.errors.ClassNotFoundError;
import nexus.nexuslib_internal;
import nexus.utils.Parse;

/**
 * Creates a TypeInfo object using flash.utils.describeType
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 */
internal class TypeInfoCreatorXml implements ITypeInfoCreator
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	CLASS VARIABLES
	//--------------------------------------
	
	//--------------------------------------
	//	PUBLIC STATIC METHODS
	//--------------------------------------
	
	public function create(object:Object, type:Class, applicationDomain:ApplicationDomain):TypeInfo
	{
		var xml:XML = describeType(type);
		
		var reflectedType:TypeInfo = new TypeInfo(xml.@name, applicationDomain, type,
			xml.method.length() + xml.factory.method.length(),
			xml.accessor.length() + xml.factory.accessor.length(),
			xml.variable.length() + xml.constant.length() + xml.factory.variable.length() + xml.factory.constant.length());
			
		if(xml.factory[0] != null)
		{
			addMetadata(reflectedType, xml.factory[0]);
		}
		
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
			reflectedType.extendedClasses.push(Reflection.getClassByName(extendedClassXml.@type, applicationDomain));
		}
		//trace(reflectedType.extendedClasses);
		
		for each(var implementedInterfacesXml:XML in xml.factory.implementsInterface)
		{
			reflectedType.implementedInterfaces.push(Reflection.getClassByName(implementedInterfacesXml.@type, applicationDomain));
		}
		//trace(reflectedType.implementedInterfaces);
		
		//isDynamic info is incorrect if doing a describeType of a Class instead of an instance
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
		
		
		
		if("disposeXML" in System)
		{
			System["disposeXML"](xml);
		}
		xml = null;
		
		return reflectedType;
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
				member.assignNamespace(Reflection.getNamespace(xmlItem.@uri));
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
				var metadata:MetadataInfo = null;
				var metadataName : String = metadataXml.@name;
				var metadataDict : Dictionary = new Dictionary();
				for each(var argXml:XML in metadataXml.arg)
				{
					metadataDict[String(argXml.@key)] = String(argXml.@value);
				}
				
				//see if there is a registered strongly-typed class for this metadata
				for(var qualifiedName:String in Reflection.REGISTERED_METADATA_CLASSES)
				{
					var unqualifiedName : String = Reflection.REGISTERED_METADATA_NAMES[qualifiedName];
					//implementers of metadata should omit the "Metadata" suffix, it is added here
					if(metadataName == unqualifiedName || metadataName + "Metadata" == unqualifiedName)
					{
						metadata = new Reflection.REGISTERED_METADATA_CLASSES[qualifiedName](metadataName, metadataDict);
						break;
					}
				}
				
				//if no special metadatainfo exists, use the default class
				if(metadata == null)
				{
					metadata = new MetadataInfo(metadataName, metadataDict);
				}
				
				member.addMetadata(metadata);
			}
		}
	}
	
	static private function parseFieldInfo(xmlItem:XML, typeInfo:TypeInfo, appDomain:ApplicationDomain, isStatic:Boolean, isConstant:Boolean):FieldInfo
	{
		//TODO: add declaring type info. it will require recursing through all superclass typeinfos
		return new FieldInfo(xmlItem.@name, isStatic, Reflection.getClassByName(xmlItem.@type, appDomain), null, typeInfo, !isConstant);
	}
	
	static private function parseMethodInfo(xmlItem:XML, typeInfo:TypeInfo, appDomain:ApplicationDomain, isStatic:Boolean, isConstant:Boolean):MethodInfo
	{
		var method:MethodInfo = new MethodInfo(xmlItem.@name, isStatic, Reflection.getClassByName(xmlItem.@returnType, appDomain), Reflection.getClassByName(xmlItem.@declaredBy, appDomain), typeInfo, xmlItem.parameter.length());
		for each(var paramXml:XML in xmlItem.parameter)
		{
			method.addMethodParameter(new MethodParameterInfo(Reflection.getClassByName(paramXml.@type, appDomain), Parse.integer(paramXml.@index, 1) - 1, Parse.boolean(paramXml.@optional, false)));
		}
		return method;
	}
	
	static private function parseConstructorInfo(xmlItem:XML, typeInfo:TypeInfo, appDomain:ApplicationDomain, isStatic:Boolean, isConstant:Boolean):MethodInfo
	{
		var method:MethodInfo;
		if(xmlItem != null)
		{
			method = new MethodInfo("_ctor", isStatic, null, typeInfo.type, typeInfo, xmlItem.parameter.length());
			for each(var paramXml:XML in xmlItem.parameter)
			{
				method.addMethodParameter(new MethodParameterInfo(Reflection.getClassByName(paramXml.@type, appDomain), Parse.integer(paramXml.@index, 1) - 1, Parse.boolean(paramXml.@optional, false)));
			}
		}
		else
		{
			method = new MethodInfo("_ctor", isStatic, null, typeInfo.type, typeInfo, 0);
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
			property = new PropertyInfo(name, isStatic, Reflection.getClassByName(xmlItem.@type, appDomain), Reflection.getClassByName(xmlItem.@declaredBy, appDomain), typeInfo, access == "readonly" || access == "readwrite", access == "writeonly" || access == "readwrite");
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