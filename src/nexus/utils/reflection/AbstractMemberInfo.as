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
 * Base class for reflected member info for a class
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since 7/23/2011 3:34 AM
 */
public class AbstractMemberInfo extends AbstractMetadataRecipient
{
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	protected var m_declaringType:Class;
	protected var m_reflectedFrom : TypeInfo;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function AbstractMemberInfo(name:String, declaringType:Class, reflectedTypeInfo:TypeInfo, metadataCount:int)
	{
		super(name, metadataCount);
		
		m_declaringType = declaringType;
		m_reflectedFrom  = reflectedTypeInfo;
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	/**
	 * The class which declares this member
	 */
	public function get declaringType():Class { return m_declaringType; }
	
	/**
	 * The TypeInfo that was created to derive this member info
	 */
	public function get reflectedFrom():TypeInfo { return m_reflectedFrom; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	//--------------------------------------
	//	PROTECTED INSTANCE METHODS
	//--------------------------------------
	
}

}