package mock.foo.bar
{

import flash.utils.*;

public final class FinalClass extends TestClass
{
	//--------------------------------------
	//	CLASS CONSTANTS
	//--------------------------------------
	
	//--------------------------------------
	//	INSTANCE VARIABLES
	//--------------------------------------
	
	//--------------------------------------
	//	CONSTRUCTOR
	//--------------------------------------
	
	public function FinalClass(ctorArgReq:Boolean=true, ctorArgOpt:String=null)
	{
		super(ctorArgReq, ctorArgOpt);
	}
	
	//--------------------------------------
	//	GETTER/SETTERS
	//--------------------------------------
	
	//--------------------------------------
	//	PUBLIC INSTANCE METHODS
	//--------------------------------------
	
	[MethodMetadata(on="FinalClass")]
	override public function baseMethod(arg1:String, arg2:String="", arg3:Array=null):Object
	{
		return super.baseMethod(arg1, arg2, arg3);
	}
	
	//--------------------------------------
	//	PRIVATE & PROTECTED INSTANCE METHODS
	//--------------------------------------
}

}