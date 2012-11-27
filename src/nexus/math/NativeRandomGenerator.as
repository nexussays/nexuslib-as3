// Copyright 2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.math
{

import flash.utils.*;

/**
 * Random number generator using the built-in Math.random() function
 */
public final class NativeRandomGenerator implements IPRNG
{
	private var m_state:int;
	
	public function NativeRandomGenerator()
	{
		
	}
	
	[Inline]
	public final function get state():int { return m_state; }
	
	public function next():int
	{
		return m_state = Math.random() * int.MAX_VALUE;
	}
}
}