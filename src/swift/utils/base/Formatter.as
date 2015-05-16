package swift.utils.base
{
	public class Formatter
	{
		
		/**
		 * DateFormat 格式化Date
		 *
		 * @param o       要格式化的Date对象实例
		 * @param format  格式化模板.支持"YYYY YY MMMM MMM MM M DD D EEEE EEE EE E A L HH:NN:SS:RRR".可选.默认值:"YYYY-MM-DD HH:NN:SS".
		 */
		public static function DateFormat(o:Date, format:String = "YYYY-MM-DD HH:NN:SS", UTC:Boolean = false):String
		{
			var utc:String = UTC === true ? "UTC" : "";
			var months:Array = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
			var weeks:Array = ["Sunday", "Monday", "TuesDay", "Wednesday", "Thursday", "Friday", "Saturday"];
			var _y:String = o["fullYear" + utc].toString();
			var _m:Number = o["month" + utc];
			var _mb:String = _m < 9 ? "0" + (_m + 1) : (_m + 1).toString();
			var _e:Number = o["day" + utc];
			var _eb:String = "0" + (_e + 1);
			var _d:Number = o["date" + utc];
			var _db:String = _d < 10 ? "0" + _d : _d.toString();
			var _h:Number = o["hours" + utc];
			var _hb:String = _h < 10 ? "0" + _h : _h.toString();
			var _n:Number = o["minutes" + utc];
			var _nb:String = _n < 10 ? "0" + _n : _n.toString();
			var _s:Number = o["seconds" + utc];
			var _sb:String = _s < 10 ? "0" + _s : _s.toString();
			var _r:Number = o["milliseconds" + utc];
			var _rb:String = "";
			var _rl:uint = 3 - _r.toString().length;
			while (_rl > 0) {
				_rl--;
				_rb += "0";
			}
			_rb += _r;
			var reStr:String = format;
			reStr = reStr.replace(/YYYY/g, _y);
			reStr = reStr.replace(/YY/g, _y.slice(-2));
			reStr = reStr.replace(/MMMM/g, months[_m]);
			reStr = reStr.replace(/MMM/g, months[_m].substr(0, 3));
			reStr = reStr.replace(/MM/g, _mb);
			reStr = reStr.replace(/M/g, _m + 1);
			reStr = reStr.replace(/DD/g, _db);
			reStr = reStr.replace(/D/g, _d);
			reStr = reStr.replace(/A/g, _h < 12 ? "AM" : "PM");
			reStr = reStr.replace(/HH/g, _hb);
			reStr = reStr.replace(/H/g, _h);
			reStr = reStr.replace(/L/g, _h % 12);
			reStr = reStr.replace(/NN/g, _nb);
			reStr = reStr.replace(/N/g, _n);
			reStr = reStr.replace(/SS/g, _sb);
			reStr = reStr.replace(/S/g, _s);
			reStr = reStr.replace(/RRR/g, _rb);
			reStr = reStr.replace(/R/g, _r);
			reStr = reStr.replace(/EEEE/g, weeks[_e]);
			reStr = reStr.replace(/EEE/g, weeks[_e].substr(0, 3));
			reStr = reStr.replace(/EE/g, _eb);
			reStr = reStr.replace(/E/g, (_e + 1));
			return reStr;
		}
		
		/**
		 * 格式化秒数.适合格式化播放器时间等
		 *
		 * @param t       要格式化的秒数
		 * @param format  格式化模板.支持"DD D HH H NN N SS S".可选.默认值:"HH:NN:SS".
		 */
		public static function TimeFormat(t:Number, format:String = "HH:NN:SS", mathF:Function = null):String
		{
			if (null === mathF) mathF = Math.floor;
			t = t < 0 ? 0 : t;
			var _d:int = mathF(t / 3600 / 24);
			var _h:int = mathF(t / 3600);
			var _n:int = mathF(t % 3600 / 60);
			var _s:int = mathF(t - 60 * _n - _h * 3600);
			_h = _h % 24;
			var _dd:String = (_d < 10 ? "0" : "") + _d;
			var _hh:String = (_h < 10 ? "0" : "") + _h;
			var _nn:String = (_n < 10 ? "0" : "") + _n;
			var _ss:String = (_s < 10 ? "0" : "") + _s;
			format = format.replace(/DD/g, _dd);
			format = format.replace(/D/g, _d);
			format = format.replace(/HH/g, _hh);
			format = format.replace(/H/g, _h);
			format = format.replace(/NN/g, _nn);
			format = format.replace(/N/g, _n);
			format = format.replace(/SS/g, _ss);
			format = format.replace(/S/g, _s);
			return format;
		}
		
		/**
		 * 百分比格式化.用于进度类的计算
		 * @param current    当前量
		 * @param total      总量
		 * @param precision  精度.默认值100.可选;
		 */
		public static function percentFormart(current:uint, total:uint, precision:uint = 100):uint
		{
			return Math.floor(current / total * precision);
		}
		
	}
}
