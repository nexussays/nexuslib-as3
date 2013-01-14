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
public final class LehmerGenerator implements ISeededPRNG
{
	private var m_seed:int;
	private var m_currentState:uint;
	private var m_numbersGenerated:int;
	
	public function LehmerGenerator(seed:int=1)
	{
		this.seed = seed;
	}
	
	[Inline]
	public final function get seed():int { return m_seed; }
	public final function set seed(value:int):void
	{
		//if(value > 0 && value < 2147483647)
		//{
		m_seed = value;
		m_currentState = m_seed;
		m_numbersGenerated = 0;
		//}
		//else
		//{
			//throw new ArgumentError("Seed must be between 0 and 2147483647");
		//}
	}
	
	[Inline]
	public final function get currentState():uint { return m_currentState; }
	
	[Inline]
	public function get period():int { return 2147483647 /*int.MAX_VALUE*/; }
	
	[Inline]
	public final function get numbersGenerated():int { return m_numbersGenerated; }
	
	public function next():uint
	{
		++m_numbersGenerated;
		return m_currentState = ((m_currentState * 16807) % 2147483647);
		//return m_state = ((m_state * 279470273) % 4294967291);
	}
}
}