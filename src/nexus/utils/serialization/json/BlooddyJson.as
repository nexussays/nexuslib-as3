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
package nexus.utils.serialization.json
{

import by.blooddy.crypto.serialization.JSON;

/**
 * ...
 * @author	Malachi Griffie
 * @since	11/29/2011 4:12 AM
 */
internal class BlooddyJson
{
	//--------------------------------------
	//	INTERNAL CLASS METHODS
	//--------------------------------------
	
	internal static const encode : Function = by.blooddy.crypto.serialization.JSON.encode;
	internal static const decode : Function = by.blooddy.crypto.serialization.JSON.decode;

}

}