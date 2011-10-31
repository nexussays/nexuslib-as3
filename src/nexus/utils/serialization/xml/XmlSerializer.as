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
package nexus.utils.serialization.xml
{

import flash.utils.*;

import nexus.errors.NotImplementedError;
import nexus.utils.reflection.*;
import nexus.utils.serialization.ISerializer;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	7/23/2011 3:34 AM
 */
public class XmlSerializer implements ISerializer
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	CLASS VARIABLES
	//--------------------------------------
	
	static private var s_serializeConstants : Boolean;
	
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
	public function serialize(sourceObject:Object):Object
	{
		return XmlSerializer.serialize(sourceObject, false);
	}
	
	/**
	 * @inheritDoc
	 */
	public function deserialize(serializedData:Object):Object
	{
		return XmlSerializer.deserialize(serializedData as XML);
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
	public static function serialize(sourceObject:Object, serializeConstants:Boolean = false):XML
	{
		s_serializeConstants = serializeConstants;
		var xml:XML = <{Reflection.getUnqualifiedClassName(sourceObject)} />;
		serializeObject(sourceObject, xml);
		return xml;
	}
	
	static private function serializeObject(sourceObject:Object, parent:XML, elementName:String=null):XML
	{
		var x : int;
		
		if(sourceObject == null)
		{
			//no-op
		}
		else if(sourceObject is XML
			|| Reflection.isPrimitive(sourceObject))
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
		else if(Reflection.isArray(sourceObject))
		{
			for(x = 0; x < sourceObject.length; x++)
			{
				parent.appendChild(serializeObject(sourceObject[x], <{elementName||"_"+x} />));
			}
		}
		else if(Reflection.isAssociativeArray(sourceObject))
		{
			var key : String;
			for(key in sourceObject)
			{
				parent.appendChild(serializeObject(sourceObject[key], <{key} />));
			}
		}
		else
		{
			//Loop over all of the variables and accessors in the class and
			//serialize them along with their values.
			var typeInfo : TypeInfo = Reflection.getTypeInfo(sourceObject);
			for each(var field : AbstractMemberInfo in typeInfo.allMembers)
			{
				if(	field is AbstractFieldInfo
					&& !AbstractFieldInfo(field).isStatic
					&& AbstractFieldInfo(field).canRead
					//don't serialize constant fields if told not to, but always serialize read-only properties
					&& (s_serializeConstants || AbstractFieldInfo(field).canWrite || field is PropertyInfo)
					&& field.getMetadataByName("Transient") == null)
				{
					parent.appendChild(serializeObject(sourceObject[field.name], <{field.name} />));
				}
			}
			
			if(typeInfo.isDynamic)
			{
				for(var dynamicField : String in sourceObject)
				{
					//won't this always be true if we'e able to iterate it with a for/in?
					if(sourceObject.hasOwnProperty(dynamicField))
					{
						parent.appendChild(serializeObject(sourceObject[dynamicField], <{dynamicField} />));
					}
				}
			}
		}
		return parent;
	}
	
	/**
	 * Creates an instance of the passed class from the passed XML data
	 * @param	sourceXML	The XML to source the object from
	 * @param	type	The type of object to create. If null, the Class type is derived from the "type" attribute of the root XML node
	 * @return
	 */
	public static function deserialize(sourceXML:XML):Object
	{
		/*
		type = type || Class(getDefinitionByName(sourceXML.@type));
		var result:* = new type();
		var props:Object = Reflection.getPublicPropertyValues(result);
		//loop through the properties of the object, not the XML
		for(var prop:String in props)
		{
			if(sourceXML[prop.toLowerCase()])
			{
				if(result[prop] is Boolean)
				{
					result[prop] = Parse.boolean(sourceXML[prop.toLowerCase()], false);
				}
				else if(result[prop] is Date)
				{
					result[prop] = new Date(Parse.number(sourceXML[prop.toLowerCase()], 0));
				}
				else
				{
					try
					{
						result[prop] = sourceXML[prop.toLowerCase()];
					}
					catch(ex:Error)
					{
						//trace(ex);
					}
				}
				trace(prop, "xml: ", sourceXML[prop.toLowerCase()], "result: ", result[prop]);
			}
		}
		return result;
		//*/
		throw new NotImplementedError();
	}
	
	//--------------------------------------
	//	PRIVATE INSTANCE METHODS
	//--------------------------------------
	
	//private final function trace(... params):void
	//{
		//Debug.debug(XmlSerializer, params);
	//}
}

}