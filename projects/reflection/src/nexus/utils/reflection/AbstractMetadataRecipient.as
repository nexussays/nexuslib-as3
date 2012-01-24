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
 * Malachi Griffie.
 * Portions created by the Initial Developer are Copyright (C) 2011
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** */
package nexus.utils.reflection
{

import flash.utils.*;
import nexus.nexuslib_internal;

/**
 * Abstract base class for any reflected object that can be tagged with metadata
 * @private
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	9/21/2011 2:57 AM
 */
public class AbstractMetadataRecipient
{
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	protected var m_name:String;
	
	protected var m_metadata:Vector.<MetadataInfo>;
	
	protected var m_metadataByName:Dictionary;
	
	///as defined in the debug-only metadata tag __go_to_definition_help
	protected var m_position:int;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function AbstractMetadataRecipient(name:String)
	{
		m_name = name;
		
		m_metadata = new Vector.<MetadataInfo>();
		m_metadataByName = new Dictionary();
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	/**
	 * The name of this member
	 */
	public function get name():String { return m_name; }
	
	/**
	 * Any metadata attached to this member
	 */
	public function get metadata():Vector.<MetadataInfo> { return m_metadata; }
	
	/**
	 * The value of the "__go_to_definition_help" metadata tag
	 */
	public function get position():int { return m_position; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	/**
	 * Retrieves the MetadataInfo, if any, with the given name
	 * @param	name	The name of the metadata tag
	 * @return
	 */
	public function getMetadataByName(name:String):MetadataInfo
	{
		return m_metadataByName[name];
	}
	
	/**
	 * Retrieves the MetadataInfo of a specific subclass. Be sure to register the class with Reflection.registerMetadataClass first
	 * @param	type	A class which extends MetadataInfo
	 * @return
	 */
	public function getMetadataByClass(type:Class):MetadataInfo
	{
		return m_metadataByName[type];
	}
	
	//--------------------------------------
	//	INTERNAL INSTANCE METHODS
	//--------------------------------------
	
	internal function setPosition(value:int):void
	{
		m_position = value;
	}
	
	internal function addMetadata(meta:MetadataInfo):void
	{
		use namespace nexuslib_internal;
		
		m_metadata.push(meta);
		m_metadataByName[meta.metadataName] = meta;
		
		//if the metadata class has been registered, index it by that type as well
		var type:Class = Reflection.getMetadataClass(meta);
		if(type != null)
		{
			if(m_metadataByName[type] != null)
			{
				throw new Error("Metadata tag of type \"" + type + "\" defined twice on the same member");
			}
			else
			{
				m_metadataByName[type] = meta;
			}
		}
	}
}

}