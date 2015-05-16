package swift.core.shell
{
	import flash.utils.Dictionary;
	
	import org.aisy.interfaces.IClear;
	
	use namespace shell_internal;

	public class Shell implements IClear
	{
		shell_internal var _shellData:ShellData;
		
		public function Shell()
		{
			_shellData = new ShellData();
		}
		
		public function get name():String
		{
			return _shellData._name;
		}
		
		public function set name(value:String):void
		{
			_shellData._name = value;
			value = null;
		}
		
		public function get command():String
		{
			return _shellData._command;
		}
		
		public function set command(value:String):void
		{
			_shellData._command = value;
			value = null;
		}
		
		/**
		 * 
		 * 返回 参数类型选项
		 * 
		 * @return 
		 * 
		 */
		public function get option():Array
		{
			return _shellData._option;
		}
		
		/**
		 * 
		 * 设置 参数类型选项
		 * 
		 * @param value
		 * 
		 */
		public function set option(value:Array):void
		{
			if (null !== value) {
				var j:int, k:int, obj:*, opt0:Vector.<String> = new Vector.<String>(), opt1:Vector.<int> = new Vector.<int>();
				for (var i:int = 0, l:int = value.length; i < l; i++) {
					obj = value[i];
					if (obj is String) {
						if (j > k) opt1[k++] = 0;
						opt0[j++] = obj;
					}
					else if (j > k && obj is int) opt1[k++] = obj;
				}
				opt1.length = j;
				value = [opt0, opt1];
				opt0 = null;
				opt1 = null;
				obj = null;
			}
			_shellData._option = value;
			value = null;
		}
		
		public function get callback():Function
		{
			return _shellData._callback;
		}
		
		public function set callback(value:Function):void
		{
			_shellData._callback = value;
			value = null;
		}
		
		public function get description():*
		{
			if (null !== _shellData._properties) return _shellData._properties["description"];
			return null;
		}
		
		public function set description(value:*):void
		{
			if (null === _shellData._properties) _shellData._properties = {};
			_shellData._properties["description"] = value;
			value = null;
		}
		
		/**
		 * 
		 * 返回 父级 Shell
		 * 
		 * @return 
		 * 
		 */
		public function get parent():Shell
		{
			return _shellData._parent;
		}
		
		/**
		 * 
		 * 返回 ShellController
		 * 
		 * @return 
		 * 
		 */
		public function get shellController():ShellController
		{
			return null !== _shellData._shellController ? _shellData._shellController : _shellData._shellController = (null === _shellData._parent ? null : _shellData._parent.shellController);
		}
		
		public function getShellByName(value:String):Shell
		{
			return null === _shellData._shells ? null : _shellData._shells[value] as Shell;
		}
		
		public function getShellByCommand(value:String, transparent:Boolean = false):Shell
		{
			var shell:Shell = null === _shellData._commands ? null : _shellData._commands[value] as Shell;
			if (null === shell && transparent === true && null !== parent) shell = parent.getShellByCommand(value, true);
			value = null;
			return shell;
		}
		
		public function addShell(value:Shell):void
		{
			if (null === value.name) throw new Error("no name: " + value);
			if (null === _shellData._shells) _shellData._shells = new Dictionary();
			if (_shellData._shells.hasOwnProperty(value.name) === true) throw new Error("same name: " + value.name);
			if (null !== value.command) {
				if (null === value.callback) throw new Error("no callback: " + value.command);
				if (null === _shellData._commands) _shellData._commands = new Dictionary();
				if (_shellData._commands.hasOwnProperty(value.command) === true) throw new Error("same command: " + value.command);
				_shellData._commands[value.command] = value;
			}
			value._shellData._parent = this;
			value._shellData._shellController = _shellData._shellController;
			_shellData._shells[value.name] = value;
			value = null;
		}
		
		shell_internal function removeShellByName(value:String):void
		{
			if (null === _shellData._shells) return;
			else if (_shellData._shells.hasOwnProperty(value) === false) return;
			var shell:Shell = getShellByName(value);
			shell._shellData._parent = null;
			shell._shellData._shellController = null;
			if (null !== shell.command) if (null !== _shellData._commands) delete _shellData._commands[shell.command];
			delete _shellData._shells[value];
			shell.clear();
			shell = null;
			value = null;
		}
		
		shell_internal function removeShellByCommand(value:String):void
		{
			if (null === _shellData._commands) return;
			else if (_shellData._commands.hasOwnProperty(value) === false) return;
			var shell:Shell = getShellByCommand(value);
			shell._shellData._parent = null;
			shell._shellData._shellController = null;
			if (null !== shell.command) delete _shellData._commands[shell.command];
			if (null !== _shellData._shells) delete _shellData._shells[value];
			shell.clear();
			shell = null;
			value = null;
		}
		
		public function clear():void
		{
			if (null !== _shellData) {
				_shellData.clear();
				_shellData = null;
			}
		}
		
	}
}

internal namespace shell_internal = "1500821a06f913bd7c019689e2f34c6dcb4b3e0bce0b241c206edb0bdbf6462f";