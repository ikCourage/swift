package swift.utils.view
{
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import org.ais.system.Ais;
	import org.aisy.interfaces.IClear;

	public class ViewUtil
	{
		static protected var _bitmap:Bitmap;
		
		public function ViewUtil()
		{
		}
		
		static public function addEventWithIClearInContainer(container:DisplayObjectContainer, callback:Function, type:String = MouseEvent.CLICK):void
		{
			var obj:DisplayObject;
			for (var i:int = 0, l:int = container.numChildren; i < l; i++) {
				obj = container.getChildAt(i);
				if (obj is IClear) obj["addEventListener"](type, callback);
			}
		}
		
		static public function removeEventWithIClearInContainer(container:DisplayObjectContainer, callback:Function, type:String = MouseEvent.CLICK):void
		{
			var obj:DisplayObject;
			for (var i:int = 0, l:int = container.numChildren; i < l; i++) {
				obj = container.getChildAt(i);
				if (obj is IClear) obj["removeEventListener"](type, callback);
			}
		}
		
		static public function addEventInContainer(container:DisplayObjectContainer, callback:Function, type:String = MouseEvent.CLICK):void
		{
			var obj:DisplayObject;
			for (var i:int = 0, l:int = container.numChildren; i < l; i++) {
				obj = container.getChildAt(i);
				if (obj is InteractiveObject) obj["addEventListener"](type, callback);
			}
		}
		
		static public function removeEventInContainer(container:DisplayObjectContainer, callback:Function, type:String = MouseEvent.CLICK):void
		{
			var obj:DisplayObject;
			for (var i:int = 0, l:int = container.numChildren; i < l; i++) {
				obj = container.getChildAt(i);
				if (obj is InteractiveObject) obj["removeEventListener"](type, callback);
			}
		}
		
		static public function addEventInArray(arr:Array, callback:Function, type:String = MouseEvent.CLICK, buttonMode:Boolean = true):void
		{
			var obj:DisplayObject;
			for (var i:int = 0, l:int = arr.length; i < l; i++) {
				obj = arr[i];
				if (obj is InteractiveObject) {
					if (obj.hasOwnProperty("buttonMode") == true) {
						obj["buttonMode"] = buttonMode;
					}
					obj["addEventListener"](type, callback);
				}
			}
		}
		
		static public function removeEventInArray(arr:Array, callback:Function, type:String = MouseEvent.CLICK):void
		{
			var obj:DisplayObject;
			for (var i:int = 0, l:int = arr.length; i < l; i++) {
				obj = arr[i];
				if (obj is InteractiveObject) obj["removeEventListener"](type, callback);
			}
		}
		
		static public function makeChildrenToArray(container:DisplayObjectContainer):Array
		{
			var arr:Array = [];
			for (var i:int = 0, l:int = container.numChildren; i < l; i++) {
				arr[i] = container.getChildAt(i);
			}
			return arr;
		}
		
		static public function makeChildrenToArrayByName(container:DisplayObjectContainer, prefix:String = "", suffix:String = "", start:int = 0, end:int = -1):Array
		{
			if (end === -1) end = container.numChildren;
			var obj:DisplayObject, arr:Array = [];
			for (var i:int = 0; start <= end; start++) {
				obj = container.getChildByName(prefix + start + suffix);
				if (null != obj) arr[i++] = obj;
			}
			return arr;
		}
		
		static public function reSetXY(obj:DisplayObject):void
		{
			var r:Rectangle = obj.getBounds(obj.parent);
			obj.x = -r.x;
			obj.y = -r.y;
		}
		
		static public function clear(obj:*, removeParent:Boolean = true):void
		{
			var l:int;
			if (obj is IClear) {
				if (removeParent === true) (obj as IClear).clear();
				else {
					var c:DisplayObjectContainer = (obj is DisplayObject) ? obj.parent : null;
					if (null !== c) {
						l = c.getChildIndex(obj as DisplayObject);
						(obj as IClear).clear();
						c.addChildAt(obj as DisplayObject, l);
					}
					else (obj as IClear).clear();
				}
			}
			else if (obj is DisplayObjectContainer) {
				c = obj as DisplayObjectContainer;
				if (removeParent === true && null !== c.parent) c.parent.removeChild(c);
				for (l = c.numChildren; l > 0;) {
					l--;
					obj = c.getChildAt(l);
					if (obj is IClear) (obj as IClear).clear();
					else c.removeChildAt(l);
				}
			}
			else if (obj is DisplayObject) {
				var o:DisplayObject = obj as DisplayObject;
				if (removeParent === true && null !== o.parent) o.parent.removeChild(o);
			}
			else if (obj is Array) {
				var arr:Array = obj as Array;
				for (l = arr.length; l > 0;) {
					l--;
					clear(arr[l], removeParent);
				}
			}
		}
		
		static public function drawStage():BitmapData
		{
			var bmd:BitmapData = new BitmapData(Ais.IMain.stage.stageWidth, Ais.IMain.stage.stageHeight);
			bmd.draw(Ais.IMain.stage);
			return bmd;
		}
		
		static public function sceneChange(delayA:Number = 0.5, delayB:Number = 1.5, view:DisplayObject = null, view2:DisplayObject = null, callback:Function = null):void
		{
			clearBitmap();
			if (null === view2) view2 = _bitmap = new Bitmap(drawStage());
			if (null === view2.parent) Ais.IMain.stage.addChild(view2);
			if (null !== view) {
				view.alpha = 0;
			}
			TweenLite.to(view2, delayA, {"alpha": 0, "onComplete": function ():void
			{
				if (null !== view) {
					TweenLite.to(view, delayB, {"alpha": 1, "onComplete": function ():void
					{
						if (null !== callback) {
							callback();
							callback = null;
						}
					}});
					view = null;
				}
				else if (null !== callback) {
					callback();
					callback = null;
				}
				if (view2 is IClear) {
					IClear(view2).clear()
				}
				else if (null != view2.parent) {
					view2.parent.removeChild(view2);
				}
				clearBitmap();
			}});
		}
		
		static protected function clearBitmap():void
		{
			if (null === _bitmap) return;
			if (null !== _bitmap.bitmapData) {
				_bitmap.bitmapData.dispose();
				_bitmap.bitmapData = null;
			}
			if (null !== _bitmap.parent) _bitmap.parent.removeChild(_bitmap);
			_bitmap = null;
		}
		
	}
}