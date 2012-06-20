/* Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package nexus.utils.reflection
{

import flash.utils.*;

/**
 * Base class for reflected member info for a class
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
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