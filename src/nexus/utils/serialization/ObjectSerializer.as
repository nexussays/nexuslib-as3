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
package nexus.utils.serialization
{

import nexus.errors.NotImplementedError;
import nexus.utils.reflection.*;

/**
 * Serialize a strongly-typed object into a native object
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	9/7/2011 4:39 AM
 */
public class ObjectSerializer implements ISerializer
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	public static const TYPE_KEY:String = ".type";
	public static const DATA_KEY:String = ".data";
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function ObjectSerializer()
	{
	
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	public function serialize(sourceObject:Object, includeReadOnlyFields:Boolean = false):Object
	{
		return ObjectSerializer.serialize(sourceObject, includeReadOnlyFields);
	}
	
	public function deserialize(serializedData:Object, type:Class = null):Object
	{
		return ObjectSerializer.deserialize(serializedData, type);
	}
	
	public function fill(objectInstance:Object, data:Object):void 
	{
		
	}
	
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	/**
	 * Creates a native object representing the provided typed-object instance. Only public properties are included, and Dates
	 * are converted to number of milliseconds since Jan 1, 1970 UTC
	 * @param	sourceObject	The typed object to convert to a native object
	 * @param	includeReadOnlyFields	By default, read-only properties are not serialized you can override that here
	 * @return	A native object representing the provided object instance
	 */
	static public function serialize(sourceObject:Object, includeReadOnlyFields:Boolean = false):Object
	{
		if(sourceObject == null || Reflection.isPrimitive(sourceObject))
		{
			return sourceObject;
		}
		
		var data:Object = {};
		var typeInfo:TypeInfo = Reflection.getTypeInfo(sourceObject);
		
		//if the object is a map, iterate over the values of the object
		if(Reflection.isAssociativeArray(typeInfo.type))
		{
			for(var key:Object in sourceObject)
			{
				data[key] = serialize(sourceObject[key], includeReadOnlyFields);
			}
		}
		//if the object is an array-type, iterate over the values of the object
		else if(Reflection.isArray(typeInfo.type))
		{
			data = [];
			for(var x : int = 0; x < sourceObject.length; ++x)
			{
				if(x in sourceObject)
				{
					data[x] = serialize(sourceObject[x], includeReadOnlyFields);
				}
			}
		}
		//otherwise iterate over the values of the reflected type of the object
		else
		{
			//write out fields
			for each(var field:FieldInfo in typeInfo.fields)
			{
				if(includeReadOnlyFields || !field.isConstant)
				{
					data[field.name] = serialize(sourceObject[field.name], includeReadOnlyFields);
				}
			}
			
			//write out properties
			for each(var property:PropertyInfo in typeInfo.properties)
			{
				if(property.canRead && (includeReadOnlyFields || property.canWrite))
				{
					data[property.name] = serialize(sourceObject[property.name], includeReadOnlyFields);
				}
			}
		}
		
		var result:Object = {};
		result[TYPE_KEY] = Reflection.getQualifiedClassName(sourceObject);
		result[DATA_KEY] = data;
		return result;
	}
	
	/**
	 * Deserializes the provided native object into an instance of a typed class, either specified in the object or provided as an argument.
	 * @param	serializedData	The native object from which to create a typed object instance
	 * @param	type			The type of object to create. If null, the Class type is derived from the type value of the serializedData
	 * @return
	 */
	static public function deserialize(serializedData:Object, type:Class = null, forceType:Boolean=true):Object
	{
		if(serializedData == null || Reflection.isPrimitive(serializedData))
		{
			return serializedData;
		}
		
		//check to see if object is in the same format that as this deserializes to or if we have the data only
		var dataOnly:Boolean = false;
		for(var key:String in serializedData)
		{
			if(key != DATA_KEY && key != TYPE_KEY)
			{
				dataOnly = true;
			}
		}
		
		var data:Object = dataOnly ? serializedData : serializedData[DATA_KEY];
		if(data == null || Reflection.isPrimitive(data))
		{
			return data;
		}
		
		var dataType : Class = (!dataOnly && TYPE_KEY in serializedData ? Reflection.getClass(serializedData[TYPE_KEY]) : null);
		
		//check to see if the format provides the type or not
		//if forceType and a class it provided, use it, otherwise check the object first and override the provided type if one exists
		var type:Class = forceType ? (type || dataType) : (dataType || type);
		if(type == null)
		{
			throw new Error("Cannot deserialize object, no type is provided and none could be derived from the object (\"" + TYPE_KEY + "\":\"" + serializedData[TYPE_KEY] + "\").");
		}
		
		var typeInfo:TypeInfo = Reflection.getTypeInfo(type);
		var instance:Object = new type();
		if(Reflection.isArray(typeInfo.type))
		{
			for(var x : int = 0; x < data.length; ++x)
			{
				if(x in data)
				{
					instance[x] = deserialize(data[x], Object, false);
				}
			}
		}
		else if(Reflection.isAssociativeArray(typeInfo.type))
		{
			for(key in data)
			{
				instance[key] = deserialize(data[key], Object, false);
			}
		}
		else
		{
			for(key in data)
			{
				var member:AbstractFieldInfo = typeInfo.getMemberByName(key) as AbstractFieldInfo;
				if(member != null && ( (member is PropertyInfo && PropertyInfo(member).canWrite) || (member is FieldInfo && !FieldInfo(member).isConstant) ))
				{
					instance[member.name] = deserialize(data[key], AbstractFieldInfo(member).type);
				}
			}
		}
		return instance;
	}

	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
}

}