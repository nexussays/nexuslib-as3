// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.net.mercury.transport
{

import nexus.Debug;
import nexus.errors.ObjectDisposedError;
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.media.Sound;
import flash.media.SoundLoaderContext;
import flash.net.URLRequest;
import flash.utils.*;

/**
 * ...
 * @since 3/14/2011 10:21 PM
 */
public class SoundTransport extends AbstractTransport
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------

	//--------------------------------------
	//	PRIVATE VARIABLES
	//--------------------------------------

	private var m_sound : Sound;

	private var m_isInitialized : Boolean;
	private var m_isDisposed : Boolean;

	private var m_bufferTime : int;

	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------

	public function SoundTransport(onComplete:Function, onProgress:Function, onError:Function, buffer:int=4000)
	{
		super(onComplete, onProgress, onError);

		m_sound = new Sound();

		m_isInitialized = false;
		m_isDisposed = false;

		m_bufferTime = buffer;

		m_supportsRetry = false;
	}

	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------

	override public function get data():* { return m_sound; }

	public function get bufferTime():int { return m_bufferTime; }
	public function set bufferTime(value:int):void
	{
		m_bufferTime = value;
	}

	//--------------------------------------
	//	PUBLIC METHODS
	//--------------------------------------

	override public function initialize():void
	{
		checkDisposed();

		if(!m_isInitialized)
		{
			//Dispatched when a load operation starts.
			m_sound.addEventListener(Event.OPEN, loaderOpenHandler);

			//Dispatched when data has loaded successfully.
			m_sound.addEventListener(Event.COMPLETE, loaderCompleteHandler);

			//Dispatched when data is received as a load operation progresses.
			m_sound.addEventListener(ProgressEvent.PROGRESS, loaderProgressHandler);

			//Dispatched when an input/output error occurs that causes a load operation to fail.
			m_sound.addEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);

			m_isInitialized = true;
		}
	}

	override public function load(request:URLRequest):void
	{
		checkDisposed();

		if(!m_isInitialized)
		{
			throw new IllegalOperationError("Cannot load SoundTransport before initialization");
		}

		//TODO: policy file should be provided as an argument, not hardcoded
		m_sound.load(request, new SoundLoaderContext(m_bufferTime, false));
	}

	override public function close():void
	{
		checkDisposed();

		//FIXME: Need to be able to cancel
		//malachi: don't close because the sound is essentially dead after that
		//close will throw if there is no load in progress
		if(m_bytesLoaded < m_bytesTotal)
		{
			//m_sound.close();
		}

		m_isInitialized = false;

		m_sound.removeEventListener(Event.OPEN, loaderOpenHandler);
		m_sound.removeEventListener(Event.COMPLETE, loaderCompleteHandler);
		m_sound.removeEventListener(ProgressEvent.PROGRESS, loaderProgressHandler);
		m_sound.removeEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
	}

	override public function dispose():void
	{
		if(!m_isDisposed)
		{
			//calls close()
			super.dispose();

			m_sound = null;

			m_isDisposed = true;
		}
	}

	//--------------------------------------
	//	EVENT HANDLERS
	//--------------------------------------

	private function loaderProgressHandler(e:ProgressEvent):void
	{
		m_bytesLoaded = e.bytesLoaded;
		m_bytesTotal = e.bytesTotal;
		m_onProgress();
	}

	private function loaderOpenHandler(e:Event):void
	{
		m_statusMessage = e.type;
	}

	private function loaderIOErrorHandler(e:IOErrorEvent):void
	{
		m_statusMessage = e.text;
		m_onError();
	}

	private function loaderCompleteHandler(e:Event):void
	{
		m_statusMessage = e.type;
		m_bytesLoaded = m_sound.bytesLoaded;
		m_bytesTotal = m_sound.bytesTotal;
		m_onComplete();
	}

	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------

	private function checkDisposed():void
	{
		if(m_isDisposed)
		{
			throw new ObjectDisposedError("SoundTransport");
		}
	}

	private final function trace(...params): void
	{
		Debug.debug(SoundTransport, params);
	}
}

}
