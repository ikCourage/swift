package swift.utils.view
{
	import flash.display.DisplayObject;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;

	public class SetFilter
	{
		
		public static function applyGray(child:DisplayObject):void
		{
			var matrix:Array = [];
			matrix = matrix.concat([0.3086, 0.6094, 0.0820, 0, 0]);
			matrix = matrix.concat([0.3086, 0.6094,0.0820, 0, 0]);
			matrix = matrix.concat([0.3086, 0.6094, 0.0820, 0, 0]);
			matrix = matrix.concat([0, 0, 0, 1, 0]);
			applyFilter(child, matrix);
			matrix = null;
			child = null;
		}
		
		public static function applyHighlight(child:DisplayObject):void
		{
			var matrix:Array = [];
			matrix = matrix.concat([1.5, 0, 0, 0, 0]);
			matrix = matrix.concat([0, 1.5, 0, 0, 0]);
			matrix = matrix.concat([0, 0, 1.5, 0, 0]);
			matrix = matrix.concat([0, 0, 0, 1, 0]);
			applyFilter(child, matrix);
			matrix = null;
			child = null;
		}
		
		public static function applyDefault(child:DisplayObject):void
		{
			child.filters = null;
			child = null;
		}
		
		public static function applyGlow(child:DisplayObject, color:uint = 0xffffff, alpha:Number = 0.8, blurX:Number = 4, blurY:Number = 4, strength:Number = 2):void
		{
			var inner:Boolean = false;
			var knockout:Boolean = false;
			var quality:Number = BitmapFilterQuality.HIGH;
			var arr:Array = child.filters;
			if (null === arr) arr = [];
			arr[arr.length] = new GlowFilter(color, alpha, blurX, blurY, strength, quality, inner, knockout);
			child.filters = arr;
			child = null;
			arr = null;
		}
		
		public static function applyColor(child:DisplayObject, color:String):void
		{
			var matrix:Array = [];
			var c1:int = 0, c2:int = 0, c3:int = 0;
			if (color === "red") c1 = 1;
			if (color === "green") c2 = 1;
			if (color ==="blue") c3 = 1;
			matrix = matrix.concat([c1, 0, 0, 0, 0]);
			matrix = matrix.concat([0, c2, 0, 0, 0]);
			matrix = matrix.concat([0, 0, c3, 0, 0]);
			matrix = matrix.concat([0, 0, 0, 1, 0]);
			applyFilter(child, matrix);
			matrix = null;
			child = null;
			color = null;
		}
		
		protected static function applyFilter(child:DisplayObject, matrix:Array):void
		{
			var arr:Array = child.filters;
			if (null === arr) arr = [];
			arr[arr.length] = new ColorMatrixFilter(matrix);
			child.filters = arr;
			child = null;
			matrix = null;
			arr = null;
		}
		
	}
}