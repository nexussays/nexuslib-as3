// Copyright 2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package test.nexus.math
{

import asunit.framework.TestCase;

import flash.utils.*;

import nexus.math.*;

/**
 * ...
 */
public class AbstractIPRNGTest extends TestCase
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	public static const DISTRIBUTION_ITERATIONS:int = 10000;
	public static const STRESS_ITERATIONS:int = 1000000;
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	protected var m_generator:IPRNG;
	
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
	
	public function test_monteCarlo():void
	{
		for(var x:int = 0; x < 10; ++x)
		{
			runMonteCarloTest();
		}
	}
	
	public function off_test_performance():void
	{
		var start:int = getTimer();
		for(var x:int = 0; x < STRESS_ITERATIONS; ++x)
		{
			m_generator.next();
		}
		var end:int = getTimer() - start;
		trace("test_performance", m_generator, STRESS_ITERATIONS + " iterations: " + end + "ms");
		assertTrue(end < 800);
	}
	
	public function test_randomInteger():void
	{
		var rand : Random = new Random(m_generator);
		var highHit : Boolean = false;
		var lowHit : Boolean = false;
		const low : int = 1;
		const high : int = 100;
		for(var x : int = 0; x < DISTRIBUTION_ITERATIONS; ++x)
		{
			var num : int = rand.integer(low, high);
			assertTrue(num + " is not <= " + high,	num <= high);
			assertTrue(num + " is not >= " + low,	num >= low);
			if(!lowHit && num == low)
			{
				lowHit = true;
			}
			if(!highHit && num == high)
			{
				highHit = true;
			}
		}
		
		assertTrue(high + " never generated", highHit);
		assertTrue(low + " never generated", lowHit);
	}
	
	public function test_randomFloat():void
	{
		var rand : Random = new Random(m_generator);
		var highHit : Boolean = false;
		var lowHit : Boolean = false;
		const low : Number = 1.0;
		const high : Number = 100.0;
		for(var x : int = 0; x < DISTRIBUTION_ITERATIONS; ++x)
		{
			var num : int = rand.float(low, high);
			assertTrue(num + " is not <= " + high,	num <= high);
			assertTrue(num + " is not >= " + low,	num >= low);
			if(!lowHit && num == low)
			{
				lowHit = true;
			}
			if(!highHit && num == high - 1)
			{
				highHit = true;
			}
		}
		
		assertTrue((high - 1).toFixed(1) + " never generated", highHit);
		assertTrue(low.toFixed(1) + " never generated", lowHit);
	}
	
	public function test_boolean():void
	{
		var rand : Random = new Random(m_generator);
		var trueCount : int = 0;
		var falseCount : int = 0;
		for(var x : int = 0; x < DISTRIBUTION_ITERATIONS; ++x)
		{
			if(rand.boolean())
			{
				trueCount++;
			}
			else
			{
				falseCount++;
			}
		}
		var diff : int = Math.abs(trueCount - falseCount);
		trace("test_boolean", m_generator, diff, trueCount, falseCount, diff / DISTRIBUTION_ITERATIONS * 100);
		assertTrue((diff / DISTRIBUTION_ITERATIONS * 100) < 2.0);
	}
	
	public function test_round1():void
	{
		var rand : Random = new Random(m_generator);
		var upCount : int = 0;
		var downCount : int = 0;
		const num : Number = 4.5;
		for(var x : int = 0; x < DISTRIBUTION_ITERATIONS; ++x)
		{
			if(rand.round(num) == 4)
			{
				downCount++;
			}
			else
			{
				upCount++;
			}
		}
		var diff : int = Math.abs(upCount - downCount);
		trace("test_round1", m_generator, diff, upCount, downCount, diff / DISTRIBUTION_ITERATIONS * 100);
		assertTrue((diff / DISTRIBUTION_ITERATIONS * 100) < 2.0);
	}
	
	//--------------------------------------
	//	HELPER METHODS
	//--------------------------------------
	
	protected function runMonteCarloTest():void
	{
		var inCircle:int = 0;
		for(var i:int = 0; i < DISTRIBUTION_ITERATIONS; ++i)
		{
			var xr:Number = m_generator.next() / m_generator.period;
			var yr:Number = m_generator.next() / m_generator.period;
			// find the calculated distance to the center
			if((xr * xr) + (yr * yr) <= 1.0)
			{
				inCircle++;
			}
		}
		
		// calculate the Pi approximations
		var calculatedPi:Number = inCircle / DISTRIBUTION_ITERATIONS * 4;
		
		// calculate the % error
		var error:Number = Math.abs((calculatedPi - Math.PI) / Math.PI * 100);
		
		var resultText:String = "Random Pi Approximation: " + calculatedPi + " Error: " + (Math.floor(error * 100) / 100) + "%";
		//trace(m_generator + " " + resultText);
		
		assertTrue(resultText, error < 1.5);
	}
}

}