package swift.utils.base
{
	public class StringUtil
	{
		public function StringUtil()
		{
		}
		
		static public function toUnicodeStr(str:String):String
		{
			var uStr:String = "";
			for (var i:uint = 0, l:uint = str.length; i < l; i++) {
				uStr += "&#" + str.charCodeAt(i) + ";";
			}
			str = null;
			return uStr;
		}
		
		static public function formatString(str:String, vars:Object, r:RegExp = null):String
		{
			if (null === r) r = /\$\{([^\{\}]+)\}/g;
			str = str.replace(r, function ():String
			{
				if (vars.hasOwnProperty(arguments[1]) === true) return vars[arguments[1]];
				return arguments[0];
			});
			vars = null;
			r = null;
			return str;
		}
		
	}
}