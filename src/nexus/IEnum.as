package nexus
{

/**
 * ...
 */
public interface IEnum
{
	/**
	 * Returns true if the passed value is an exact match to this value
	 * @param	value	An object of type Enum, EnumSet, an Array of Enums, or a Vector of Enums
	 * @return	True if the values ae an exact match
	 */
	function equals(value:Object):Boolean;
	
	/**
	 * Returns true if there are any matches between this value and the provided argument
	 * @param	value	An object of type Enum, EnumSet, an Array of Enums, or a Vector of Enums
	 * @return	True if any values match
	 */
	function intersects(value:Object):Boolean;
}

}