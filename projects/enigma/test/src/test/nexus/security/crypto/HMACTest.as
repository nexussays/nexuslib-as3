// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
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

public class HMACTest extends TestCase
{
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var digests_SHA1 : Array;
	private var digests_SHA256 : Array;
	private var keys : Array;
	private var messages : Array;
	
	private var emptyBytes : ByteArray;
	private var randomBytes : ByteArray;
	
	private var hmac_sha1:HMAC;
	private var hmac_sha256:HMAC;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function HMACTest(testMethod:String = null)
	{
		super(testMethod);
		
		//
		// these should be state-less so instantiate here instead of in setUp() to confirm
		//
		
		emptyBytes = new ByteArray();
		randomBytes = ByteUtils.fromString("Lorem Ipsum" + (new Date()).getTime());
		
		// http://tools.ietf.org/html/rfc2202
		// http://tools.ietf.org/html/rfc4231
		
		digests_SHA1 = [
			"fbdb1d1b18aa6c08324b7d64b71fb76370690e1d",
			"b617318655057264e28bc0b6fb378c8ef146be00",
			"effcdf6ae5eb2fa2d27416d5f184df9c259a7c79",
			"125d7342b9ac11cd91a39af48aa17b4f63f175d3",
			"4c9007f4026250c6bc8414f9bf50c86c2d7235da",
			"4c1a03424b55e07fe7f27be1d58bb9324a9a5a04",
			"aa4ae5e15272d00e95705637ce8a3b55ed402112",
			null,
			"e8e99d0f45237d786d6bbaa7965c7808bbff1a91",
			null
		];
		digests_SHA256 = [
			"b613679a0814d9ec772f95d778c35fc5ff1697c493715653c6c712144292c5ad",
			"b0344c61d8db38535ca8afceaf0bf12b881dc200c9833da726e9376c2e32cff7",
			"5bdcc146bf60754e6a042426089575c75a003f089d2739839dec58b964ec3843",
			"773ea91e36800e46854db8ebd09181a72959098b3ef8c122d9635514ced565fe",
			"82558a389a443c0ea4cc819899f2083a85f0faa3e578f8077a2e3ff46729665b",
			"a3b6167473100ee06e0c796c2955552bfa6f7c0a6a8aef8b93f860aab0cd20c5",
			null,
			"60e431591ee0b67f0d8a26aacbf5b77f8e0bc6213728c5140546040f0ee37f54",
			null,
			"9b09ffa71b942fcb27635fbcd5b0e944bfdc63644f0713938a7f51535c3a35e2"
		];
		keys = [
			ByteUtils.fromString(""),
			// 20 bytes
			ByteUtils.hexFormattedStringToBytes("0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b"),
			// "Jefe"
			ByteUtils.hexFormattedStringToBytes("4a656665"),
			// 20 bytes
			ByteUtils.hexFormattedStringToBytes("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"),
			// 25 bytes
			ByteUtils.hexFormattedStringToBytes("0102030405060708090a0b0c0d0e0f10111213141516171819"),
			// 20 bytes
			ByteUtils.hexFormattedStringToBytes("0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c0c"),
			// 80 bytes
			ByteUtils.hexFormattedStringToBytes("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"),
			// 131 bytes
			ByteUtils.hexFormattedStringToBytes("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"),
			// 80 bytes
			ByteUtils.hexFormattedStringToBytes("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"),
			// 131 bytes
			ByteUtils.hexFormattedStringToBytes("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"),
		];
		messages = [
			ByteUtils.fromString(""),
			//"Hi There"
			ByteUtils.hexFormattedStringToBytes("4869205468657265"),
			//"what do ya want for nothing?"
			ByteUtils.hexFormattedStringToBytes("7768617420646f2079612077616e7420666f72206e6f7468696e673f"),
			// 50 bytes
			ByteUtils.hexFormattedStringToBytes("dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd"),
			//50 bytes
			ByteUtils.hexFormattedStringToBytes("cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd"),
			// "Test With Truncation"
			ByteUtils.hexFormattedStringToBytes("546573742057697468205472756e636174696f6e"),
			// "Test Using Larger Than Block-Size Key - Hash Key First"
			ByteUtils.hexFormattedStringToBytes("54657374205573696e67204c6172676572205468616e20426c6f636b2d53697a65204b6579202d2048617368204b6579204669727374"),
			// "Test Using Larger Than Block-Size Key - Hash Key First"
			ByteUtils.hexFormattedStringToBytes("54657374205573696e67204c6172676572205468616e20426c6f636b2d53697a65204b6579202d2048617368204b6579204669727374"),
			// "Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data"
			ByteUtils.fromString("Test Using Larger Than Block-Size Key and Larger Than One Block-Size Data"),
			// "This is a test using a larger than block-size key and a larger than block-size data. The key needs to be hashed before being used by the HMAC algorithm."
			ByteUtils.hexFormattedStringToBytes("5468697320697320612074657374207573696e672061206c6172676572207468616e20626c6f636b2d73697a65206b657920616e642061206c6172676572207468616e20626c6f636b2d73697a6520646174612e20546865206b6579206e6565647320746f20626520686173686564206265666f7265206265696e6720757365642062792074686520484d414320616c676f726974686d2e")
		];
	}
	
	//--------------------------------------
	//	SETUP & TEARDOWN
	//--------------------------------------
	
	override protected function setUp():void
	{
		hmac_sha1 = new HMAC(new SHA1());
		hmac_sha256 = new HMAC(new SHA256());
	}
	
	override protected function tearDown():void
	{
		hmac_sha1 = null;
		hmac_sha256 = null;
	}
	
	//--------------------------------------
	//	TESTS
	//--------------------------------------
	
	public function test_testHarness():void
	{
		assertEquals("m_digestsSHA1",	10, digests_SHA1.length);
		assertEquals("m_digestsSHA256",	10, digests_SHA256.length);
		assertEquals("m_keys",			10, keys.length);
		assertEquals("m_messages",		10, messages.length);
	}
	
	public function test_sha1():void
	{
		runTestsOnHMAC(hmac_sha1, digests_SHA1);
	}
	
	public function test_sha1Static():void
	{
		runTestsOnFunction(HMAC.sha1, digests_SHA1);
	}
	
	public function test_sha256():void
	{
		runTestsOnHMAC(hmac_sha256, digests_SHA256);
	}
	
	public function test_sha256Static():void
	{
		runTestsOnFunction(HMAC.sha256, digests_SHA256);
	}
	
	public function test_nullKey():void
	{
		assertThrows(ArgumentError, function():void { hmac_sha1.generate(null, null) } );
		assertThrows(ArgumentError, function():void { hmac_sha1.generate(emptyBytes, null) } );
		assertThrows(ArgumentError, function():void { hmac_sha1.generate(randomBytes, null) } );
		
		assertThrows(ArgumentError, function():void { hmac_sha256.generate(null, null) } );
		assertThrows(ArgumentError, function():void { hmac_sha256.generate(emptyBytes, null) } );
		assertThrows(ArgumentError, function():void { hmac_sha256.generate(randomBytes, null) } );
	}
	
	public function test_emptyMessage():void
	{
		assertSame(ByteUtils.bytesToHexFormattedString(hmac_sha1.generate(null, emptyBytes)),
			ByteUtils.bytesToHexFormattedString(hmac_sha1.generate(emptyBytes, emptyBytes)));
		
		assertSame(ByteUtils.bytesToHexFormattedString(hmac_sha256.generate(null, emptyBytes)),
			ByteUtils.bytesToHexFormattedString(hmac_sha256.generate(emptyBytes, emptyBytes)));
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
	
	//--------------------------------------
	//	PRIVATE METHODS
	//--------------------------------------
	
	private function runTestsOnHMAC(hmac:HMAC, digests:Array):void
	{
		runTestsOnFunction(hmac.generate, digests);
		
		for(var x : int = 0; x < digests.length; ++x)
		{
			if(digests[x] != null)
			{
				hmac.secretKey = keys[x];
				assertEquals(digests[x], ByteUtils.bytesToHexFormattedString(hmac.generate(messages[x])));
			}
		}
	}
	
	private function runTestsOnFunction(func:Function, digests:Array):void
	{
		for(var x : int = 0; x < digests.length; ++x)
		{
			if(digests[x] != null)
			{
				assertEquals(digests[x], ByteUtils.bytesToHexFormattedString(func(messages[x], keys[x])));
			}
		}
	}
}

}