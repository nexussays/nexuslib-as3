// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.vcs.git
{

public class GitFileMode
{
	/**
	 * 0100000000000000 (040000): Directory
	 */
	public static const DIRECTORY:String = "040000";
	
	/**
	 * 1000000110100100 (100644): Regular non-executable file
	 */
	public static const REGULAR_FILE:String = "100644";
	
	/**
	 * 1000000110110100 (100664): Regular non-executable group-writeable file
	 */
	//legacy, can probably safely ignore this
	//public static const REGULAR_FILE_GROUP_WRITE: String = "100664";
	
	/**
	 * 1000000111101101 (100755): Regular executable file
	 */
	public static const REGULAR_EXE:String = "100755";
	
	/**
	 * 1010000000000000 (120000): Symbolic link
	 */
	public static const SYMLINK:String = "120000";
	
	/**
	 * 1110000000000000 (160000): Gitlink
	 */
	public static const GITLINK:String = "160000";
}

}