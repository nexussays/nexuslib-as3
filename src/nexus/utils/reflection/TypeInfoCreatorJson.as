// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.utils.reflection
{

import avmplus.AVMDescribeType;
import flash.system.*;
import flash.utils.*;
import nexus.utils.serialization.json.JsonSerializer;

import nexus.errors.ClassNotFoundError;
import nexus.nexuslib_internal;
import nexus.utils.Parse;

/**
 * Creates a TypeInfo object using avmplus.describeTypeJSON
 * @private
 */
internal class TypeInfoCreatorJson implements ITypeInfoCreator
{
	//--------------------------------------
	//	PUBLIC STATIC METHODS
	//--------------------------------------
	
	public function create(type:Class, applicationDomain:ApplicationDomain):TypeInfo
	{
		var json : Object = AVMDescribeType.getJson(type);
		var x : int;
		
		var reflectedType:TypeInfo = new TypeInfo(json.factory.name, applicationDomain, type,
					json.methods.length + json.factory.methods.length,
					json.accessors.length + json.factory.accessors.length,
					json.variables.length + json.factory.variables.length);
		
		reflectedType.setIsDynamic(json.factory.isDynamic);
		reflectedType.setIsFinal(json.factory.isFinal);
		
		addMetadata(reflectedType, json.factory);
		
		//add constructor
		reflectedType.setConstructor(parseConstructorInfo(json.factory.constructor, reflectedType, applicationDomain));
		
		//add fields
		addMembers(parseFieldInfo, json.variables, reflectedType, applicationDomain, true);
		addMembers(parseFieldInfo, json.factory.variables, reflectedType, applicationDomain, false);
		
		//add methods
		addMembers(parseMethodInfo, json.methods, reflectedType, applicationDomain, true);
		addMembers(parseMethodInfo, json.factory.methods, reflectedType, applicationDomain, false);
		
		//add properties
		addMembers(parsePropertyInfo, json.accessors, reflectedType, applicationDomain, true);
		addMembers(parsePropertyInfo, json.factory.accessors, reflectedType, applicationDomain, false);
		
		for(x = 0; x < json.factory.bases.length; ++x)
		{
			reflectedType.extendedClasses.push(Reflection.getClassByName(json.factory.bases[x], applicationDomain));
		}
		
		for(x = 0; x < json.factory.interfaces.length; ++x)
		{
			reflectedType.implementedInterfaces.push(Reflection.getClassByName(json.factory.interfaces[x], applicationDomain));
		}
		
		json = null;
		
		return reflectedType;
	}
	
	//--------------------------------------
	//	PRIVATE CLASS METHODS
	//--------------------------------------
	
	private static function addMembers(method:Function, members:Array, typeInfo:TypeInfo, appDomain:ApplicationDomain, isStatic:Boolean):void
	{
		for each(var member:Object in members)
		{
			var memberInfo:AbstractMemberInfo = method(member, typeInfo, appDomain, isStatic);
			if(memberInfo != null)
			{
				addMetadata(memberInfo, member);
				memberInfo.assignNamespace(Reflection.getNamespace(member.uri));
				typeInfo.addMember(memberInfo);
			}
		}
	}
	
	static private function parsePropertyInfo(object:Object, typeInfo:TypeInfo, appDomain:ApplicationDomain, isStatic:Boolean):PropertyInfo
	{
		var property:PropertyInfo;
		var name:String = object.name;
		if(name == "prototype")
		{
			typeInfo.properties.fixed = false;
			typeInfo.properties.length--;
			typeInfo.properties.fixed = true;
		}
		else
		{
			var access:String = object.access;
			var canRead : Boolean = access == "readonly" || access == "readwrite";
			var canWrite : Boolean = access == "writeonly" || access == "readwrite";
			property = new PropertyInfo(name, isStatic, Reflection.getClassByName(object.type, appDomain), Reflection.getClassByName(object.declaredBy, appDomain),
				typeInfo, canRead, canWrite);
		}
		return property;
	}
	
	static private function parseFieldInfo(object:Object, typeInfo:TypeInfo, appDomain:ApplicationDomain, isStatic:Boolean):FieldInfo
	{
		//TODO: support adding "declaredBy" field. It will require recursing through all superclass TypeInfos looking for the first appearance
		return new FieldInfo(object.name, isStatic, Reflection.getClassByName(object.type, appDomain), null, typeInfo, object.access == "readwrite");
	}
	
	static private function parseMethodInfo(object:Object, typeInfo:TypeInfo, appDomain:ApplicationDomain, isStatic:Boolean):MethodInfo
	{
		var method:MethodInfo = new MethodInfo(object.name, isStatic, Reflection.getClassByName(object.returnType, appDomain), Reflection.getClassByName(object.declaredBy, appDomain), typeInfo, object.parameters.length);
		for(var x : int = 0; x < object.parameters.length; ++x)
		{
			var param:Object = object.parameters[x];
			method.addMethodParameter(new MethodParameterInfo(Reflection.getClassByName(param.type, appDomain), x, param.optional));
		}
		return method;
	}
	
	static private function parseConstructorInfo(params:Array, typeInfo:TypeInfo, appDomain:ApplicationDomain):MethodInfo
	{
		var method:MethodInfo = new MethodInfo("_ctor", true, null, typeInfo.type, typeInfo, params.length);
		for(var x : int = 0; x < params.length; ++x)
		{
			var param:Object = params[x];
			method.addMethodParameter(new MethodParameterInfo(Reflection.getClassByName(param.type, appDomain), x, param.optional));
		}
		return method;
	}
	
	static private function addMetadata(member:AbstractMetadataRecipient, sourceObject:Object):void
	{
		var metadataArray:Array = sourceObject.metadata;
		/*
		{
		   "name": "MetadataName",
		   "value": [
			  {"key":"param","value":"value"},
			  {"key":"param2","value":"value2"}
		   ]
		}
		//*/
		//add metadata
		for each(var metadataObject:Object in metadataArray)
		{
			var metadataName : String = metadataObject.name;
			//this is a default matadata tag added by the compiler in a debug build
			if(metadataName == "__go_to_definition_help")
			{
				member.setPosition(parseInt(metadataObject.value[0].value));
			}
			else if(metadataName == "__go_to_ctor_definition_help")
			{
				//just drop this
			}
			else
			{
				var metadata:MetadataInfo = null;
				var metadataDict : Dictionary = new Dictionary();
				for each(var keyValuePair:Object in metadataObject.value)
				{
					metadataDict[keyValuePair["key"]] = keyValuePair["value"];
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
}

}