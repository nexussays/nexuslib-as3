// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus
{

import flash.errors.IllegalOperationError;
import flash.utils.*;

/**
 * Used to set a time for the system that is not based on the client's local machine. Typically this value is set as one
 * of the very first actions of the application after a call to a server.
 * @since 8/5/2010 10:34 PM
 */
public class SystemTime
{
   //--------------------------------------
   //   CLASS VARIABLES
   //--------------------------------------

   private static var m_initializedTime : Number = 0;
   private static var m_isInitialized : Boolean = false;

   //--------------------------------------
   //   GETTER/SETTERS
   //--------------------------------------

   static public function get isInitialized():Boolean { return m_isInitialized; }

   /**
    * The time the system was initialized to, in number of milliseconds since Jan 1, 1970
    */
   public static function get initializationTime():Number
   {
      if(!m_isInitialized)
      {
         throw new IllegalOperationError("Cannot access SystemTime until it has been initialized");
      }
      return m_initializedTime;
   }

   /**
    * The number of milliseconds since Jan 1, 1970 as defined by a getTimer() offset from the initialization time
    */
   public static function get actualTime():Number
   {
      if(!m_isInitialized)
      {
         throw new IllegalOperationError("Cannot access SystemTime until it has been initialized");
      }
      return m_initializedTime + getTimer();
   }

   //--------------------------------------
   //   PUBLIC CLASS METHODS
   //--------------------------------------

   /**
    * Set the system time to some number of milliseconds since Jan 1, 1970. Can only be performed once
    * @param   time   Number of milliseconds since Jan 1, 1970
    * @throws   IllegalOperationError   After being called once, will throw an IllegalOperationError on each successive call
    */
   public static function initialize(time:Number):void
   {
      if(m_isInitialized)
      {
         throw new IllegalOperationError("SystemTime is already initialized and can only be initialized once");
      }

      if(isNaN(time))
      {
         throw new ArgumentError("Cannot initialize SystemTime to NaN");
      }

      if(!isFinite(time))
      {
         throw new ArgumentError("Cannot initialize SystemTime to " + time + ", value must be finite");
      }

      if(time < 0)
      {
         throw new ArgumentError("Cannot initialize SystemTime to a negative value: " + time);
      }

      m_initializedTime = time;
      m_isInitialized = true;
   }
}

}
