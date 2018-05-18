// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.net.mercury
{

import nexus.net.HttpRequestMethod;

/**
 * ...
 * @since 4/18/2011 11:59 AM
 */
public interface IMessengerRequest
{
	function get method() : HttpRequestMethod;
	function set method(value:HttpRequestMethod) : void;

	/**
	 * The content of the request. When the request method is HttpRequestMethod.GET this is appended to the URL, otherwise
	 * it is sent in the request body.
	 */
	function get content() : *;
	function set content(value:*) : void;

	function get gzipContent() : Boolean;
	function set gzipContent(value:Boolean) : void;

	function get setNoCacheHeaders() : Boolean;
	function set setNoCacheHeaders(value:Boolean) : void;
}

}
