// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus
{
   
/**
 * Use the Dispose method of this interface to explicitly release unmanaged resources in conjunction with
 * the garbage collector. The consumer of an object can call this method when the object is no longer needed.
 */
public interface IDisposable
{
   /**
    * Performs tasks associated with freeing, releasing, or resetting unmanaged resources.
    */
   function dispose():void;
}

}
