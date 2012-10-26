// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.utils.serialization.json
{

import flash.system.ApplicationDomain;
import flash.utils.Dictionary;

import nexus.utils.ObjectUtils;
import nexus.utils.reflection.*;
import nexus.utils.serialization.ISerializer;

/**
 * An object serializer for JSON.
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
	
	static private const s_staticSerializer : JsonSerializer = new JsonSerializer();
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_indentationCharacters:String;
	private var m_maxLineLength:int;
	private var m_isSerializingConstantScalars:Boolean;
	private var m_isOutputAlphabetized : Boolean;
	private var m_includedNamespaces : Dictionary;
	
	///the current indentation characters used in this serialization pass
	private var m_currentIndentation:String;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	/**
	 * Creates a new JsonSerializer which provides more customization than that static serialize/deserialize methods.
	 * @param	indentationCharacters			The character(s) to use for indentation in the output JSON
	 * @param	lineLength						Pretty-print JSON by defining a maximum character length of a single line. By default the output JSON will not have any newlines.
	 * @param	isSerializingConstantScalars	By default, scalar values that are constant or are provided only through a get function (with no corresponding set function) are not serialized.
	 * @param	isOutputAlphabetized			Should the resulting JSON alphabetize objects by key, default is true.
	 */
	public function JsonSerializer(indentationCharacters:String = "", lineLength:int = int.MAX_VALUE,
		isSerializingConstantScalars:Boolean = false, isOutputAlphabetized:Boolean = true)
	{
		this.indentationCharacters = indentationCharacters;
		this.maxLineLength = lineLength;
		this.isSerializingConstantScalars = isSerializingConstantScalars;
		this.isOutputAlphabetized = isOutputAlphabetized;
		
		m_includedNamespaces = new Dictionary();
		m_includedNamespaces[new Namespace()] = true;
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	/**
	 * If the serializer has a maximum line length set, then the indentation character(s) provided here are used after each newline
	 * If the provided string value is longer than 10 characters, only the first 10 characters of the string value are used.
	 */
	public function get indentationCharacters():String { return m_indentationCharacters; }
	public function set indentationCharacters(value:String):void
	{
		if(value == null)
		{
			m_indentationCharacters = "";
		}
		else if(m_indentationCharacters != value)
		{
			m_indentationCharacters = value || "";
			if(m_indentationCharacters.length > 10)
			{
				m_indentationCharacters = m_indentationCharacters.substr(0, 10);
			}
		}
	}
	
	/**
	 * If true, objects in the resulting JSON will be alphabetized by key
	 * @default	true
	 */
	public function get isOutputAlphabetized():Boolean { return m_isOutputAlphabetized; }
	public function set isOutputAlphabetized(value:Boolean):void
	{
		m_isOutputAlphabetized = value;
	}
	
	/**
	 * If true, constants are serialized in the JSON output along with variables and getter properties.
	 * @default	false
	 */
	public function get isSerializingConstantScalars():Boolean { return m_isSerializingConstantScalars; }
	public function set isSerializingConstantScalars(value:Boolean):void
	{
		m_isSerializingConstantScalars = value;
	}
	
	/**
	 * The maximum allowed length of a single line of the JSON string before the JSON data is wrapped appropriately. This
	 * value is not a hard limit but the serializer will do its best to meet the limit.
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
	 * Includes the provided namespace in serialization.
	 * @param	ns		The namespace to include
	 * @param	prefix	The prefix to use on the key of serialized objects, defaults to the URI of the namespace
	 */
	public function includeNamespace(ns:Namespace, prefix:String=null):void
	{
		m_includedNamespaces[ns] = true;
	}
	
	/**
	 * @inheritDoc
	 */
	public function serialize(sourceObject:Object, applicationDomain:ApplicationDomain = null):Object
	{
		m_currentIndentation = "";
		return serializeObject(sourceObject, applicationDomain);
	}
	
	/**
	 * @inheritDoc
	 */
	public function deserialize(serializedData:Object, type:Class = null, applicationDomain:ApplicationDomain = null):Object
	{
		var json : String = serializedData as String;
		var result : Object;
		
		try
		{
			result = JsonParser.decode(json);
		}
		catch(e:SyntaxError)
		{
			throw new SyntaxError("Error deserializing object, invalid JSON input.");
		}
		
		if(type != null)
		{
			return ObjectUtils.createTypedObjectFromNativeObject(type, result, applicationDomain);
		}
		
		return result;
	}
	
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	static public function serialize(sourceObject:Object, applicationDomain:ApplicationDomain = null, indentationCharacters:String = "", maxLineLength:int = int.MAX_VALUE):Object
	{
		s_staticSerializer.indentationCharacters = indentationCharacters;
		s_staticSerializer.maxLineLength = maxLineLength;
		return s_staticSerializer.serialize(sourceObject, applicationDomain);
	}
	
	static public function deserialize(json:String, type:Class = null, applicationDomain:ApplicationDomain = null):Object
	{
		return s_staticSerializer.deserialize(json, type, applicationDomain);
	}
	
	//--------------------------------------
	//	PRIVATE METHODS
	//--------------------------------------
	
	private function serializeObject(sourceObject:Object, applicationDomain:ApplicationDomain):String
	{
		var result:String;
		var lineWrap : Boolean;
		var x : int;
		
		//see if this object has a toJSON method
		if(	sourceObject != null
			&&	(
				sourceObject is IJsonSerializable
				|| (!(sourceObject is Dictionary) && "toJSON" in sourceObject && sourceObject["toJSON"] is Function)
				)
			)
		{
			sourceObject = sourceObject.toJSON(null);
		}
		
		if(sourceObject == null)
		{
			result = "null";
		}
		else if(Reflection.isScalar(sourceObject) || sourceObject is Date)
		{
			result = JsonParser.encode(sourceObject);
		}
		else
		{
			result = "";
			
			//if a max line length has been set, use the native encoder to very quickly roughly determine the string length
			//of the current object and then use that to determine if we need to run the pretty formatter or not
			//TODO: find a faster way to determine this
			lineWrap = (m_maxLineLength == 0 || (m_maxLineLength < int.MAX_VALUE && JsonParser.encode(sourceObject).length > m_maxLineLength));
			
			if(lineWrap)
			{
				m_currentIndentation += m_indentationCharacters;
			}
			
			if(Reflection.isArrayType(sourceObject))
			{
				for(x = 0; x < sourceObject.length; x++)
				{
					if(result.length > 0)
					{
						result += lineWrap ? ",\n" : ",";
					}
					result += lineWrap ? m_currentIndentation : "";
					result += serializeObject(sourceObject[x], applicationDomain);
				}
				
				if(lineWrap)
				{
					//unindent
					m_currentIndentation = m_currentIndentation.substring(0, m_currentIndentation.length - m_indentationCharacters.length);
					result = "[" + "\n" + result + "\n" + m_currentIndentation + "]";
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
					if(m_isOutputAlphabetized)
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
							result += setupObjectString(result, key, sourceObject[key], lineWrap, applicationDomain);
						}
					}
					else
					{
						for(key in sourceObject)
						{
							result += setupObjectString(result, key, sourceObject[key], lineWrap, applicationDomain);
						}
					}
				}
				else
				{
					//Loop over all of the variables and accessors in the class and
					//serialize them along with their values.
					var typeInfo : TypeInfo = Reflection.getTypeInfo(sourceObject, applicationDomain);
					if(typeInfo.isDynamic)
					{
						var fieldsInDataFoundInClass : Dictionary = new Dictionary();
					}
					
					var memberNames : Vector.<AbstractMemberInfo> = m_isOutputAlphabetized ? typeInfo.allMembersSortedByName : typeInfo.allMembers;
					for each(var member : AbstractMemberInfo in memberNames)
					{
						var field : AbstractFieldInfo = member as AbstractFieldInfo;
						if(	field != null
							&& field.canRead
							&& !field.isStatic
							&& (m_isSerializingConstantScalars || field.canWrite || !Reflection.isScalar(field.type))
							&& field.getMetadataByName("Transient") == null
							&& (field.namespace == null || field.namespace in m_includedNamespaces) )
						{
							result += setupObjectString(result, field.qname.toString(), sourceObject[field.qname], lineWrap, applicationDomain);
						}
					}
					
					if(typeInfo.isDynamic)
					{
						for(var dynamicKey:String in sourceObject)
						{
							if(!(dynamicKey in fieldsInDataFoundInClass))
							{
								result += setupObjectString(result, dynamicKey, sourceObject[dynamicKey], lineWrap, applicationDomain);
							}
						}
					}
				}
				
				if(lineWrap)
				{
					//unindent
					m_currentIndentation = m_currentIndentation.substring(0, m_currentIndentation.length - m_indentationCharacters.length);
					result = "{" + "\n" + result + "\n" + m_currentIndentation + "}";
				}
				else
				{
					result = "{" + result + "}";
				}
			}
		}
		return result;
	}
	
	private function setupObjectString(current:String, key:String, value:Object, lineWrap:Boolean, applicationDomain:ApplicationDomain):String
	{
		var result : String = "";
		if(!(value is Function))
		{
			if(current.length > 0)
			{
				result += lineWrap ? ",\n" : ",";
			}
			result += lineWrap ? m_currentIndentation : "";
			result += JsonParser.encode(key);
			result += lineWrap ? ": " : ":";
			result += serializeObject(value, applicationDomain);
		}
		return result;
	}
}

}