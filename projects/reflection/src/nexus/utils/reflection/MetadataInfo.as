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
 * Represents a metadata tag applied to an element.
 *
 * Notes on metadata:
 * <ul>
 * <li>A metadata tag on the class level is never inherited by subclasses.</li>
 * <li>A metadata tag on a property or method that is not overridden in a subclass is always available when reflecting on the subclass.</li>
 * <li>A metadata tag on an overridden property getter/setter or method is only inherited if the overriding method or property does not have any metadata itself.</li>
 * </ul>

 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 */
public class MetadataInfo
{
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	protected var m_metadataName : String;
	protected var m_metadataKeyValuePairs : Dictionary;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function MetadataInfo(name:String, keyValueCollection:Dictionary)
	{
		m_metadataName = name;
		m_metadataKeyValuePairs = keyValueCollection;
	}

	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public final function get metadataName():String { return m_metadataName; }
	
	public final function get metadataKeyValuePairs():Dictionary { return m_metadataKeyValuePairs; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	public final function getValue(key:String):String
	{
		return m_metadataKeyValuePairs[key];
	}
	
	public function toString():String
	{
		return "[Metadata|" + m_metadataName + "]";
	}
	
	//--------------------------------------
	//	INTERNAL INSTANCE METHODS
	//--------------------------------------
}

}