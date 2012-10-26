// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.utils.serialization.json
{

import by.blooddy.crypto.serialization.JSON;

/**
 * Wraps the by.blooddy.crypto.serialization.JSON encode and decode methods since there is a name conflict with
 * the native JSON if this package is imported directly in nexus.utils.serialization.json.JsonParser
 * @private
 */
internal class JsonParserBlooddy
{
	//--------------------------------------
	//	INTERNAL CLASS METHODS
	//--------------------------------------
	
	/**
	 * @private
	 */
	internal static const encode : Function = by.blooddy.crypto.serialization.JSON.encode;
	
	/**
	 * @private
	 */
	internal static const decode : Function = by.blooddy.crypto.serialization.JSON.decode;
}

}