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

import flash.utils.Dictionary;

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
	//	SPECIAL
	//--------------------------------------
	
	/**
	 * Override the toJSON method for Date to return the milliseconds since epoch
	 */
	Date.prototype.toJSON = function(_:String):*
	{
		return this.getTime();
	}
	
	/**
	 * Override the toJSON method for Dictionary to return the contents as a native Object
	 */
	/*
	Dictionary.prototype.toJSON = function(_:String):*
	{
		var result : Object = { };
		for(var key : Object in this)
		{
			result[key] = this[key];
		}
		return result;
	}
	//*/
	
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	CLASS VARIABLES
	//--------------------------------------
	
	static private var s_indentationLevel : int;
	static private var s_spaceCharacters : String;
	static private var s_maxLineLength : int;
	static private var s_includeReadOnly : Boolean;
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_indentationCharacters:String;
	private var m_maxLineLength:int;
	private var m_includeReadOnlyFields:Boolean;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function JsonSerializer(indentationCharacters:String = "", lineLength:int = int.MAX_VALUE)
	{
		m_indentationCharacters = indentationCharacters;
		m_maxLineLength = lineLength;
		m_includeReadOnlyFields = false;
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	/**
	 * Entries in generated JSON objects and JSON arrays are separated by a gap derived from the space value.
	 * This gap is always 0 to 10 characters wide. If space is longer than 10 characters only the first 10
	 * characters of the string are used.
	 */
	public function get indentationCharacters():String { return m_indentationCharacters; }
	public function set indentationCharacters(value:String):void
	{
		m_indentationCharacters = value;
	}
	
	public function get includeReadOnlyFields():Boolean { return m_includeReadOnlyFields; }
	public function set includeReadOnlyFields(value:Boolean):void
	{
		m_includeReadOnlyFields = value;
	}
	
	/**
	 * The maximum allowed length of a single line of the JSON string before the JSON data is wrapped appropriately.
	 */
	public function get maxLineLength():int { return m_maxLineLength; }
	public function set maxLineLength(value:int):void
	{
		m_maxLineLength = value;
	}
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	/**
	 * @inheritDoc
	 */
	public function serialize(sourceObject:Object):Object
	{
		return JsonSerializer.serialize(sourceObject, m_indentationCharacters, m_maxLineLength, m_includeReadOnlyFields);
	}
	
	public function deserialize(serializedData:Object):Object
	{
		return JsonSerializer.deserialize(serializedData as String);
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
	static public function serialize(sourceObject:Object, space:String = "", maxLineLength:int = int.MAX_VALUE, includeReadOnlyFields:Boolean = false):String
	{
		s_indentationLevel = 0;
		s_spaceCharacters = space || "";
		s_maxLineLength = maxLineLength;
		s_includeReadOnly = includeReadOnlyFields;
		return serializeObject(sourceObject) + "";
	}
	
	static public function deserialize(json:String):Object
	{
		try
		{
			return JSON.parse(json);
		}
		catch(e:SyntaxError)
		{
			throw new SyntaxError("Error parsing object, invalid JSON input.");
		}
		return null;
	}
	
	//--------------------------------------
	//	PRIVATE CLASS METHODS
	//--------------------------------------
	
	static private function serializeObject(sourceObject:Object):String
	{
		var result:String;
		
		if(sourceObject == null)
		{
			result = "null";
		}
		else if(Reflection.isPrimitive(sourceObject) || sourceObject is Date)
		{
			result = JSON.stringify(sourceObject);
		}
		//else if(sourceObject is RegExp)
		//{
			//return JSON.stringify( {
				//"pattern":RegExp(sourceObject).source,
				//"options": RegExp(sourceObject).dotall ? "s" : ""
					//+ RegExp(sourceObject).global ? "g" : ""
					//+ RegExp(sourceObject).ignoreCase ? "i" : ""
					//+ RegExp(sourceObject).multiline ? "m" : ""
				//} );
		//}
		else if(Reflection.isArray(sourceObject))
		{
			//if a max line length has been set, use the native encoder to very quickly roughly determine the string length
			//of the current object and then use that to determine if we need to run the pretty formatter or not
			result = arrayToString(sourceObject, (s_maxLineLength < int.MAX_VALUE && JSON.stringify(sourceObject).length > s_maxLineLength));
		}
		else
		{
			//if a max line length has been set, use the native encoder to very quickly roughly determine the string length
			//of the current object and then use that to determine if we need to run the pretty formatter or not
			result = objectToString(sourceObject, (s_maxLineLength < int.MAX_VALUE && JSON.stringify(sourceObject).length > s_maxLineLength));
		}
		return result;
	}
	
	static private function arrayToString(array:Object, pretty:Boolean):String
	{
		//create a string to store the array's jsonstring value
		var result:String = "";
		
		s_indentationLevel++;
		
		for(var x:int = 0; x < array.length; x++)
		{
			if(result.length > 0)
			{
				result += pretty ? ",\n" : ",";
			}
			result += pretty ? getSpacingForIndentationLevel() : "";
			result += serializeObject(array[x]);
		}
		
		//close the array and return it's string value
		s_indentationLevel--;
		
		return pretty
			? "[" + "\n" + result + "\n" + getSpacingForIndentationLevel() + "]"
			: "[" + result + "]";
	}
	
	static private function objectToString(obj:Object, pretty:Boolean):String
	{
		var result:String = "";
		
		s_indentationLevel++;
		
		//iterate over the keys in a native object, use reflection if it is typed
		if(Reflection.isAssociativeArray(obj))
		{
			var key : String;
			//don't check if(pretty) here because we want to sort on case if the entire serialize call is pretty printed
			//even if this specific object we are recursing over is not
			if(s_maxLineLength < int.MAX_VALUE)
			{
				var keys : Array = [];
				for(key in obj)
				{
					keys.push(key);
				}
				keys.sort(Array.CASEINSENSITIVE);
				
				for(var x : int = 0; x < keys.length; ++x)
				{
					key = keys[x];
					result += setupObjectString(result, key, obj[key], pretty);
				}
			}
			else
			{
				for(key in obj)
				{
					result += setupObjectString(result, key, obj[key], pretty);
				}
			}
		}
		else
		{
			//Loop over all of the variables and accessors in the class and
			//serialize them along with their values.
			var typeInfo : TypeInfo = Reflection.getTypeInfo(obj);
			var memberNames : Vector.<AbstractMemberInfo> = s_maxLineLength < int.MAX_VALUE ? typeInfo.allMembersByName : typeInfo.allMembers;
			for each(var field : AbstractMemberInfo in memberNames)
			{
				if(	field is AbstractFieldInfo
					&& !AbstractFieldInfo(field).isStatic
					&& AbstractFieldInfo(field).canRead
					&& (s_includeReadOnly || AbstractFieldInfo(field).canWrite)
					&& field.getMetadataByName("Transient") == null)
				{
					result += setupObjectString(result, field.name, obj[field.name], pretty);
				}
			}
		}
		
		s_indentationLevel--;
		
		return pretty
			? "{" + "\n" + result + "\n" + getSpacingForIndentationLevel() + "}"
			: "{" + result + "}";
	}
	
	static private function setupObjectString(current:String, key:String, value:Object, pretty:Boolean):String
	{
		var result : String = "";
		if(!(value is Function))
		{
			if(current.length > 0)
			{
				result += pretty ? ",\n" : ",";
			}
			result += pretty ? getSpacingForIndentationLevel() : "";
			result += JSON.stringify(key);
			result += pretty ? ": " : ":";
			result += serializeObject(value);
		}
		return result;
	}
	
	static private function deserializeObject(data:*, desiredType:Class):Object
	{
		var result:Object;
		
		//TODO: consider adding error checking if the data and desired type do not match
		if(data == null)
		{
			result = null;
		}
		else if(Reflection.isPrimitive(desiredType))
		{
			result = data;
		}
		else if(desiredType == Date)
		{
			result = new Date(data);
		}
		else if(Reflection.isArray(desiredType))
		{
			result = new desiredType();
			for(var x:int = 0; x < data.length; ++x)
			{
				if(x in data && data[x] !== undefined)
				{
					result[x] = deserializeObject(data[x], Reflection.getVectorClass(desiredType));
				}
			}
		}
		else if(Reflection.isAssociativeArray(desiredType))
		{
			result = new desiredType();
			for(var key : String in data)
			{
				result[key] = deserializeObject(data[key], Reflection.getClass(data[key]));
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
				var typeInfo:TypeInfo = Reflection.getTypeInfo(desiredType);
				if(typeInfo.implementedInterfaces.indexOf(IJsonDeserializable) != -1)
				{
					return IJsonDeserializable(result).createFromJson(data);
				}
				else
				{
					for each(var member:AbstractMemberInfo in typeInfo.allMembers)
					{
						if(	member is AbstractFieldInfo
							&& AbstractFieldInfo(member).canWrite
							//ensure the field exists in the data
							&& member.name in data && data[member.name] !== undefined)
						{
							var resultValue:Object = deserializeObject(data[member.name], AbstractFieldInfo(member).type);
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
	
	static private function getSpacingForIndentationLevel():String
	{
		var result : String = "";
		for(var x:int = 0; x < s_indentationLevel; ++x)
		{
			result += s_spaceCharacters;
		}
		return result;
	}
}

}