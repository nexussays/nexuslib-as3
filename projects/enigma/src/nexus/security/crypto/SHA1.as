// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.security.crypto
{

import by.blooddy.crypto.SHA1;
import flash.utils.ByteArray;
import nexus.utils.ByteUtils;

/**
 * Wraps by.blooddy.crypto.SHA1 to provide an instance implementation that implements an interface for
 * use in various higher-level crypto functions (g, HMAC). For static operations and optimum performance,
 * call the blooddy library directly.
 */
public class SHA1 implements IHashFunction
{
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	/**
	 * Hash the provided bytes and returned the hashed value
	 * @param	bytes	The bytes to hash
	 * @return	The hashed bytes
	 */
	public function hash(bytes:ByteArray):ByteArray
	{
		//would be really nice if the blooddy lib just returned a damn byte array
		return ByteUtils.hexFormattedStringToBytes(by.blooddy.crypto.SHA1.hashBytes(bytes));
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
	
	
}

}