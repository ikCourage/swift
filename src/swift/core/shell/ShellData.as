package swift.core.shell
{
	import flash.utils.Dictionary;
	
	import org.aisy.interfaces.IClear;
	
	use namespace shell_internal;

	internal class ShellData implements IClear
	{
		shell_internal var _name:String;
		shell_internal var _command:String;
		shell_internal var _option:Array;
		shell_internal var _callback:Function;
		
		shell_internal var _properties:Object;
		
		shell_internal var _shells:Dictionary;
		shell_internal var _shellsLength:uint;
		shell_internal var _commands:Dictionary;
		shell_internal var _commandsLength:uint;
		
		shell_internal var _parent:Shell;
		shell_internal var _shellController:ShellController;
		
		public function ShellData()
		{
		}
		
		public function clear():void
		{
			for each (var i:Shell in _shells) {
				i.clear();
			}
			_shellsLength = 0;
			_commandsLength = 0;
			_name = null;
			_command = null;
			_option = null;
			_callback = null;
			_properties = null;
			_shells = null;
			_commands = null;
			_parent = null;
			_shellController = null;
		}
		
	}
}

internal namespace shell_internal = "1500821a06f913bd7c019689e2f34c6dcb4b3e0bce0b241c206edb0bdbf6462f";