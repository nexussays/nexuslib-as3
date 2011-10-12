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
	
	private var m_space : Object;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function JsonSerializer()
	{
		
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	/**
	 * Entries in generated JSON objects and JSON arrays are separated by a gap derived from the space value.
	 * This gap is always 0 to 10 characters wide. If space is longer than 10 characters only the first 10
	 * characters of the string are used.
	 */
	public function get space():Object { return m_space; }
	public function set space(value:Object):void 
	{
		m_space = value;
	}
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	/**
	 * @inheritDoc
	 */
	public function serialize(sourceObject:Object, includeReadOnlyFields:Boolean = false):Object
	{
		return JsonSerializer.serialize(sourceObject, m_space, includeReadOnlyFields);
	}
	
	public function deserialize(serializedData:Object, type:Class = null):Object
	{
		return JsonSerializer.deserialize(serializedData, type);
	}
	
	public function fill(objectInstance:Object, data:Object):void 
	{
		
	}
	
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	/**
	 * Serializes the given object into a JSON string
	 * @param	sourceObject
	 * @param	space
	 * @param	includeReadOnlyFields
	 * @return
	 */
	static public function serialize(sourceObject:Object, space:Object = null, includeReadOnlyFields:Boolean = false):String
	{
		return JSON.stringify(sourceObject, null, space);
	}
	
	static public function deserialize(json:Object, type:Class = null):Object
	{
		//if(!(serializedData is String))
		//{
			//throw new ArgumentError("Cannot deserialize object of type \"" + Reflection.getQualifiedClassName(serializedData) + "\", must be a String in JSON format");
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
	
	static private function parseObject(data:*, desiredType:Class):Object
	{
		var result : Object;
		
		//TODO: consider adding error checking if the data and desired type do not match
		if(data == null)
		{
			result = null;
		}
		else if(Reflection.isPrimitive(desiredType))
		{
			result = data;
		}
		else if(Reflection.isArray(desiredType))
		{
			result = new desiredType();//Reflection.getClass(data)();
			for(var x : int = 0; x < data.length; ++x)
			{
				if(x in data && data[x] !== undefined)
				{
					result[x] = parseObject(data[x], Reflection.getVectorClass(desiredType));
				}
			}
		}
		else
		{
			try
			{
				result = new desiredType();
			}
			catch(e:ArgumentError)
			{
				//ctor takes arguments
			}
			
			if(result != null)
			{
				var typeInfo : TypeInfo = Reflection.getTypeInfo(desiredType);
				if(typeInfo.implementedInterfaces.indexOf(IJsonDeserializable) != -1)
				{
					return IJsonDeserializable(result).createFromJson(data);
				}
				else
				{
					for each(var member : AbstractMemberInfo in typeInfo.allMembers)
					{
						if(	((member is PropertyInfo && PropertyInfo(member).canWrite)
							|| (member is FieldInfo && !FieldInfo(member).isConstant))
							//ensure the field exists in the data
							&& member.name in data && data[member.name] !== undefined)
						{
							var resultValue : Object = parseObject(data[member.name], AbstractFieldInfo(member).type);
							try
							{
								result[member.name] = resultValue;
							}
							catch(e:Error)
							{
								//TODO: is a catch-all here ok?
							}
						}
					}
				}
			}
		}
		return result;
	}
}

}