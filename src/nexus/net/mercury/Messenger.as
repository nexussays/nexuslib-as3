// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.net.mercury
{

import nexus.Debug;
import nexus.errors.ObjectDisposedError;
import nexus.net.*;
import nexus.net.mercury.transport.*;

import flash.events.EventDispatcher;
import flash.utils.*;

/**
 * The base-level request mechanicsm to load resources and send requests to a remote server
 * @since 3/14/2011 6:58 PM
 */
[Event(name=" nexus.net.mercury.LOAD_PROGRESS", type=" nexus.net.mercury.MessengerEvent")]
[Event(name=" nexus.net.mercury.LOAD_ERROR", type=" nexus.net.mercury.MessengerEvent")]
[Event(name=" nexus.net.mercury.LOAD_COMPLETE", type=" nexus.net.mercury.MessengerEvent")]
public class Messenger extends EventDispatcher
{
   //--------------------------------------
   //   CLASS CONSTANTS
   //--------------------------------------

   //--------------------------------------
   //   PRIVATE VARIABLES
   //--------------------------------------

   private var m_key : String;
   private var m_url : String;

   private var m_timeCreated : int;

   private var m_loadState : LoadState;

   private var m_startedTime : int;
   private var m_completionTime : int;

   private var m_maxLoadAttempts : int;
   private var m_loadAttempts : int;

   private var m_request : MessengerRequest;
   private var m_transport : IMessengerTransport;
   private var m_resourceType : ResourceType;

   private var m_isDisposed : Boolean;

   //--------------------------------------
   //   CONSTRUCTOR
   //--------------------------------------

   public function Messenger(url:String, resourceType:ResourceType, maxAttempts:int=1, key:String=null)
   {
      m_key = key || url;
      m_url = url;
      m_maxLoadAttempts = maxAttempts;
      this.resourceType = resourceType;

      m_loadState = LoadState.Pending;

      m_timeCreated = getTimer();

      m_loadAttempts = 0;
      m_startedTime = 0;
      m_completionTime = int.MAX_VALUE;

      m_isDisposed = false;

      m_request = new MessengerRequest(m_url);
   }

   //--------------------------------------
   //   GETTER/SETTERS
   //--------------------------------------

   public function get key():String { return m_key; }
   public function set key(value:String):void
   {
      m_key = value;
   }

   public function get url():String { return m_url; }

   public function get timeCreated():int { return m_timeCreated; }

   public function get data():* { return m_transport.data; }

   public function get loadState():LoadState { return m_loadState; }

   public function get loadAttempts():int { return m_loadAttempts; }

   /**
    * The time this load took to complete, in ms
    */
   public function get loadTime():int { return m_completionTime - m_startedTime; }

   public function get percentLoaded():Number { return (m_transport.bytesLoaded / m_transport.bytesTotal); }

   public function get bytesLoaded():int { return m_transport.bytesLoaded; }

   public function get bytesTotal():int { return m_transport.bytesTotal; }

   public function get httpStatus():int { return m_transport.httpStatus; }

   public function get statusMessage():String { return m_transport.statusMessage; }

   /**
    * The speed of this load in KBps
    */
   public function get throughput():int { return (m_transport.bytesTotal / 1024) / (this.loadTime / 1000); }

   public function get maxLoadAttempts():int { return m_maxLoadAttempts; }
   public function set maxLoadAttempts(value:int):void
   {
      m_maxLoadAttempts = Math.max(1, value);
   }

   public function get destinationApplicationDomain():ApplicationDomainType { return m_transport.destinationApplicationDomain; }
   public function set destinationApplicationDomain(value:ApplicationDomainType):void
   {
      m_transport.destinationApplicationDomain = value;
   }

   public function get request():IMessengerRequest { return m_request; }

   public function get resourceType():ResourceType { return m_resourceType; }
   public function set resourceType(value:ResourceType):void
   {
      if(value == null)
      {
         throw new ArgumentError("ResourceType cannot be null on Messenger.");
      }

      if(m_resourceType != value)
      {
         if(m_transport != null)
         {
            m_transport.dispose();
         }

         m_resourceType = value;

         m_transport = getTransport();
      }
   }

   protected function get isDisposed():Boolean { return m_isDisposed; }

   //--------------------------------------
   //   PUBLIC METHODS
   //--------------------------------------

   public function load():void
   {
      checkDisposed();

      if(m_loadState == LoadState.Pending)
      {
         m_startedTime = getTimer();
         m_loadState = LoadState.Loading;

         m_transport.initialize();

         attemptLoad();
      }
   }

   public function stopLoad():void
   {
      checkDisposed();

      if(m_loadState == LoadState.Loading)
      {
         m_startedTime = 0;
         m_loadState = LoadState.Pending;

         if(m_transport.supportsRetry)
         {
            m_transport.close();
         }
      }
   }

   public function dispose():void
   {
      if(!m_isDisposed)
      {
         //TODO: Remove handlers from event listener by keeping track of what has been added

         m_resourceType = null;

         m_transport.dispose();
         m_request.dispose();

         m_isDisposed = true;
      }
   }

   override public function toString():String
   {
      return "[Messenger(" + this.loadState + "):" + this.url + "]";
   }

   //--------------------------------------
   //   PROTECTED INSTANCE METHODS
   //--------------------------------------

   /**
    * Dispatch a MessengerEvent.LOAD_COMPLETE event. Override this in a subclass if you want to perform additional
    * processing or validation on the completed request before dispatching the complete event
    */
   protected function dispatchCompleteEvent():void
   {
      this.dispatchEvent(new MessengerEvent(MessengerEvent.LOAD_COMPLETE));
   }

   /**
    * Dispatch a MessengerEvent.LOAD_ERROR event. Override this in a subclass if you want to perform additional
    * processing or validation on the failed request before dispatching the error event
    */
   protected function dispatchErrorEvent(errorMessageOverride:String=null):void
   {
      this.dispatchEvent(new MessengerEvent(MessengerEvent.LOAD_ERROR, errorMessageOverride));
   }

   //--------------------------------------
   //   PRIVATE INSTANCE METHODS
   //--------------------------------------

   /**
    * Callback for ITransport when a load failure has occured. If maxLoadAttempts has not been surpassed, it will
    * attempt to load again.
    */
   private function transportErrorHandler():void
   {
      if(m_loadAttempts >= m_maxLoadAttempts)
      {
         m_completionTime = getTimer();
         m_loadState = LoadState.Failure;

         m_transport.close();

         //fire event handler after completing internally
         dispatchErrorEvent();
      }
      else
      {
         //try again
         attemptLoad();
      }
   }

   /**
    * Callback for ITransport completion
    */
   private function transportCompleteHandler():void
   {
      m_completionTime = getTimer();
      m_loadState = LoadState.Success;

      m_transport.close();

      try
      {
         //ensure that we can at least access the transport data without exception
         var data : * = m_transport.data;
         data = null;

         //fire event handler after completing internally
         dispatchCompleteEvent();
      }
      catch(e:Error)
      {
         trace("Error in transportCompleteHandler", e);

         //fire event handler after completing internally
         dispatchErrorEvent(e.message);
      }
   }

   /**
    * Callback for ITransport progress made
    */
   private function transportProgressHandler():void
   {
      this.dispatchEvent(new MessengerEvent(MessengerEvent.LOAD_PROGRESS));
   }

   /**
    * Tell the ITransport to load if its state supports it, and increment the load attempts counter
    */
   private function attemptLoad():void
   {
      ++m_loadAttempts;
      if(m_loadAttempts == 1 || m_transport.supportsRetry)
      {
         m_transport.load(m_request.getURLRequest());
      }
   }

   private function getTransport():IMessengerTransport
   {
      var transport : IMessengerTransport;
      switch(m_resourceType)
      {
         case ResourceType.Audio:
            transport = new SoundTransport(transportCompleteHandler, transportProgressHandler, transportErrorHandler);
            break;
         case ResourceType.Bitmap:
            transport = new LoaderTransport(transportCompleteHandler, transportProgressHandler, transportErrorHandler, true);
            break;
         case ResourceType.SWF:
            transport = new LoaderTransport(transportCompleteHandler, transportProgressHandler, transportErrorHandler, false);
            break;
         case ResourceType.Text:
            transport = new URLStreamTransport(transportCompleteHandler, transportProgressHandler, transportErrorHandler, false);
            break;
         case ResourceType.Bytes:
            transport = new URLStreamTransport(transportCompleteHandler, transportProgressHandler, transportErrorHandler, true);
            break;
         default:
            throw new ArgumentError("No loader associated with resource \"" + m_resourceType + "\"");
      }
      return transport;
   }

   private function checkDisposed():void
   {
      if(m_isDisposed)
      {
         throw new ObjectDisposedError("Messenger");
      }
   }

   private final function trace(...params): void
   {
      Debug.debug(Messenger, params);
   }
}

}
