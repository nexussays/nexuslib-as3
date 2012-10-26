// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.utils.serialization.xml
{

import flash.system.ApplicationDomain;
import flash.utils.*;
import nexus.nexuslib_internal;
import nexus.utils.ObjectUtils;

import nexus.errors.NotImplementedError;
import nexus.utils.reflection.*;
import nexus.utils.serialization.ISerializer;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 */
public class XmlSerializer implements ISerializer
{
	//--------------------------------------
	//	CLASS INITIALIZER
	//--------------------------------------
	
	{
		Reflection.registerMetadataClass(XmlMetadata);
	}
	
	//--------------------------------------
	//	CLASS VARIABLES
	//--------------------------------------
	
	static private var s_serializeConstants:Boolean;
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function XmlSerializer()
	{
	
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	/**
	 * @inheritDoc
	 */
	public function serialize(sourceObject:Object, applicationDomain:ApplicationDomain = null):Object
	{
		return XmlSerializer.serialize(sourceObject, applicationDomain, false);
	}
	
	/**
	 * @inheritDoc
	 */
	public function deserialize(serializedData:Object, type:Class = null, applicationDomain:ApplicationDomain = null):Object
	{
		var object:Object = XmlSerializer.deserialize(serializedData is XML ? serializedData as XML : new XML(serializedData));
		if(type != null)
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
	
	/**
	 * Creates an XML object representing the passed object instance. Only public properties are included, and Dates
	 * are converted to number of milliseconds since Jan 1, 1970 UTC
	 * @param	sourceObject	The object to convert to XML
	 * @param	elementName		The name of the root element. If null, the name of the object's class is used.
	 * @return
	 */
	public static function serialize(sourceObject:Object, applicationDomain:ApplicationDomain = null, serializeConstants:Boolean = false):XML
	{
		s_serializeConstants = serializeConstants;
		var typeInfo:TypeInfo = Reflection.getTypeInfo(sourceObject);
		var metadata:XmlMetadata = typeInfo.getMetadataByClass(XmlMetadata) as XmlMetadata;
		var name:String = (metadata != null && metadata.nodeName != null ? metadata.nodeName : Reflection.getUnqualifiedClassName(typeInfo.type)).toLowerCase();
		var xml:XML =  <{name}/>;
		serializeObject(sourceObject, xml);
		return xml;
	}
	
	/**
	 * Creates an instance of the passed class from the passed XML data
	 * @param	sourceXML	The XML to source the object from
	 * @param	type	The type of object to create. If null, the Class type is derived from the "type" attribute of the root XML node
	 * @return
	 */
	public static function deserialize(sourceXML:XML):Object
	{
		if(sourceXML == null)
		{
			return null;
		}
		
		var result:Object = {};
		var element:XML;
		var arrays:Dictionary;
		
		//check if the xml is formatted such that the resulting object should be an array
		if(sourceXML.hasComplexContent())
		{
			if(sourceXML.children()[0].name().toString().charAt(0) == "_")
			{
				result = [];
			}
			else
			{
				arrays = new Dictionary();
				var names:Dictionary = new Dictionary();
				for each(element in sourceXML.elements())
				{
					if(element.name().toString() in names)
					{
						//same named child element exists twice, if this element has the same name as well, then it is an array, otherwise
						//it was flattened during serialization and we should create a child key with the name of the child elements
						//and it should be an array
						if(element.name().toString() == sourceXML.name().toString())
						{
							result = [];
							break;
						}
						else
						{
							result[element.name().toString()] = [];
							arrays[element.name().toString()] = true;
						}
					}
					names[element.name().toString()] = true;
				}
				names = null;
			}
		}
		
		for each(element in sourceXML.elements())
		{
			var name:String = element.name().toString()
			var obj:Object = name in arrays ? result[name] : result;
			
			if(element.hasComplexContent() || element.attributes().length() > 0)
			{
				obj[getKey(obj, name)] = deserialize(element);
			}
			else
			{
				setValue(obj, name, element.toString());
			}
		}
		
		for each(element in sourceXML.attributes())
		{
			setValue(result, element.name().toString(), element.toString());
		}
		
		return result;
	}
	
	//--------------------------------------
	//	PRIVATE CLASS METHODS
	//--------------------------------------
	
	static private function serializeObject(sourceObject:Object, parent:XML, elementName:String = null):XML
	{
		var x:int;
		
		if(sourceObject == null)
		{
			//no-op
		}
		else if(sourceObject is XML || Reflection.isScalar(sourceObject))
		{
			parent.appendChild(sourceObject);
		}
		else if(sourceObject is Date)
		{
			parent.appendChild((sourceObject as Date).getTime());
		}
		else if(sourceObject is IXmlSerializable || "toXML" in sourceObject)
		{
			parent.appendChild(sourceObject.toXML());
		}
		else if(Reflection.isArrayType(sourceObject))
		{
			for(x = 0; x < sourceObject.length; x++)
			{
				parent.appendChild(serializeObject(sourceObject[x],  <{elementName || "_" + x}/>));
			}
		}
		else if(Reflection.isAssociativeArray(sourceObject))
		{
			var key:String;
			for(key in sourceObject)
			{
				parent.appendChild(serializeObject(sourceObject[key],  <{key}/>));
			}
		}
		else
		{
			//Loop over all of the variables and accessors in the class and
			//serialize them along with their values.
			var typeInfo:TypeInfo = Reflection.getTypeInfo(sourceObject);
			for each(var field:AbstractMemberInfo in typeInfo.allMembers)
			{
				if(field is AbstractFieldInfo && !AbstractFieldInfo(field).isStatic && AbstractFieldInfo(field).canRead
					//don't serialize constant fields if told not to, but always serialize read-only properties
					&& (s_serializeConstants || AbstractFieldInfo(field).canWrite || field is PropertyInfo) && field.getMetadataByName("Transient") == null)
				{
					var metadata:XmlMetadata = field.getMetadataByClass(XmlMetadata) as XmlMetadata;
					var nodeName:String = (metadata != null ? metadata.nodeName || field.name : field.name);
					if(metadata != null && metadata.flattenArray)
					{
						serializeObject(sourceObject[field.name], parent, nodeName);
					}
					else
					{
						parent.appendChild(serializeObject(sourceObject[field.name],  <{nodeName}/>));
					}
				}
			}
			
			if(typeInfo.isDynamic)
			{
				for(var dynamicField:String in sourceObject)
				{
					//won't this always be true if we'e able to iterate it with a for/in?
					if(sourceObject.hasOwnProperty(dynamicField))
					{
						parent.appendChild(serializeObject(sourceObject[dynamicField],  <{dynamicField}/>));
					}
				}
			}
		}
		return parent;
	}
	
	static private function setValue(obj:Object, name:String, value:String):void
	{
		if(/^\d*\.?\d+$/.test(value))
		{
			obj[getKey(obj, name)] = parseFloat(value);
		}
		else
		{
			obj[getKey(obj, name)] = value;
		}
	}
	
	static private function getKey(object:Object, name:String):Object
	{
		if(object is Array)
		{
			if(name.charAt(0) == "_")
			{
				return parseInt(name.substring(1));
			}
			else
			{
				return object.length;
			}
		}
		return name;
	}
}

}