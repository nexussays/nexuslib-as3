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
package dna.utils.serialization
{

import dna.errors.NotImplementedError;
import dna.utils.reflection.*;

/**
 * Serialize a strongly-typed object into a native object
 * @author	Malachi Griffie <malachi@nexussays.com>
 * @since	9/7/2011 4:39 AM
 */
public class ObjectSerializer implements ISerializer
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	public static const TYPE_KEY : String = ".type";
	public static const DATA_KEY : String = ".data";
	
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
	
	public function serialize(sourceObject:Object, includeReadOnlyProperties:Boolean = false):Object
	{
		return ObjectSerializer.serialize(sourceObject, includeReadOnlyProperties);
	}
	
	public function deserialize(serializedObject:Object, classType:Class = null):Object
	{
		return ObjectSerializer.deserialize(serializedObject, classType);
	}
	
	public function toString(verbose:Boolean = false):String
	{
		return "[ObjectSerializer]";
	}
	
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	/**
	 * Creates a native object representing the provided typed-object instance. Only public properties are included, and Dates
	 * are converted to number of milliseconds since Jan 1, 1970 UTC
	 * @param	sourceObject	The typed object to convert to a native object
	 * @param	includeReadOnlyProperties	By default, read-only properties are not serialized you can override that here
	 * @return	A native object representing the provided object instance
	 */
	static public function serialize(sourceObject:Object, includeReadOnlyProperties:Boolean = false):Object
	{
		if(sourceObject == null)
		{
			return null;
		}
		
		var data : Object = { };
		var typeInfo : TypeInfo = Reflection.getTypeInfo(sourceObject);
		
		//write out fields
		for each(var field : FieldInfo in typeInfo.fields)
		{
			if(includeReadOnlyProperties || !field.isConstant)
			{
				data[field.name] = Reflection.isPrimitive(field.type) ? sourceObject[field.name] : serialize(sourceObject[field.name], includeReadOnlyProperties);
			}
		}
		
		//write out properties
		for each(var property : PropertyInfo in typeInfo.properties)
		{
			if(property.canRead && (includeReadOnlyProperties || property.canWrite))
			{
				data[property.name] = Reflection.isPrimitive(property.type) ? sourceObject[property.name] : serialize(sourceObject[property.name], includeReadOnlyProperties);
			}
		}
		
		var result : Object = { };
		result[TYPE_KEY] = Reflection.getQualifiedClassName(sourceObject);
		result[DATA_KEY] = data;
		return result;
	}
	
	/**
	 * Deserializes the provided native object into an instance of a typed class, either specified in the object or provided as an argument.
	 * @param	serializedObject	The native object from which to create a typed object instance
	 * @param	classType			The type of object to create. If null, the Class type is derived from the type value of the serializedObject
	 * @return
	 */
	static public function deserialize(serializedObject:Object, classType:Class = null):Object
	{
		if(serializedObject == null)
		{
			return null;
		}
		
		//check to see if object is in the same format that as this deserializes to or if we have the data only
		var dataOnly:Boolean = false;
		for(var key:String in serializedObject)
		{
			if(key != DATA_KEY && key != TYPE_KEY)
			{
				dataOnly = true;
			}
		}
		
		var data:Object = dataOnly ? serializedObject : serializedObject.data;
		
		var type:Class = classType;
		if(type == null)
		{
			//check to see if the format provides the type or not
			if(!dataOnly && TYPE_KEY in serializedObject)
			{
				type = Reflection.getClass(serializedObject.type);
			}
			else
			{
				throw new Error("Cannot deserialize object, no type is provided and none could be derived from the object on key \"" + TYPE_KEY + "\".");
			}
		}
		
		var typeInfo:TypeInfo = Reflection.getTypeInfo(type);
		var instance:Object = new type();
		for(key in data)
		{
			var member : AbstractMemberInfo = typeInfo.getMemberByName(key);
			if(member != null && member is AbstractFieldInfo)
			{
				if(Reflection.isPrimitive(AbstractFieldInfo(member).type))
				{
					instance[member.name] = data[key];
				}
				else
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