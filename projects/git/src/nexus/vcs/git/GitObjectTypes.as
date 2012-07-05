// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.vcs.git
{

public class GitObjectTypes
{
	public static const COMMIT:String = "commit";
	public static const TREE:String = "tree";
	public static const BLOB:String = "blob";
	public static const TAG:String = "tag";
	
	public static const PACK_COMMIT:int = 1;
	public static const PACK_TREE:int = 2;
	public static const PACK_BLOB:int = 3;
	public static const PACK_TAG:int = 4;
	
	/**
	   n-byte offset (see below) interpreted as a negative
	   offset from the type-byte of the header of the
	   ofs-delta entry (the size above is the size of
	   the delta data that follows).
	   delta data, deflated.
	
	   offset encoding:
	   n bytes with MSB set in all but the last one.
	   The offset is then the number constructed by
	   concatenating the lower 7 bit of each byte, and
	   for n >= 2 adding 2^7 + 2^14 + ... + 2^(7*(n-1))
	   to the result.
	 */
	public static const PACK_DELTA_OFFSET:int = 6;
	
	/**
	   20-byte base object name SHA1 (the size above is the
	   size of the delta data that follows).
	   delta data, deflated.
	 */
	//The base object is allowed to be omitted from the packfile, but only in the case of a thin pack being transferred over the network.
	public static const PACK_DELTA_REFERENCE:int = 7;
}

}