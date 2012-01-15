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
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	1/14/2012 2:13 AM
 */
public class AmfSerializer implements ISerializer
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_serializeType : Boolean;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function AmfSerializer(serializeType:Boolean=true)
	{
		m_serializeType = serializeType;
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	/**
	 * If true, the object is serialized with its qualified type information. If false, it is serialized as a native Object
	 */
	public function get serializeType():Boolean { return m_serializeType; }
	public function set serializeType(value:Boolean):void
	{
		m_serializeType = value;
	}
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	/**
	 * @inheritDoc
	 */
	public function serialize(sourceObject:Object):Object
	{
		return AmfSerializer.serialize(sourceObject, m_serializeType);
	}
	
	/**
	 * @inheritDoc
	 */
	public function deserialize(serializedData:Object, type:Class=null, applicationDomain:ApplicationDomain = null):Object
	{
		var object : Object = AmfSerializer.deserialize(serializedData as String);
		if(type != null && !(object is type))
		{
			return ObjectUtils.createTypedObjectFromNativeObject(type, object, applicationDomain);
		}
		else
		{
			return object;
		}
	}
	
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	static public function serialize(sourceObject:Object, serializeType:Boolean=true, applicationDomain:ApplicationDomain = null):Object
	{
		var bytes : ByteArray = new ByteArray();
		bytes.objectEncoding = ObjectEncoding.AMF3;
		if(serializeType && !Reflection.isScalar(sourceObject))
		{
			var typeName : String = Reflection.getQualifiedClassName(sourceObject);
			if(typeName != "Object" && typeName != "Array")
			{
				var type : Class = Reflection.getClassByName(typeName, applicationDomain);
				registerClassAlias(typeName, type);
			}
		}
		bytes.writeObject(sourceObject);
		bytes.position = 0;
		return bytes;
	}
	
	static public function deserialize(sourceObject:Object):Object
	{
		if(sourceObject is ByteArray)
		{
			var bytes : ByteArray = sourceObject as ByteArray;
			bytes.position = 0;
			return bytes.readObject();
		}
		else
		{
			throw new ArgumentError("Cannot deserialize object, it is not of type ByteArray");
		}
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
}

}