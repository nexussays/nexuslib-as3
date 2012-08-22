// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package test.nexus.security.crypto
{

import asunit.framework.TestCase;
import flash.utils.*;
import nexus.security.crypto.*;
import nexus.utils.ByteUtils;

public class HMACSHA1Test extends TestCase
{
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_stringTests : Array;
	private var m_byteTests : Array;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function HMACSHA1Test(testMethod:String = null)
	{
		super(testMethod);
		
		//
		// these should be state-less so instantiate here instead of in setUp()
		//
		
		m_stringTests = [
			["effcdf6ae5eb2fa2d27416d5f184df9c259a7c79", "Jefe",	"what do ya want for nothing?"],
			["fbdb1d1b18aa6c08324b7d64b71fb76370690e1d", "",		""],
			["de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9", "key",		"The quick brown fox jumps over the lazy dog"]
		];
		
		m_byteTests = [];
		for(var x : int = 0; x < m_stringTests.length; ++x)
		{
			var test : Array = m_stringTests[x];
			m_byteTests[x] = [test[0], ByteUtils.fromString(test[1]), ByteUtils.fromString(test[2])];
		}
		m_byteTests.push(["b617318655057264e28bc0b6fb378c8ef146be00",
			ByteUtils.hexStringToBytes("0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b"),
			ByteUtils.fromString("Hi There")]);
		m_byteTests.push(["125d7342b9ac11cd91a39af48aa17b4f63f175d3",
			ByteUtils.hexStringToBytes("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"),
			ByteUtils.hexStringToBytes("dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd")]);
		m_byteTests.push(["4c9007f4026250c6bc8414f9bf50c86c2d7235da",
			ByteUtils.hexStringToBytes("0102030405060708090a0b0c0d0e0f10111213141516171819"),
			ByteUtils.hexStringToBytes("cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd")]);
		m_byteTests.push(["aa4ae5e15272d00e95705637ce8a3b55ed402112",
			ByteUtils.hexStringToBytes("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"),
			ByteUtils.fromString("Test Using Larger Than Block-Size Key - Hash Key First")]);
		m_byteTests.push(["e8e99d0f45237d786d6bbaa7965c7808bbff1a91",
			ByteUtils.hexStringToBytes("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"),
			ByteUtils.fromString("Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data")]);
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
	
	public function test_sha1():void
	{
		var hmac_sha1 : HMAC = new HMAC(new SHA1());
		var test : Array;
		for each(test in m_stringTests)
		{
			assertEquals(test[0], ByteUtils.bytesToHexString(hmac_sha1.computeWithStrings(test[2], test[1])));
		}
		for each(test in m_byteTests)
		{
			assertEquals(test[0], ByteUtils.bytesToHexString(hmac_sha1.compute(test[2], test[1])));
		}
	}
	
	/*
	public function test_performance():void
	{
		var hmac_sha1 : HMAC = new HMAC(new SHA1());
		
		var start : int = getTimer();
		for(var x : int = 0; x < 5000; ++x)
		{
			hmac_sha1.hash("key", "The quick brown fox jumps over the lazy dog");
		}
		var end : int = getTimer() - start;
		trace("test_hashPerf", end + "ms");
		assertTrue(end < 1000);
	}
	//*/
}

}