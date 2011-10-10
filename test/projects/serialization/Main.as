package
{
import flash.display.MovieClip;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import nexus.utils.reflection.Reflection;
import nexus.utils.serialization.json.JsonSerializer;

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
		
		trace(JsonSerializer.serialize(new Shape()));
	}
	
	private function stage_keyUp(e:KeyboardEvent):void
	{
		
	}
}

}