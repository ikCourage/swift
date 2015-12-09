package swift.event
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class UMouseEvent extends MouseEvent
	{
		static public var ROLL_OVER:String = "U_" + MouseEvent.ROLL_OVER;
		static public var ROLL_OUT:String = "U_" + MouseEvent.ROLL_OUT;
		static public var MOUSE_OVER:String = "U_" + MouseEvent.MOUSE_OVER;
		static public var MOUSE_OUT:String = "U_" + MouseEvent.MOUSE_OUT;
		static public var MOUSE_MOVE:String = "U_" + MouseEvent.MOUSE_MOVE;
		static public var MOUSE_DOWN:String = "U_" + MouseEvent.MOUSE_DOWN;
		static public var MOUSE_UP:String = "U_" + MouseEvent.MOUSE_UP;
		static public var MOUSE_WHEEL:String = "U_" + MouseEvent.MOUSE_WHEEL;
		static public var CLICK:String = "U_" + MouseEvent.CLICK;
		static public var DOUBLE_CLICK:String = "U_" + MouseEvent.DOUBLE_CLICK;
		
		protected var _target2:DisplayObject;
		protected var _relatedObject2:DisplayObject;
		
		public function UMouseEvent(target:DisplayObject, type:String, bubbles:Boolean = false, cancelable:Boolean = false, localX:Number = 0, localY:Number = 0, relatedObject:DisplayObject = null, ctrlKey:Boolean = false, altKey:Boolean = false, shiftKey:Boolean = false, buttonDown:Boolean = false, delta:int = 0)
		{
			_target2 = target;
			_relatedObject2 = relatedObject;
			
			super(type, bubbles, cancelable, localX, localY, relatedObject as InteractiveObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
			
			type = null;
			target = null;
			relatedObject = null;
		}
		
		public function get target2():DisplayObject
		{
			return _target2;
		}
		
		public function get relatedObject2():DisplayObject
		{
			return _relatedObject2;
		}
		
		override public function clone():Event
		{
			return new UMouseEvent(target2, type, bubbles, cancelable, localX, localY, relatedObject2, ctrlKey, altKey, shiftKey, buttonDown, delta);
		}
		
		static public function reset():void
		{
			ROLL_OVER = MouseEvent.ROLL_OVER;
			ROLL_OUT = MouseEvent.ROLL_OUT;
			MOUSE_OVER = MouseEvent.MOUSE_OVER;
			MOUSE_OUT = MouseEvent.MOUSE_OUT;
			MOUSE_MOVE = MouseEvent.MOUSE_MOVE;
			MOUSE_DOWN = MouseEvent.MOUSE_DOWN;
			MOUSE_UP = MouseEvent.MOUSE_UP;
			MOUSE_WHEEL = MouseEvent.MOUSE_WHEEL;
			CLICK = MouseEvent.CLICK;
			DOUBLE_CLICK = MouseEvent.DOUBLE_CLICK;
		}
		
	}
}