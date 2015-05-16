package swift.view.core
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	import swift.controller.event.IUMouseEvent;

	public class UIMBitmap extends UBitmap implements IUMouseEvent
	{
		public function UIMBitmap(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false)
		{
			super(bitmapData, pixelSnapping, smoothing);
			bitmapData = null;
			pixelSnapping = null;
		}
		
		override public function hitTestPoint(x:Number, y:Number, shapeFlag:Boolean = false):Boolean
		{
			if (null === bitmapData) return super.hitTestPoint(x, y, shapeFlag);
			var p:Point = new Point(x, y);
			p = globalToLocal(p);
			return bitmapData.getPixel32(p.x, p.y) !== 0;
		}
		
		public function set tMouseEnabled(enabled:Boolean):void
		{
			
		}
		
		public function get tMouseEnabled():Boolean
		{
			return true;
		}
		
		public function set tMouseChildren(enable:Boolean):void
		{
			
		}
		
		public function get tMouseChildren():Boolean
		{
			return false;
		}
		
	}
}