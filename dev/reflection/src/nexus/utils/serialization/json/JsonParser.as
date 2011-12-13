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
 * Provides an API to access the native JSON parser or fallback to the blooddy-crypto library JSON parser
 * if running on a version of flash without native JSON.
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	11/29/2011 3:55 AM
 */
internal class JsonParser
{
	//--------------------------------------
	//	CLASS VARIABLES
	//--------------------------------------
	
	/**
	 * Signature => public static function encode(object:Object):String
	 */
	internal static var encode : Function;
	/**
	 * Signature => public static function decode(json:String):Object
	 */
	internal static var decode : Function;
	
	//--------------------------------------
	//	STATIC INITIALIZER
	//--------------------------------------
	
	{
		try
		{
			encode = JSON.stringify;
			decode = JSON.parse;
			trace("Using native JSON");
		}
		catch(e:Error)
		{
			encode = JsonParserBlooddy.encode;
			decode = JsonParserBlooddy.decode;
			trace("Using blooddy JSON");
		}
	}
	
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
}

}