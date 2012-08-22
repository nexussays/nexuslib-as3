// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.security.crypto
{

import flash.utils.*;
import nexus.utils.ByteUtils;

/**
 * ...
 */
public class HMACSHA1
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	private static const BLOCKSIZE_BYTES:int = 64;
	private static const HASH : SHA1 = new SHA1();
	
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	static public function hash(key:String, message:String):ByteArray
	{
		return hashBytes(ByteUtils.fromString(key), ByteUtils.fromString(message));
	}
	
	static public function hashBytes(key:ByteArray, message:ByteArray):ByteArray
	{
		var value:ByteArray = new ByteArray();
		if(key.length > BLOCKSIZE_BYTES)
		{
			value.writeBytes(HASH.hash(key));
		}
		else
		{
			value.writeBytes(key);
		}
		
		while(value.length < BLOCKSIZE_BYTES)
		{
			value.writeByte(0);
		}
		
		var innerPad:ByteArray = new ByteArray();
		var outerPad:ByteArray = new ByteArray();
		for(var x:int = 0; x < BLOCKSIZE_BYTES; ++x)
		{
			innerPad.writeByte(value[x] ^ 0x36);
			outerPad.writeByte(value[x] ^ 0x5c);
		}
		
		innerPad.writeBytes(message);
		outerPad.writeBytes(HASH.hash(innerPad));
		
		value.clear();
		value = null;
		innerPad.clear();
		innerPad = null;
		
		return HASH.hash(outerPad);
	}
	
	//--------------------------------------
	//	PRIVATE CLASS METHODS
	//--------------------------------------
}

}