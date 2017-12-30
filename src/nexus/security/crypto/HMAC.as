// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.security.crypto
{

import flash.utils.*;
import nexus.utils.ByteUtils;

/**
 * Implementation of hash-based message authentication code
 * @see   http://tools.ietf.org/html/rfc2104
 */
public class HMAC
{
   //--------------------------------------
   //   CLASS CONSTANTS
   //--------------------------------------
   
   private static const BLOCKSIZE_BYTES:int = 64;
   
   private static const HMAC_SHA1 : HMAC = new HMAC(new SHA1HashFunction());
   private static const HMAC_SHA256 : HMAC = new HMAC(new SHA256HashFunction());
   
   //--------------------------------------
   //   INSTANCE VARIABLES
   //--------------------------------------
   
   private var m_hashFunction : IHashFunction;
   private var m_secretKey : ByteArray;
   
   //--------------------------------------
   //   CONSTRUCTOR
   //--------------------------------------
   
   public function HMAC(hashFunction:IHashFunction)
   {
      m_hashFunction = hashFunction;
   }
   
   //--------------------------------------
   //   GETTERS/SETTERS
   //--------------------------------------
   
   public function get secretKey():ByteArray { return m_secretKey; }
   public function set secretKey(value:ByteArray):void
   {
      m_secretKey = value;
   }
   
   //--------------------------------------
   //   PUBLIC INSTANCE METHODS
   //--------------------------------------
   
   /**
    * Generate a message authentication code for the given message. If a key is provided, it will be used. If the
    * key is null, the value set in secretKey will be used. If both are null, an exception is thrown.
    * @param   message         The message from which to generate the authentication code.
    * @param   key            The secret key to use. Optional if secretKey has been set.
    * @throws   ArgumentError   If key is null and secretKey has not been set
    * @return   A ByteArray whose length is determined by the hash algorithm used.
    */
   public function generate(message:ByteArray, secretKey:ByteArray=null):ByteArray
   {
      secretKey = secretKey || m_secretKey;
      if(secretKey == null)
      {
         throw new ArgumentError("Cannot compute HMAC without secret key.");
      }
      
      //write the key to a different ByteArray so we don't mutate it
      var value:ByteArray = new ByteArray();
      if(secretKey.length > BLOCKSIZE_BYTES)
      {
         value.writeBytes(m_hashFunction.hash(secretKey));
      }
      else
      {
         value.writeBytes(secretKey);
      }
      
      while(value.length < BLOCKSIZE_BYTES)
      {
         value.writeByte(0);
      }
      
      var innerPad:ByteArray = new ByteArray();
      var outerPad:ByteArray = new ByteArray();
      for(var x:int = 0; x < BLOCKSIZE_BYTES; ++x)
      {
         innerPad.writeByte(value[x] ^ 0x36);
         outerPad.writeByte(value[x] ^ 0x5c);
      }
      
      if(message != null)
      {
         innerPad.writeBytes(message);
      }
      outerPad.writeBytes(m_hashFunction.hash(innerPad));
      
      value.clear();
      value = null;
      innerPad.clear();
      innerPad = null;
      
      return m_hashFunction.hash(outerPad);
   }
   
   //--------------------------------------
   //   PRIVATE INSTANCE METHODS
   //--------------------------------------
   
   //--------------------------------------
   //   PUBLIC CLASS METHODS
   //--------------------------------------
   
   static public function sha1(message:ByteArray, key:ByteArray):ByteArray
   {
      return HMAC_SHA1.generate(message, key);
   }
   
   static public function sha256(message:ByteArray, key:ByteArray):ByteArray
   {
      return HMAC_SHA256.generate(message, key);
   }
}

}
