package
{
import flash.display.*;
import flash.events.*;
import flash.events.KeyboardEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.Dictionary;
import flash.utils.getTimer;
import nexus.utils.ObjectUtils;
import nexus.utils.serialization.json.*;
import nexus.utils.serialization.xml.XmlSerializer;
//import by.blooddy.crypto.serialization.JSON;

/**
 * ...
 * @author Malachi Griffie
 */
public class Main extends Sprite
{
	static public const COUNT:int = 5;
	
	private var txt:TextField;
	public function Main()
	{
		trace("JSON test string is " + stuff.JSON_TEST.length + " characters long");
		
		//stage.addEventListener(Event.ENTER_FRAME, jsonTest);
		stage.addEventListener(Event.ENTER_FRAME, xmlTest);
		stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUp);
		
		txt = new TextField();
		txt.defaultTextFormat = new TextFormat("Consolas", 12, 0);
		txt.width = stage.stageWidth;
		txt.height = stage.stageHeight;
		this.addChild(txt);
	}
	
	private function xmlTest(e:Event):void
	{
		stage.removeEventListener(Event.ENTER_FRAME, xmlTest);
		
		var start : int;
		var end : int;
		var x : int;
		var xml : XML;
		var foo : TestClass;
		var str : String;
		var obj : Object;
		
		foo = new TestClass();
		//foo["dynamicField"] = "field value";
		//foo["dynamicField2"] = new Dictionary();
		//foo["dynamicField2"]["bar"] = "value";
		//foo["dynamicField2"]["foo"] = 56.74;
		
		/**
		 * Test output
		 */
		
		xml = XmlSerializer.serialize(foo);
		out(xml.toXMLString());
		out(JsonSerializer.serialize(JsonSerializer.deserialize(JsonSerializer.serialize(foo)), "\t", 30, false));
		obj = XmlSerializer.deserialize(XmlSerializer.serialize(foo));
		out(JsonSerializer.serialize(obj, "\t", 30, false));
	}
	
	private function jsonTest(e:Event):void
	{
		stage.removeEventListener(Event.ENTER_FRAME, jsonTest);
		
		var start : int;
		var end : int;
		var x : int;
		var json : String;
		var foo : TestClass;
		var str : String;
		
		foo = new TestClass();
		
		/**
		 * Test typed object conversion
		 */
		
		json = JsonSerializer.serialize(foo, "\t", 20, false);
		var bar : TestClass = ObjectUtils.createTypedObjectFromNativeObject(TestClass, JsonSerializer.deserialize(json)) as TestClass;
		trace(foo.sub.foo, foo.bar, foo.baz);
		trace(bar.sub.foo, bar.bar, foo.baz);
		bar = new TestClass(4);
		bar.baz.push("another value");
		trace(bar.sub.foo, bar.bar, bar.baz);
		ObjectUtils.assignTypedObjectFromNativeObject(bar, JsonSerializer.deserialize(json));
		trace(bar.sub.foo, bar.bar, bar.baz);
		
		/**
		 * Test output
		 */
		
		//*
		json = JsonSerializer.serialize(foo, "\t", 20, false);
		out("mine: ", json);
		json = JsonSerializer.serialize(JsonSerializer.deserialize(json), "", int.MAX_VALUE, true);
		out("mine2:", json);
		
		json = JSON.stringify(foo, null, "\t");
		out("ntiv: ", json);
		json = JSON.stringify(JSON.parse(json));
		out("ntiv2:", json);
		
		json = JSON.stringify(foo);
		out("ntiv: ", json);
		json = JsonSerializer.serialize(JsonSerializer.deserialize(json));
		out("n->m: ", json);
		
		json = JsonSerializer.serialize(foo);
		out("mine: ", json);
		json = JSON.stringify(JSON.parse(json));
		out("m->n: ", json);
		//*/
		
		/**
		 * Test performance
		 */
		
		start = getTimer();
		for(x = 0; x < COUNT; ++x)
		{
			str = JsonSerializer.serialize(stuff.OBJECT_TEST, "\t", 20);
		}
		end = (getTimer() - start);
		out("pretty took " + end + "ms, " + (end / COUNT) + "ms per object on " + str.length + " characters");
		
		start = getTimer();
		for(x = 0; x < COUNT; ++x)
		{
			str = JsonSerializer.serialize(stuff.OBJECT_TEST);
		}
		end = (getTimer() - start);
		out("normal took " + end + "ms, " + (end / COUNT) + "ms per object on " + str.length + " characters");
		
		start = getTimer();
		for(x = 0; x < COUNT; ++x)
		{
			//str = by.blooddy.crypto.serialization.JSON.encode(stuff.OBJECT_TEST);
			str = JSON.stringify(stuff.OBJECT_TEST);
		}
		end = (getTimer() - start);
		out("native took " + end + "ms, " + (end / COUNT) + "ms per object on " + str.length + " characters");
	}
	
	private function stage_keyUp(e:KeyboardEvent):void
	{
		
	}
	
	private final function out(...params): void
	{
		params.map(output);
		txt.appendText("\n");
	}
	
	private function output(d:Object, ...params):void
	{
		txt.appendText(d + "");
	}
}

}