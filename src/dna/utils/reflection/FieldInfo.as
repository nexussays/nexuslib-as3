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
public class FieldInfo extends AbstractMemberInfo
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_type:Class;
	private var m_typeName : String;
	
	private var m_isStatic : Boolean;
	private var m_isConstant : Boolean;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function FieldInfo(name:String, isStatic:Boolean, isConstant:Boolean, type:Class, declaringType:Class, reflectedType:Class, reflectedTypeInfo:TypeInfo, metadatacount:int)
	{
		super(name, declaringType, reflectedType, reflectedTypeInfo, metadatacount);
		
		m_type = type;
		m_isStatic = isStatic;
		m_isConstant = isConstant;
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get type():Class { return m_type; }
	
	public function get isStatic():Boolean { return m_isStatic; }
	
	public function get isConstant():Boolean { return m_isConstant; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	public function toString():String
	{
		if(m_typeName == null)
		{
			m_typeName = Reflection.getUnqualifiedClassName(m_type);
		}
		return "[" + (m_isStatic ? "Static" : "") + (m_isConstant ? "Constant" : "Variable") + "|" + m_name + ":" + m_typeName + "]";
	}
}

}