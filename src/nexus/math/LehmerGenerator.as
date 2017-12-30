// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.math
{

import flash.utils.*;

/**
 * Variant on Linear Congruential Generator.
 * @see http://en.wikipedia.org/wiki/Lehmer_random_number_generator
 */
public final class LehmerGenerator implements ISeededPRNG
{
   private var m_seed:uint;
   private var m_currentState:uint;
   private var m_numbersGenerated:int;
   
   public function LehmerGenerator(seed:uint=1)
   {
      this.seed = seed;
   }
   
   public final function get seed():uint { return m_seed; }
   public final function set seed(value:uint):void
   {
      m_seed = value;
      m_currentState = m_seed;
      m_numbersGenerated = 0;
   }
   
   public final function get currentState():uint { return m_currentState; }
   
   [Inline]
   public function get period():uint { return 2147483647 /*int.MAX_VALUE*/; }
   
   public final function get numbersGenerated():int { return m_numbersGenerated; }
   
   public function next():uint
   {
      ++m_numbersGenerated;
      return m_currentState = ((m_currentState * 16807) % 2147483647);
      //return m_state = ((m_state * 279470273) % 4294967291);
   }
}
}
