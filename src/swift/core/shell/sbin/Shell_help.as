package swift.core.shell.sbin
{
	import swift.core.shell.Shell;
	
	use namespace shell_internal;

	public class Shell_help extends Shell
	{
		public function Shell_help()
		{
			name = command = "help";
			option = ["a", "i"];
			callback = __exec;
			description = "帮助\n" +
				"a 显示当前目录到根目录的所有命令\n" +
				"i 显示详细信息 描述";
		}
		
		protected function __exec(str:String, args:Vector.<Array>):Object
		{
			var i:int, j:int, k:int, l_0:int, l_1:int, l_2:int, arr:Array = [], arr2:Array, shell:Shell = shellController.currentShell, opt0:Vector.<String>, opt1:Vector.<int>;
			var desc:Boolean;
			for (i = 0, l_1 = args[1].length; i < l_1; i++) {
				switch (args[1][i][0]) {
					case "a":
						while (null !== shell) {
							arr[l_0++] = __getHelp(shell);
							shell = shell.parent;
						}
						break;
					case "i":
						desc = true;
						break;
				}
			}
			if (l_0 == 0) {
				arr2 = [];
				for (i = 0, l_1 = args[0].length; i < l_1; i++) {
					if (null != shell.getShellByCommand(args[0][i])) {
						arr2[l_0++] = shell.getShellByCommand(args[0][i]);
					}
				}
				if (l_0 != 0) {
					arr2.reverse();
					arr2[l_0] = shell;
					arr2.reverse();
					arr[0] = arr2;
					l_0 = 1;
				}
				else {
					arr[l_0++] = __getHelp(shell);
				}
			}
			str = "commands:";
			for (i = 0; i < l_0; i++) {
				arr2 = arr[i];
				if (null !== arr2) {
					if (i !== 0) {
						str += "\n**          " + __getPath(arr2[0]);
					}
					for (j = 1, l_1 = arr2.length; j < l_1; j++) {
						shell = arr2[j];
						if (desc == true && null != shell.description) {
							str += "\n\n" + shell.description;
						}
						str += "\n//          " + shell.command;
						l_2 = shell._shellData._shellsLength;
						if (l_2 !== 0) {
							str += " / " + l_2;
						}
						if (null !== shell.option) {
							opt0 = shell.option[0] as Vector.<String>;
							opt1 = shell.option[1] as Vector.<int>;
							l_2 = opt0.length;
							if (l_2 !== 0) {
								str += " ";
								for (k = 0; k < l_2; k++) {
									str += " [" + opt0[k] + " " + opt1[k] + "]";
								}
							}
							opt0 = null;
							opt1 = null;
						}
					}
				}
			}
			arr = null;
			arr2 = null;
			shell = null;
			return str;
		}
		
		protected function __getHelp(shell:Shell):Array
		{
			var i:int, arr:Array, tempShell:Shell;
			for each (tempShell in shell._shellData._commands) {
				if (i === 0) arr = [];
				arr[i++] = tempShell;
			}
			if (i !== 0) {
				arr.sortOn("command");
				arr.reverse();
				arr[i] = shell;
				arr.reverse();
			}
			tempShell = null;
			shell = null;
			return arr;
		}
		
		protected function __getPath(shell:Shell = null):String
		{
			if (null === shell) shell = shellController.currentShell;
			var p:String = shell.name;
			while (shell = shell.parent) p = shell.name + "/" + p;
			shell = null;
			return p;
		}
		
	}
}

internal namespace shell_internal = "1500821a06f913bd7c019689e2f34c6dcb4b3e0bce0b241c206edb0bdbf6462f";