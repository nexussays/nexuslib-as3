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
package nexus.utils.serialization.json
{

import nexus.errors.NotImplementedError;

import nexus.utils.reflection.*;
import nexus.utils.serialization.ISerializer;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	9/29/2011 2:13 AM
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
	
	public function serialize(sourceObject:Object, includeReadOnlyFields:Boolean = false):Object
	{
		return JsonSerializer.serialize(sourceObject, includeReadOnlyFields);
	}
	
	public function deserialize(serializedObject:Object, classType:Class = null):Object
	{
		return JsonSerializer.deserialize(serializedObject, classType);
	}
	
	public function fill(objectInstance:Object, data:Object):void 
	{
		
	}
	
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	static public function serialize(sourceObject:Object, includeReadOnlyFields:Boolean = false):String
	{
		return JSON.stringify(sourceObject, null);
	}
	
	static public function deserialize(json:Object, type:Class = null):Object
	{
		//if(!(serializedObject is String))
		//{
			//throw new ArgumentError("Cannot deserialize object of type \"" + Reflection.getQualifiedClassName(serializedObject) + "\", must be a String in JSON format");
		//}
		var object : Object = json is String ? JSON.parse(String(json)) : json;
		delete object.baz;
		return type == null ? object : parseObject(object, type);
	}
	
	static public function fill(objectInstance:Object, data:Object):void 
	{
		
	}
	
	//--------------------------------------
	//	PRIVATE CLASS METHODS
	//--------------------------------------
	
	static private function parseObject(data:Object, desiredType:Class):Object
	{
		//TODO: consider adding error checking if the data and desired type do not match
		if(Reflection.isPrimitive(desiredType))
		{
			return data;
		}
		else if(Reflection.isArray(desiredType))
		{
			var array : Object = new desiredType();//Reflection.getClass(data)();
			for(var x : int = 0; x < data.length; ++x)
			{
				var value : Object = parseObject(data[x], Reflection.getVectorClass(desiredType));
				array[x] = value;
			}
			return array;
		}
		else
		{
			var result : Object = new desiredType();
			var typeInfo : TypeInfo = Reflection.getTypeInfo(desiredType);
			if(typeInfo.implementedInterfaces.indexOf(IJsonDeserializable) != -1)
			{
				return IJsonDeserializable(result).createFromJson(data);
			}
			else
			{
				for each(var member : AbstractMemberInfo in typeInfo.allMembers)
				{
					if(	(member is PropertyInfo && PropertyInfo(member).canWrite)
						|| (member is FieldInfo && !FieldInfo(member).isConstant) )
					{
						result[member.name] = parseObject(data[member.name], AbstractFieldInfo(member).type);
					}
				}
				return result;
			}
		}
	}
}

}