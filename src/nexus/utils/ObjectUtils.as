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
package nexus.utils
{

import nexus.errors.NotImplementedError;
import nexus.utils.reflection.AbstractFieldInfo;
import nexus.utils.reflection.AbstractMemberInfo;
import nexus.utils.reflection.Reflection;
import nexus.utils.reflection.TypeInfo;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	10/25/2011 3:26 AM
 */
public class ObjectUtils
{
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	/**
	 * Creates a new instance of the given type from the native object provided. Any values that exist in the provided
	 * object but not in the instance are ignored/dropped; and any values that exist in the instance but not the provided object
	 * are never assigned and left at their default values.
	 * Requires that the instance being instantiated provides a constructor with no arguments.
	 * @param	source	A native object which contains the values to assign into the newly created instance.
	 * @param	type	The class type of the object to instantiate
	 * @return	A newly instantiated typed object with fields assigned from the provided data object.
	 */
	static public function createTypedObjectFromNativeObject(type:Class, source:Object):Object
	{
		var result:Object;
		
		//TODO: consider adding error checking if the data and desired type do not match
		if(source == null)
		{
			result = null;
		}
		else if(Reflection.isPrimitive(type))
		{
			result = source;
		}
		else if(type == Date)
		{
			result = new Date(source);
		}
		else if(Reflection.isArray(type))
		{
			result = new type();
			for(var x:int = 0; x < source.length; ++x)
			{
				if(x in source && source[x] !== undefined)
				{
					result[x] = createTypedObjectFromNativeObject(Reflection.getVectorClass(type), source[x]);
				}
			}
		}
		else if(Reflection.isAssociativeArray(type))
		{
			result = new type();
			for(var key : String in source)
			{
				result[key] = createTypedObjectFromNativeObject(Reflection.getClass(source[key]), source[key]);
			}
		}
		else
		{
			try
			{
				result = new type();
			}
			catch(e:ArgumentError)
			{
				//probably because ctor requires arguments
			}
			
			if(result != null)
			{
				var typeInfo:TypeInfo = Reflection.getTypeInfo(type);
				//if(typeInfo.implementedInterfaces.indexOf(IJsonDeserializable) != -1)
				//{
					//return IJsonDeserializable(result).createFromJson(data);
				//}
				//else
				//{
					for each(var member:AbstractMemberInfo in typeInfo.allMembers)
					{
						if(	member is AbstractFieldInfo
							&& AbstractFieldInfo(member).canWrite
							//ensure the field exists in the data
							&& member.name in source && source[member.name] !== undefined)
						{
							var resultValue:Object = createTypedObjectFromNativeObject(AbstractFieldInfo(member).type, source[member.name]);
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
				//}
			}
		}
		return result;
	}
	
	/**
	 * Assigns properties and fields of the provided instance object from values in the provided data object. This method does not
	 * instantiate a new instance of the typed object, otherwise it is functionally equivalent to createTypedObjectFromNativeObject()
	 * @param	instance	A typed object instance whose members we want to assign from the provided data
	 * @param	source	A native object which contains the values to assign into the newly created instance.
	 */
	static public function assignTypedObjectFromNativeObject(instance:Object, source:Object):void
	{
		throw new NotImplementedError();
	}
	
	//--------------------------------------
	//	PRIVATE CLASS METHODS
	//--------------------------------------
}

}