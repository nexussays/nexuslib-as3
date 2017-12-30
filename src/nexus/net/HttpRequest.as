// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.net
{

import flash.errors.*;
import flash.events.*;
import flash.net.*;
import flash.utils.*;

/**
 * @private
 */
public class HttpRequest
{
   //--------------------------------------
   //   CLASS CONSTANTS
   //--------------------------------------
   
   //--------------------------------------
   //   INSTANCE VARIABLES
   //--------------------------------------
   
   /**
    * The underlying URLStream for this request
    * @see   http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/net/URLStream.html
    */
   private var m_stream:URLStream;
   private var m_url:URLRequest;
   
   //
   // transient data per send
   //
   
   private var m_response : HttpResponse;
   private var m_onCompleteCallback:Function;
   
   //--------------------------------------
   //   CONSTRUCTOR
   //--------------------------------------
   
   public function HttpRequest()
   {
      m_url = new URLRequest();
      m_url.method = URLRequestMethod.GET;
      
      m_stream = new URLStream();
   }
   
   //--------------------------------------
   //   GETTER/SETTERS
   //--------------------------------------
   
   public function get url():String { return m_url.url; }
   public function set url(value:String):void
   {
      m_url.url = value;
   }
   
   public function get method():String { return m_url.method; }
   public function set method(value:String):void
   {
      m_url.method = value;
   }
   
   public function get body():Object { return m_url.data; }
   public function set body(value:Object):void
   {
      m_url.data = value;
   }
   
   public function get headers():Array { return m_url.requestHeaders; }
   
   //--------------------------------------
   //   PUBLIC INSTANCE METHODS
   //--------------------------------------
   
   public function send(callback:Function/*HttpRequest*/):void
   {
      if(m_stream.connected)
      {
         throw new IllegalOperationError("Cannot send. HttpRequest already in progress.");
      }
      
      m_onCompleteCallback = callback;
      m_response = new HttpResponse();
      //TODO: Provide some mechanism to get progress of the response; then set the response body to the stream while it loads
      //m_response.setBody(m_stream);
      
      //
      // Add event listeners on each send(), so we can fully tear down when complete and avoid possible memory leaks
      //
      
      //Dispatched when a load operation starts.
      m_stream.addEventListener(Event.OPEN, stream_open);
      
      //Dispatched when data has loaded successfully.
      m_stream.addEventListener(Event.COMPLETE, stream_complete);
      
      //Dispatched when data is received as the download operation progresses.
      m_stream.addEventListener(ProgressEvent.PROGRESS, stream_progress);
      
      //Dispatched if a call to URLStream.load() attempts to access data over HTTP, and Flash Player
      //or Adobe AIR is able to detect and return the status code for the request.
      m_stream.addEventListener(HTTPStatusEvent.HTTP_STATUS, stream_status);
      
      //Dispatched if a call to the URLStream.load() method attempts to access data over HTTP and Adobe AIR
      //is able to detect and return the status code for the request.
      m_stream.addEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, stream_responseStatus);
      
      //Dispatched when an input/output error occurs that causes a load operation to fail.
      m_stream.addEventListener(IOErrorEvent.IO_ERROR, stream_error);
      
      //Dispatched if a call to URLStream.load() attempts to load data from a server outside the security sandbox.
      m_stream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, stream_error);
      
      try
      {
         m_stream.load(m_url);
      }
      //1) Local untrusted SWF files may not communicate with the Internet. This may be worked around
      //by reclassifying this SWF file as local-with-networking or trusted.
      //2) You are trying to connect to a commonly reserved port. For a complete list of blocked ports,
      //see "Restricting Networking APIs" in the ActionScript 3.0 Developer's Guide.
      catch(securityError:SecurityError)
      {
         complete(securityError.getStackTrace() || securityError.toString());
      }
      //1) Flash Player or Adobe AIR cannot convert the URLRequest.data parameter from UTF8 to MBCS. This
      //error is applicable if the URLRequest object passed to load() is set to perform a GET operation and
      //if System.useCodePage is set to true.
      //2) Flash Player or Adobe AIR cannot allocate memory for the POST data. This error is applicable if
      //the URLRequest object passed to load is set to perform a POST operation.
      catch(memoryError:MemoryError)
      {
         complete(memoryError.getStackTrace() || memoryError.toString());
      }
      //URLRequest.requestHeader objects may not contain certain prohibited HTTP request headers.
      //For more information, see the URLRequestHeader class description.
      catch(argumentError:ArgumentError)
      {
         complete(argumentError.getStackTrace() || argumentError.toString());
      }
   }
   
   public function cancel():void
   {
      if(m_stream.connected)
      {
         m_stream.close();
      }
   }
   
   public function setBasicAuthentication(user:String, password:String):void
   {
      /*
      if(m_authHeader == null)
      {
      m_authHeader = new URLRequestHeader("Authorization");
      m_request.requestHeaders.push(m_authHeader);
      }
      var auth : ByteArray = new ByteArray();
      auth.writeUTFBytes(user + ":" + password);
      m_authHeader.value = "Basic " + Base64.encode(auth, false);
      //*/
   }
   
   //--------------------------------------
   //   PRIVATE & PROTECTED INSTANCE METHODS
   //--------------------------------------
   
   private function stream_open(e:Event):void
   {
      trace(e);
   }
   
   private function stream_status(e:HTTPStatusEvent):void
   {
      //only set if a valid status is returned & one is not already set (stream_responseStatus supercedes this method)
      if(e.status != 0 && m_response.status == -1)
      {
         m_response.setStatus(e.status);
      }
   }
   
   private function stream_responseStatus(e:HTTPStatusEvent):void
   {
      m_response.setStatus(e.status);
      m_response.setUrl(e.responseURL);
      m_response.addHeaders(e.responseHeaders);
   }
   
   private function stream_progress(e:ProgressEvent):void
   {
      m_response.setBytesLoaded(e.bytesLoaded);
      m_response.setBytesTotal(e.bytesTotal);
   }
   
   private function stream_complete(e:Event):void
   {
      complete(m_stream);
   }
   
   private function stream_error(e:ErrorEvent):void
   {
      complete(e.text);
   }
   
   private function complete(responseBody:Object):void
   {
      //
      // set response body
      //
      
      //set response body to a new ByteArray to break the reference to the stream
      var bytes : ByteArray = new ByteArray();
      if(responseBody == m_stream || responseBody is IDataInput)
      {
         IDataInput(responseBody).readBytes(bytes);
      }
      else if(responseBody is String)
      {
         bytes.writeUTFBytes(String(responseBody));
      }
      else
      {
         throw new ArgumentError("Invalid response body type");
      }
      
      //TODO: set loaded & total here? What about the case of errors. I think the idea is to make sure any visuals or logic
      //that are waiting for bytesLoaded to equal bytesTotal to complete properly, but what about the error case? Don't we
      //want to know that we're complete but the bytes don't match?
      m_response.setBytesLoaded(bytes.length);
      m_response.setBytesTotal(bytes.length);
      
      m_response.setBody(bytes);
      
      //
      // clean up stream
      //
      
      m_stream.removeEventListener(Event.OPEN, stream_open);
      m_stream.removeEventListener(Event.COMPLETE, stream_complete);
      m_stream.removeEventListener(ProgressEvent.PROGRESS, stream_progress);
      m_stream.removeEventListener(HTTPStatusEvent.HTTP_STATUS, stream_status);
      m_stream.removeEventListener(HTTPStatusEvent.HTTP_RESPONSE_STATUS, stream_responseStatus);
      m_stream.removeEventListener(IOErrorEvent.IO_ERROR, stream_error);
      m_stream.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, stream_error);
      
      //close stream after listeners have been removed so none are triggered
      this.cancel();
      
      //
      // invoke callback
      //
      
      m_onCompleteCallback(m_response);
      m_onCompleteCallback = null;
      m_response = null;
   }
}

}
