package mock.foo
{

import flash.utils.*;

public final class SubObject
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	private var m_timing : Date;
	private var m_array : Array;
	private var m_timeVec : Vector.<String>;
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function SubObject()
	{
		
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	public function get array():Array { return m_array; }
	
	public function get date():Date { return m_timing; }
	public function set date(value:Date):void
	{
		m_timing = value;
	}
	
	public function get vector():Vector.<String> { return m_timeVec; }
	public function set vector(value:Vector.<String>):void
	{
		m_timeVec = value;
	}
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
}

}