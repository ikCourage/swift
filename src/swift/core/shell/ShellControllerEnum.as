package swift.core.shell
{
	use namespace shell_internal;

	public final class ShellControllerEnum
	{
		shell_internal static const EXECUTOR_DEFAULT:int = EXECUTOR_ADD;
		shell_internal static const EXECUTOR_ADD:int = 0;
		shell_internal static const EXECUTOR_NO:int = 1;
		
		shell_internal static const MESSAGE_DEFAULT:int = MESSAGE_ADD;
		shell_internal static const MESSAGE_ADD:int = 0;
		shell_internal static const MESSAGE_NO:int = 1;
		
		static public const TYPE_DEFAULT:int = 0;
		static public const TYPE_INPUT:int = 1;
		static public const TYPE_RETURN:int = 2;
		static public const TYPE_TIP:int = 3;
		static public const TYPE_TIP2:int = 4;
		
		static public var TAG_DEFAULT:int = 0;
		
		public function ShellControllerEnum()
		{
		}
	}
}

internal namespace shell_internal = "1500821a06f913bd7c019689e2f34c6dcb4b3e0bce0b241c206edb0bdbf6462f";