// Copyright 2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.math
{

import flash.utils.*;

/**
 * Variant on Linear Congruential Generator.
 * @see http://en.wikipedia.org/wiki/Lehmer_random_number_generator
 */
public final class LehmerGenerator implements IPRNG
{
	private var m_startingSeed:int;
	private var m_state:int;
	private var m_numbersGenerated:int;
	
	public function LehmerGenerator(seed:int)
	{
		m_startingSeed = seed;
		m_state = m_startingSeed;
	}
	
	[Inline]
	public final function get startingSeed():int { return m_startingSeed; }
	
	[Inline]
	public final function get state():int { return m_state; }
	
	[Inline]
	public final function get numbersGenerated():int { return m_numbersGenerated; }
	
	public function next():int
	{
		++m_numbersGenerated;
		return m_state = ((m_state * 16807) % 2147483647);
		//return m_state = ((m_state * 279470273) % 4294967291);
	}
}
}