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
package dna.utils.reflection
{

import flash.utils.*;

/**
 * Represents a metadata tag applied to an element
 * @author	Malachi Griffie (malachi@nexussays.com)
 * @since 7/23/2011 3:34 AM
 */
public class MetadataInfo
{
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_name : String;
	
	private var m_properties : Dictionary;
	//private var m_keys : Vector.<String>;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function MetadataInfo(name:String)
	{
		m_name = name;
		m_properties = new Dictionary();
	}

	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get name():String { return m_name; }
	
	//public function get keys():Vector.<String> { return m_keys; }
	
	public function get properties():Dictionary { return m_properties; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	public function getValue(key:String):String
	{
		return m_properties[key];
	}
	
	public function toString():String
	{
		return "[Metadata|" + m_name + "]";
	}
	
	//--------------------------------------
	//	INTERNAL INSTANCE METHODS
	//--------------------------------------
	
	internal function addValue(key:String, value:String):void
	{
		m_properties[key] = value;
		//m_keys.push(key);
	}
}

}