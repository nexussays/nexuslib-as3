// Copyright 2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package test.nexus.math
{

import asunit.framework.TestCase;
import flash.utils.Dictionary;
import flash.utils.getTimer;

import nexus.math.*;

/**
 * ...
 */
public class AbstractIPRNGTest extends TestCase
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	private static const DISTRIBUTION_ITERATIONS : int = 1000;
	private static const STRESS_ITERATIONS : int = 1000000;
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	protected var m_algorithm : Class;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function AbstractIPRNGTest(testMethod:String = null)
	{
		super(testMethod);
	}
	
	//--------------------------------------
	//	SETUP & TEARDOWN
	//--------------------------------------
	
	override protected function setUp():void
	{
		
	}
	
	override protected function tearDown():void
	{
		
	}
	
	//--------------------------------------
	//	TESTS
	//--------------------------------------
	
	public function test_seeds():void
	{
		assertEqualsArrays(get100(m_algorithm, 0), get100(m_algorithm, 0));
		assertEqualsArrays(get100(m_algorithm, 1), get100(m_algorithm, 1));
		assertEqualsArrays(get100(m_algorithm, 2), get100(m_algorithm, 2));
		assertEqualsArrays(get100(m_algorithm, 1000), get100(m_algorithm, 1000));
		//prime
		assertEqualsArrays(get100(m_algorithm, 214021), get100(m_algorithm, 214021));
		
		assertEqualsArrays(get100(m_algorithm, int.MAX_VALUE), get100(m_algorithm, int.MAX_VALUE));
		assertEqualsArrays(get100(m_algorithm, int.MIN_VALUE), get100(m_algorithm, int.MIN_VALUE));
		assertEqualsArrays(get100(m_algorithm, uint.MAX_VALUE), get100(m_algorithm, uint.MAX_VALUE));
		assertEqualsArrays(get100(m_algorithm, uint.MIN_VALUE), get100(m_algorithm, uint.MIN_VALUE));
	}
	
	public function test_distribution():void
	{
		var prng : IPRNG = new m_algorithm((new Date()).getTime());
		var dist : Dictionary = new Dictionary();
		for(var x : int = 0; x < DISTRIBUTION_ITERATIONS; ++x)
		{
			var num : int = ((prng.next()/ int.MAX_VALUE) * (10 - 0)) + 0;
			if(!(num in dist))
			{
				dist[num] = 0;
			}
			dist[num]++;
		}
		
		for(x = 0; x < 10; ++x)
		{
			trace(x, dist[x]);
		}
	}
	
	/*
	public function test_performance():void
	{
		var prng : IPRNG = new m_algorithm(100);
		
		var start : int = getTimer();
		for(var x : int = 0; x < STRESS_ITERATIONS; ++x)
		{
			prng.next();
			//Math.random();
		}
		var end : int = getTimer() - start;
		trace("test_performance", m_algorithm, STRESS_ITERATIONS + " iterations: " + end + "ms");
		assertTrue(end < 1000);
	}
	//*/
	
	//--------------------------------------
	//	HELPER METHODS
	//--------------------------------------
	
	private function get100(type:Class, seed:int):Array
	{
		var result : Array = [];
		var prng : IPRNG = new type(seed);
		for(var x : int = 0; x < 100; ++x)
		{
			result[x] = prng.next();
		}
		return result;
	}
}
	
}