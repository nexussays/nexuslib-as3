// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.audio
{

import nexus.net.loading.ILoadQueue;
import nexus.utils.Parse;
import nexus.utils.Utility;
import flash.errors.IllegalOperationError;
import flash.media.*;
import flash.utils.*;
import flash.events.*;
import nexus.IDisposable;

/**
 * The SoundSystem class manages all audio functions; adding sounds, playing sounds and loops, and controlling volume. This
 * should be implemented as a Singleton in your project.
 */
public class SoundSystem extends VolumeControl
{
   //--------------------------------------
   //  PRIVATE VARIABLES
   //--------------------------------------

   //dictionary -> key:String / value:Array[sound, sound channel]
   private var m_sounds: Dictionary; /*Array*/
   private var m_categoryVolume : StandardSoundChannels;

   private var m_loadQueue : ILoadQueue;

   //--------------------------------------
   //  CONSTRUCTOR
   //--------------------------------------

   public function SoundSystem( keySoundPairs: Array/*CoreSound*/ = null, loadQueue : ILoadQueue = null)
   {
      m_sounds = new Dictionary();
      m_categoryVolume = new StandardSoundChannels(categoryVolumeChangedHandler);

      //adjust system volume
      onVolumeChanged.add(systemVolumeChangedHandler);

      m_loadQueue = loadQueue;

      this.addSounds( keySoundPairs );
   }

   //--------------------------------------
   //  GETTER/SETTERS
   //--------------------------------------

   /**
    * The master volume of this SoundSystem. In most cases this should remain
    * at the default value of 1.0 -- you should instead set the userVolume and allow
    * the user to further adjust it.
    */
   override public function get systemVolume():Number { return super.systemVolume; }

   /**
    * The master volume of user-defined volume control.
    */
   override public function get userVolume():Number { return super.userVolume; }

   /**
    * Provides access to each sound channel and volumne controls for each
    */
   public function get channelVolumes():StandardSoundChannels { return m_categoryVolume; }

   //--------------------------------------
   //  PUBLIC METHODS
   //--------------------------------------

   /**
    * Adds a sound to the SoundSystem with the given key value.
    * @param   key               The key of the CoreSound
    * @param   sound            A CoreSound instance, a Class of an [Embed] sound, or a path to a sound asset
    * @param   category         The category for the sound. Used to control volume by category. If null, uses SoundChannel.SoundEffects
    * @param   playImmediately      Should this sound play immediately on creation
    * @throws   ArgumentError      If a sound already exists with the same key
    * @throws   ArgumentError      If the passed sound object is nto of a valid type
    * @see CoreSound
    * @see SelfLoadingSound
    * @see RandomSound
    * @example   <pre>SoundSystem.shared.addSound("sound1Key", new SelfLoadingSound("runtime_assets/sound3.mp3"), SoundChannel.BackgroundMusic);</pre>
    * You can also omit instantiating a SelfLoadingSound as addSound will assume a URL if you pass in a string, like so:
    * <pre>SoundSystem.shared.addSound("sound1Key", "runtime_assets/sound3.mp3", SoundChannel.BackgroundMusic);</pre>
    * This is the preferred method as it will allow the SoundSystem to determine if it should use the provided ILoadQueue or not
    * The same applies for embedded sounds, both of the following produce the same result:
    * <pre>SoundSystem.shared.addSound("sound2Key", new CoreSound(new EmbeddedSoundClass()), SoundChannel.BackgroundMusic);</pre>
    * <pre>SoundSystem.shared.addSound("sound2Key", EmbeddedSoundClass, SoundChannel.BackgroundMusic);</pre>
    */
   public function addSound( key : String, sound : *, category : SoundChannel = null, playImmediately: Boolean = false ): void
   {
      var soundToAdd : CoreSound = CoreSound.create(sound, m_loadQueue, key);

      if(soundToAdd == null)
      {
         throw new ArgumentError("[SoundSystem]: Unable to add sound \"" + sound + "\" it is of an unsupported type.");
      }

      if( m_sounds[ key ] == null )
      {
         category == category || SoundChannel.SoundEffects;
         m_sounds[ key ] = [ soundToAdd, category ];
         if( playImmediately )
         {
            this.playSound( key );
         }
      }
      else
      {
         throw new ArgumentError("[SoundSystem]: A sound with key \"" + key + "\" already exists in this SoundSystem.");
      }
   }

   /**
    * Add groups of sounds at once in an array.
    * @param   a_keySoundPairs
    * @example   <pre>SoundSystem.shared.addSounds([
         ["sound1Key", "sound1.mp3"],
         ["sound2key", EmbeddedSoundClass],
         ["sound2Key", new CoreSound(soundInstance)],
         ["sound3Key", new SelfLoadingSound("sound2.mp3")],
         ["soundVariety", ["sound3.mp3", new SelfLoadingSound("sound4.mp3"), EmbeddedSoundClass2] ]
      ], SoundChannel.SoundEffects);</pre>
    */
   public function addSounds( a_keySoundPairs : Array, a_category : SoundChannel = null ) : void
   {
      if(a_keySoundPairs != null && a_keySoundPairs.length > 0)
      {
         for each( var array: Array in a_keySoundPairs )
         {
            if(array.length != 2)
            {
               throw new ArgumentError("Invalid array format passed into SoundSystem.addSounds()");
            }

            a_category == a_category || SoundChannel.SoundEffects;
            //check for a sound variety
            if(array[1] is Array)
            {
               var soundsForVariety : Array = [];
               for(var x : int = 0; x < array[1].length; ++x)
               {
                  soundsForVariety.push(CoreSound.create(array[1][x], m_loadQueue));
               }
               this.addSound(array[0], new RandomSound(soundsForVariety), a_category, false);
            }
            else
            {
               this.addSound( array[0], array[1], a_category, false );
            }
         }
      }
   }

   /**
    * Starts playing the sound with the given key.
    * @param   key               The sound to play
    * @param   onCompleteCallback   A function to execute when the sound is finished playing
    * @param   waitForLoad         If true and this sound has not yet been loaded, then it will wait to begin playing until
    *                         the load begins. If false (the default), onCompleteCallback will be executed
    *                         and will not begin playing when loading starts.
    */
   public function playSound( key: String, onCompleteCallback: Function = null, waitForLoad: Boolean = false ) : CoreSound
   {
      var arr: Array = m_sounds[key];
      if(arr != null)
      {
         //TODO: increase load queue priority for this item, as well as start its loading in case the queue is lazy loading
         if(m_loadQueue != null)
         {
            if(arr[0] is RandomSound && RandomSound(arr[0]).nextSound != null)
            {
               m_loadQueue.loadItemByKey(RandomSound(arr[0]).nextSound.key);
            }
            else
            {
               m_loadQueue.loadItemByKey(key);
            }
         }

         CoreSound(arr[0]).volume = m_categoryVolume.getVolumeControlByCategory(arr[1]).actualVolume;
         CoreSound(arr[0]).play( onCompleteCallback, waitForLoad );

         return arr[0] as CoreSound;
      }
      return null;
   }

   /**
    * Starts playing the loop with the given key. If the loop is already playing, nothing happens unless
    * a_forceRestart is specified in which case the loop is stopped and then started again.
    * @param   key               The sound to play
    * @param   forceRestart      Force the sound to be stopped and started again if it is already playing.
    * @param   waitForLoad         If true and this sound has not yet been loaded, then it will wait to begin playing until
    *                         the load begins. If false (the default), onCompleteCallback will be executed
    *                         and will not begin playing when loading starts.
    */
   public function playSoundAsLoop( key: String, forceRestart : Boolean = false, waitForLoad: Boolean = false ): CoreSound
   {
      unpauseSound(key);
      var loopIsPlaying : Boolean = soundIsPlaying( key );
      var arr: Array = m_sounds[key];
      if( ( forceRestart || !loopIsPlaying ) && arr != null )
      {
         //if we're forcing a restart and the loop is already playing then stop it first
         if(forceRestart && loopIsPlaying)
         {
            CoreSound(arr[0]).stop();
         }

         //TODO: increase load queue priority for this item, as well as start its loading in case the queue is lazy loading
         if(m_loadQueue != null)
         {
            m_loadQueue.loadItemByKey(key);
         }

         CoreSound(arr[0]).volume = m_categoryVolume.getVolumeControlByCategory(arr[1]).actualVolume;
         CoreSound(arr[0]).loop(waitForLoad);

         return arr[0] as CoreSound;
      }
      return null;
   }

   /**
    * Play the given sound one time
    * @param   a_sound               The sound to play
    * @param   a_category            The category used for volume control.
    * @param   a_onCompleteCallback   A function to execute when the sound is finished playing
    * @param   a_volumeModifier      An optional volume modifier for this play of this sound. There is no need
    * to change this from the default value unless you know what you are doing
    */
   public function playQuickSound( a_sound: Sound, a_category : SoundChannel, a_onCompleteCallback: Function = null, a_volumeModifier : Number = 1.0 ) : void
   {
      var channel: SoundChannel = a_sound.play( 0, 1,
         new SoundTransform(CoreSound.filterVolume(a_volumeModifier) * m_categoryVolume.getVolumeControlByCategory(a_category).actualVolume)
      );

      if( a_onCompleteCallback != null )
      {
         channel.addEventListener( Event.SOUND_COMPLETE, a_onCompleteCallback, false, 0, true );
      }
   }

   /**
    * Stop the sound with the given key value
    * @param   key   The SoundLoop to stop playing
    */
   public function stopSound( key: String ): void
   {
      var sound: CoreSound = getSound(key);
      if( sound != null )
      {
         sound.stop();
      }
   }

   /**
    * If the sound with the given key value is currently playing in a loop, this will stop
    * the looping resulting in the sound ending after the current playthrough finishes.
    * @param   key               The sound to stop from looping
    * @param   a_onCompleteCallback   If provided, calls this function when the sound stops
    */
   public function stopSoundFromLooping( key: String, a_onCompleteCallback: Function = null ): void
   {
      var sound: CoreSound = getSound(key);
      if( sound != null )
      {
         sound.stopLooping( a_onCompleteCallback );
      }
   }

   public function stopAllSoundsInCategory(category:SoundChannel):void
   {
      //update the volume of each sound in this category
      for each( var arr: Array in m_sounds )
      {
         if( arr[1] == category )
         {
            (arr[0] as CoreSound).stop();
         }
      }
   }

   /**
    * Stops all sounds that are currently playing.
    */
   public function stopAllSounds():void
   {
      for(var key : String in m_sounds)
      {
         this.stopSound(key);
      }
      SoundMixer.stopAll();
   }

   /**
    * Stops and removes the given sound
    * @param   key   The key of the sound to destroy
    */
   public function removeSound( key: String ): void
   {
      this.stopSound( key );
      var sound: CoreSound = getSound(key);
      if( sound != null )
      {
         sound.dispose();
         sound = null;
         delete m_sounds[ key ];
      }
   }

   public function removeAllSounds(): void
   {
      for(var key : String in m_sounds)
      {
         this.removeSound(key);
         delete m_sounds[ key ];
      }
   }

   /**
    * Returns the CoreSound for the given key value.
    * @param   key   The key of the CoreSound to return
    * @return   The CoreSound with this key value
    */
   public function getSound( key: String ): CoreSound
   {
      var arr : Array = m_sounds[ key ];
      if(arr != null)
      {
         return arr[0];
      }
      return null;
   }

   /**
    * Returns true if the sound exists
    */
   public function soundExists( key: String ): Boolean
   {
      return ( getSound( key ) != null );
   }

   /**
    * The sound is currently active (either playing or paused)
    */
   public function soundIsActive( key: String ): Boolean
   {
      var sound: CoreSound = getSound( key );
      return ( sound != null && sound.isActive );
   }

   /**
    * The sound is active and playing (not paused)
    */
   public function soundIsPlaying( key: String ): Boolean
   {
      var sound: CoreSound = getSound( key );
      return ( sound != null && sound.isPlaying );
   }

   /**
    * Pause the given sound. IF the sound is currently paused, nothing will happen
    * @param   key   The key of the sound to pause
    */
   public function pauseSound( key: String ): void
   {
      var sound: CoreSound = getSound(key);
      if( sound != null )
      {
         sound.pause();
      }
   }

   public function resetVolumes():void
   {
      throw new IllegalOperationError("Not Implemented");
   }

   /**
    * Returns true if this SoundSystem hasa load queue attached
    * @return
    */
   public function hasLoadQueue():Boolean
   {
      return m_loadQueue != null;
   }

   /**
    *
    * @param   loadQueue
    * @throws    IllegalOperationError   If this SoundSystem already has a load queue
    */
   public function setLoadQueue(loadQueue:ILoadQueue):void
   {
      if(m_loadQueue != null)
      {
         throw new IllegalOperationError("SoundSystem already has a load queue set: " + m_loadQueue);
      }
      m_loadQueue = loadQueue;
   }

   //--------------------------------------
   //  PRIVATE & PROTECTED INSTANCE METHODS
   //--------------------------------------

   /**
    * Unpause the given sound. If the sound is not currently paused, nothing will happen
    * @param   key
    */
   public function unpauseSound( key: String ):void
   {
      var sound: CoreSound = getSound( key );
      if( sound != null )
      {
         sound.unpause();
      }
   }

   private function categoryVolumeChangedHandler(control:VolumeControl):void
   {
      var category : SoundChannel = m_categoryVolume.getCategoryByVolumeControl(control);

      //update the volume of each sound in this category
      for each(var arr: Array in m_sounds)
      {
         if(arr[1] == category)
         {
            arr[0].volume = control.actualVolume;
         }
      }
   }

   private function systemVolumeChangedHandler(control:VolumeControl):void
   {
      trace(control, this.actualVolume);
      SoundMixer.soundTransform = new SoundTransform(this.actualVolume);
   }

   private function getSoundCategory( key: String ): SoundChannel
   {
      var arr : Array = m_sounds[ key ];
      if(arr != null)
      {
         return arr[1];
      }
      return null;
   }
}
}
