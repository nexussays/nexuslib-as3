// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.errors
{

import flash.errors.IllegalOperationError;
import flash.utils.*;

/**
 * ...
 * @since 3/14/2011 6:44 PM
 */
public class ObjectDisposedError extends IllegalOperationError
{
   //--------------------------------------
   //   CLASS CONSTANTS
   //--------------------------------------

   //--------------------------------------
   //   PRIVATE VARIABLES
   //--------------------------------------

   //--------------------------------------
   //   CONSTRUCTOR
   //--------------------------------------

   public function ObjectDisposedError(classType:Class = null)
   {
      super("Cannot access this " + (classType == null ? "object" : classType) + ", it has been disposed");

      this.name = "ObjectDisposedError";
   }

   //--------------------------------------
   //   GETTER/SETTERS
   //--------------------------------------

   //--------------------------------------
   //   PUBLIC METHODS
   //--------------------------------------

   //--------------------------------------
   //   EVENT HANDLERS
   //--------------------------------------

   //--------------------------------------
   //   PRIVATE & PROTECTED INSTANCE METHODS
   //--------------------------------------
}

}
