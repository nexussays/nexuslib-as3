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
	
	public function toString(verbose:Boolean=false):String
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
		throw new NotImplementedError();
	}
	
	/**
	 * Deserializes the provided native object into an instance of a typed class, either specified in the object or provided as an argument.
	 * @param	serializedObject	The native object from which to create a typed object instance
	 * @param	classType			The type of object to create. If null, the Class type is derived from the "type" value of the serializedObject
	 * @return
	 */
	static public function deserialize(serializedObject:Object, classType:Class = null):Object
	{
		throw new NotImplementedError();
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
	private final function trace(...params): void
	{
		Debug.debug(JsonSerializer, params);
	}
}

}