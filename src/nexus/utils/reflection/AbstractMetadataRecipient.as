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
 * The Original Code is PROJECT_NAME.
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

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	9/21/2011 2:57 AM
 */
public class AbstractMetadataRecipient
{
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	protected var m_name:String;
	
	private var m_metadataIndex:int = 0;
	protected var m_metadata:Vector.<MetadataInfo>;
	protected var m_metadataByName:Dictionary;
	///if provided, metadata tags can be parsed into classes that are registered with Metadata
	protected var m_metadataInstances:Dictionary;
	
	///as defined in the debug-only metadata tag __go_to_definition_help
	protected var m_position:int;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function AbstractMetadataRecipient(name:String, metadataCount:int)
	{
		m_name = name;
		
		m_metadata = new Vector.<MetadataInfo>(metadataCount, true);
		m_metadataByName = new Dictionary();
		m_metadataInstances = new Dictionary();
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
	
	public function getTypdMetadataByClass(type:Class):Metadata
	{
		return m_metadataInstances[type] as Metadata;
	}
	
	public function getTypdMetadataByName(name:String):Metadata
	{
		return m_metadataInstances[name] as Metadata;
	}
	
	//--------------------------------------
	//	INTERNAL INSTANCE METHODS
	//--------------------------------------
	
	internal function setPosition(value:int):void
	{
		m_position = value;
	}
	
	internal function addMetadataInfo(meta:MetadataInfo):void
	{
		m_metadata[m_metadataIndex++] = meta;
		m_metadataByName[meta.name] = meta;
	}
	
	internal function addMetadataInstance(meta:Metadata, name:String):void
	{
		var type:Class = Reflection.getClass(meta);
		if(m_metadataInstances[type] != null)
		{
			throw new Error("Metadata tag of type \"" + type + "\" defined twice on the same member");
		}
		else
		{
			m_metadataInstances[type] = meta;
			m_metadataInstances[name] = meta;
		}
	}
}

}