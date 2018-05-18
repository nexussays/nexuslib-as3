// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.graphics
{

import flash.display.Graphics;

/**
 * ...
 */
public interface IFill
{
   /**
    *  Starts the fill.
    * @param   target   The target Graphics object that is being filled.
    */
   function begin(target:Graphics):void;
   /**
    *  Ends the fill.
    * @param   target   The target Graphics object that is being filled.
    */
   function end(target:Graphics):void;

   function clone():IFill;
}

}
