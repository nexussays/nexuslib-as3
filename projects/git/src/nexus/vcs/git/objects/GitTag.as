// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.vcs.git.objects
{

import flash.utils.ByteArray;

import nexus.vcs.git.*;

public class GitTag extends AbstractGitObject
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
	
	public function GitTag(hash:String, repo:GitRepository)
	{
		super(hash, repo);
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	override public function get type():String { return GitObjectTypes.TAG; }
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
}

}