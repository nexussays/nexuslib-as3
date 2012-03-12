/* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is nexuslib.
 *
 * The Initial Developer of the Original Code is
 * Malachi Griffie <malachi@nexussays.com>.
 * Portions created by the Initial Developer are Copyright (C) 2011
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** */
package
{

import asunit.core.TextCore;
import flash.display.Sprite;
import flash.system.Capabilities;
import flash.text.TextFormat;

/**
 * ...
 * @author	Malachi Griffie <malachi&#64;nexussays.com>
 * @since	1/14/2012 11:38 PM
 */
[SWF(width="800", height="600", backgroundColor="#333333", frameRate="30")]
public class ReflectionTestRunner extends Sprite
{
	private var core:TextCore;
	
	public function ReflectionTestRunner()
	{
		core = new TextCore();
		core.textPrinter.fontFamily = "Consolas";
		core.textPrinter.fontSize = 12;
		core.textPrinter.header = "nexuslib.reflection\nFlash Player version: " + Capabilities.version;
		core.textPrinter.hideLocalPaths = true;
		core.textPrinter.traceOnComplete = false;
		core.start(ReflectionTests, null, this);
		
		//this.setPrinter(new ResultPrinter(false, 0x333333, new TextFormat("Consolas", 12, 0xffffff)));
		
		// NOTE: sending a particular class and method name will
		// execute setUp(), the method and NOT tearDown.
		// This allows you to get visual confirmation while developing
		// visual entities
		// start(AllTests, null, TestRunner.SHOW_TRACE);
		
		//start(ReflectionTests);
	}
}

}