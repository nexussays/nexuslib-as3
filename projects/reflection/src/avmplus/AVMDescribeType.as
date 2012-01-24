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
package avmplus
{

/**
 * Provides access to the avmplus.describeTypeJSON method which was (accidentally?) exposed in Flash 10.2
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	11/29/2011 1:15 AM
 */
public final class AVMDescribeType
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	private static var s_isAvailable : Boolean = false;
	
	//--------------------------------------
	//	STATIC INITIALIZER
	//--------------------------------------
	
	{
		try
		{
			if(describeTypeJSON is Function && describeType is Function)
			{
				s_isAvailable = true;
			}
		}
		catch(e:Error)
		{
			s_isAvailable = false;
		}
	}
	
	//--------------------------------------
	//	GETTERS/SETTERS
	//--------------------------------------
	
	public static function get isAvailable():Boolean { return s_isAvailable; }
	
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	public static function getClassJson(object:Object):Object
	{
		//1404 represents the bitwise flags to display class-level information but no instance data, base classes, or constructor
		return describeTypeJSON(object, 1404);
	}
	
	public static function getInstanceJson(object:Object):Object
	{
		//2046 represents the bitwise flags to display instance information
		return describeTypeJSON(object, 2046);
	}
	
	public static function getClassXml(object:Object):XML
	{
		return describeType(object, 1404);
	}
	
	public static function getInstanceXml(object:Object):XML
	{
		return describeType(object, 2046);
	}
}

}