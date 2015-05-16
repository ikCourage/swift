package swift.core.shell
{
	import org.aisy.interfaces.IClear;

	public class ShellObject implements IClear
	{
		public var type:int;
		public var obj:*;
		
		public function ShellObject()
		{
		}
		
		public function clear():void
		{
			obj = null;
		}
		
		static public function newObj(obj:* = null, type:int = 0):ShellObject
		{
			var o:ShellObject = new ShellObject();
			o.obj = obj;
			o.type = type;
			obj = null;
			return o;
		}
		
	}
}