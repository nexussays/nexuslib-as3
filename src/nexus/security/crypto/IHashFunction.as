// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.security.crypto
{
import flash.utils.ByteArray;

/**
 * Interface for all cryptographic hash functions to implement so they can be used as primitives to construct
 */
public interface IHashFunction
{
   /**
    * Hash the provided bytes and returned the hashed value
    * @param   bytes   The bytes to hash
    * @return   The hashed bytes
    */
   function hash(bytes:ByteArray):ByteArray;
}

}
