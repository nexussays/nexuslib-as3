// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.net.mercury.transport
{

import nexus.Debug;
import nexus.event.TypedEvent;
import nexus.net.mercury.ApplicationDomainType;
import nexus.net.mercury.IMessengerTransport;
import flash.errors.IllegalOperationError;
import flash.net.URLRequest;

import flash.utils.*;


/**
 * An abstract implementation of IMessengerTransport with some basic functionality for subclasses to take advantage of
 * @since 3/14/2011 8:12 PM
 */
public class AbstractTransport implements IMessengerTransport
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------

	public static const DEFAULT_LOADED_APPLICATIONDOMAIN : ApplicationDomainType = ApplicationDomainType.Child;

	private static var s_id : int = 0;

	//--------------------------------------
	//	PRIVATE VARIABLES
	//--------------------------------------

	protected const m_id : int = (++s_id);

	protected var m_onComplete : Function;
	protected var m_onProgress : Function;
	protected var m_onError : Function;

	protected var m_httpStatus : int;
	protected var m_statusMessage : String;

	protected var m_bytesLoaded : int;
	protected var m_bytesTotal : int;

	protected var m_supportsRetry : Boolean;

	protected var m_destinationApplicationDomain : ApplicationDomainType;

	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------

	public function AbstractTransport(onComplete:Function, onProgress:Function, onError:Function)
	{
		if(onComplete == null || onProgress == null || onError == null)
		{
			throw new ArgumentError("Transport cannot be initialized without valid complete, error, and progress callbacks");
		}

		m_bytesLoaded = 0;
		m_bytesTotal = 1;

		m_statusMessage = "";

		m_onComplete = onComplete;
		m_onProgress = onProgress;
		m_onError = onError;

		m_supportsRetry = true;

		m_httpStatus = -1;

		destinationApplicationDomain = DEFAULT_LOADED_APPLICATIONDOMAIN;
	}

	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------

	public function get id():int { return m_id; }

	public function get httpStatus():int { return m_httpStatus; }

	public function get statusMessage():String { return m_statusMessage; }

	public function get bytesLoaded():int { return m_bytesLoaded; }

	public function get bytesTotal():int { return m_bytesTotal; }

	public function get supportsRetry():Boolean { return m_supportsRetry; }

	public function get data():*
	{
		throw new IllegalOperationError("This method must be overridden in a subclass");
	}

	public function get destinationApplicationDomain():ApplicationDomainType { return m_destinationApplicationDomain; }
	public function set destinationApplicationDomain(value:ApplicationDomainType):void
	{
		m_destinationApplicationDomain = value;
		if(m_destinationApplicationDomain == null)
		{
			m_destinationApplicationDomain = DEFAULT_LOADED_APPLICATIONDOMAIN;
		}
	}

	//--------------------------------------
	//	PUBLIC METHODS
	//--------------------------------------

	public function initialize():void
	{
		throw new IllegalOperationError("This method must be overridden in a subclass");
	}

	public function load(request:URLRequest):void
	{
		throw new IllegalOperationError("This method must be overridden in a subclass");
	}

	public function close():void
	{
		throw new IllegalOperationError("This method must be overridden in a subclass");
	}

	public function dispose():void
	{
		m_onComplete = null;
		m_onError = null;
		m_onProgress = null;
		close();
	}

	//--------------------------------------
	//	EVENT HANDLERS
	//--------------------------------------

	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------

	private final function trace(...params): void
	{
		Debug.debug(AbstractTransport, params);
	}
}

}
