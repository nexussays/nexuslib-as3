// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.utils.serialization.xml
{

import flash.utils.Dictionary;

import nexus.utils.Parse;
import nexus.utils.reflection.MetadataInfo;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 */
public class XmlMetadata extends MetadataInfo
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	public var nodeName : String;
	public var isAttribute : Boolean;
	public var flattenArray : Boolean;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function XmlMetadata(name:String, keyValueCollection:Dictionary)
	{
		super(name, keyValueCollection);
		this.nodeName = this.getValue("nodeName");
		this.isAttribute = Parse.boolean(this.getValue("isAttribute"), false);
		this.flattenArray = Parse.boolean(this.getValue("flattenArray"), false);
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
}

}