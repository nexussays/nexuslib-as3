// Copyright 2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.math
{

import flash.utils.*;

/**
 * Given a random number generator, this class provides convenience methods for
 * random number generation and other random operations.
 */
public class Random
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	private static const s_random:Random = new Random(new NativeRandomGenerator());
	
	public static function get instance():Random
	{
		return s_random;
	}
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_generator:IPRNG;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function Random(generator:IPRNG)
	{
		m_generator = generator;
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	/**
	 * Generates a random floating point in the range [min, max) which is [0, 1) if neither
	 * argument is given.
	 *
	 * If max is NaN, Infinity, or -Infinity, a number in the range [min, 1) is returned
	 * If min is NaN, Infinity, or -Infinity, a number in the range [0, max) is returned
	 * @param	min		The lowest value to return, inclusive
	 * @param	max		The highest value to return, exclusive
	 * @return A number in the range [min, max)
	 */
	public function float(min:Number = NaN, max:Number = NaN):Number
	{
		min = isNaN(min) || !isFinite(min) ? 0 : min;
		max = isNaN(max) || !isFinite(max) ? 1 : max;
		var p:Number = m_generator.next() / m_generator.period;
		return (p * (max - min)) + min;
	}
	
	/**
	 * Generates a random integer in the range [min, max)
	 * @param	min		The lowest value to return, inclusive
	 * @param	max		The highest value to return, exclusive
	 * @return An int in the range [min, max)
	 */
	public function integer(min:uint = 0, max:int = int.MAX_VALUE):int
	{
		return m_generator.next() % (max - min) + min;
	}
	
	/**
	 * Generates a random unsigned integer in the range [min, max)
	 * @param	min		The lowest value to return, inclusive
	 * @param	max		The highest value to return, exclusive
	 * @return A uint in the range [min, max)
	 */
	public function unsignedInteger(min:uint = 0, max:uint = uint.MAX_VALUE):uint
	{
		return m_generator.next() % (max - min) + min;
	}
	
	/**
	 * Returns a random true/false value, with a 50% chance of either
	 */
	public function boolean():Boolean
	{
		return(m_generator.next() / m_generator.period) < 0.5;
	}
	
	/**
	 * Given a floating-point value, return either the value's floor or its ceiling
	 * chosen randomly according to whether the value is closer to the floor or
	 * the ceiling.
	 * @example <code>randomRound(4.3)</code> should return 4 70% of the time
	 * and 5 30% of the time.
	 */
	public function weightedRound(value:Number):int
	{
		var floor:int = Math.floor(value);
		return(m_generator.next() / m_generator.period) > (value - floor) ? floor : floor + 1;
	}
	
	/**
	 * Returns one of the items passed in at random.
	 * @param items A vararg list of objects to choose from. If a single argument is passed, it
	 * is assumed to be a Vector or Array (or otherwise have a <code>length</code> property and
	 * be able to be accessed with the index operators).
	 */
	public function choice(... items):Object
	{
		var choice:int;
		if(items.length == 1)
		{
			choice = integer(0, items[0].length - 1);
			return items[0][choice];
		}
		else
		{
			choice = integer(0, items.length - 1);
			return items[choice];
		}
	}
	
	/**
	 * Destructively shuffles the container using the Fisher-Yates algorithm.
	 */
	public function shuffle(container:Object):void
	{
		for(var x:int = container.length - 1; x > 0; x--)
		{
			var j:int = integer(0, x + 1);
			var tmp:* = container[x];
			container[x] = container[j];
			container[j] = tmp;
		}
	}
	
	public function toString(verbose:Boolean = false):String
	{
		return "[Random" + m_generator + "]";
	}

	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
}

}