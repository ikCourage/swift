package swift.core.shell.sbin
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.utils.getQualifiedClassName;
	
	import org.ais.system.Ais;
	
	import swift.core.shell.Shell;
	
	use namespace shell_internal;

	public class Shell_stree extends Shell
	{
		public function Shell_stree()
		{
			name = command = "stree";
			callback = __exec;
			description = "从舞台开始打印树形结构 （可以用空格隔开参数从而复合输出）\n" +
				"1 以名字输出\n" +
				"2 以类名输出\n" +
				"3 以元件 name 输出";
		}
		
		protected function __exec(str:String):Object
		{
			return "\n" + __tree(Ais.IMain.stage, "     ", Vector.<int>(str.split(" ")));
		}
		
		protected function __tree(c:DisplayObjectContainer, sep:String, format:Vector.<int>):String
		{
			var str:String = "+ " + getName(c, format), o:DisplayObject;
			for (var i:int = 0, l:int = c.numChildren; i < l; i++) {
				o = c.getChildAt(i);
				if (o is DisplayObjectContainer) {
					str += "\n" + sep + __tree(o as DisplayObjectContainer, sep + "    ", format);
				}
				else {
					str += "\n" + sep + getName(o, format);
				}
			}
			o = null;
			c = null;
			sep = null;
			return str;
		}
		
		protected function getName(o:DisplayObject, format:Vector.<int>):String
		{
			var n:String, str:String = "";
			for (var i:int = 0, l:int = format.length; i < l; i++) {
				switch (format[i]) {
					case 0:
						n = String(o);
						break;
					case 1:
						n = String(o).replace(/^\[object\s|\]$/g, "");
						break;
					case 2:
						n = getQualifiedClassName(o);
						break;
					case 3:
						n = o.name;
						if (null == n) n = "Stage";
						break;
				}
				str += n;
				if (i < l - 1) str += "  ";
			}
			if (!str) str = String(o);
			n = null;
			o = null;
			format = null;
			return str;
		}
		
	}
}

internal namespace shell_internal = "1500821a06f913bd7c019689e2f34c6dcb4b3e0bce0b241c206edb0bdbf6462f";