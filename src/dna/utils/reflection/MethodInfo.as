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

import dna.errors.NotImplementedError;
import flash.utils.*;

/**
 * ...
 * @author mgriffie
 * @since 7/23/2011 3:34 AM
 */
public class MethodInfo extends AbstractMemberInfo
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_returnType:Class;
	private var m_returnTypeName : String;
	private var m_parameters : Vector.<MethodParameterInfo>;
	private var m_isStatic : Boolean;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function MethodInfo(name:String, isStatic:Boolean, returnType:Class, declaringType:Class, reflectedType:Class, reflectedTypeInfo:TypeInfo, paramCount:int, metadataCount:int)
	{
		super(name, declaringType, reflectedType, reflectedTypeInfo, metadataCount);
		
		m_returnType = returnType;
		m_isStatic = isStatic;
		m_parameters = new Vector.<MethodParameterInfo>(paramCount, true);
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	/**
	 * The return type of this method. If the return type is void, this will return null
	 */
	public function get returnType():Class { return m_returnType; }
	
	/**
	 * The parameters this method takes, indexed by their order they are passed to the method
	 */
	public function get parameters():Vector.<MethodParameterInfo> { return m_parameters; }
	
	public function get isStatic():Boolean { return m_isStatic; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	/**
	 * Invokes the method on the provided instance using the specified parameters.
	 * @param	scope
	 * @param	...params
	 * @return
	 */
	public function invoke(scope:Object, ...params):Object
	{
		if(m_returnType != null)
		{
			return scope[m_name].apply(scope, params);
		}
		else
		{
			scope[m_name].apply(scope, params);
			return null;
		}
	}
	
	public function toString():String
	{
		if(m_returnTypeName == null)
		{
			m_returnTypeName = (m_returnType == null ? "void" : Reflection.getUnqualifiedClassName(m_returnType));
		}
		return "[" + (m_isStatic ? "Static" : "") + "Method|" + m_name + "(" + m_parameters.join(",") + "):" + m_returnTypeName + "]";
	}
	
	//--------------------------------------
	//	INTERNAL INSTANCE METHODS
	//--------------------------------------
	
	internal function addMethodParameter(param:MethodParameterInfo):void
	{
		m_parameters[param.position] = param;
	}
}

}