package
{

import flash.display.*;
import flash.events.*;
import flash.utils.*;

import foo.*;
import foo.bar.*;

import nexus.utils.reflection.*;

/**
 * ...
 * @author	Malachi Griffie
 * @since 7/28/2011 8:46 PM
 */
public class Main extends Sprite
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	static public const COUNT:int = 11234;
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function Main()
	{
		stage.addEventListener(Event.ENTER_FRAME, frame1);
	}
	
	private function frame1(e:Event):void
	{
		stage.removeEventListener(Event.ENTER_FRAME, frame1);
		//stage.addChild(new FPSLabel());
		stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUp);
		
		var start : int;
		
		//call it once first in case there is any internal caching going on
		trace(describeType(TestClass).toXMLString());
		//trace(describeType(IFoo).toXMLString());
		
		start = getTimer();
		Reflection.getTypeInfo(TestClass);
		trace("took " + (getTimer() - start) + "ms for Reflection");
		start = getTimer();
		describeType(TestClass);
		trace("took " + (getTimer() - start) + "ms for describeType");
		
		/*
		start = getTimer();
		for (var x : int = 0; x < COUNT; ++x)
		{
			//took 3025ms for 11234, 0.2692718533024746ms each
			//describeType(TestClass);
			//uncached: took 6953ms for 11234, 0.618924692896564ms each
			//cached: took 5ms for 11234, 0.0004450774434751647ms each
			Reflection.getTypeInfo(TestClass);
		}
		
		trace("took " + (getTimer() - start) + "ms for " + COUNT + ", " + ((getTimer() - start) / COUNT) + "ms each" );
		//*/
		
		/*
		var testClass : TestClass = new TestClass(false);
		var typeInfo : TypeInfo = Reflection.getTypeInfo(testClass);
		typeInfo.getMethodByName("publicFun").invoke(testClass, testClass, 5);
		var type : Class = Reflection.getClass(typeInfo.getMethodByName("publicFinalFun").parameters[0].type);
		trace(type);
		var bar : Object = new type();
		//*/
		
		/*
		trace("testClass.declaringType", testClass.declaringType);
		trace("testClass.implementedInterfaces", testClass.implementedInterfaces);
		trace("testClass.methods", testClass.methods);
		trace("testClass.properties", testClass.properties);
		trace("testClass.fields", testClass.fields);
		trace("testClass.name", testClass.name);
		trace(testClass.extendedClasses.indexOf(Object));
		trace(testClass.extendedClasses.indexOf(Sprite));
		trace(testClass.extendedClasses.indexOf(BaseClass));
		//*/
		
		/*
		trace(Reflection.getClass(testClass));
		trace(Reflection.getClass(TypeInfo));
		trace(Reflection.getClass("dna.utils.reflection::TypeInfo"));
		trace(Reflection.getClass("TypeInfo"));
		trace(Reflection.getSuperClass(testClass));
		trace(Reflection.getSuperClass(TypeInfo));
		trace(Reflection.getSuperClass("dna.utils.reflection::TypeInfo"));
		trace(Reflection.getSuperClass("TypeInfo"));
		//*/
		
		/*
		trace(Reflection.isPrimitive(TypeInfo));
		trace(Reflection.isPrimitive(int));
		trace(Reflection.isPrimitive(uint));
		trace(Reflection.isPrimitive(String));
		trace(Reflection.isPrimitive(Number));
		//*/
		
		//trace(JSON.encode(ObjectSerializer.serialize(new AdvancedSprite())));
	}
	
	private function stage_keyUp(e:KeyboardEvent):void
	{
		Reflection.getTypeInfo(MovieClip);
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	//--------------------------------------
	//	EVENT HANDLERS
	//--------------------------------------
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
}

}