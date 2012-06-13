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