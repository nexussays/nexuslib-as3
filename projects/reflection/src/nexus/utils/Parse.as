/* Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package nexus.utils
{

import flash.geom.Point;
import flash.utils.Dictionary;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 */
public class Parse
{
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	/**
	 * Parse the given value as a Number. If the parsed Number is NaN or Infinity then defaultValue is returned instead.
	 * @param	source
	 * @param	defaultValue	The default value to use if the parsed Number is NaN or Infinity
	 * @return
	 */
	public static function number(source:*, defaultValue:Number):Number
	{
		var result : Number = parseFloat(source);
		return isNaN(result) || !isFinite(result) ? defaultValue : result;
	}
	
	/**
	 * Parse the given value as an int. If the parsed value is NaN or Infinity then defaultValue is returned instead.
	 * @param	source
	 * @param	defaultValue
	 * @return
	 */
	public static function integer(source:*, defaultValue:int, radix:int=10):int
	{
		//malachi: parse int returns a number which we use to check for NaN before setting to default value, if
		//result was of type int than NaN would result in 0 and we wouldn't be able to check and assign default value
		var result : Number = parseInt(source, radix);
		return isNaN(result) || !isFinite(result) ? defaultValue : result;
	}
	
	/**
	 * Parses a string value, the default value is used if the source is null or undefined
	 * @return
	 */
	public static function string(source:*, defaultValue:String):String
	{
		return (source !== null && source !== undefined ? String(source + "") : defaultValue);
	}
	
	/**
	 * Parses the given value as a Point, assuming a string input in the format "x,y"
	 * @param	source
	 * @param	defaultX	The x value to use if the parsed value is NaN or Infinity
	 * @param	defaultY	The y value to use if the parsed value is NaN or Infinity
	 * @return
	 */
	public static function point(source:*, defaultX:int, defaultY:int):Point
	{
		var array : Array = String(source + "").split(",");
		return new Point(Parse.number(array[0], defaultX), Parse.number(array[1], defaultY));
	}
	
	/**
	 * Case-insensitive. If defaultValue is false, this converts "true", "t", "1", "yes", and "y" to a true boolean and all
	 * other values return false. If defaultValue is true, this converts "false", "f", "0", "no", and "n" to a false boolean
	 * and all other values return true.
	 * @param	source		A value to convert to Boolean
	 * @param 	alsoMatch	If provided, will return true if the source matches this value (case-insensitive)
	 * @return
	 */
	public static function boolean( source: *, defaultValue:Boolean, alsoMatch : String = null ): Boolean
	{
		var match : String = alsoMatch != null ? (alsoMatch + "").toLowerCase() : null;
		var check : String = (source + "").toLowerCase();
		
		if(defaultValue)
		{
			switch(check)
			{
				case "false":
				case "f":
				case "0":
				case "no":
				case "n":
				case match:
					return false;
				default:
					return true;
			}
		}
		
		switch(check)
		{
			case "true":
			case "t":
			case "1":
			case "yes":
			case "y":
			case match:
				return true;
			default:
				return false;
		}
	}
	
	/*
	public static function enum(source:*, enumClass:Class, caseSensitive:Boolean=false):Enum
	{
		return Enum.fromString(enumClass, value, caseSensitive);
	}
	*/
	
	/**
	 * Parses the given value as a Dictionary using the provided delimiters to split entries and key/value pairs. If
	 * there are errors in the parsing or the source object cannot be parsed correctly, null is returned
	 * @param	source
	 * @param	entryDelimiter		A string delimiter for each key/value entry for the dictionary
	 * @param	keyValueDelimiter	A string delimiter between each key/value pair
	 * @return	A Dictionary or null if the source cannot be parsed
	 * @example <listing version="3.0">
	 * var str1 : String = "key1:value1|key2:value2|key3:value3|key4:value4";
	 * var str2 : String = "key1,value1 key2,value2 key3,value3 key4,value4";
	 * var dict1 : Dictionary = Parse.dictionary(str1, "|", ":");
	 * var dict2 : Dictionary = Parse.dictionary(str2, " ", ",");
	 * </listing>
	 */
	public static function dictionary(source:*, entryDelimiter:String, keyValueDelimiter:String):Dictionary
	{
		var result : Dictionary = new Dictionary();
		//if nothing can be parsed from the source, then we return null instead of an empty dictionary
		var valuesFound : Boolean = false;
		
		var entries : Array = (source + "").split(entryDelimiter);
		for(var x : int = 0; x < entries.length; ++x)
		{
			entries[x] = String(entries[x]).split(keyValueDelimiter);
			//make sure that upon splitting this entry into key/value that it has two fields and the key isn't null
			if(entries[x].length == 2 && entries[x][0] != null)
			{
				result[entries[x][0]] = entries[x][1];
				valuesFound = true;
			}
		}
		
		return valuesFound ? result : null;
	}
	
	/**
	 * Parses a string in ISO 8601 format and returns a Date object with the corresponding date
	 * @param	a_string	a string formatted in a valid W3C subset of ISO 8601
	 * @return
	 */
	public static function iso8601Date( a_string : String, defaultValue:Date=null ) : Date
	{
		if (a_string == null || a_string == "")
		{
			return defaultValue;
		}
		
		var regexp : RegExp = /^(\d{4})-(\d{2})-(\d{2})(?:T(\d{2}):(\d{2})(?::(\d{2})(?:\.(\d{1,3}))?)?)?((?:([+-])(\d{2})(?::(\d{2}))?)|Z)?$/;
		var match : Array = a_string.match(regexp);
		
		//trace(a_string);
		
		if (match == null)
		{
			return new Date(0,0);
		}
		
		//remove full-match from resulting array
		match.shift();
		
		//trace(match);
		
		//months are 0-based in the Date constructor for some reason
		if (match[1])
		{
			match[1]--;
		}
		
		var result : Date = new Date(match[0] || 1970, match[1] || 0, match[2] || 1, match[3] || 0, match[4] || 0, match[5] || 0, match[6] || 0);
		
		//account for timezone
		var timezoneOffset : int = 0;
		//if there was something provided for timezone
		if (match[7])
		{
			if (match[7] != "Z")
			{
				var hours : int = parseInt(match[9]) || 0;
				var minutes : int = parseInt(match[10]) || 0;
				timezoneOffset = (hours * 60) + minutes;
				if (match[8] == '+')
				{
					timezoneOffset *= -1;
				}
			}
			//cancel out this system's timezone offset
			timezoneOffset -= result.getTimezoneOffset();
		}
		
		//BUG: This causes a problem the the US during the spring time change when clocks advance an hour. That hour of time has
		//not actually elapsed, so any time-related functions (eg, time elapsed to change state of an object) will fail
		if (timezoneOffset != 0)
		{
			result.setTime(result.getTime() + (timezoneOffset * 60 * 1000));
		}
		
		//trace(DateUtil.toISOString(result));
		return result;
	}
}

}
