// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.errors
{

import flash.utils.*;

/**
 * Thrown by various methods in the Reflection framework when a class object cannot be found in a particular context.
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 */
public class ClassNotFoundError extends Error
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_qualifiedClassName : String;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function ClassNotFoundError(qualifiedName : String)
	{
		super("Cannot find definition for " + qualifiedName + ", the class is either not present in the application domain or is not public.");
		
		m_qualifiedClassName = qualifiedName;
		this.name = "ClassNotFoundError";
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get qualifiedClassName():String { return m_qualifiedClassName; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
}

}