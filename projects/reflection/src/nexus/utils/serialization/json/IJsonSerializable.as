/* Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package nexus.utils.serialization.json
{

/**
 * An interface for objects to provide custom serialization to and from JSON. It is not required that objects implement this in order to
 * serialize to JSON, and in fact most objects will not need to implement this at all as the native serialization provided by JsonSerializer
 * will be adequate.
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 */
public interface IJsonSerializable
{
	/**
	 * Used by the JsonSerializer to return a custom native object representation of this instance. If an Object is returned,
	 * the serializer recurses into the object. If a String is returned, the serializer does not recurse and will continue on.
	 * @param	key	The key of this object in its parent
	 * @return	A String or Object representing this object.
	 */
	function toJSON(key:String):Object;
	
	/**
	 * Returns true if the data provided has the same signature as this class (typically this means that all the fields and properties in
	 * the class have corresponding keys in the data, and there are no keys in the data that do not exist as class members -- however if
	 * you have provided a custom toJson() implementation then you will likely need to override this check as well)
	 * @param	data	A native object which has been parsed from JSON
	 * @return	True if the provided data has an equivalent signature to this class, false if it does not.
	 */
	function jsonLikeType(data:Object):Boolean;
}

}