package swift.core.shell
{
	import org.aisy.interfaces.IClear;
	
	use namespace shell_internal;

	public class Executor implements IClear
	{
		shell_internal var _source:Object;
		shell_internal var _message:Vector.<Array>;
		
		public function Executor()
		{
		}
		
		public function get source():Object
		{
			return _source;
		}
		
		public function addMessage(...parameters):void
		{
			var len:int;
			if (null === _message) _message = new Vector.<Array>();
			else len = _message.length;
			_message[len] = parameters;
			parameters = null;
		}
		
		public function clear():void
		{
			_source = null;
			_message = null;
		}

	}
}

internal namespace shell_internal = "1500821a06f913bd7c019689e2f34c6dcb4b3e0bce0b241c206edb0bdbf6462f";