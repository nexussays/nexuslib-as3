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
import flash.errors.IOError;
import flash.errors.MemoryError;
import flash.events.*;
import flash.net.*;
import flash.utils.*;

/**
 * An implementation of IMessengerTransport using a URLStream as the underlying mechanism
 * @since 3/8/2011 2:34 PM
 */
public class URLStreamTransport extends AbstractTransport
{
   //--------------------------------------
   //   CLASS CONSTANTS
   //--------------------------------------

   //--------------------------------------
   //   PRIVATE VARIABLES
   //--------------------------------------

   private var m_urlStream : URLStream;

   private var m_isInitialized : Boolean;
   private var m_isDisposed : Boolean;

   private var m_returnText : Boolean;
   private var m_data:*;

   //--------------------------------------
   //   CONSTRUCTOR
   //--------------------------------------

   /**
    * Creates a new transport
    * @param   isBytes   If true, the response content is returned as a ByteArray, if false it is returned as a String
    */
   public function URLStreamTransport(onComplete:Function, onProgress:Function, onError:Function, isBytes:Boolean)
   {
      super(onComplete, onProgress, onError);

      m_urlStream = new URLStream();

      m_isInitialized = false;
      m_isDisposed = false;

      m_returnText = !isBytes;
   }

   //--------------------------------------
   //   GETTER/SETTERS
   //--------------------------------------

   override public function get data():* { return m_data; }

   //--------------------------------------
   //   PUBLIC METHODS
   //--------------------------------------

   override public function initialize():void
   {
      checkDisposed();

      if(!m_isInitialized)
      {
         //Dispatched when a load operation starts.
         m_urlStream.addEventListener(Event.OPEN, streamOpenHandler);

         //Dispatched when data has loaded successfully.
         m_urlStream.addEventListener(Event.COMPLETE, streamCompleteHandler);

         //Dispatched when data is received as the download operation progresses.
         //m_urlStream.addEventListener(ProgressEvent.PROGRESS, streamProgressHandler);

         //Dispatched if a call to URLStream.load() attempts to access data over HTTP, and Flash Player
         //or Adobe AIR is able to detect and return the status code for the request.
         m_urlStream.addEventListener(HTTPStatusEvent.HTTP_STATUS, streamHttpStatusHandler);

         //Dispatched when an input/output error occurs that causes a load operation to fail.
         m_urlStream.addEventListener(IOErrorEvent.IO_ERROR, streamIOErrorHandler);

         //Dispatched if a call to URLStream.load() attempts to load data from a server outside the security sandbox.
         m_urlStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, streamSecurityErrorHandler);

         m_isInitialized = true;
      }
   }

   override public function load(request:URLRequest):void
   {
      checkDisposed();

      if(!m_isInitialized)
      {
         throw new IllegalOperationError("Cannot load URLStreamTransport before initialization");
      }

      try
      {
         m_urlStream.load(request);
      }
      //1) Local untrusted SWF files may not communicate with the Internet. This may be worked around
      //by reclassifying this SWF file as local-with-networking or trusted.
      //2) You are trying to connect to a commonly reserved port. For a complete list of blocked ports,
      //see "Restricting Networking APIs" in the ActionScript 3.0 Developer's Guide.
      catch(securityError:SecurityError)
      {
         m_statusMessage = securityError.getStackTrace() || securityError.toString();
         m_onError()
      }
      //1) Flash Player or Adobe AIR cannot convert the URLRequest.data parameter from UTF8 to MBCS. This
      //error is applicable if the URLRequest object passed to load() is set to perform a GET operation and
      //if System.useCodePage is set to true.
      //2) Flash Player or Adobe AIR cannot allocate memory for the POST data. This error is applicable if
      //the URLRequest object passed to load is set to perform a POST operation.
      catch(memoryError:MemoryError)
      {
         m_statusMessage = memoryError.getStackTrace() || memoryError.toString();
         m_onError()
      }
   }

   override public function close():void
   {
      checkDisposed();

      try
      {
         m_urlStream.close();
      }
      catch(e:IOError)
      {
         //The stream could not be closed, or the stream was not open.
      }

      m_isInitialized = false;

      m_urlStream.removeEventListener(Event.OPEN, streamOpenHandler);
      m_urlStream.removeEventListener(Event.COMPLETE, streamCompleteHandler);
      m_urlStream.removeEventListener(IOErrorEvent.IO_ERROR, streamIOErrorHandler);
      m_urlStream.removeEventListener(ProgressEvent.PROGRESS, streamProgressHandler);
      m_urlStream.removeEventListener(HTTPStatusEvent.HTTP_STATUS, streamHttpStatusHandler);
      m_urlStream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, streamSecurityErrorHandler);
   }

   override public function dispose():void
   {
      if(!m_isDisposed)
      {
         //calls close()
         super.dispose();

         m_urlStream = null;

         m_isDisposed = true;
      }
   }

   //--------------------------------------
   //   EVENT HANDLERS
   //--------------------------------------

   private function streamIOErrorHandler(e:IOErrorEvent):void
   {
      m_statusMessage = e.text;
      m_onError()
   }

   private function streamSecurityErrorHandler(e:SecurityErrorEvent):void
   {
      m_statusMessage = e.text;
      m_onError()
   }

   private function streamOpenHandler(e:Event):void
   {
      m_statusMessage = e.type;
   }

   private function streamHttpStatusHandler(e:HTTPStatusEvent):void
   {
      if(e.status != 0)
      {
         m_httpStatus = e.status;
      }
   }

   private function streamProgressHandler(e:ProgressEvent):void
   {
      m_bytesLoaded = e.bytesLoaded;
      m_bytesTotal = e.bytesTotal;
      m_onProgress();
   }

   private function streamCompleteHandler(e:Event):void
   {
      m_statusMessage = e.type;

      var bytes:ByteArray = new ByteArray();
      m_urlStream.readBytes(bytes);

      m_bytesLoaded = bytes.length;
      m_bytesTotal = bytes.length;

      m_data = m_returnText ? bytes.toString() : bytes;

      m_onComplete();
   }

   //--------------------------------------
   //   PRIVATE & PROTECTED INSTANCE METHODS
   //--------------------------------------

   private function checkDisposed():void
   {
      if(m_isDisposed)
      {
         throw new ObjectDisposedError("URLStreamTransport");
      }
   }

   private final function trace(...params): void
   {
      Debug.debug(URLStreamTransport, params);
   }
}

}
