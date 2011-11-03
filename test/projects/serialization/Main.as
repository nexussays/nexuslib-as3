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
		 * Test deserialization
		 */
		
		obj = XmlSerializer.deserialize(XMLData);
		out(JsonSerializer.serialize(obj, "\t", 30, false));
		xml = XmlSerializer.serialize(obj);
		out(xml.toXMLString());
		
		/**
		 * Test serialization
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
	
	private const XMLData : XML = <type name="foo.bar::TestClass" base="Class" isDynamic="true" isFinal="true" isStatic="true">
  <extendsClass type="Class"/>
  <extendsClass type="Object"/>
  <variable name="staticVar" type="String">
    <metadata name="__go_to_definition_help">
      <arg key="pos" value="482"/>
    </metadata>
  </variable>
  <constant name="staticConst" type="String">
    <metadata name="__go_to_definition_help">
      <arg key="pos" value="426"/>
    </metadata>
  </constant>
  <constant name="foo_namespace" type="*"/>
  <constant name="embed" type="Class">
    <metadata name="__go_to_definition_help">
      <arg key="pos" value="732"/>
    </metadata>
  </constant>
  <accessor name="prototype" access="readonly" type="*" declaredBy="Class"/>
  <accessor name="staticProperty" access="readonly" type="dna::Enum" declaredBy="foo.bar::TestClass">
    <metadata name="__go_to_definition_help">
      <arg key="pos" value="779"/>
    </metadata>
  </accessor>
  <method name="foo" declaredBy="foo.bar::TestClass" returnType="void">
    <metadata name="__go_to_definition_help">
      <arg key="pos" value="2582"/>
    </metadata>
  </method>
  <factory type="foo.bar::TestClass">
    <extendsClass type="foo.bar::BaseClass"/>
    <extendsClass type="Object"/>
    <implementsInterface type="foo::IFoo"/>
    <constructor>
      <parameter index="1" type="Boolean" optional="false"/>
      <parameter index="2" type="String" optional="true"/>
    </constructor>
    <constant name="instanceEmbed" type="Class">
      <metadata name="__go_to_definition_help">
        <arg key="pos" value="1106"/>
      </metadata>
    </constant>
    <constant name="publicConst" type="String">
      <metadata name="__go_to_definition_help">
        <arg key="pos" value="1145"/>
      </metadata>
    </constant>
    <variable name="publicVar" type="int">
      <metadata name="CMSComponentSet">
        <arg key="className" value="datamodel.schemas::CookingComponents"/>
        <arg key="source" value="components"/>
      </metadata>
      <metadata name="__go_to_definition_help">
        <arg key="pos" value="1281"/>
      </metadata>
    </variable>
    <accessor name="publicProperty" access="readwrite" type="int" declaredBy="foo.bar::TestClass">
      <metadata name="__go_to_definition_help">
        <arg key="pos" value="1735"/>
      </metadata>
      <metadata name="blargh">
        <arg key="param" value="value"/>
        <arg key="param2" value="value2"/>
      </metadata>
      <metadata name="__go_to_definition_help">
        <arg key="pos" value="1856"/>
      </metadata>
    </accessor>
    <method name="publicFinalFun" declaredBy="foo.bar::TestClass" returnType="*">
      <parameter index="1" type="foo.bar::TestClass" optional="false"/>
      <metadata name="RandomMetadata">
        <arg key="param" value="value"/>
        <arg key="param2" value="value2"/>
      </metadata>
      <metadata name="__go_to_definition_help">
        <arg key="pos" value="2391"/>
      </metadata>
    </method>
    <method name="publicFun" declaredBy="foo.bar::TestClass" returnType="int">
      <parameter index="1" type="foo.bar::TestClass" optional="false"/>
      <parameter index="2" type="Number" optional="true"/>
      <parameter index="3" type="*" optional="true"/>
      <metadata name="__go_to_definition_help">
        <arg key="pos" value="2468"/>
      </metadata>
    </method>
    <method name="baseMethod" declaredBy="foo.bar::TestClass" returnType="dna.geom::CircleIntersection">
      <parameter index="1" type="*" optional="false"/>
      <parameter index="2" type="Object" optional="false"/>
      <metadata name="__go_to_definition_help">
        <arg key="pos" value="2214"/>
      </metadata>
    </method>
    <method name="namespacedMethod" declaredBy="foo.bar::TestClass" returnType="Object" uri="special_namespace">
      <parameter index="1" type="String" optional="false"/>
      <parameter index="2" type="*" optional="false"/>
      <metadata name="bazbazbaz">
        <arg key="param" value="value"/>
        <arg key="param2" value="value2"/>
      </metadata>
      <metadata name="__go_to_definition_help">
        <arg key="pos" value="1998"/>
      </metadata>
    </method>
    <metadata name="classMetadata">
      <arg key="param" value="value"/>
      <arg key="param2" value="value2"/>
    </metadata>
    <metadata name="__go_to_ctor_definition_help">
      <arg key="pos" value="1535"/>
    </metadata>
    <metadata name="__go_to_definition_help">
      <arg key="pos" value="247"/>
    </metadata>
  </factory>
</type>;
}

}