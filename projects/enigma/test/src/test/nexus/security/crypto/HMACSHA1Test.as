// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package test.nexus.security.crypto
{

import asunit.framework.TestCase;
import flash.utils.*;
import nexus.security.crypto.HMACSHA1;
import nexus.security.crypto.SHA1;
import nexus.utils.ByteUtils;

public class HMACSHA1Test extends TestCase
{
	public function HMACSHA1Test(testMethod:String = null)
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
	
	public function test_hash():void
	{
		assertEquals("effcdf6ae5eb2fa2d27416d5f184df9c259a7c79", ByteUtils.bytesToHexString(HMACSHA1.hash("Jefe", "what do ya want for nothing?")));
		assertEquals("fbdb1d1b18aa6c08324b7d64b71fb76370690e1d", ByteUtils.bytesToHexString(HMACSHA1.hash("", "")));
		assertEquals("de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9", ByteUtils.bytesToHexString(HMACSHA1.hash("key", "The quick brown fox jumps over the lazy dog")));
	}
	
	/*
	public function test_performance():void
	{
		var start : int = getTimer();
		for(var x : int = 0; x < 5000; ++x)
		{
			HMACSHA1.hash("key", "The quick brown fox jumps over the lazy dog");
		}
		var end : int = getTimer() - start;
		trace("test_hashPerf", end + "ms");
		assertTrue(end < 1000);
	}
	//*/
}

}