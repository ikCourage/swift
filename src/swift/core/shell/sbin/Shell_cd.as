package swift.core.shell.sbin
{
	import swift.core.shell.Shell;
	
	use namespace shell_internal;

	public class Shell_cd extends Shell
	{
		public function Shell_cd()
		{
			name = command = "cd";
			callback = __exec;
		}
		
		protected function __exec(str:String):Object
		{
			var path:String = str.replace(/^\s+|\s+$/g, "");
			if (!path) {
				path = null;
				str = null;
				return null;
			}
			path = path.replace(/[\"\']/g, "");
			if (!path) {
				path = null;
				str = null;
				return null;
			}
			path = path.replace(/^[\\\/]+|[\\\/]+$/g, "");
			if (!path) {
				path = null;
				str = null;
				return null;
			}
			path = path.replace(/[\\\/]+/g, "/");
			var pathArr:Array = path.split("/");
			var i:int, len:int = pathArr.length, p:String, tmpShell:Shell, currentShell:Shell = shellController.currentShell;
			for (i = 0; i < len; i++) {
				p = pathArr[i];
				if (p === "~") {
					currentShell = shellController.rootShell;
				}
				else if (p === "..") {
					if (null !== currentShell.parent) {
						currentShell = currentShell.parent;
					}
				}
				else {
					tmpShell = currentShell.getShellByName(p);
					if (null === tmpShell) return new Error("no path: " + path);
					else {
						currentShell = tmpShell;
					}
				}
			}
			shellController.currentShell = currentShell;
			shellController._shellControllerData._lastShell = currentShell;
			path = null;
			pathArr = null;
			p = null;
			tmpShell = null;
			currentShell = null;
			str = null;
			return null;
		}
		
	}
}

internal namespace shell_internal = "1500821a06f913bd7c019689e2f34c6dcb4b3e0bce0b241c206edb0bdbf6462f";