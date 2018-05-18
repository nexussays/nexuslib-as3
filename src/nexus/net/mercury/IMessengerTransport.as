// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.net.mercury
{

import nexus.event.TypedEvent;
import nexus.IDisposable;
import flash.net.URLRequest;

/**
 * ...
 * @since 3/14/2011 7:16 PM
 */
public interface IMessengerTransport extends IDisposable
{
   function get id():int;

   function initialize():void;
   function load(request:URLRequest):void;
   function close():void;

   function get supportsRetry():Boolean;

   function get httpStatus():int;
   function get statusMessage():String;

   function get bytesLoaded():int;
   function get bytesTotal():int;

   function get data():*;

   function get destinationApplicationDomain():ApplicationDomainType;
   function set destinationApplicationDomain(value:ApplicationDomainType):void;
}

}
