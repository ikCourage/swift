package swift.core.magic
{
	import flash.utils.Dictionary;
	
	use namespace magic_internal;

	internal class MagicFunctionData extends MagicBlockData
	{
		magic_internal var cmds:Vector.<Array>;
		magic_internal var indexV:Vector.<uint>;
		magic_internal var parameters:Vector.<String>;
		magic_internal var fun:Dictionary;
		
		public function MagicFunctionData()
		{
		}
		
		override public function clear():void
		{
			super.clear();
			if (null !== fun) {
				for each (var i:MagicFunctionData in fun) {
					i.clear();
				}
				fun = null;
			}
			cmds = null;
			indexV = null;
			parameters = null;
		}
		
	}
}

internal namespace magic_internal = "213384665b731cdf2fe17d13266786f65ceee0e1ab799e0ee704860761556606";