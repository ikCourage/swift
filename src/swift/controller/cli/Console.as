package swift.controller.cli
{
	import swift.core.shell.Shell;

	public class Console
	{
		static public var shellController:Object;
		
		public function Console()
		{
		}
		
		static public function show():Boolean
		{
			return shellController.show();
		}
		
		static public function exec(...parameters):Object
		{
			return shellController.exec.apply(null, parameters);
		}
		
		static public function print(...parameters):Object
		{
			return shellController.print.apply(null, parameters);
		}
		
		static public function parseShell(str:String, shellObjectArr:Array = null, shell:Shell = null, transparent:Boolean = true):Object
		{
			return shellController.parseShell(str, shellObjectArr, shell, transparent);
		}
		
		static public function doShell(shell:Shell, ...parameters):Object
		{
			return shellController.doShell.apply(null, [shell].concat(parameters));
		}
		
		static public function addMessage(...parameters):void
		{
			shellController.addMessage.apply(null, parameters);
			parameters = null;
		}
		
		static public function get rootShell():Shell
		{
			return shellController.rootShell;
		}
		
		static public function set rootShell(value:Shell):void
		{
			shellController.rootShell = value;
			value = null;
		}
		
		static public function get currentShell():Shell
		{
			return shellController.currentShell;
		}
		
		static public function set currentShell(value:Shell):void
		{
			shellController.currentShell = value;
			value = null;
		}
		
		static public function set executor(value:Object):void
		{
			shellController.executor = value;
			value = null;
		}
		
		static public function clear():void
		{
			if (null !== shellController) {
				shellController.clear();
				shellController = null;
			}
		}
		
	}
}