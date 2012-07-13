// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.vcs.git.errors
{

import flash.utils.*;
import nexus.vcs.git.GitPack;

/**
 * For errors occuring when reading or writing objects in a GitPack
 */
public class GitPackError extends Error
{
	private var m_packName : String;
	
	public function GitPackError(packName:String, message:String)
	{
		m_packName = packName;
		super("(" + m_packName + ") " + message);
		
		this.name = "GitPackError";
	}
	
	public function get packName():String { return m_packName; }
}

}