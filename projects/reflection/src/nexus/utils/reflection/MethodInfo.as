// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.utils.reflection
{

import nexus.errors.NotImplementedError;
import flash.utils.*;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 */
public final class MethodInfo extends AbstractMemberInfo
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
	private var m_requiredParametersCount : int;
	
	///@see toString
	private var m_parametersString : String;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function MethodInfo(name:String, isStatic:Boolean, returnType:Class, declaringType:Class, reflectedTypeInfo:TypeInfo, paramCount:int)
	{
		super(name, isStatic, declaringType, reflectedTypeInfo);
		
		m_returnType = returnType;
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
	 * The parameters this method takes, indexed by their order in the method signature
	 */
	public function get parameters():Vector.<MethodParameterInfo> { return m_parameters; }
	
	/**
	 * The number of method parameters that are required
	 */
	public function get requiredParametersCount():int { return m_requiredParametersCount; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	/**
	 * Invokes the method on the provided instance using the specified parameters.
	 * @param	scope
	 * @param	...params
	 * @return	Returns the result of the method invocation or null if the return type is void
	 */
	public function invoke(scope:Object, ...params):Object
	{
		//TODO: Decide if this is necessary or if we can let errors fall through and throw when apply() is called
		if((!m_isStatic && !(scope is m_declaringType)) || (m_isStatic && scope != m_declaringType))
		{
			throw new ArgumentError("Cannot invoke " + this.toString() + ", declared on " + Reflection.getQualifiedClassName(m_declaringType) + ", on an object of type " + Reflection.getQualifiedClassName(scope) + ".");
		}
		//TODO: Decide if this is necessary or if we can let errors fall through and throw when apply() is called
		/*
		for(var x : int = 0; x < m_parameters.length; ++x)
		{
			var paramInfo : MethodParameterInfo = m_parameters[x];
			if(x >= params.length)
			{
				if(!paramInfo.isOptional)
				{
					throw new ArgumentError("Cannot invoke " + this.toString() + " with " + params.length + " arguments.");
				}
			}
			else if(!(params[x] is paramInfo.type))
			{
				throw new ArgumentError("Cannot invoke " + this.toString() + " with an argument of type " + Reflection.getQualifiedClassName(params[x]) + " at position " + x + ".");
			}
		}
		//*/
		
		if(m_returnType != null)
		{
			return scope[m_qname].apply(scope, params);
		}
		else
		{
			scope[m_qname].apply(scope, params);
			return null;
		}
	}
	
	public function toString():String
	{
		if(m_returnTypeName == null)
		{
			m_returnTypeName = (m_returnType == null ? "void" : Reflection.getUnqualifiedClassName(m_returnType));
		}
		
		if(m_parametersString == null)
		{
			m_parametersString = "";
			for each(var param : MethodParameterInfo in m_parameters)
			{
				m_parametersString += param.toString() + (param.isOptional ? "?" : "") + ",";
			}
			m_parametersString = m_parametersString.substr(0, m_parametersString.length - 1);
		}
		
		return "[" + (m_isStatic ? "Static" : "") + "Method|" + m_name + "(" + m_parametersString + "):" + m_returnTypeName + "]";
	}
	
	//--------------------------------------
	//	INTERNAL INSTANCE METHODS
	//--------------------------------------
	
	internal function addMethodParameter(param:MethodParameterInfo):void
	{
		m_parameters[param.position] = param;
		if(!param.isOptional)
		{
			m_requiredParametersCount++;
		}
	}
}

}