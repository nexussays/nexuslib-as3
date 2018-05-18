// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.net.mercury
{

import com.probertson.utils.GZIPBytesEncoder;

import nexus.Debug;
import nexus.IDisposable;
import nexus.errors.ObjectDisposedError;
import nexus.net.HttpRequestMethod;
import nexus.utils.StringUtils;

import flash.net.*;
import flash.utils.*;

/**
 * A request for an external resource and any request body that should be included. Use with Messenger.
 * @since 3/14/2011 11:36 AM
 */
public class MessengerRequest implements IDisposable, IMessengerRequest
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------

	//--------------------------------------
	//	PRIVATE VARIABLES
	//--------------------------------------

	private var m_method : HttpRequestMethod;

	private var m_content : *;
	private var m_gzipContent : Boolean;

	private var m_setNoCacheHeaders : Boolean;

	private var m_urlRequest : URLRequest;
	private var m_urlRequestInitialized : Boolean;

	private var m_isDisposed : Boolean;

	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------

	public function MessengerRequest(url:String)
	{
		m_urlRequest = new URLRequest(url);

		m_method = HttpRequestMethod.GET;
		m_gzipContent = false;

		m_setNoCacheHeaders = false;

		m_urlRequestInitialized = false;

		m_isDisposed = false;
	}

	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------

	public function get method():HttpRequestMethod { return m_method; }
	public function set method(value:HttpRequestMethod):void
	{
		checkDisposed();

		if(value == null)
		{
			throw new ArgumentError("Cannot set method to null in Messenger");
		}

		if(m_method != value)
		{
			m_method = value;
			m_urlRequestInitialized = false;
		}
	}

	public function get content():* { return m_content; }
	public function set content(value:*):void
	{
		checkDisposed();

		if(value == null || value is XML || value is ByteArray || value is String || value is URLVariables)
		{
			m_content = value;
			m_urlRequestInitialized = false;
		}
		else
		{
			throw new ArgumentError("Cannot set content in Messenger to \"" + value + "\", must be of type XML, ByteArray, String, or URLVariables");
		}
	}

	public function get gzipContent():Boolean { return m_gzipContent; }
	public function set gzipContent(value:Boolean):void
	{
		checkDisposed();

		if(m_gzipContent != value)
		{
			m_gzipContent = value;
			m_urlRequestInitialized = false;
		}
	}

	public function get setNoCacheHeaders():Boolean { return m_setNoCacheHeaders; }
	public function set setNoCacheHeaders(value:Boolean):void
	{
		checkDisposed();

		if(m_setNoCacheHeaders != value)
		{
			m_setNoCacheHeaders = value;
			m_urlRequestInitialized = false;
		}
	}

	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------

	public function getURLRequest():URLRequest
	{
		checkDisposed();

		if(!m_urlRequestInitialized)
		{
			//clear any headers and data
			m_urlRequest.requestHeaders = [];
			m_urlRequest.data = null;

			//support PUT, DELETE, etc by using special header X-HTTP-Method-Override
			if(m_method.isNativelySupported)
			{
				m_urlRequest.method = m_method.toString();
			}
			else
			{
				m_urlRequest.method = URLRequestMethod.POST;
				m_urlRequest.requestHeaders.push(new URLRequestHeader("X-HTTP-Method-Override", m_method.toString()));
			}

			//add headers for urlRequest content and compress if necessary
			if(m_content != null)
			{
				m_urlRequest.data = m_content;

				//m_urlRequest.contentType = "application/x-www-form-urlencoded";
				if(m_content is XML)
				{
					m_urlRequest.requestHeaders.push(new URLRequestHeader("Content-Type", "application/xml"));
					//m_urlRequest.contentType = "application/xml";
				}
				else if(m_content is ByteArray)
				{
					m_urlRequest.requestHeaders.push(new URLRequestHeader("Content-Type", "application/octet-stream"));
					//m_urlRequest.contentType = "application/octet-stream";
				}
				else if(m_content is String)
				{
					m_urlRequest.requestHeaders.push(new URLRequestHeader("Content-Type", "text/plain"));
					//m_urlRequest.contentType = "text/plain";
				}

				//compress the urlRequest content if necessary
				if(m_gzipContent == true)
				{
					var bytes:ByteArray = new ByteArray();
					var encoder:GZIPBytesEncoder = new GZIPBytesEncoder();

					if(m_content is XML)
					{
						bytes.writeUTFBytes(XML(m_content).toString());
					}
					else if(m_content is String)
					{
						bytes.writeUTFBytes(String(m_content));
					}
					else if(m_content is URLVariables)
					{
						bytes.writeUTFBytes(URLVariables(m_content).toString());
					}
					else if(m_content is ByteArray)
					{
						bytes = ByteArray(m_content);
					}

					m_urlRequest.data = encoder.compressToByteArray(bytes);
					m_urlRequest.requestHeaders.push(new URLRequestHeader("Content-Encoding", "gzip"));
				}

				//trace("CONTENT TYPE", m_urlRequest.contentType, m_urlRequest.url);
				//trace("DATA", "gzip?", m_gzipContent, m_urlRequest.data);
			}

			//Note: If running in Flash Player and the referenced form has no body, Flash Player automatically uses a
			//GET operation, even if the method is set to URLRequestMethod.POST. For this reason, it is recommended to
			//always include a "dummy" body to ensure that the correct method is used.
			if(m_urlRequest.method == URLRequestMethod.POST && (m_urlRequest.data == null || StringUtils.trim(m_urlRequest.data + "") == ""))
			{
				m_urlRequest.data = "?empty=true";
			}

			if(m_setNoCacheHeaders)
			{
				m_urlRequest.requestHeaders.push(new URLRequestHeader("Pragma", "no-cache"));
				m_urlRequest.requestHeaders.push(new URLRequestHeader("Cache-Control", "no-cache"));
			}

			m_urlRequestInitialized = true;
		}

		return m_urlRequest;
	}

	public function dispose():void
	{
		if(!m_isDisposed)
		{
			m_urlRequest.data = null;
			m_urlRequest.requestHeaders = [];
			m_urlRequest = null;
			m_content = null;

			m_isDisposed = true;
		}
	}

	public function toString(verbose:Boolean=false):String
	{
		checkDisposed();

		return "[MessengerRequest:" + m_urlRequest.url + "]";
	}

	//--------------------------------------
	//	PRIVATE INSTANCE METHODS
	//--------------------------------------

	private function checkDisposed():void
	{
		if(m_isDisposed)
		{
			throw new ObjectDisposedError("MessengerRequest");
		}
	}

	private final function trace(...params): void
	{
		Debug.debug(MessengerRequest, params);
	}
}

}
