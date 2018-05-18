package nexus.net
{

import nexus.EnumSet;
import flash.utils.*;

import nexus.Enum;

/**
 * An enumeration of the possible states of a Messenger load
 * @since 3/8/2011 11:59 AM
 */
public class LoadState extends Enum
{
	{initEnum(LoadState);}

	/**
	 * The load has been setup but has not started
	 */
	public static const Pending : LoadState = new LoadState();

	/**
	 * The load is in progress
	 */
	public static const Loading : LoadState = new LoadState();

	/**
	 * The load has completed successfully
	 */
	public static const Success : LoadState = new LoadState();

	/**
	 * The load has completed unsuccessfully
	 */
	public static const Failure : LoadState = new LoadState();

	public static function get All():EnumSet
	{
		return Enum.valuesAsEnumSet(LoadState);
	}

	public static function fromString(value:*):LoadState
	{
		var enum : LoadState = Enum.fromString(LoadState, value, false) as LoadState;
		if(enum == null)
		{
			throw new ArgumentError("Cannot convert \"" + value + "\" into a LoadState");
		}
		return enum;
	}
}

}
