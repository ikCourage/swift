package swift.utils.view
{
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	import org.ais.event.TEvent;
	import org.ais.system.Ais;

	public class WinManager
	{
		static public const CLEAR_ALL:uint = 0;
		static public const CLEAR_OTHER_GROUP:uint = 1;
		static public const CLEAR_GROUP:uint = 2;
		static public const CLEAR_OTHER_ELEMENT:uint = 3;
		static public const CLEAR_ELEMENT:uint = 4;
		static public const RESIZE:uint = 5;
		static public const ADD_ELEMENT:uint = 6;
		
		static public var SHOW_LAYOUT:Function = __showLayout;
		static public var HIDE_LAYOUT:Function = __hideLayout;
		
		static private var winLen:uint;
		static private var wins:Dictionary;
		
		public function WinManager()
		{
		}
		
		static public function exec(groupName:String, name:String, view:DisplayObject, mode:Array = null, index:int = -1, showLayout:Function = null, hideLayout:Function = null):void
		{
			if (null === showLayout) showLayout = SHOW_LAYOUT;
			if (null === hideLayout) hideLayout = HIDE_LAYOUT;
			if (null === mode) mode = [ADD_ELEMENT];
			else mode.sort(Array.NUMERIC);
			var j:uint, sl:uint = showLayout.length, hl:uint = hideLayout.length, vl:uint, v:Array;
			for (var i:uint, l:uint = mode.length; i < l; i++) {
				switch (mode[i]) {
//					清除全部
					case CLEAR_ALL:
						if (winLen !== 0) {
							winLen = 0;
							for each (v in wins) hideLayout.apply(null, [v].slice(0, hl));
							v = null;
							wins = null;
						}
						break;
//					清除其他组
					case CLEAR_OTHER_GROUP:
						if (winLen !== 0) {
							for (var k:String in wins) {
								if (k === groupName) continue;
								v = wins[k];
								winLen--;
								delete wins[k];
								hideLayout.apply(null, [v].slice(0, hl));
								v = null;
							}
							if (winLen === 0) wins = null;
						}
						break;
//					清除当前组
					case CLEAR_GROUP:
						if (winLen !== 0 && wins.hasOwnProperty(groupName) === true) {
							v = wins[groupName];
							winLen--;
							if (winLen === 0) wins = null;
							else delete wins[groupName];
							hideLayout.apply(null, [v].slice(0, hl));
							v = null;
						}
						break;
//					清除当前组其他元素
					case CLEAR_OTHER_ELEMENT:
						if (winLen !== 0 && wins.hasOwnProperty(groupName) === true) {
							v = wins[groupName];
							for (j = 0, vl = v.length; j < vl; j++) if (v[j][0] === name) break;
							if (j < vl) {
								v = v.splice(j, 1);
								hideLayout.apply(null, [wins[groupName]].slice(0, hl));
								wins[groupName] = v;
								showLayout.apply(null, [v, index].slice(0, sl));
							}
							else {
								winLen--;
								if (winLen === 0) wins = null;
								else delete wins[groupName];
								hideLayout.apply(null, [v].slice(0, hl));
							}
							v = null;
						}
						break;
//					清除此元素
					case CLEAR_ELEMENT:
						if (winLen !== 0 && wins.hasOwnProperty(groupName) === true) {
							v = wins[groupName];
							for (j = 0, vl = v.length; j < vl; j++) {
								if (v[j][0] === name) {
									if (vl === 1) {
										winLen--;
										if (winLen === 0) wins = null;
										else delete wins[groupName];
									}
									hideLayout.apply(null, [v.splice(j, 1)].slice(0, hl));
									if (vl !== 1) showLayout.apply(null, [v, -1].slice(0, sl));
									break;
								}
							}
							v = null;
						}
						break;
					case RESIZE:
						if (winLen !== 0) {
							if (null === groupName) for each (v in wins) showLayout.apply(null, [v, -1].slice(0, sl));
							else if (wins.hasOwnProperty(groupName) === true) showLayout.apply(null, [wins[groupName], -1].slice(0, sl));
							v = null;
						}
						break;
//					添加到当前组
					default:
						if (winLen === 0) {
							winLen = 1;
							wins = new Dictionary();
							wins[groupName] = v = [];
						}
						else if (wins.hasOwnProperty(groupName) === false) {
							winLen++;
							wins[groupName] = v = [];
						}
						else v = wins[groupName];
						for (j = 0, vl = v.length; j < vl; j++) if (index < v[j][1]) break;
						v.splice(j, 0, [name, index, view]);
						showLayout.apply(null, [v, j].slice(0, sl));
						v = null;
						break;
				}
			}
			v = null;
			groupName = null;
			name = null;
			view = null;
			mode = null;
			showLayout = null;
			hideLayout = null;
		}
		
		static private function __showLayout(v:Array, index:int = -1):void
		{
			var l:uint = v.length;
			if (l === 0) return;
			var i:uint, x:Number = 0, y:Number = 0;
			for (; i < l; i++) {
				x += v[i][2].width;
				y = y >= v[i][2].height ? y : v[i][2].height;
			}
			x = (Ais.IMain.stage.stageWidth - x) * 0.5;
			y = (Ais.IMain.stage.stageHeight - y) * 0.5;
			for (i = 0; i < l; i++) {
				TweenLite.to(v[i][2], 0.5, {x: x, y: y});
				x += v[i][2].width;
			}
			v = null;
		}
		
		static private function __hideLayout(v:Array):void
		{
			for (var i:uint = 0, l:uint = v.length; i < l; i++) TEvent.trigger("UP_WINDOW_M", "CLEAR", {name: v[i][0], obj: v[i][2]});
			v = null;
		}
		
	}
}