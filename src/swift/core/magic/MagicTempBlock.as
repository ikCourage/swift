package swift.core.magic
{
	import flash.utils.Dictionary;
	
	import org.aisy.interfaces.IClear;
	
	use namespace magic_internal;

	internal class MagicTempBlock implements IClear
	{
		magic_internal var blocks:Dictionary;
		
		public function MagicTempBlock()
		{
			blocks = new Dictionary();
		}
		
		magic_internal function getBlockData(key:MagicBlockData):MagicTempBlockData
		{
			var tbd:MagicTempBlockData = blocks[key];
			return null !== tbd ? tbd : blocks[key] = new MagicTempBlockData();
		}
		
		public function clear():void
		{
			blocks = null;
		}
		
	}
}

internal namespace magic_internal = "213384665b731cdf2fe17d13266786f65ceee0e1ab799e0ee704860761556606";