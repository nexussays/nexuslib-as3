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

import dna.Debug;
import dna.errors.NotImplementedError;
import dna.utils.reflection.AbstractMemberInfo;
import dna.utils.reflection.FieldInfo;
import dna.utils.reflection.PropertyInfo;
import dna.utils.reflection.Reflection;
import dna.utils.reflection.TypeInfo;

/**
 * ...
 * @author	Malachi Griffie <malachi@nexussays.com>
 * @since	9/7/2011 4:39 AM
 */
public class JsonSerializer implements ISerializer
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function JsonSerializer()
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
		return JsonSerializer.serialize(sourceObject, includeReadOnlyProperties);
	}
	
	public function deserialize(serializedObject:Object, classType:Class = null):Object
	{
		return JsonSerializer.deserialize(serializedObject, classType);
	}
	
	public function toString(verbose:Boolean = false):String
	{
		return "[JsonSerializer]";
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
		
		var result:Object = { "type": Reflection.getQualifiedClassName(sourceObject), "data": { }};
		var typeInfo : TypeInfo = Reflection.getTypeInfo(sourceObject);
		//var members : Vector.<AbstractMemberInfo> = typeInfo.fields.concat(typeInfo.properties);
		//for each(var member : AbstractMemberInfo in typeInfo.fields)
		//{
			//if( includeReadOnlyProperties || ((member is FieldInfo && !FieldInfo(member).isConstant) || (member is PropertyInfo && PropertyInfo(member).canWrite)) )
			//{
				//result.data[member.name] = Reflection.isPrimitive(member.type) ? sourceObject[member.name] : serialize(sourceObject[member.name], includeReadOnlyProperties);
			//}
		//}
		for each(var field : FieldInfo in typeInfo.fields)
		{
			if(includeReadOnlyProperties || !field.isConstant)
			{
				result.data[field.name] = Reflection.isPrimitive(field.type) ? sourceObject[field.name] : serialize(sourceObject[field.name], includeReadOnlyProperties);
			}
		}
		for each(var property : PropertyInfo in typeInfo.properties)
		{
			if(property.canRead && (includeReadOnlyProperties || property.canWrite))
			{
				result.data[property.name] = Reflection.isPrimitive(property.type) ? sourceObject[property.name] : serialize(sourceObject[property.name], includeReadOnlyProperties);
			}
		}
		return result;
	}
	
	/**
	 * Deserializes the provided native object into an instance of a typed class, either specified in the object or provided as an argument.
	 * @param	serializedObject	The native object from which to create a typed object instance
	 * @param	classType			The type of object to create. If null, the Class type is derived from the "type" value of the serializedObject
	 * @return
	 */
	static public function deserialize(serializedObject:Object, classType:Class = null):Object
	{
		if(serializedObject == null)
		{
			return null;
		}
		
		//check to see if object is in the same format as this deserializes to or if we have the data only
		var dataOnly:Boolean = false;
		for(var key:String in serializedObject)
		{
			if(key != "data" && key != "type")
			{
				dataOnly = true;
			}
		}
		
		var data:Object = dataOnly ? serializedObject : serializedObject.data;
		
		var type:Class = classType;
		if(type == null)
		{
			//check to see if the format provides the type or not
			if(!dataOnly && "type" in serializedObject)
			{
				type = Reflection.getClass(serializedObject.type);
			}
			else
			{
				throw new Error("Cannot deserialize object, no type is provided and none could be derived.");
			}
		}
		
		var typeInfo:TypeInfo = Reflection.getTypeInfo(type);
		var instance:Object = new type();
		for(key in data)
		{
			
		}
		return instance;
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
	private final function trace(... params):void
	{
		Debug.debug(JsonSerializer, params);
	}
}

}