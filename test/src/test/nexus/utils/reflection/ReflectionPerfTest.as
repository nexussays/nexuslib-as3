// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package test.nexus.utils.reflection
{

import asunit.framework.TestCase;
import flash.utils.getTimer;
import mock.foo.bar.TestClass;
import nexus.utils.reflection.Reflection;

/**
 * ...
 */
public class ReflectionPerfTest extends TestCase
{
   //--------------------------------------
   //   CLASS CONSTANTS
   //--------------------------------------
   
   //--------------------------------------
   //   INSTANCE VARIABLES
   //--------------------------------------
   
   //--------------------------------------
   //   CONSTRUCTOR
   //--------------------------------------
   
   public function ReflectionPerfTest(testMethod:String = null)
   {
      super(testMethod);
   }
   
   //--------------------------------------
   //   SETUP & TEARDOWN
   //--------------------------------------
   
   override protected function setUp():void
   {
      
   }
   
   override protected function tearDown():void
   {
      
   }
   
   //--------------------------------------
   //   TESTS
   //--------------------------------------
   
   public function test_isVector_perfHitString():void
   {
      var start : int = getTimer();
      var str : Vector.<String> = new Vector.<String>();
      for(var x : int = 0; x < 1000000; ++x)
      {
         Reflection.isVector(str);
      }
      var end : int = getTimer() - start;
      trace("test_isVector_perfHitString", end + "ms");
      assertTrue("test_isVector_perfHitString < 1000ms = " + end, end < 1000);
   }
   
   public function test_isVector_perfHitNumber():void
   {
      var start : int = getTimer();
      var num : Vector.<Number> = new Vector.<Number>();
      for(var x : int = 0; x < 1000000; ++x)
      {
         Reflection.isVector(num);
      }
      var end : int = getTimer() - start;
      trace("test_isVector_perfHitNumber", end + "ms");
      assertTrue("test_isVector_perfHitNumber < 1000ms = " + end, end < 1000);
   }
   
   public function test_isVector_perfMissClass():void
   {
      var start : int = getTimer();
      for(var x : int = 0; x < 1000000; ++x)
      {
         Reflection.isVector(TestClass);
      }
      var end : int = getTimer() - start;
      trace("test_isVector_perfMissClass", end + "ms");
      assertTrue("test_isVector_perfMissClass < 1000ms = " + end, end < 1000);
   }
   
   public function test_isVector_perfMissNonVector():void
   {
      var start : int = getTimer();
      var str : String = "";
      for(var x : int = 0; x < 1000000; ++x)
      {
         Reflection.isVector(str);
      }
      var end : int = getTimer() - start;
      trace("test_isVector_perfMissNonVector", end + "ms");
      assertTrue("test_isVector_perfMissNonVector < 1000ms = " + end, end < 1000);
   }
}
   
}
