// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.vcs.git.objects
{

import flash.errors.IllegalOperationError;
import flash.utils.*;
import nexus.vcs.git.GitRepository;

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
	protected var m_repo : GitRepository;
	//HACK: hack for packfiles, will refactor out once logic works
	private var m_bytes : ByteArray;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function AbstractGitObject(hash:String, repo:GitRepository)
	{
		m_hash = hash;
		m_repo = repo;
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
	
	public function get bytes():ByteArray
	{
		m_bytes.position = 0;
		var foo : ByteArray = new ByteArray();
		m_bytes.readBytes(foo);
		return foo;
	}
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	public function generateBytes():ByteArray
	{
		throw new IllegalOperationError("This method must be implemented by a subclass");
	}
	
	public function populateContent(content:IDataInput, size:int):void
	{
		if(size <= 0)
		{
			throw new ArgumentError("Invalid size " + size + " provided for object " + m_hash);
		}
		m_size = size;
		m_bytes = new ByteArray();
		content.readBytes(m_bytes);
		ByteArray(content).position = 0;
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