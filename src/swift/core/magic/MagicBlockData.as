package swift.core.magic
{
	import org.aisy.interfaces.IClear;
	
	use namespace magic_internal;

	internal class MagicBlockData implements IClear
	{
		magic_internal var type:uint;
		magic_internal var start:uint;
		magic_internal var end:uint;
		magic_internal var blockV:Vector.<MagicBlockData>;
		magic_internal var next:Vector.<MagicBlockData>;
		magic_internal var parent:MagicBlockData;
		
		magic_internal var blockIndex:uint;
		magic_internal var nextIndex:uint;
		
		magic_internal var flag:Boolean;
		
		public function MagicBlockData()
		{
		}
		
		public function clear():void
		{
			if (null !== blockV) {
				for (var i:uint = 0, l:uint = blockV.length; i < l; i++) {
					blockV[i].clear();
				}
				blockV = null;
			}
			if (null !== next) {
				for (i = 0, l = next.length; i < l; i++) {
					next[i].clear();
				}
				next = null;
			}
			parent = null;
		}
		
	}
}

internal namespace magic_internal = "213384665b731cdf2fe17d13266786f65ceee0e1ab799e0ee704860761556606";