// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.utils
{

import flash.utils.*;

/**
 * A collection of functions to perform operations on ByteArrays and othr implementations of IDataInput and IDataOutput
 */
public class ByteUtils
{
	/**
	 * Generates a ByteArray from a hex-formatted String. Note that the string cannot contain any delimeters such as : or -
	 * @param	hexString	A String composed of only the characters [a-fA-F0-9]
	 * @return	A new ByteArray
	 */
	static public function hexToBytes(hexString:String):ByteArray
	{
		if(hexString.length % 2 == 1)
		{
			hexString = "0" + hexString;
		}
		var result:ByteArray = new ByteArray();
		for(var x:int = 0; x < hexString.length; x += 2)
		{
			result.writeByte(parseInt(hexString.substr(x, 2), 16));
		}
		return result;
	}
	
	/**
	 * Converts a ByteArray into a hex-formatted string representation
	 * @param	stream	The ByteArray to parse
	 * @return	A lowercase hex-formatted string
	 */
	static public function bytesToHex(stream:ByteArray):String
	{
		stream.position = 0;
		var sha1:String = "";
		while(stream.bytesAvailable)
		{
			var val:uint = stream.readUnsignedByte();
			sha1 += (val < 16 ? "0" : "") + val.toString(16);
		}
		return sha1;
	}
	
	/**
	 * Write the provided string into a new ByteArray
	 * @param	string
	 * @return	A new ByteArray
	 */
	static public function createByteArrayFromString(string:String):ByteArray
	{
		var result:ByteArray = new ByteArray();
		result.writeUTFBytes(string);
		return result;
	}
}

}