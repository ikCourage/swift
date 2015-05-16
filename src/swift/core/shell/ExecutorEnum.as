package swift.core.shell
{
	use namespace shell_internal;

	public final class ExecutorEnum
	{
		shell_internal static const DEFAULT:ExecutorEnum = new ExecutorEnum();
		shell_internal static const COMMAND:ExecutorEnum = new ExecutorEnum();
		
		public function ExecutorEnum()
		{
		}
	}
}

internal namespace shell_internal = "1500821a06f913bd7c019689e2f34c6dcb4b3e0bce0b241c206edb0bdbf6462f";