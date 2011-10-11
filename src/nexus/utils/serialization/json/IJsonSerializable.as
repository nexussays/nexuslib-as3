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
	
/**
 * An interface for objects to provide custom serialization to and from JSON. It is not required that objects implement this in order to
 * serialize to JSON, and in fact most objects will not need to implement this at all as the native serialization provided by JsonSerializer
 * will be adequate.
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	9/29/2011 2:12 AM
 */
public interface IJsonSerializable
{
	/**
	 * Used by the JsonSerializer to return a custom native object representation of this instance. Note that an Object should
	 * be returned, not a JSON-formatted String; the returned Object will be converted to JSON by the serializer.
	 * @return
	 */
	function toJson():Object;
	
	/**
	 * Returns true if the data provided has the same signature as this class (typically this means that all the fields and properties in
	 * the class have corresponding keys in the data, and there are no keys in the data that do not exist as class members &mdash; however if
	 * you have provided a custom toJson() implementation then you will likely need to override this check as well)
	 * @param	data	A native object which has been parsed from JSON
	 * @return	True if the provided data has an equivalent signature to this class, false if it does not.
	 */
	function jsonLikeType(data:Object):Boolean;
}

}