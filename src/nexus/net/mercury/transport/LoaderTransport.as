// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.net.mercury.transport
{

import nexus.Debug;
import nexus.errors.ObjectDisposedError;
import nexus.net.mercury.ApplicationDomainType;
import flash.display.Loader;
import flash.errors.IllegalOperationError;
import flash.events.*;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.SecurityDomain;

/**
 * An implementation of IMessengerTransport using a Loader as the underlying mechanism
 * @since 3/8/2011 1:58 PM
 */
public class LoaderTransport extends AbstractTransport
{
   //--------------------------------------
   //   CLASS CONSTANTS
   //--------------------------------------

   //--------------------------------------
   //   PRIVATE VARIABLES
   //--------------------------------------

   private var m_loader : Loader;

   private var m_isInitialized : Boolean;
   private var m_isDisposed : Boolean;

   private var m_loadImageOnly : Boolean;

   //--------------------------------------
   //   CONSTRUCTOR
   //--------------------------------------

   public function LoaderTransport(onComplete:Function, onProgress:Function, onError:Function, loadImage:Boolean)
   {
      super(onComplete, onProgress, onError);

      m_loader = new Loader();

      m_isInitialized = false;
      m_isDisposed = false;

      m_loadImageOnly = loadImage;
   }

   //--------------------------------------
   //   GETTER/SETTERS
   //--------------------------------------

   override public function get data():* { return m_loader.content; }

   //--------------------------------------
   //   PUBLIC METHODS
   //--------------------------------------

   override public function initialize():void
   {
      checkDisposed();

      if(!m_isInitialized)
      {
         //Dispatched when a load operation starts.
         m_loader.contentLoaderInfo.addEventListener(Event.OPEN, loaderOpenHandler);

         //Dispatched when the properties and methods of a loaded SWF file are accessible and ready for use.
         m_loader.contentLoaderInfo.addEventListener(Event.INIT, loaderInitHandler);

         //Dispatched when data has loaded successfully.
         m_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);

         //Dispatched by a LoaderInfo object whenever a loaded object is removed by using the unload() method
         //of the Loader object, or when a second load is performed by the same Loader object and the original
         //content is removed prior to the load beginning.
         //m_loader.contentLoaderInfo.addEventListener(Event.UNLOAD, loaderUnloadHandler);

         //Dispatched when data is received as the download operation progresses.
         //m_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loaderProgressHandler);

         //Dispatched when a network request is made over HTTP and an HTTP status code can be detected.
         m_loader.contentLoaderInfo.addEventListener(HTTPStatusEvent.HTTP_STATUS, loaderHttpStatusHandler);

         //Dispatched when an input or output error occurs that causes a load operation to fail.
         m_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);

         m_isInitialized = true;
      }
   }

   override public function load(request:URLRequest):void
   {
      checkDisposed();

      if(!m_isInitialized)
      {
         throw new IllegalOperationError("Cannot load LoaderTransport before initialization");
      }

      var appDomain : ApplicationDomain;
      switch(m_destinationApplicationDomain)
      {
         case ApplicationDomainType.Child:
            appDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
            break;
         case ApplicationDomainType.Current:
            appDomain = ApplicationDomain.currentDomain;
            break;
         case ApplicationDomainType.Separate:
            appDomain = new ApplicationDomain(null);
            break;
         default:
            throw new Error("Cannot place loaded content into unknown application domain \"" + m_destinationApplicationDomain + "\"");
      }

      var context : LoaderContext = new LoaderContext(m_loadImageOnly, appDomain);

      //Flash 10.1 feature, set to true if m_loadImageOnly is true
      //duplicates AIR-specific allowLoadBytesCodeExecution property
      //@see: http://www.adobe.com/devnet/flashplayer/articles/fplayer10_1_air2_security_changes.html#head2
      if(context.hasOwnProperty("allowCodeImport"))
      {
         context["allowCodeImport"] = !m_loadImageOnly;
      }

      m_loader.load(request, context);
   }

   override public function close():void
   {
      checkDisposed();

      try
      {
         m_loader.close();
      }
      catch(e:Error)
      {

      }

      m_isInitialized = false;

      m_loader.contentLoaderInfo.removeEventListener(Event.OPEN, loaderOpenHandler);
      m_loader.contentLoaderInfo.removeEventListener(Event.INIT, loaderInitHandler);
      m_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loaderCompleteHandler);
      m_loader.contentLoaderInfo.removeEventListener(Event.UNLOAD, loaderUnloadHandler);
      m_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, loaderProgressHandler);
      m_loader.contentLoaderInfo.removeEventListener(HTTPStatusEvent.HTTP_STATUS, loaderHttpStatusHandler);
      m_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loaderIOErrorHandler);
   }

   override public function dispose():void
   {
      if(!m_isDisposed)
      {
         //calls close()
         super.dispose();

         m_loader.unloadAndStop();
         m_loader = null;

         m_isDisposed = true;
      }
   }

   //--------------------------------------
   //   EVENT HANDLERS
   //--------------------------------------

   private function loaderProgressHandler(e:ProgressEvent):void
   {
      m_bytesLoaded = e.bytesLoaded;
      m_bytesTotal = e.bytesTotal;
      m_onProgress();
   }

   private function loaderCompleteHandler(e:Event):void
   {
      m_statusMessage = e.type;
      m_bytesLoaded = m_loader.contentLoaderInfo.bytesLoaded;
      m_bytesTotal = m_loader.contentLoaderInfo.bytesTotal;
      m_onComplete();
   }

   private function loaderUnloadHandler(e:Event):void
   {
      //trace(e);
   }

   private function loaderInitHandler(e:Event):void
   {
      m_statusMessage = e.type;
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

   private function loaderHttpStatusHandler(e:HTTPStatusEvent):void
   {
      if(e.status != 0)
      {
         m_httpStatus = e.status;
      }
   }

   //--------------------------------------
   //   PRIVATE & PROTECTED INSTANCE METHODS
   //--------------------------------------

   private function checkDisposed():void
   {
      if(m_isDisposed)
      {
         throw new ObjectDisposedError("LoaderTransport");
      }
   }

   private final function trace(...params): void
   {
      Debug.debug(LoaderTransport, params);
   }
}

}
