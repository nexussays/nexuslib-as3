// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.utils.serialization.amf
{

import flash.net.ObjectEncoding;
import flash.net.registerClassAlias;
import flash.system.ApplicationDomain;
import flash.utils.*;

import nexus.utils.ObjectUtils;
import nexus.utils.reflection.Reflection;
import nexus.utils.serialization.ISerializer;

/**
 * ...
 * 
 */
public class AmfSerializer implements ISerializer
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_isTypeSerialized : Boolean;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function AmfSerializer(serializeType:Boolean=true)
	{
		m_isTypeSerialized = serializeType;
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	/**
	 * If true, the object is serialized with its qualified type information. If false, it is serialized as a native Object
	 */
	public function get isTypeSerialized():Boolean { return m_isTypeSerialized; }
	public function set isTypeSerialized(value:Boolean):void
	{
		m_isTypeSerialized = value;
	}
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	/**
	 * @inheritDoc
	 */
	public function serialize(sourceObject:Object, applicationDomain:ApplicationDomain = null):Object
	{
		return AmfSerializer.serialize(sourceObject, m_isTypeSerialized);
	}
	
	/**
	 * @inheritDoc
	 */
	public function deserialize(serializedData:Object, type:Class=null, applicationDomain:ApplicationDomain = null):Object
	{
		return AmfSerializer.deserialize(serializedData, type, applicationDomain);
	}
	
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	static public function serialize(sourceObject:Object, typeIsSerialized:Boolean=true, applicationDomain:ApplicationDomain = null):Object
	{
		if(typeIsSerialized)
		{
			registerType(sourceObject);
		}
		
		var bytes : ByteArray = new ByteArray();
		bytes.objectEncoding = ObjectEncoding.AMF3;
		bytes.writeObject(sourceObject);
		bytes.position = 0;
		return bytes;
	}
	
	static public function deserialize(serializedData:Object, type:Class=null, applicationDomain:ApplicationDomain = null):Object
	{
		if(serializedData is ByteArray)
		{
			var bytes : ByteArray = serializedData as ByteArray;
			bytes.position = 0;
			var object : Object = bytes.readObject();
			if(type != null && !(object is type))
			{
				//object is not of the correct type, try to register it and read it out again
				registerType(type, applicationDomain);
				bytes.position = 0;
				object = bytes.readObject();
				//still no? then parse it ourselves
				if(!(object is type))
				{
					return ObjectUtils.createTypedObjectFromNativeObject(type, object, applicationDomain);
				}
			}
			return object;
		}
		else
		{
			throw new ArgumentError("Cannot deserialize object, it is not of type ByteArray");
		}
	}
	
	//--------------------------------------
	//	PRIVATE CLASS METHODS
	//--------------------------------------
	
	static private function registerType(sourceObject:Object, applicationDomain:ApplicationDomain = null):void
	{
		if(!Reflection.isScalar(sourceObject))
		{
			var typeName : String = Reflection.getQualifiedClassName(sourceObject);
			if(typeName != "Object" && typeName != "Array")
			{
				var type : Class = Reflection.getClassByName(typeName, applicationDomain);
				registerClassAlias(typeName, type);
			}
		}
	}
}

}