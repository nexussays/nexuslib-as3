/* Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package nexus.utils.serialization.json
{

/**
 * Provides an API to access the native JSON parser or fallback to the blooddy-crypto library JSON parser
 * if running on a version of flash without native JSON.
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
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