package swift.core.shell.sbin
{
	import swift.core.shell.Shell;
	
	use namespace shell_internal;

	public class Shell_print extends Shell
	{
		public function Shell_print()
		{
			name = command = "print";
			callback = __exec;
		}
		
		protected function __exec(str:String):Object
		{
			trace(str);
			str = null;
			return null;
		}
		
	}
}

internal namespace shell_internal = "1500821a06f913bd7c019689e2f34c6dcb4b3e0bce0b241c206edb0bdbf6462f";