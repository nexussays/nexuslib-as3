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
package nexus.utils.serialization.xml
{

import flash.utils.Dictionary;

import nexus.utils.Parse;
import nexus.utils.reflection.MetadataInfo;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	11/2/2011 2:38 AM
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