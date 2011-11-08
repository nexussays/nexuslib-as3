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
import nexus.utils.ObjectUtils;

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
	
	//static private var s_indentationLevel : int;
	static private var s_spaceCharacters : String;
	static private var s_maxLineLength : int;
	static private var s_serializeConstants : Boolean;
	static private var s_indentation:String;
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_indentationCharacters:String;
	private var m_maxLineLength:int;
	private var m_serializeConstants:Boolean;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function JsonSerializer(indentationCharacters:String = "", lineLength:int = int.MAX_VALUE)
	{
		m_indentationCharacters = indentationCharacters;
		m_maxLineLength = lineLength;
		m_serializeConstants = false;
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
	
	public function get serializeConstants():Boolean { return m_serializeConstants; }
	public function set serializeConstants(value:Boolean):void
	{
		m_serializeConstants = value;
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
		return JsonSerializer.serialize(sourceObject, m_indentationCharacters, m_maxLineLength, m_serializeConstants);
	}
	
	/**
	 * @inheritDoc
	 */
	public function deserialize(serializedData:Object, type:Class=null):Object
	{
		var object : Object = JsonSerializer.deserialize(serializedData as String);
		if(type == null)
		{
			return ObjectUtils.createTypedObjectFromNativeObject(type, object);
		}
		else
		{
			return object;
		}
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
	static public function serialize(sourceObject:Object, space:String = "", maxLineLength:int = int.MAX_VALUE, serializeConstants:Boolean = false):String
	{
		//s_indentationLevel = 0;
		s_indentation = "";
		s_spaceCharacters = space || "";
		s_maxLineLength = maxLineLength;
		s_serializeConstants = serializeConstants;
		return serializeObject(sourceObject);
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
		var pretty : Boolean;
		var x : int;
		
		if(sourceObject == null)
		{
			result = "null";
		}
		else if(Reflection.isPrimitive(sourceObject)
			|| sourceObject is Date
			|| sourceObject is IJsonSerializable
			|| ("toJSON" in sourceObject && !sourceObject is Dictionary))
		{
			result = JSON.stringify(sourceObject);
		}
		else
		{
			result = "";
			
			//if a max line length has been set, use the native encoder to very quickly roughly determine the string length
			//of the current object and then use that to determine if we need to run the pretty formatter or not
			//TODO: find a faster way to determine this
			pretty = (s_maxLineLength == 0 || (s_maxLineLength < int.MAX_VALUE && JSON.stringify(sourceObject).length > s_maxLineLength));
			
			if(pretty)
			{
				s_indentation += s_spaceCharacters;
			}
			
			if(Reflection.isArray(sourceObject))
			{
				for(x = 0; x < sourceObject.length; x++)
				{
					if(result.length > 0)
					{
						result += pretty ? ",\n" : ",";
					}
					result += pretty ? s_indentation : "";
					result += serializeObject(sourceObject[x]);
				}
				
				if(pretty)
				{
					//unindent
					s_indentation = s_indentation.substring(0, s_indentation.length - s_spaceCharacters.length);
					result = "[" + "\n" + result + "\n" + s_indentation + "]";
				}
				else
				{
					result = "[" + result + "]";
				}
			}
			else
			{
				//iterate over the keys in a native object, use reflection if it is typed
				if(Reflection.isAssociativeArray(sourceObject))
				{
					var key : String;
					//alphabetize output
					//don't check if(pretty) here because we want to sort on case if the entire serialize call is pretty printed
					//even if this specific object we are recursing over is not
					if(s_maxLineLength < int.MAX_VALUE)
					{
						var keys : Array = [];
						for(key in sourceObject)
						{
							keys.push(key);
						}
						keys.sort(Array.CASEINSENSITIVE);
						
						for(x = 0; x < keys.length; ++x)
						{
							key = keys[x];
							result += setupObjectString(result, key, sourceObject[key], pretty);
						}
					}
					else
					{
						for(key in sourceObject)
						{
							result += setupObjectString(result, key, sourceObject[key], pretty);
						}
					}
				}
				else
				{
					//Loop over all of the variables and accessors in the class and
					//serialize them along with their values.
					var typeInfo : TypeInfo = Reflection.getTypeInfo(sourceObject);
					var memberNames : Vector.<AbstractMemberInfo> = s_maxLineLength < int.MAX_VALUE ? typeInfo.allMembersSortedByName : typeInfo.allMembers;
					for each(var field : AbstractMemberInfo in memberNames)
					{
						if(	field is AbstractFieldInfo
							&& !AbstractFieldInfo(field).isStatic
							&& AbstractFieldInfo(field).canRead
							//don't serialize constant fields if told not to, but always serialize read-only properties
							&& (s_serializeConstants || AbstractFieldInfo(field).canWrite || field is PropertyInfo)
							&& field.getMetadataByName("Transient") == null)
						{
							result += setupObjectString(result, field.name, sourceObject[field.name], pretty);
						}
					}
				}
				
				if(pretty)
				{
					//unindent
					s_indentation = s_indentation.substring(0, s_indentation.length - s_spaceCharacters.length);
					result = "{" + "\n" + result + "\n" + s_indentation + "}";
				}
				else
				{
					result = "{" + result + "}";
				}
			}
		}
		return result;
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
			result += pretty ? s_indentation : "";
			result += JSON.stringify(key);
			result += pretty ? ": " : ":";
			result += serializeObject(value);
		}
		return result;
	}
}

}