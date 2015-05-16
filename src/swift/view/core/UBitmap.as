package swift.view.core
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	
	import org.aisy.interfaces.IClear;

	public class UBitmap extends Bitmap implements IClear
	{
		public function UBitmap(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false)
		{
			super(bitmapData, pixelSnapping, smoothing);
			bitmapData = null;
			pixelSnapping = null;
		}
		
		public function clear():void
		{
			if (null !== parent) parent.removeChild(this);
			bitmapData = null;
		}
		
	}
}