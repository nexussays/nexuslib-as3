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
package nexus.vcs.git.objects
{

import flash.errors.IllegalOperationError;
import flash.utils.*;
import nexus.vcs.git.GitManager;

/**
 * Abstract class to represent the data held in a git object.
 * @see: http://www.kernel.org/pub/software/scm/git/docs/v1.7.3/user-manual.html#object-details
 */
public class AbstractGitObject
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	protected var m_hash : String;
	protected var m_size : int;
	protected var m_repo : GitManager;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function AbstractGitObject(hash:String, repo:GitManager, size:int=-1)
	{
		m_hash = hash;
		m_repo = repo;
		m_size = size;
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get hash():String { return m_hash; }
	
	public function get size():int { return m_size; }
	
	public function get type():String
	{
		throw new IllegalOperationError("This method must be implemented by a subclass");
	}
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	public function generateBytes():ByteArray
	{
		throw new IllegalOperationError("This method must be implemented by a subclass");
	}
	
	public function populateContent(content:IDataInput, size:int=-1):void
	{
		if(size == -1)
		{
			if(m_size == -1)
			{
				throw new Error("Size never set on object " + m_hash);
			}
		}
		else
		{
			if(m_size != -1 && m_size != size)
			{
				throw new Error("Different sizes provided for object " + m_hash);
			}
			m_size = size;
		}
	}
	
	public function toString(verbose:Boolean = false):String
	{
		return "[GitObject:" + m_hash + "]";
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
}

}