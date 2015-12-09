package swift.core.magic
{
	use namespace magic_internal;

	internal class MagicEnum
	{
		
		static magic_internal const TYPE_ELSE:uint = 3;
		static magic_internal const TYPE_FUNCTION:uint = 4;
		static magic_internal const TYPE_BLOCK_START:uint = 5;
		static magic_internal const TYPE_IF:uint = 6;
		static magic_internal const TYPE_SWITCH:uint = 7;
		static magic_internal const TYPE_WHILE:uint = 8;
		static magic_internal const TYPE_TRY:uint = 9;
		
		static magic_internal const TYPE_ENUM:Object = {"if": TYPE_IF, "switch": TYPE_SWITCH, "while": TYPE_WHILE, "try": TYPE_TRY}
		
		public function MagicEnum()
		{
		}
	}
}

internal namespace magic_internal = "213384665b731cdf2fe17d13266786f65ceee0e1ab799e0ee704860761556606";