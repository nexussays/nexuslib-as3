package
{
import flash.display.*;
import flash.events.*;
import flash.events.KeyboardEvent;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.getTimer;
import nexus.utils.ObjectUtils;
import nexus.utils.serialization.json.*;
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
		trace(stuff.JSON_TEST.length);
		
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