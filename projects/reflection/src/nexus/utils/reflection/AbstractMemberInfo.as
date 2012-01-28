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
	
	protected var m_isStatic : Boolean;
	
	protected var m_namespace : Namespace;
	protected var m_qname : QName;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function AbstractMemberInfo(name:String, isStatic:Boolean, declaringType:Class, reflectedTypeInfo:TypeInfo)
	{
		super(name);
		
		m_isStatic = isStatic;
		
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
	
	public function get isStatic():Boolean { return m_isStatic; }
	
	/**
	 * The namespace of this member, if one exists.
	 */
	public function get namespace():Namespace { return m_namespace; }
	
	/**
	 * The QName of this member. Use this for access instead of name
	 */
	public function get qname():QName { return m_qname; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	//--------------------------------------
	//	INTERNAL INSTANCE METHODS
	//--------------------------------------
	
	internal function assignNamespace(ns:Namespace):void
	{
		m_namespace = ns;
		m_qname = new QName(m_namespace == null ? "" : m_namespace, m_name);
	}
}

}