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
package dna.utils.reflection
{

/**
 * ...
 * @author	Malachi Griffie <malachi@nexussays.com>
 * @since 7/23/2011 3:34 AM
 */
public class MethodParameterInfo
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_type : Class;
	private var m_typeName : String;
	private var m_isOptional : Boolean;
	private var m_position : int;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function MethodParameterInfo(type:Class, pos:int, isOptional:Boolean)
	{
		m_type = type;
		m_position = pos;
		m_isOptional = isOptional;
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	/**
	 * The type of this parameter. If the paramater is untyped, this will return null
	 */
	public function get type():Class { return m_type; }
	
	/**
	 * If the argument is optional to the method, that is, a default value is provided if the argument is not
	 */
	public function get isOptional():Boolean { return m_isOptional; }
	
	/**
	 * The zero-based position of the parameter in the parameter list
	 */
	public function get position():int { return m_position; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	public function toString():String
	{
		if(m_typeName == null)
		{
			m_typeName = Reflection.getUnqualifiedClassName(m_type);
		}
		return m_typeName;
	}
}

}