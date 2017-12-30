// Copyright M. Griffie <nexus@nexussays.com>
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
public class AbstractISeededPRNGTest extends AbstractIPRNGTest
{
   //--------------------------------------
   //   CLASS CONSTANTS
   //--------------------------------------
   
   private static const DISTRIBUTION_ITERATIONS : int = 1000;
   private static const STRESS_ITERATIONS : int = 1000000;
   
   //--------------------------------------
   //   INSTANCE VARIABLES
   //--------------------------------------
   
   protected var m_algorithm : Class;
   private var m_seededGenerator1 : ISeededPRNG;
   private var m_seededGenerator2 : ISeededPRNG;
   
   //--------------------------------------
   //   CONSTRUCTOR
   //--------------------------------------
   
   public function AbstractISeededPRNGTest(testMethod:String = null)
   {
      super(testMethod);
   }
   
   //--------------------------------------
   //   SETUP & TEARDOWN
   //--------------------------------------
   
   override protected function setUp():void
   {
      m_seededGenerator1 = new m_algorithm();
      m_seededGenerator1.seed = (new Date()).getTime();
      m_seededGenerator2 = new m_algorithm();
      m_seededGenerator2.seed = (new Date()).getTime() - getTimer();
      m_generator = m_seededGenerator1;
   }
   
   override protected function tearDown():void
   {
      
   }
   
   //--------------------------------------
   //   TESTS
   //--------------------------------------
   
   public function test_seeds():void
   {
      assertEqualsArrays(get100(m_seededGenerator1, 0),      get100(m_seededGenerator2, 0));
      assertEqualsArrays(get100(m_seededGenerator1, 1),      get100(m_seededGenerator2, 1));
      assertEqualsArrays(get100(m_seededGenerator1, 2),      get100(m_seededGenerator2, 2));
      assertEqualsArrays(get100(m_seededGenerator1, 1000),    get100(m_seededGenerator2, 1000));
      //prime
      assertEqualsArrays(get100(m_seededGenerator1, 214021),   get100(m_seededGenerator2, 214021));
      
      assertEqualsArrays(get100(m_seededGenerator1, int.MAX_VALUE),   get100(m_seededGenerator2, int.MAX_VALUE));
      assertEqualsArrays(get100(m_seededGenerator1, int.MIN_VALUE),   get100(m_seededGenerator2, int.MIN_VALUE));
      assertEqualsArrays(get100(m_seededGenerator1, uint.MAX_VALUE),   get100(m_seededGenerator2, uint.MAX_VALUE));
      assertEqualsArrays(get100(m_seededGenerator1, uint.MIN_VALUE),    get100(m_seededGenerator2, uint.MIN_VALUE));
   }
   
   //--------------------------------------
   //   HELPER METHODS
   //--------------------------------------
   
   private function get100(prng : ISeededPRNG, seed:int):Array
   {
      prng.seed = seed;
      var result : Array = [];
      for(var x : int = 0; x < 100; ++x)
      {
         result[x] = prng.next();
      }
      return result;
   }
   
   override protected function runMonteCarloTest():void
   {
      m_seededGenerator1.seed = (new Date()).getTime();
      super.runMonteCarloTest();
   }
}
   
}
