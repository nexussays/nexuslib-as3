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
	
	public function test_distribution():void
	{
		var dist:Dictionary = new Dictionary();
		for(var x:int = 0; x < DISTRIBUTION_ITERATIONS; ++x)
		{
			var num:int = ((m_generator.next() / int.MAX_VALUE) * (10 - 0)) + 0;
			if(!(num in dist))
			{
				dist[num] = 0;
			}
			dist[num]++;
		}
		
		//trace(m_generator);
		for(x = 0; x < 10; ++x)
		{
			if(!(x in dist))
			{
				dist[x] = 0;
			}
				//trace(x, dist[x]);
		}
	}
	
	public function test_monteCarlo():void
	{
		for(var x:int = 0; x < 10; ++x)
		{
			runMonteCarloTest();
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
	
	protected function runMonteCarloTest():void
	{
		var inCircle:int = 0;
		for(var i:int = 0; i < DISTRIBUTION_ITERATIONS; ++i)
		{
			// xr and yr will be the random point
			var xr:Number = m_generator.next() / m_generator.period;
			var yr:Number = m_generator.next() / m_generator.period;
			// zr will be the calculated distance to the center
			var zr:Number = (xr * xr) + (yr * yr);
			
			if(zr <= 1.0)
			{
				inCircle++;
			}
		}
		
		// calculate the Pi approximations
		var calculatedPi:Number = inCircle / DISTRIBUTION_ITERATIONS * 4;
		
		// calculate the % error
		var error:Number = Math.abs((calculatedPi - Math.PI) / Math.PI * 100);
		var resultText : String = "Random Pi Approximation: " + calculatedPi + " Error: " + (Math.floor(error * 100) / 100) + "%";
		//trace(resultText);
		assertTrue(resultText, error < 1.5);
	}
}

}