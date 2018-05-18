// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.audio
{

import nexus.math.MathHelper;
import nexus.net.loading.ILoadQueue;
import nexus.net.mercury.ResourceType;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.media.*;
import nexus.IDisposable;

/**
 * The base class used for the audio framework. This wraps multiple classses to provide functionality like
 * start/stop, pause, looping, volume control
 * @since 2009.02.10
 */
public class CoreSound implements IDisposable
{
   //--------------------------------------
   //  PROTECTED VARIABLES
   //--------------------------------------

   protected static const SOUND_PLAYING:String    = "SOUND_PLAYING";      // complete successfully by playing
   protected static const SOUND_LOADING:String    = "SOUND_LOADING";      // complete successfully by not being loaded but waiting for the load to start
   protected static const CANNOT_PLAY_AUDIO:String    = "CANNOT_PLAY_AUDIO";      // fail by be unable to complete due to no audio or audio channels maxed out
   protected static const SOUND_NOT_LOADED:String    = "SOUND_NOT_LOADED";   // fail due to being not loaded yet

   protected var m_key : String;

   protected var m_channel: SoundChannel;
   protected var m_sound: Sound;

   protected var m_volumeNormalization: Number;
   protected var m_volume: Number;

   protected var m_currentPlayIsLooping : Boolean;
   protected var m_currentPlayStoppedCallback : Function;

   //--------------------------------------
   //  PRIVATE VARIABLES
   //--------------------------------------

   private var m_playPositionForPausing : int;
   private var m_isPaused : Boolean;
   //used if a call to play() is made before an external sound asset has been told to load(), this will keep track
   //of whether or not the sound should begin playing once loading starts
   private var m_playAttempted : Boolean;
   //whether to use the above value or not
   private var m_playWhenLoadBegins : Boolean;

   //--------------------------------------
   //  CONSTRUCTOR
   //--------------------------------------

   /**
    * Creates a new sound
    * @param   sound               The Sound file to use
    * @param   volumeNormalization      A value used to attempt to normalize the sound if it can't be modified through
    *                            an external sound editing program
    */
   public function CoreSound( sound : Sound, key:String="", volumeNormalization : Number = 1.0)
   {
      m_key = key;
      m_sound = sound;
      m_volumeNormalization = volumeNormalization;
      m_volume = 1.0;
      this.stop();
   }

   //--------------------------------------
   //  GETTER/SETTERS
   //--------------------------------------

   /**
    * Used for any necessary identification of this sound
    */
   public function get key():String { return m_key; }
   public function set key(value:String):void
   {
      m_key = value;
   }

   public function get volume():Number { return m_volume; }
   public function set volume(value:Number):void
   {
      m_volume = CoreSound.filterVolume( value );
      adjustVolume();
   }

   /**
    * A volume modifier used when creating this sound.
    */
   public function get volumeNormalization():Number { return m_volumeNormalization; }

   /**
    * The absolute volume of this sound accounting for all modifiers in place
    */
   public function get absoluteVolume():Number
   {
      return ( this.isActive ? m_channel.soundTransform.volume : m_volume * m_volumeNormalization );
   }

   /**
    * The length of the current sound in milliseconds.
    */
   public function get length():Number { return m_sound.length; }

   /**
    * Returns the total number of bytes in this sound object.
    */
   public function get bytesTotal():Number { return m_sound.bytesTotal; }

   /**
    * Returns true if the sound is currently looping
    */
   public function get isLooping():Boolean { return m_currentPlayIsLooping; }

   /**
    * The sound is currently active (playing or paused)
    */
   public function get isActive() : Boolean
   {
      return m_channel != null;
   }

   /**
    * The sound is currently active but paused
    */
   public function get isPaused() : Boolean
   {
      return this.isActive && m_isPaused;
   }

   /**
    * The sound is currently active and playing (not paused)
    */
   public function get isPlaying() : Boolean
   {
      return this.isActive && !m_isPaused;
   }

   /**
    * The sound is buffering (not yet ready to play)
    */
   public function get isBuffering() : Boolean
   {
      return m_sound.isBuffering;
   }

   /**
    * Returns the percentage of the sound that has played so far.
    * If the sound is not playing, this returns NaN
    */
   public function get percentComplete():Number
   {
      if(this.isActive)
      {
         return m_channel.position / m_sound.length;
      }
      return NaN;
   }

   /**
    * Panning of the sound between left (-1) and right (1) speakers
    */
   public function get pan() : Number
   {
      if(this.isActive)
      {
         return m_channel.soundTransform.pan;
      }
      return 0;
   }
   /**
    * Panning of the sound between left (-1) and right (1) speakers
    * @param   a_pan   The left-to-right panning of the sound, ranging from -1 (full pan left) to 1 (full pan right).
    */
   public function set pan( a_pan : Number ) : void
   {
      if(this.isActive)
      {
         var transform : SoundTransform = m_channel.soundTransform;
         transform.pan = MathHelper.clamp(a_pan, -1, 1);
         m_channel.soundTransform = transform;
      }
   }

   internal function get channel():SoundChannel { return m_channel; }

   internal function get sound():Sound { return m_sound; }

   //--------------------------------------
   //  PUBLIC METHODS
   //--------------------------------------

   /**
    * Play this sound to completion one time.
    * @param   onCompleteCallback   A function which will fire once this sound has completed playing
    * @param   waitForLoad         If true and this sound is told to play before it begins loading, then it will wait to
    *                         begin playing until the load begins. If false (the default), it will fire the onComplete
    *                         handler and   will not begin playing when loading starts.
    */
   public function play(onCompleteCallback: Function = null, waitForLoad : Boolean = false ): void
   {
      startPlay(false, onCompleteCallback, waitForLoad);
   }

   /**
    * Loop this sound until stopped
    * @param   waitForLoad         If true and this sound is told ot play before it begins loading, then it will wait to
    *                         begin playing until the load begins. If false (the default), it will fire the onComplete
    *                         handler and   will not begin playing when loading starts.
    */
   public function loop(waitForLoad : Boolean = false): void
   {
      startPlay(true, null, waitForLoad);
   }

   /**
    * If paused, unpause. If unpaused, pause.
    */
   public function togglePause(): void
   {
      if(m_isPaused)
      {
         unpause();
      }
      else
      {
         pause();
      }
   }

   /**
    * Pause this sound if it is currently playing and unpaused.
    */
   public function pause(): void
   {
      if(!m_isPaused && this.isActive)
      {
         m_playPositionForPausing = m_channel.position;
         m_channel.stop();
         m_isPaused = true;
      }
   }

   /**
    * If this sound is currently paused, unpause it.
    */
   public function unpause(): void
   {
      if(m_isPaused)
      {
         playSound(m_playPositionForPausing);
         m_isPaused = false;
         m_playPositionForPausing = 0;
      }
   }

   /**
    * Stops the sound from playing. If the sound is not currently playing nothing happens.
    */
   public function stop(): void
   {
      if( m_channel != null )
      {
         m_channel.removeEventListener( Event.SOUND_COMPLETE, soundPlaybackCompleteHandler );
         m_channel.stop();
      }

      if(m_sound != null)
      {
         m_sound.removeEventListener(Event.OPEN, soundLoadOpenHandler);
      }

      m_playAttempted = false;
      m_channel = null;
      m_playPositionForPausing = 0;
      m_isPaused = false;
      m_currentPlayIsLooping = false;
      m_currentPlayStoppedCallback = null;
   }

   /**
    * If the sound is currently looping, this stops the loop and the sound will end after the current playthrough.
    * @param   onCompleteCallback   If provided, calls this function when the sound stops. This WILL NOT
    *                         overwrite an existing complete callback if one exists.
    */
   public function stopLooping( onCompleteCallback: Function = null ):void
   {
      if(m_currentPlayIsLooping)
      {
         m_currentPlayIsLooping = false;

         if(m_currentPlayStoppedCallback == null)
         {
            m_currentPlayStoppedCallback = onCompleteCallback;
         }

         //if the sound is currently paused, then setting m_currentPlayIsLooping to false
         //is all we need to do. When the sound is resumed, it will read this value and only
         //play it once. If the sound is currently playing, then we pause and unpause it to
         //restart from the same position but with the new m_currentPlayIsLooping value
         if(this.isPlaying)
         {
            this.pause();
            this.unpause();
         }
      }
   }

   /**
    * Stops the sound and disposes of any resources
    */
   public function dispose() : void
   {
      this.stop();
      m_sound = null;
   }

   /**
    * Ensures that the number passed is in the range [0-1] inclusive and reduces the significant
    * digits to 3
    * @param   a_volume
    * @return
    */
   public static function filterVolume( a_volume: Number ) : Number
   {
      a_volume = isNaN(a_volume) || !isFinite(a_volume) ? 1 : a_volume;
      a_volume = Math.floor( a_volume * 100 ) / 100;
      a_volume = MathHelper.clamp(a_volume, 0, 1);
      return a_volume;
   }

   /**
    * Creates a new sound object from a variety fo sources
    * @param   sound      A CoreSound instance, a Class of an [Embed] sound, or a path to a sound asset
    * @param   loadQueue   If the sound source is a string and loadQueue is not null, the sound iwll be added to the queue
    * @return
    */
   static public function create(sound:*, loadQueue:ILoadQueue=null, key:String=null):CoreSound
   {
      if(sound is Class)
      {
         return new CoreSound(new sound(), sound);
      }
      else if(sound is CoreSound)
      {
         return sound;
      }
      else if(sound is String)
      {
         //if asked to load an external asset, see if we have a load queue
         if(loadQueue != null)
         {
            //sound load messenger will return the sound object straight away so we can wrap it in a core sound
            //without waiting for the load to complete
            return new CoreSound(loadQueue.addItem(String(sound), ResourceType.Audio, key || sound).data, key || sound, 1.0);
         }
         else
         {
            return new SelfLoadingSound(sound);
         }
      }
      return null;
   }

   //--------------------------------------
   //  EVENT HANDLERS
   //--------------------------------------

   /**
    * When a sound File has completed playback
    */
   protected function soundPlaybackCompleteHandler(a_event:Event):void
   {
      if(m_channel != null)
      {
         m_channel.removeEventListener( Event.SOUND_COMPLETE, soundPlaybackCompleteHandler );
      }

      if(m_currentPlayStoppedCallback != null)
      {
         m_currentPlayStoppedCallback(a_event);
      }

      this.stop();
   }

   private function soundLoadOpenHandler(e:Event):void
   {
      m_sound.removeEventListener(Event.OPEN, soundLoadOpenHandler);
      if(m_playAttempted && m_playWhenLoadBegins)
      {
         //just in case the error happens consistently, we don't want this to result in an infinite loop
         m_playWhenLoadBegins = false;
         var loop : Boolean = m_currentPlayIsLooping;
         var callback : Function = m_currentPlayStoppedCallback;
         startPlay(loop, callback, false);
      }
   }

   //--------------------------------------
   //  PRIVATE & PROTECTED INSTANCE METHODS
   //--------------------------------------

   protected function startPlay(loop:Boolean, callback:Function, waitForLoad : Boolean):void
   {
      this.stop();

      m_currentPlayIsLooping = loop;
      m_currentPlayStoppedCallback = callback;
      m_playWhenLoadBegins = waitForLoad;

      var playSoundState:String = playSound(0);
      if(playSoundState == SOUND_PLAYING || playSoundState == SOUND_LOADING)
      {
         //play could be successful but channel null if we're caching the playback waiting for load
         if(m_channel != null)
         {
            adjustVolume();
            m_channel.addEventListener( Event.SOUND_COMPLETE, soundPlaybackCompleteHandler );
         }
      }
      else if(playSoundState == CANNOT_PLAY_AUDIO)
      {
         soundPlaybackCompleteHandler( new Event(ErrorEvent.ERROR) );
      }
      //since this sound will never play, we need to dispatch a complete event
      //check if the playback is cached though, and only fire the complete handler if it is not
      else
      {
         soundPlaybackCompleteHandler( new Event(Event.SOUND_COMPLETE) );
      }
   }

   /**
    * Plays the Sound File
    * @param   millisecondOffset   int      The Sounds start time offset
    * @return   Returns true if successful, false if there was an error and the complete handler should fire immediately
    */
   private function playSound( millisecondOffset : int ) : String
   {
      try
      {
         //play will return null if user has no sound card or if the maximum number of sound channels (32) has been surpassed
         m_channel = m_sound.play( millisecondOffset, (m_currentPlayIsLooping ? int.MAX_VALUE : 1),
            new SoundTransform( m_volumeNormalization * m_volume )
         );

         return m_channel != null ? SOUND_PLAYING : CANNOT_PLAY_AUDIO;
      }
      //note: calling play() before load() on a sound will throw "ArgumentError: Error #2068: Invalid sound."
      //we catch that here and add a listener for the start of load as well as setting a flag so that when the
      //sound begins loading we can start playing
      catch(e:ArgumentError)
      {
         m_channel = null;
         if(m_playWhenLoadBegins)
         {
            m_playAttempted = true;
            //note: I can't remember if the same method can be added as a listener more than once, if it can, this
            //could cause a memory leak as the handler will be added multiple times if the sound is never told to load
            m_sound.addEventListener(Event.OPEN, soundLoadOpenHandler);
         }

         //return state depending on if we are delaying playback for load
         return m_playWhenLoadBegins ? SOUND_LOADING : SOUND_NOT_LOADED;
      }

      return CANNOT_PLAY_AUDIO;
   }

   /**
    * Adjusts the Volume of the Current Sound
    */
   private function adjustVolume():void
   {
      if(m_channel != null)
      {
         var transform : SoundTransform = m_channel.soundTransform;
         transform.volume = m_volumeNormalization * m_volume;
         m_channel.soundTransform = transform;
      }
   }

}
}
