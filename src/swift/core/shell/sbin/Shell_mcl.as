package swift.core.shell.sbin
{
	import org.ais.system.Memory;
	
	import swift.core.shell.Shell;

	public class Shell_mcl extends Shell
	{
		public function Shell_mcl()
		{
			name = command = "mcl";
			callback = __exec;
			description = "清空内存\n" +
				"0 智能清空内存\n" +
				"1 立即清空内存，但不更新清空条件\n" +
				"2 立即清空内存，同时更新清空条件";
		}
		
		protected function __exec(str:String):Object
		{
			Memory.clear(parseInt(str));
			str = null;
			return null;
		}
		
	}
}