// Copyright 2011 Malachi Griffie <malachi@nexussays.com>
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
package
{

import asunit.core.TextCore;
import flash.display.Sprite;
import flash.system.Capabilities;

[SWF(width="800",height="600",backgroundColor="#333333",frameRate="30")]
public class NexuslibTestRunner extends Sprite
{
	private var core:TextCore;
	
	public function NexuslibTestRunner()
	{
		//Use to trigger the FPL warning
		/*
		var stage3D:Stage3D = stage.stage3Ds[0];
		stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, function(e:Event):void
			{
				trace(stage.stage3Ds[0].context3D);
			});
		stage.stage3Ds[0].requestContext3D();
		//*/
		
		core = new TextCore();
		core.textPrinter.fontFamily = "Consolas";
		core.textPrinter.fontSize = 12;
		core.textPrinter.header = "nexuslib\nFlash Player version: " + Capabilities.version;
		core.textPrinter.hideLocalPaths = true;
		core.textPrinter.traceOnComplete = false;
		core.start(MainTestSuite, null, this);
		
		//this.setPrinter(new ResultPrinter(false, 0x333333, new TextFormat("Consolas", 12, 0xffffff)));
		// NOTE: sending a particular class and method name will
		// execute setUp(), the method and NOT tearDown.
		// This allows you to get visual confirmation while developing
		// visual entities
		// start(AllTests, null, TestRunner.SHOW_TRACE);
		
		//start(MainTestSuite);
	}
}

}