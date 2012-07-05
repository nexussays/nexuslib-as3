// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
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