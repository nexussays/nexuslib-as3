// Copyright (c) 2013 Robert Zubek and SomaSim LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
package nexus.math
{

import flash.utils.*;

/**
 * Actionscript port of the TinyMT random number generator, a small-footprint
 * variant of the Mersenne Twister.
 *
 * <p> Original algorithm by Mutsuo Saito and Makoto Matsumoto.
 * http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/TINYMT/index.html
 */
public class TinyMersenneTwisterGenerator implements ISeededPRNG
{
   // initialization constants (in the MT reference implementation
	// they're specified by the user during initialization, but they don't change)
	private static const MAT1:uint = 0x70707070;
	private static const MAT2:uint = 0x07070707;
	private static const TMAT:uint = 0x55555555;
	
	protected static const MIN_LOOP:int = 8;
	protected static const PRE_LOOP:int = 8;

	private var m_seed:uint;
	private var m_currentState:uint;
	private var m_numbersGenerated:int;
	
	public function TinyMersenneTwisterGenerator(seed:uint = 1)
	{
		this.seed = seed;
	}
	
	public final function get seed():uint { return m_seed; }
	public final function set seed(value:uint):void
	{
		m_seed = value;
		m_currentState = m_seed;
		m_numbersGenerated = 0;
		
      stateVars[0] = m_seed;
		stateVars[1] = MAT1;
		stateVars[2] = MAT2;
		stateVars[3] = TMAT;
		
		for(var i:int = 1; i < MIN_LOOP; i++)
		{
			stateVars[i & 3] ^= i + 1812433253 * (stateVars[(i - 1) & 3] ^ (stateVars[(i - 1) & 3] >>> 30));
		}
		
		for(var j:int = 0; j < PRE_LOOP; j++)
		{
			nextState();
		}
	}
	
	public final function get currentState():uint { return m_currentState; }
	
	[Inline]
	public function get period():uint { return 4294967295; }
	
	public final function get numbersGenerated():int
	{
		return m_numbersGenerated;
	}
	
	public function next():uint
	{
		nextState();
		return temper();
	}
	
	// state variables
	private const stateVars:Vector.<uint> = new Vector.<uint>(4, true);
	
	/**
	 * Advances internal state
	 */
	[Inline]
	private final function nextState():void
	{
		var x:uint;
		var y:uint;
		
		y = stateVars[3];
		x = (stateVars[0] & 0x7fffffff) ^ stateVars[1] ^ stateVars[2];
		x ^= (x << 1);
		y ^= (y >>> 1) ^ x;
		stateVars[0] = stateVars[1];
		stateVars[1] = stateVars[2];
		stateVars[2] = x ^ (y << 10);
		stateVars[3] = y;
		stateVars[1] ^= -(y & 1) & MAT1;
		stateVars[2] ^= -(y & 1) & MAT2;
		
		m_numbersGenerated++;
	}
	
	/**
	 * Outputs an unsigned int from the current internal stats
	 */
	[Inline]
	private final function temper():uint
	{
		var t0:uint = stateVars[3];
		var t1:uint = stateVars[0] ^ (stateVars[2] >>> 8);
		t0 ^= t1;
		t0 ^= -(t1 & 1) & TMAT;
		return t0;
	}
}

}