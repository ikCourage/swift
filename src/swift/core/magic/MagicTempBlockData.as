package swift.core.magic
{
	import org.aisy.interfaces.IClear;
	
	use namespace magic_internal;

	internal class MagicTempBlockData implements IClear
	{
		magic_internal var blockIndex:uint;
		magic_internal var nextIndex:uint;
		
		magic_internal var flag:Boolean;
		
		public function MagicTempBlockData()
		{
		}
		
		public function clear():void
		{
			blockIndex = 0;
			nextIndex = 0;
			flag = false;
		}
		
	}
}

internal namespace magic_internal = "213384665b731cdf2fe17d13266786f65ceee0e1ab799e0ee704860761556606";