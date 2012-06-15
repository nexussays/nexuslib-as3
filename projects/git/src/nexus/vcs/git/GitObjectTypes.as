/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is nexuslib.
 *
 * The Initial Developer of the Original Code is
 * Malachi Griffie <malachi@nexussays.com>.
 * Portions created by the Initial Developer are Copyright (C) 2011
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** */
package nexus.vcs.git
{

public class GitObjectTypes
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
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