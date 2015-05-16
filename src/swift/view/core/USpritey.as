package swift.view.core
{
	import org.aisy.display.USprite;
	import org.aisy.interfaces.IClear;

	public class USpritey extends USprite
	{
		public function USpritey()
		{
		}
		
		/**
		 * 清空显示
		 */
		public function clearView():void
		{
			var i:uint = numChildren, obj:*;
			while (i) {
				i--;
				obj = getChildAt(i);
				if (obj is IClear) obj.clear();
				else removeChildAt(0);
			}
			obj = null;
		}
		
	}
}