// Copyright (C) 2011-2012 Malachi Griffie <malachi@nexussays.com>
// 
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.vcs.git
{

public class GitObjectModes
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	public static const DIRECTORY	: String = "040000";
	public static const REGULAR_FILE: String = "100644";
	public static const REGULAR_EXE	: String = "100755";
	public static const SYMLINK		: String = "120000";
	public static const GITLINK		: String = "160000";
	
	/* valid modes
	 * 0100000000000000 (040000): Directory
	 * 1000000110100100 (100644): Regular non-executable file
	 * //legacy, can probably safely ignore this
	 * 1000000110110100 (100664): Regular non-executable group-writeable file
	 * 1000000111101101 (100755): Regular executable file
	 * 1010000000000000 (120000): Symbolic link
	 * 1110000000000000 (160000): Gitlink
	 */
}

}