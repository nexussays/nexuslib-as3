package
{
import flash.display.*;
import flash.events.*;
import flash.events.KeyboardEvent;
import nexus.utils.serialization.json.*;

/**
 * ...
 * @author Malachi Griffie
 */
public class Main extends Sprite
{
	public function Main()
	{
		stage.addEventListener(Event.ENTER_FRAME, frame1);
	}
	
	private function frame1(e:Event):void
	{
		stage.removeEventListener(Event.ENTER_FRAME, frame1);
		
		stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUp);
		
		var start : int;
		
		var json : String;
		var foo : Object;
		
		foo = new TestClass();
		
		json = JsonSerializer.serialize(foo);
		trace("mine: ", json);
		json = JsonSerializer.serialize(JsonSerializer.deserialize(json));
		trace("mine2:", json);
		
		json = JSON.stringify(foo);
		trace("ntiv: ", json);
		json = JSON.stringify(JSON.parse(json));
		trace("ntiv2:", json);
		
		json = JSON.stringify(foo);
		trace("ntiv: ", json);
		json = JsonSerializer.serialize(JsonSerializer.deserialize(json));
		trace("n->m: ", json);
		
		json = JsonSerializer.serialize(foo);
		trace("mine: ", json);
		json = JSON.stringify(JSON.parse(json));
		trace("m->n: ", json);
	}
	
	private function stage_keyUp(e:KeyboardEvent):void
	{
		
	}
}

}