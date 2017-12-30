// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus.net
{


import flash.net.URLRequestHeader;
import flash.utils.*;

/**
 * @private
 */
public class HttpResponse
{
   //--------------------------------------
   //   CLASS CONSTANTS
   //--------------------------------------
   
   //--------------------------------------
   //   INSTANCE VARIABLES
   //--------------------------------------
   
   private var m_url : String;
   private var m_status : int;
   private var m_bytesLoaded : int;
   private var m_bytesTotal : int;
   private var m_headers : Vector.<URLRequestHeader>;
   private var m_body : IDataInput;
   
   //--------------------------------------
   //   CONSTRUCTOR
   //--------------------------------------
   
   public function HttpResponse()
   {
      m_headers = new Vector.<URLRequestHeader>();
      m_status = -1;
   }
   
   //--------------------------------------
   //   GETTER/SETTERS
   //--------------------------------------
   
   public function get headers():Vector.<URLRequestHeader> { return m_headers; }
   
   public function get status():int { return m_status; }
   internal function setStatus(value:int):void
   {
      m_status = value;
   }
   
   public function get url():String { return m_url; }
   internal function setUrl(value:String):void
   {
      m_url = value;
   }
   
   public function get body():IDataInput { return m_body; }
   internal function setBody(value:IDataInput):void
   {
      m_body = value;
   }
   
   public function get bytesLoaded():int { return m_bytesLoaded; }
   internal function setBytesLoaded(value:int):void
   {
      m_bytesLoaded = value;
   }
   
   public function get bytesTotal():int { return m_bytesTotal; }
   internal function setBytesTotal(value:int):void
   {
      m_bytesTotal = value;
   }
   
   //--------------------------------------
   //   PUBLIC INSTANCE METHODS
   //--------------------------------------
   
   internal function addHeaders(array:Array):void
   {
      for each(var header : URLRequestHeader in array)
      {
         m_headers.push(header);
      }
   }
   
   public function toString(verbose:Boolean=false):String
   {
      return "[HttpResponse:" + m_status + "]";
   }
}

}
