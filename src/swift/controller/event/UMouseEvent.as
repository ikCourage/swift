package swift.controller.event
{
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;

	public class UMouseEvent extends MouseEvent
	{
		static public const MOUSE_MOVE:String = "U_mouse_move";
		static public const MOUSE_OVER:String = "U_mouse_over";
		static public const MOUSE_OUT:String = "U_mouse_out";
		static public const MOUSE_DOWN:String = "U_mouse_down";
		static public const MOUSE_UP:String = "U_mouse_up";
		static public const CLICK:String = "U_click";
		
		protected var _target:Object;
		protected var _relatedIEventDispatcher:IEventDispatcher;
		protected var _bubbles:Boolean;
		protected var _eventPhase:uint;
		
		public function UMouseEvent(target:Object, type:String, bubbles:Boolean = false, cancelable:Boolean = false, localX:Number = 0, localY:Number = 0, relatedIEventDispatcher:IEventDispatcher = null, ctrlKey:Boolean = false, altKey:Boolean = false, shiftKey:Boolean = false, buttonDown:Boolean = false, delta:int = 0)
		{
			_target = target;
			_relatedIEventDispatcher = relatedIEventDispatcher;
			
			super(type, bubbles, cancelable, localX, localY, null, ctrlKey, altKey, shiftKey, buttonDown, delta);
			
			target = null;
			type = null;
		}
		
		public function get relatedIEventDispatcher():IEventDispatcher
		{
			return _relatedIEventDispatcher;
		}
		
		override public function get target():Object
		{
			return _target;
		}
		
		override public function clone():Event
		{
			return new UMouseEvent(target, type, bubbles, cancelable, localX, localY, relatedObject, ctrlKey, altKey, shiftKey, buttonDown, delta);
		}
		
	}
}