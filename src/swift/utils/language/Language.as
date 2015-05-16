package swift.utils.language
{
	import flash.text.TextField;
	
	import org.aisy.textview.TextView;
	
	import swift.core.swift_internal;
	import swift.utils.base.StringUtil;
	
	use namespace swift_internal;

	public class Language
	{
		static swift_internal var lan:Object;
		
		public function Language()
		{
		}
		
		static public function getValue(key:String, vars:Object = null, r:RegExp = null):*
		{
			var obj:*;
			if (key.indexOf('.') == -1) {
				if (lan.hasOwnProperty(key)) {
					obj = lan[key];
					if (null == vars) {
						return obj;
					}
					return obj is String ? StringUtil.formatString(obj as String, vars, r) : obj;
				}
			}
			else {
				var arr:Array = key.split('.');
				key = arr[0];
				if (lan.hasOwnProperty(key)) {
					obj = lan[key];
					for (var i:int = 1, l:int = arr.length; i < l; i++) {
						key = arr[i];
						if (obj.hasOwnProperty(key)) {
							obj = obj[key];
						}
						else {
							return null;
						}
					}
					if (null == vars) {
						return obj;
					}
					return obj is String ? StringUtil.formatString(obj as String, vars, r) : obj;
				}
			}
			return null;
		}
		
		static public function setText(textField:Object, value:String):void
		{
			if (textField is TextField) {
				(textField as TextField).htmlText = value;
			}
			else if (textField is TextView) {
				(textField as TextView).setText(value);
			}
			textField = null;
			value = null;
		}
		
		static public function setText2(textField:Object, key:String, vars:Object = null, r:RegExp = null):void
		{
			if (textField is TextField || textField is TextView) {
				setText(textField, getValue(key, vars, r));
			}
			textField = null;
			key = null;
			vars = null;
			r = null;
		}
	}
}