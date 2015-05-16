package swift.utils.view
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Back;
	
	import flash.display.DisplayObject;
	
	import org.ais.system.Ais;

	public class WinEffect
	{
		static public var SHOW_LAYOUT:Function = __show_back_easeOut;
		static public var HIDE_LAYOUT:Function = __hide_back_easeOut;
		
		public function WinEffect()
		{
		}
		
		static public function show(obj:DisplayObject, layout:Function = null, callBack:Function = null):void
		{
			if (null !== layout) layout(obj, callBack);
			else SHOW_LAYOUT(obj, callBack);
			obj = null;
			layout = null;
			callBack = null;
		}
		
		static public function hide(obj:DisplayObject, layout:Function = null, callBack:Function = null):void
		{
			if (null !== layout) layout(obj, callBack);
			else HIDE_LAYOUT(obj, callBack);
			obj = null;
			layout = null;
			callBack = null;
		}
		
		static private function __show_back_easeOut(obj:DisplayObject, callBack:Function):void
		{
			obj.scaleX = obj.scaleY = 0;
			var x:Number = obj.x;
			var y:Number = obj.y;
			var alpha:Number = obj.alpha;
			
			obj.x = Ais.IMain.stage.stageWidth >> 1;
			obj.y = Ais.IMain.stage.stageHeight >> 1;
			obj.alpha = 0;
			
			TweenLite.to(obj, 0.7, {x: x, y: y, alpha: alpha, scaleX: 1, scaleY: 1, ease: Back.easeOut, onComplete: callBack});
			obj = null;
			callBack = null;
		}
		
		static private function __hide_back_easeOut(obj:DisplayObject, callBack:Function):void
		{
			var x:Number = Ais.IMain.stage.stageWidth >> 1;
			var y:Number = Ais.IMain.stage.stageHeight >> 1;
			
			TweenLite.to(obj, 0.7, {x: x, y: y, alpha: 0, scaleX: 0, scaleY: 0, ease: Back.easeIn, onComplete: callBack});
			obj = null;
			callBack = null;
		}
		
	}
}