package swift.controller.event
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;

	public class UMouseEventController
	{
		public var systemBubbles:Boolean;
		
		protected var _container:DisplayObjectContainer;
		protected var _lastMoveIE:IEventDispatcher;
		protected var _lastDownIE:IEventDispatcher;
		
		public function UMouseEventController(container:DisplayObjectContainer)
		{
			_container = container;
			
			__addEvent();
		}
		
		protected function __addEvent():void
		{
			_container.addEventListener(MouseEvent.MOUSE_MOVE, __mouseMoveHandler);
			_container.addEventListener(MouseEvent.MOUSE_DOWN, __mouseDownHandler);
			_container.addEventListener(MouseEvent.MOUSE_UP, __mouseUpHandler);
		}
		
		protected function __removeEvent():void
		{
			_container.removeEventListener(MouseEvent.MOUSE_MOVE, __mouseMoveHandler);
			_container.removeEventListener(MouseEvent.MOUSE_DOWN, __mouseDownHandler);
			_container.removeEventListener(MouseEvent.MOUSE_UP, __mouseUpHandler);
		}
		
		protected function dispatchEvent(ie:IEventDispatcher, e:Event, bubbles:Boolean = true):void
		{
			if (null === ie) return;
			if (ie is IEventDispatcher) {
				if (ie.hasEventListener(e.type) === true) {
					ie.dispatchEvent(e);
				}
			}
			if (bubbles === true) {
				if (e.bubbles === false) {
					dispatchEvent(DisplayObject(ie).parent, e, bubbles);
				}
			}
			ie = null;
			e = null;
		}
		
		protected function getIEventDispatcher(container:DisplayObjectContainer):IEventDispatcher
		{
			var i:uint = container.numChildren, o:DisplayObject, ie:IEventDispatcher;
			while (i > 0) {
				i--;
				o = container.getChildAt(i);
				if (o is DisplayObjectContainer) {
					if (o is IUMouseEvent) {
						if (IUMouseEvent(o).tMouseChildren === true) {
							ie = getIEventDispatcher(DisplayObjectContainer(o));
							if (null !== ie) {
								o = null;
								container = null;
								return ie;
							}
						}
					}
					else if (DisplayObjectContainer(o).mouseChildren === true) {
						ie = getIEventDispatcher(DisplayObjectContainer(o));
						if (null !== ie) {
							o = null;
							container = null;
							return ie;
						}
					}
				}
				if (o is IEventDispatcher) {
					if (o is IUMouseEvent) {
						if (IUMouseEvent(o).tMouseEnabled === true) {
							if (o.hitTestPoint(_container.mouseX, _container.mouseY, true) === true) {
								container = null;
								return IEventDispatcher(o);
							}
						}
					}
					else if (o is InteractiveObject) {
						if (InteractiveObject(o).mouseEnabled === true) {
							if (o.hitTestPoint(_container.mouseX, _container.mouseY, true) === true) {
								container = null;
								return IEventDispatcher(o);
							}
						}
					}
				}
			}
			o = null;
			container = null;
			return null;
		}
		
		protected function __mouseMoveHandler(e:MouseEvent):void
		{
			var ie:IEventDispatcher = getIEventDispatcher(_container);
			if (null !== _lastMoveIE) {
				if (ie !== _lastMoveIE) {
					dispatchEvent(_lastMoveIE, new UMouseEvent(_lastMoveIE, UMouseEvent.MOUSE_OUT, systemBubbles, e.cancelable, e.localX, e.localY, ie, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta), true);
				}
			}
			if (null !== ie) {
				dispatchEvent(ie, new UMouseEvent(ie, UMouseEvent.MOUSE_MOVE, systemBubbles, e.cancelable, e.localX, e.localY, _lastMoveIE, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta), true);
				if (ie !== _lastMoveIE) {
					dispatchEvent(ie, new UMouseEvent(ie, UMouseEvent.MOUSE_OVER, systemBubbles, e.cancelable, e.localX, e.localY, _lastMoveIE, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta), true);
				}
			}
			_lastMoveIE = ie;
			ie = null;
		}
		
		protected function __mouseDownHandler(e:MouseEvent):void
		{
			_lastDownIE = getIEventDispatcher(_container);
			if (null !== _lastDownIE) {
				dispatchEvent(_lastDownIE, new UMouseEvent(_lastDownIE, UMouseEvent.MOUSE_DOWN, systemBubbles, e.cancelable, e.localX, e.localY, null, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta), true);
			}
		}
		
		protected function __mouseUpHandler(e:MouseEvent):void
		{
			var ie:IEventDispatcher = getIEventDispatcher(_container);
			if (null !== ie) {
				dispatchEvent(ie, new UMouseEvent(ie, UMouseEvent.MOUSE_UP, systemBubbles, e.cancelable, e.localX, e.localY, _lastDownIE, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta), true);
				if (ie === _lastDownIE) {
					dispatchEvent(ie, new UMouseEvent(ie, UMouseEvent.CLICK, systemBubbles, e.cancelable, e.localX, e.localY, _lastDownIE, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta), true);
				}
			}
			ie = null;
			_lastDownIE = null;
		}
		
		public function clear():void
		{
			__removeEvent();
			_lastMoveIE = null;
			_lastDownIE = null;
			_container = null;
		}
	}
}