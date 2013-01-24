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
	private var m_currentState:uint;
	
	public function NativeRandomGenerator()
	{
		
	}
	
	[Inline]
	public function get period():uint { return 2147483647 /*int.MAX_VALUE*/; }
	
	[Inline]
	public final function get currentState():uint { return m_currentState; }
	
	public function next():uint
	{
		return m_currentState = Math.random() * 2147483647;
	}
}
}