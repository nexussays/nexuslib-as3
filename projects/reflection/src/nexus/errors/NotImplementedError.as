// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.errors
{

import flash.errors.IllegalOperationError;
import flash.utils.*;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 */
public class NotImplementedError extends IllegalOperationError
{
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function NotImplementedError(id:int=0)
	{
		super("Not Implemented", id);
	}

}

}