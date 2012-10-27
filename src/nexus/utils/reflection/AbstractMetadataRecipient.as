// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.utils.reflection
{

import flash.utils.*;
import nexus.nexuslib_internal;

/**
 * Abstract base class for any reflected object that can be tagged with metadata which includes all members
 * as well as TypeInfo itself
 */
public class AbstractMetadataRecipient
{
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	/**
	 * @private
	 */
	protected var m_name:String;
	
	/**
	 * @private
	 */
	protected var m_metadata:Vector.<MetadataInfo>;
	
	/**
	 * @private
	 */
	protected var m_metadataByName:Dictionary;
	
	/**
	 * @private
	 * As defined in the debug-only metadata tag __go_to_definition_help
	 */
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
	
	/**
	 * @private
	 */
	internal function setPosition(value:int):void
	{
		m_position = value;
	}
	
	/**
	 * @private
	 */
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