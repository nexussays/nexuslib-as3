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
 * ...
 * @author	Malachi Griffie
 * @since	11/29/2011 3:55 AM
 */
internal class JsonUtil
{
	//--------------------------------------
	//	CLASS VARIABLES
	//--------------------------------------
	
	private static var encodeMethod : Function;
	private static var decodeMethod : Function;
	{
		try
		{
			encodeMethod = JSON.stringify;
			decodeMethod = JSON.parse;
			trace("Using native JSON");
		}
		catch(e:Error)
		{
			encodeMethod = BlooddyJson.encode
			decodeMethod = BlooddyJson.decode;
			trace("Using blooddy JSON");
		}
	}
	
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	public static function encode(value:Object):String
	{
		return encodeMethod(value);
	}
	
	public static function decode(value:String):Object
	{
		return decodeMethod(value);
	}
}

}