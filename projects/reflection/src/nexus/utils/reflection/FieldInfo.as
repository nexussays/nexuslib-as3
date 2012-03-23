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

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 */
public final class FieldInfo extends AbstractFieldInfo
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function FieldInfo(name:String, isStatic:Boolean, type:Class, declaringType:Class, reflectedTypeInfo:TypeInfo, write:Boolean)
	{
		super(name, isStatic, type, declaringType, reflectedTypeInfo, true, write);
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get isConstant():Boolean { return !m_canWrite; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	override public function toString():String
	{
		if(m_typeName == null)
		{
			m_typeName = Reflection.getUnqualifiedClassName(m_type);
		}
		return "[" + (m_isStatic ? "Static" : "") + (m_canWrite ? "Variable" : "Constant") + "|" + m_name + ":" + m_typeName + "]";
	}
}

}