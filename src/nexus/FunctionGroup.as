// Copyright M. Griffie <nexus@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package nexus
{

import flash.utils.describeType;
import flash.utils.getQualifiedClassName;
import flash.utils.getTimer;

/**
 * An alternative event handling system to Flash's built-in event handling
 * @example <pre>
 * public class MyClass
 * {
 *    public const onSomeAction : FunctionGroup = new FunctionGroup();
 *    public const onAnotherAction : FunctionGroup = new FunctionGroup([String, int]);
 * }
 * </pre>
 */
public class FunctionGroup
{
   //--------------------------------------
   //   CLASS CONSTANTS
   //--------------------------------------

   //private static const NAME : String = getQualifiedClassName(FunctionGroup);

   //--------------------------------------
   //   PRIVATE VARIABLES
   //--------------------------------------

   protected var m_methods : Vector.<FunctionWrapper>;
   protected var m_fireOnceMethods : Vector.<FunctionWrapper>;
   protected var m_argumentTypes : Array;

   //--------------------------------------
   //   CONSTRUCTOR
   //--------------------------------------

   /**
    * Creates a new fucntion group. If proviuded, it uses the given array to validate (as best as possible) the arguments of functions
    * added to this group and values passed to this group when told to execute.
    * @param   functionArgumentTypes   An array of classes which define the parameter types
    */
   public function FunctionGroup(functionArgumentTypes:Array=null)
   {
      m_methods = new Vector.<FunctionWrapper>();
      m_fireOnceMethods = new Vector.<FunctionWrapper>();
      m_argumentTypes = functionArgumentTypes;
   }

   //--------------------------------------
   //   GETTER/SETTERS
   //--------------------------------------

   /**
    * The number of functions in this group (including fire once methods)
    */
   public function get functionCount():int { return (m_methods.length + m_fireOnceMethods.length); }

   //--------------------------------------
   //   PUBLIC METHODS
   //--------------------------------------

   /**
    * Adds a function to this group.
    * @param   func
    * @param   priority   A higher priority will execute first.
    * @param   duplicate    If true, the fucntion will be added even if it already exists
    */
   public function add(func:Function, priority:int = 0, duplicate:Boolean=false):void
   {
      addFunctionTo(func, priority, duplicate, m_methods);
   }

   /**
    * Adds a function which will execute once and then be removed
    * @param   func
    * @param   priority   A higher priority will execute first.
    * @param   duplicate    If true, the fucntion will be added even if it already exists
    */
   public function addFireOnce(func:Function, priority:int = 0, duplicate:Boolean = false):void
   {
      // note: need to sort in reverse order, since this Vector is iterated in reverse order
      addFunctionTo(func, priority, duplicate, m_fireOnceMethods, true);
   }

   /**
    * Returns true if the function exists in this group
    * @param   func
    * @return
    */
   public function contains(func:Function):Boolean
   {
      return getFunctionIndex(func, m_methods) != -1 || getFunctionIndex(func, m_fireOnceMethods) != -1;
   }

   /**
    * Removes the function from the list of handlers for this event
    * @param   func
    */
   public function remove(func:Function):void
   {
      var index : int = getFunctionIndex(func, m_methods);
      if(index != -1)
      {
         m_methods.splice(index, 1);
      }

      index = getFunctionIndex(func, m_fireOnceMethods);
      if(index != -1)
      {
         m_fireOnceMethods.splice(index, 1);
      }
   }

   /**
    * Remove all handlers on this event
    */
   public function removeAllFunctions():void
   {
      var x : int;

      for(x = m_methods.length - 1; x >= 0; --x)
      {
         m_methods.splice(x, 1);
      }

      for(x = m_fireOnceMethods.length - 1; x >= 0; --x)
      {
         m_fireOnceMethods.splice(x, 1);
      }
   }

   /**
    * Execute all methods in this group and pass along the given parameters
    * @param   ...params   Paramaters to apply to each method in this group
    */
   public function execute(...params):void
   {
      params = params || [];

      var x : int;

      if(m_argumentTypes != null)
      {
         //validate number of arguments
         if(params.length != m_argumentTypes.length)
         {
            throw new ArgumentError("Cannot execute this function group with " + params.length + " arguments, it requires " +
               m_argumentTypes.length);
         }

         //validate type of arguments
         for(x = 0; x < params.length; ++x)
         {
            if(params[x] != null && !(params[x] is m_argumentTypes[x]))
            {
               throw new ArgumentError("Cannot execute function group. Argument " + x + " is of type " +
                  getQualifiedClassName(params[x]) + " and it needs to be of type " + getQualifiedClassName(m_argumentTypes[x]));
            }
         }
      }

      var wrapper : FunctionWrapper;
      // clone the array in case one of the callbacks removes itself
      for each(wrapper in m_methods.slice())
      {
         wrapper.proc.apply(null, params);
      }

      for(x = m_fireOnceMethods.length - 1; x >= 0; --x)
      {
         wrapper = m_fireOnceMethods[x];
         m_fireOnceMethods.splice(x, 1);
         wrapper.proc.apply(null, params);
      }
   }

   //--------------------------------------
   //   EVENT HANDLERS
   //--------------------------------------

   //--------------------------------------
   //   PRIVATE & PROTECTED INSTANCE METHODS
   //--------------------------------------

   protected function addFunctionTo(func:Function, priority:int, duplicate:Boolean, vector:Vector.<FunctionWrapper>, sortReverse:Boolean = false):void
   {
      if(func != null && (duplicate || !contains(func)))
      {
         //note: variable arity functions return "0" for their length, so this check has been removed
         /*
         if(m_argumentTypes != null && func.length != m_argumentTypes.length)
         {
            throw new ArgumentError("Cannot add function with " + func.length + " arguments to this group. Must have " + m_argumentTypes.length + " arguments.");
         }
         //*/
         vector.push(new FunctionWrapper(func, priority));
         vector.sort(sortReverse ? sortFunctionsOnReversePriority : sortFunctionsOnPriority);
      }
   }

   private function getFunctionIndex(func:Function, vector:Vector.<FunctionWrapper>):int
   {
      for(var x : int = 0; x < vector.length; ++x)
      {
         if(vector[x].proc == func)
         {
            return x;
         }
      }
      return -1;
   }

   private function sortFunctionsOnReversePriority(l:FunctionWrapper, r:FunctionWrapper):Number
   {
      return sortFunctionsOnPriority(r, l);
   }

   private function sortFunctionsOnPriority(l:FunctionWrapper, r:FunctionWrapper):Number
   {
      return l.priority > r.priority ? -1 : (r.priority > l.priority ? 1 : sortFunctionsOnAdded(l,r));
   }

   private function sortFunctionsOnAdded(l:FunctionWrapper, r:FunctionWrapper):Number
   {
      return l.index < r.index ? -1 : (r.index < l.index ? 1 : 0);
   }

   /*
   public static function disposeOfAllEventHandlers(instance:*):void
   {
      if(instance is Class)
      {
         throw new ArgumentError("Cannot dispose of event handlers on a class. Must provide an instance.");
      }

      var start : int = getTimer();
      var func : FunctionGroup;
      var xml : XML = describeType(instance);
      for each(var constant : XML in xml.constant)
      {
         if(constant.@type == NAME)
         {
            func = (instance[String(constant.@name)] as FunctionGroup);
            if(func != null)
            {
               func.removeAllHandlers();
               trace("REMOVED", func);
            }
         }
      }
      trace(getTimer() - start);
   }
   //*/
}
}

class FunctionWrapper
{
   private static var count : int = 0;

   public const index : int = ++count;
   public var priority : int;
   public var proc : Function;

   public function FunctionWrapper(proc:Function, priority:int)
   {
      this.proc = proc;
      this.priority = priority;
   }
}
