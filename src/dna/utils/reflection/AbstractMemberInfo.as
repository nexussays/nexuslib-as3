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
 * The Original Code is dna_lib.
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
 * ...
 * @author mgriffie
 * @since 7/23/2011 3:34 AM
 */
public class AbstractMemberInfo
{
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	protected var m_name : String;
	protected var m_declaringType:Class;
	protected var m_reflectedType:Class;
	//as defined in the debug-only metadata tag __go_to_definition_help
	protected var m_position : int;
	
	private var m_metadataIndex : int = 0;
	protected var m_metadata : Vector.<MetadataInfo>;
	protected var m_metadataByName : Dictionary;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function AbstractMemberInfo(name:String, declaringType:Class, reflectedType:Class, metadataCount:int)
	{
		m_name = name;
		m_declaringType = declaringType;
		m_reflectedType = reflectedType;
		
		m_metadata = new Vector.<MetadataInfo>(metadataCount, true);
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
	 * The class which declares this member
	 */
	public function get declaringType():Class { return m_declaringType; }
	
	/**
	 * The class which was reflected to derive this member info
	 */
	public function get reflectedType():Class { return m_reflectedType; }
	
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
	
	//--------------------------------------
	//	INTERNAL INSTANCE METHODS
	//--------------------------------------
	
	internal function addMetadata(meta:MetadataInfo):void
	{
		m_metadata[m_metadataIndex++] = meta;
		m_metadataByName[meta.name] = meta;
	}
	
	internal function setPosition(value:int):void
	{
		m_position = value;
	}
	
	//--------------------------------------
	//	PROTECTED INSTANCE METHODS
	//--------------------------------------
	
	protected function getStringForClass(type:Class):String
	{
		var str : String = type + "";
		return str.substr(str.indexOf(" "), str.length - 2);
	}
}

}