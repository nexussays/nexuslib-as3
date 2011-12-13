package
{

import avmplus.AVMDescribeType;
import flash.display.*;
import flash.events.*;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.*;
import nexus.utils.serialization.json.JsonSerializer;

import foo.*;
import foo.bar.*;

import nexus.utils.reflection.*;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since 7/28/2011 8:46 PM
 */
public class Main extends Sprite
{
	static public const COUNT:int = 5678;
	
	private var txt:TextField;
	public function Main()
	{
		stage.addEventListener(Event.ENTER_FRAME, frame1);
		
		txt = new TextField();
		txt.defaultTextFormat = new TextFormat("Consolas", 12, 0);
		txt.width = stage.stageWidth;
		txt.height = stage.stageHeight;
		this.addChild(txt);
	}
	
	private function frame1(e:Event):void
	{
		stage.removeEventListener(Event.ENTER_FRAME, frame1);
		
		stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUp);
		
		var start : int;
		var x : int;
		
		//call it once first in case there is any internal caching going on
		//out(describeType(IFoo).toXMLString());
		//out(describeType(new TestClass(false)).toXMLString());// .split("\n")[0]);
		//out(describeType(TestClass).toXMLString());// .split("\n")[0]);
		
		//out(AVMDescribeType.HIDE_NSURI_METHODS);
		//out(AVMDescribeType.INCLUDE_BASES);
		//out(AVMDescribeType.INCLUDE_INTERFACES);
		//out(AVMDescribeType.INCLUDE_VARIABLES);
		//out(AVMDescribeType.INCLUDE_ACCESSORS);
		//out(AVMDescribeType.INCLUDE_METHODS);
		//out(AVMDescribeType.INCLUDE_METADATA);
		//out(AVMDescribeType.INCLUDE_CONSTRUCTOR);
		//out(AVMDescribeType.INCLUDE_TRAITS);
		//out(AVMDescribeType.USE_ITRAITS);
		//out(AVMDescribeType.HIDE_OBJECT);
		//out(AVMDescribeType.FLASH10_FLAGS);
		//out(AVMDescribeType.HIDE_NSURI_METHODS |
			//AVMDescribeType.INCLUDE_BASES |
			//AVMDescribeType.INCLUDE_INTERFACES |
			//AVMDescribeType.INCLUDE_VARIABLES |
			//AVMDescribeType.INCLUDE_ACCESSORS |
			//AVMDescribeType.INCLUDE_METHODS |
			//AVMDescribeType.INCLUDE_METADATA |
			//AVMDescribeType.INCLUDE_CONSTRUCTOR |
			//AVMDescribeType.INCLUDE_TRAITS |
			//AVMDescribeType.HIDE_OBJECT);
		//out(AVMDescribeType.GET_CLASS_INFO);
		//out(AVMDescribeType.GET_INSTANCE_INFO);
		
		//var flags : uint = AVMDescribeType.INCLUDE_INTERFACES |
			//AVMDescribeType.INCLUDE_VARIABLES |
			//AVMDescribeType.INCLUDE_ACCESSORS |
			//AVMDescribeType.INCLUDE_METHODS |
			//AVMDescribeType.INCLUDE_METADATA |
			//AVMDescribeType.INCLUDE_TRAITS |
			//AVMDescribeType.HIDE_OBJECT;
		//out(JsonSerializer.serialize(AVMDescribeType.getClassJson(TestClass), "  ", 100));
		
		//flags ^= AVMDescribeType.INCLUDE_BASES;
		//flags ^= AVMDescribeType.INCLUDE_CONSTRUCTOR;
		//out(flags, "\n", JsonSerializer.serialize(AVMDescribeType.json(TestClass, flags), "  ", 100));
		
		//flags |= AVMDescribeType.INCLUDE_CONSTRUCTOR | AVMDescribeType.INCLUDE_BASES | AVMDescribeType.USE_ITRAITS;
		//out(JsonSerializer.serialize(AVMDescribeType.getInstanceJson(TestClass), "  ", 100));
		
		//out(AVMDescribeType.xml(BaseClass, flags).toXMLString());
		//out(describeType(BaseClass).toXMLString());
		
		start = getTimer();
		describeType(TestClass);
		out("took " + (getTimer() - start) + "ms for describeType");
		start = getTimer();
		Reflection.getTypeInfo(TestClass);
		out("took " + (getTimer() - start) + "ms for Reflection");
		
		/*
		start = getTimer();
		for(x = 0; x < COUNT; ++x)
		{
			//took 3025ms for 11234, 0.2692718533024746ms each
			describeType(TestClass);
		}
		out("took " + (getTimer() - start) + "ms for " + COUNT + ", " + ((getTimer() - start) / COUNT) + "ms each" );
		//*/
		/*
		start = getTimer();
		for(x = 0; x < COUNT; ++x)
		{
			//uncached: took 6953ms for 11234, 0.618924692896564ms each
			//cached: took 5ms for 11234, 0.0004450774434751647ms each
			Reflection.getTypeInfo(TestClass);
		}
		out("took " + (getTimer() - start) + "ms for " + COUNT + ", " + ((getTimer() - start) / COUNT) + "ms each");
		//*/
		
		var testClass : TestClass = new TestClass(false);
		var typeInfo : TypeInfo = Reflection.getTypeInfo(testClass);
		
		/*
		typeInfo.getMethodByName("publicFun").invoke(testClass, testClass, 5);
		var type : Class = Reflection.getClass(typeInfo.getMethodByName("publicFinalFun").parameters[0].type);
		out(type);
		var bar : Object = new type();
		//*/
		
		out(Reflection.getQualifiedClassName(new Vector.<*>()));
		out(Reflection.getVectorClass(new Vector.<*>()));
		out(Reflection.getQualifiedClassName(new Vector.<TestClass>()));
		out(Reflection.getVectorClass(new Vector.<TestClass>()));
		
		/*
		out("testClass.type", typeInfo.type);
		out("testClass.isDynamic", typeInfo.isDynamic);
		out("testClass.implementedInterfaces", typeInfo.implementedInterfaces);
		out("testClass.methods", typeInfo.methods);
		out("testClass.properties", typeInfo.properties);
		out("testClass.fields", typeInfo.fields);
		out("testClass.name", typeInfo.name);
		out(typeInfo.extendedClasses.indexOf(Object));
		out(typeInfo.extendedClasses.indexOf(Sprite));
		out(typeInfo.extendedClasses.indexOf(BaseClass));
		//*/
		
		/*
		out(Reflection.getClass(testClass));
		out(Reflection.getClass(TypeInfo));
		out(Reflection.getClass("dna.utils.reflection::TypeInfo"));
		out(Reflection.getClass("TypeInfo"));
		out(Reflection.getSuperClass(testClass));
		out(Reflection.getSuperClass(TypeInfo));
		out(Reflection.getSuperClass("dna.utils.reflection::TypeInfo"));
		out(Reflection.getSuperClass("TypeInfo"));
		//*/
		
		/*
		out(Reflection.getUnqualifiedClassName(testClass) + "|");
		out(Reflection.getUnqualifiedClassName(TestClass) + "|");
		out(Reflection.getUnqualifiedClassName("[class TestClass]") + "|");
		out(Reflection.getUnqualifiedClassName("foo::TestClass") + "|");
		out(Reflection.getUnqualifiedClassName("TestClass") + "|");
		//*/
		
		/*
		out(Reflection.isPrimitive(TypeInfo));
		out(Reflection.isPrimitive(int));
		out(Reflection.isPrimitive(uint));
		out(Reflection.isPrimitive(String));
		out(Reflection.isPrimitive(Number));
		//*/
	}
	
	private function stage_keyUp(e:KeyboardEvent):void
	{
		Reflection.getTypeInfo(MovieClip);
	}
	
	private final function out(...params): void
	{
		params.map(output);
		txt.appendText("\n");
		trace.apply(null, params);
	}
	
	private function output(d:Object, ...params):void
	{
		txt.appendText(d + "");
	}
}

}