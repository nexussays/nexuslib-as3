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
package nexus.utils.reflection
{

import flash.utils.*;

/**
 * Represents a metadata tag applied to an element
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since 7/23/2011 3:34 AM
 */
public class MetadataInfo
{
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	protected var m_name : String;
	protected var m_data : Dictionary;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function MetadataInfo(name:String, keyValueCollection:Dictionary)
	{
		m_name = name;
		m_data = keyValueCollection;
	}

	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public final function get name():String { return m_name; }
	
	public final function get data():Dictionary { return m_data; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	public final function getValue(key:String):String
	{
		return m_data[key];
	}
	
	public function toString():String
	{
		return "[Metadata|" + m_name + "]";
	}
	
	//--------------------------------------
	//	INTERNAL INSTANCE METHODS
	//--------------------------------------
}

}