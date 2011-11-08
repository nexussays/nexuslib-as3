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
package nexus.utils.serialization
{
	
/**
 * A standardized interface for serializers
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	7/23/2011 3:34 AM
 */
public interface ISerializer
{
	/**
	 * Serializes the given object into the serialized type
	 * @param	sourceObject
	 * @param	includeReadOnlyFields
	 * @return
	 */
	function serialize(sourceObject:Object):Object;
	
	/**
	 * Deserializes the given serialized data into an object. If a type is not provided the object is a native Actionscript object.
	 * @param	serializedData	The serialized data to parse into an object
	 * @param	type	The type of object to deserialize to, or null if a native object should be returned
	 * @return	An object instance parsed from the serialized data
	 */
	function deserialize(serializedData:Object, type:Class=null):Object;
}

}