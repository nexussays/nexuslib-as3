// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.utils.serialization
{
	import flash.system.ApplicationDomain;
	
/**
 * A standardized interface for serializers
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 */
public interface ISerializer
{
	/**
	 * Serializes the given object into the serialized type
	 * @param	sourceObject
	 * @param	includeReadOnlyFields
	 * @return
	 */
	function serialize(sourceObject:Object, applicationDomain:ApplicationDomain = null):Object;
	
	/**
	 * Deserializes the given serialized data into an object. If a type is not provided the object is a native Actionscript object.
	 * @param	serializedData	The serialized data to parse into an object
	 * @param	type	The type of object to deserialize to, or null if a native object should be returned
	 * @return	An object instance parsed from the serialized data
	 */
	function deserialize(serializedData:Object, type:Class = null, applicationDomain:ApplicationDomain = null):Object;
}

}