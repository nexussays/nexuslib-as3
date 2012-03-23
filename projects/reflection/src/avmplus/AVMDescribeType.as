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
 * Provides access to the avmplus.describeTypeJSON method which was (accidentally?) exposed in Flash 10.1
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @see	http://hg.mozilla.org/tamarin-redux/file/tip/core/DescribeType.as
 * @private
 */
public final class AVMDescribeType
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	private static var s_isAvailable : Boolean = false;
	
	//as defined in avm
	/*
	public const HIDE_NSURI_METHODS:uint    = 0x0001;
    public const INCLUDE_BASES:uint         = 0x0002;
    public const INCLUDE_INTERFACES:uint    = 0x0004;
    public const INCLUDE_VARIABLES:uint     = 0x0008;
    public const INCLUDE_ACCESSORS:uint     = 0x0010;
    public const INCLUDE_METHODS:uint       = 0x0020;
    public const INCLUDE_METADATA:uint      = 0x0040;
    public const INCLUDE_CONSTRUCTOR:uint   = 0x0080;
    public const INCLUDE_TRAITS:uint        = 0x0100;
    public const USE_ITRAITS:uint           = 0x0200;
    // if set, hide everything from the base Object class
    public const HIDE_OBJECT:uint           = 0x0400;
	//*/
	private static const INCLUDE_BASES:uint		=	avmplus.INCLUDE_BASES;
	private static const INCLUDE_INTERFACES:uint=	avmplus.INCLUDE_INTERFACES;
	private static const INCLUDE_VARIABLES:uint	=	avmplus.INCLUDE_VARIABLES;
	private static const INCLUDE_ACCESSORS:uint	=	avmplus.INCLUDE_ACCESSORS;
	private static const INCLUDE_METHODS:uint	=	avmplus.INCLUDE_METHODS;
	private static const INCLUDE_METADATA:uint	=	avmplus.INCLUDE_METADATA;
	private static const INCLUDE_CONSTRUCTOR:uint	=	avmplus.INCLUDE_CONSTRUCTOR;
	private static const INCLUDE_TRAITS:uint	=	avmplus.INCLUDE_TRAITS;
	private static const USE_ITRAITS:uint		=	avmplus.USE_ITRAITS;
	private static const HIDE_OBJECT:uint		=	avmplus.HIDE_OBJECT;
	
	private static const GET_CLASS : uint    =                                      INCLUDE_VARIABLES | INCLUDE_ACCESSORS | INCLUDE_METHODS | INCLUDE_METADATA |                       INCLUDE_TRAITS |               HIDE_OBJECT;
	private static const GET_INSTANCE : uint = INCLUDE_BASES | INCLUDE_INTERFACES | INCLUDE_VARIABLES | INCLUDE_ACCESSORS | INCLUDE_METHODS | INCLUDE_METADATA | INCLUDE_CONSTRUCTOR | INCLUDE_TRAITS | USE_ITRAITS | HIDE_OBJECT;
	
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
	
	public static function getJson(object:Object):Object
	{
		var factory : Object = describeTypeJSON(object, GET_INSTANCE);
		factory.traits.isDynamic = factory.isDynamic;
		factory.traits.isFinal = factory.isFinal;
		factory.traits.isStatic = factory.isStatic;
		factory.traits.name = factory.name;
		factory = factory.traits;
		factory.methods = factory.methods || [];
		factory.accessors = factory.accessors || [];
		factory.variables = factory.variables || [];
		factory.constructor = factory.constructor || [];
		
		var obj : Object = describeTypeJSON(object, GET_CLASS);
		obj = obj.traits;
		obj.methods = obj.methods || [];
		obj.accessors = obj.accessors || [];
		obj.variables = obj.variables || [];
		delete obj.bases;
		delete obj.constructor;
		delete obj.interfaces;
		
		obj.factory = factory;
		
		return obj;
	}
	
	/**
	 * This method just calls getJson() and parses the result to XML. It is advised to not use this method unless you are sending the data
	 * to something that expects it in the standard flash.utils.describeType() format.
	 * @param	object
	 * @return
	 */
	public static function getXml(object:Object):XML
	{
		return describeType(object, GET_CLASS);
	}
}

}