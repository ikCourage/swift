package swift.core.shell
{
	import org.aisy.interfaces.IClear;
	
	use namespace shell_internal;

	internal class ShellControllerData implements IClear
	{
		shell_internal var _rootShell:Shell;
		shell_internal var _currentShell:Shell;
		shell_internal var _lastShell:Shell;
		
		shell_internal var _executors:Vector.<Executor>;
		shell_internal var _messageLength:int;
		shell_internal var _messageLengthMax:int;
		
		shell_internal var _executorF:Function;
		shell_internal var _messageF:Function;
		
		shell_internal var _executorType:int;
		shell_internal var _messageType:int;
		
		shell_internal var _type:int = ShellControllerEnum.TYPE_DEFAULT;
		shell_internal var _tag:int = ShellControllerEnum.TAG_DEFAULT;
		
		public function ShellControllerData()
		{
			_messageLengthMax = 10000;
			_executorType = ShellControllerEnum.EXECUTOR_DEFAULT;
			_messageType = ShellControllerEnum.MESSAGE_DEFAULT;
			_messageF = __messageF;
		}
		
		protected function __messageF():void
		{
			if (_messageLength >= _messageLengthMax) {
				_messageLength = 0;
				_executors = null;
			}
		}
		
		public function clear():void
		{
			if (null !== _executors) {
				var i:int, len:int = _executors.length;
				for (i = 0; i < len; i++) {
					_executors[i].clear();
				}
				_executors = null;
			}
			if (null !== _currentShell) _currentShell.clear();
			if (null !== _rootShell) _rootShell.clear();
			if (null !== _lastShell) _lastShell.clear();
			_rootShell = null;
			_currentShell = null;
			_lastShell = null;
			_executorF = null;
			_messageF = null;
			_messageLength = 0;
			_executorType = ShellControllerEnum.EXECUTOR_DEFAULT;
			_messageType = ShellControllerEnum.MESSAGE_DEFAULT;
		}
		
	}
}

internal namespace shell_internal = "1500821a06f913bd7c019689e2f34c6dcb4b3e0bce0b241c206edb0bdbf6462f";