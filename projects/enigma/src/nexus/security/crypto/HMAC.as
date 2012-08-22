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
public class HMAC
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	private static const BLOCKSIZE_BYTES:int = 64;
	private static const HMAC_SHA1 : HMAC = new HMAC(new SHA1());
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_hash : SHA1;
	private var m_secretKey : ByteArray;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function HMAC(hashFunction:SHA1)
	{
		m_hash = hashFunction;
	}
	
	//--------------------------------------
	//	GETTERS/SETTERS
	//--------------------------------------
	
	public function get secretKey():ByteArray { return m_secretKey; }
	public function set secretKey(value:ByteArray):void
	{
		m_secretKey = value;
	}
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	/**
	 * Generates an HMAC with the provided key and message. This is a convenience method for compute() that converts the
	 * String arguments into ByteArrays.
	 * @param	key
	 * @param	message
	 * @return
	 */
	public function computeWithStrings(message:String, key:String=null):ByteArray
	{
		return compute(ByteUtils.fromString(message), key != null ? ByteUtils.fromString(key) : null);
	}
	
	public function compute(message:ByteArray, key:ByteArray=null):ByteArray
	{
		key = key || m_secretKey;
		if(key == null)
		{
			throw new ArgumentError("Cannot compute HMAC without secret key.");
		}
		
		var value:ByteArray = new ByteArray();
		if(key.length > BLOCKSIZE_BYTES)
		{
			value.writeBytes(m_hash.hash(key));
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
		outerPad.writeBytes(m_hash.hash(innerPad));
		
		value.clear();
		value = null;
		innerPad.clear();
		innerPad = null;
		
		return m_hash.hash(outerPad);
	}
	
	//--------------------------------------
	//	PRIVATE INSTANCE METHODS
	//--------------------------------------
	
	//--------------------------------------
	//	PUBLIC CLASS METHODS
	//--------------------------------------
	
	static public function sha1(key:ByteArray, message:ByteArray):ByteArray
	{
		return HMAC_SHA1.compute(key, message);
	}
}

}