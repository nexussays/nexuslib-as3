// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.audio
{

import flash.errors.IOError;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.media.Sound;
import flash.media.SoundLoaderContext;
import flash.net.URLRequest;

/**
 * Extends CoreSound and loads the sound at the url provided to the constructor. This will not use any load managers or queues.
 */
public class SelfLoadingSound extends CoreSound
{
   //--------------------------------------
   //  PRIVATE VARIABLES
   //--------------------------------------

   private var m_completeCallback : Function;
   private var m_source : String;

   //--------------------------------------
   //  CONSTRUCTOR
   //--------------------------------------

   /**
    * Creates a new sound loaded from an external URL. Loading begins immediately.
    * @param   a_url            The URL of the sound to load
    * @param   a_bufferTime      The number of milliseconds to preload a streaming sound into a buffer before the sound starts to stream.
    * @param   a_checkPolicyFile   Specifies whether Flash Player should try to download a URL policy file from the loaded sound's server before beginning to load the sound.
    * @param   a_headers         The array of HTTP request headers to be appended to the HTTP request.
    * @param   a_normalization      A value used to attempt to normalize the sound if it can't be modified through an external sound editing program
    */
   public function SelfLoadingSound( a_url: String, a_bufferTime : Number = 4000, a_completeCallback : Function = null,
      a_checkPolicyFile : Boolean = false, a_headers : Array = null, a_normalization : Number = 1.0 )
   {
      m_source = a_url;

      m_completeCallback = a_completeCallback;

      var req : URLRequest = new URLRequest(a_url);
      req.requestHeaders = a_headers;

      var sound : Sound = new Sound(req, new SoundLoaderContext(a_bufferTime, a_checkPolicyFile));
      sound.addEventListener(Event.COMPLETE, soundLoadCompleteHandler);
      sound.addEventListener(IOErrorEvent.IO_ERROR, soundErrorHandler);

      super(sound, m_source, a_normalization);
   }

   //--------------------------------------
   //  GETTER/SETTERS
   //--------------------------------------

   public function get source():String { return m_source; }

   //--------------------------------------
   //  PRIVATE & PROTECTED INSTANCE METHODS
   //--------------------------------------

   private function soundErrorHandler(e:IOErrorEvent):void
   {
      throw new IOError("Error loading sound: " + e);
   }

   private function soundLoadCompleteHandler(e:Event):void
   {
      (e.target as Sound).removeEventListener(Event.COMPLETE, soundLoadCompleteHandler);
      (e.target as Sound).removeEventListener(IOErrorEvent.IO_ERROR, soundErrorHandler);
      if(m_completeCallback != null)
      {
         m_completeCallback(e);
      }
   }
}
}
