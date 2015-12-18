package swift.event
{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	
	import org.aisy.interfaces.IClear;

	/**
	 * 
	 * 如此简单的管理不同元件的光标样式，而不需要以往繁琐的手动设置。
	 * 并且可以透过元件的透明区域（如：PNG 图片），点击到下层的元件。
	 * 
	 */
	public class UMouseEventManager implements IClear
	{
		/**
		 * 默认是否显示光标
		 */
		public var cursorVisible:Boolean = true;
		/**
		 * 通过 hitTestPoint 来检查元件的像素
		 */
		public var shapeFlag:Boolean = true;
		/**
		 * 如果是图片，则检查图片的像素
		 */
		public var bitmapFlag:Boolean = true;
		/**
		 * 设置双击的最大时间间隔（毫秒）<br>
		 * <ul>
		 * <li>0：不支持双击（默认）</li>
		 * <li>正数：先触发一次 click</li>
		 * <li>负数：先触发两次 click</li>
		 * </ul>
		 */
		public var doubleClickTime:int;
		
		protected var _root:DisplayObjectContainer;
		protected var _lastMoveObj:DisplayObject;
		protected var _lastDownObj:DisplayObject;
		protected var _lastClickObj:DisplayObject;
		protected var _lastTime:int;
		protected var _event:Boolean;
		protected var _shap:Shape;
		protected var _cursors:Dictionary;
		
		public function UMouseEventManager(root:DisplayObjectContainer, event:Boolean = true)
		{
			if (UMouseEvent.MOUSE_MOVE !== MouseEvent.MOUSE_MOVE) {
				_root = root;
				this.event = event;
				_shap = new Shape();
				_shap.visible = false;
				_cursors = new Dictionary(true);
			}
			else {
				clear();
			}
			root = null;
		}
		
		/**
		 * 如果无法对元件设置 cursor 或 buttonMode 属性，则可以以元件为 key 映射一个对象
		 * @return
		 */
		public function get cursors():Dictionary
		{
			return _cursors;
		}
		
		/**
		 * 当含有 cursor 时，设置为对应的光标样式。
		 * 当含有 buttonMode 时，设置为按钮光标。
		 * 当含有 cursorVisible 时，可以设置光标的显示或隐藏。
		 * @param o
		 */
		public function set cursor(o:Object):void
		{
			if (Mouse.supportsCursor === true) {
				if (null !== o) {
					if (null != _cursors[o]) {
						cursor = _cursors[o];
						return;
					}
					if (o.hasOwnProperty("cursorVisible") === true) {
						o["cursorVisible"] ? Mouse.show() : Mouse.hide();
					}
					else {
						cursorVisible ? Mouse.show() : Mouse.hide();
					}
					if (o.hasOwnProperty("cursor") === true && o["cursor"]) {
						if (Mouse.cursor !== o["cursor"]) {
							Mouse.cursor = o["cursor"];
						}
						return;
					}
					if (o.hasOwnProperty("buttonMode") === true && o["buttonMode"] === true) {
						if (Mouse.cursor !== MouseCursor.BUTTON) {
							Mouse.cursor = MouseCursor.BUTTON;
						}
						return;
					}
				}
				else {
					cursorVisible ? Mouse.show() : Mouse.hide();
				}
				Mouse.cursor = MouseCursor.AUTO;
			}
		}
		
		/**
		 * 设置是否侦听 MOUSE_WHEEL（默认：false）
		 * @param value
		 */
		public function set wheel(value:Boolean):void
		{
			if (null !== _root) {
				_root.removeEventListener(MouseEvent.MOUSE_WHEEL, __mouseWheelHandler);
				if (_event === true && value === true) {
					_root.addEventListener(MouseEvent.MOUSE_WHEEL, __mouseWheelHandler, false, int.MAX_VALUE);
				}
			}
		}
		
		/**
		 * 设置是否触发事件，如果为 false，则仅仅自动变化光标样式
		 * @param value
		 */
		public function set event(value:Boolean):void
		{
			_event = value;
			__removeEvent();
			__addEvent();
		}
		
		protected function __addEvent():void
		{
			if (null !== _root) {
				_root.addEventListener(MouseEvent.ROLL_OUT, __rollOutHandler, false, int.MAX_VALUE);
				_root.addEventListener(MouseEvent.MOUSE_OVER, __mouseMoveHandler, false, int.MAX_VALUE);
				_root.addEventListener(MouseEvent.MOUSE_MOVE, __mouseMoveHandler, false, int.MAX_VALUE);
				if (_event === true) {
					_root.addEventListener(MouseEvent.MOUSE_DOWN, __mouseDownHandler, false, int.MAX_VALUE);
					_root.addEventListener(MouseEvent.MOUSE_UP, __mouseUpHandler, false, int.MAX_VALUE);
				}
			}
		}
		
		protected function __removeEvent():void
		{
			if (null !== _root) {
				_root.removeEventListener(MouseEvent.ROLL_OUT, __rollOutHandler);
				_root.removeEventListener(MouseEvent.MOUSE_OVER, __mouseMoveHandler);
				_root.removeEventListener(MouseEvent.MOUSE_MOVE, __mouseMoveHandler);
				_root.removeEventListener(MouseEvent.MOUSE_DOWN, __mouseDownHandler);
				_root.removeEventListener(MouseEvent.MOUSE_UP, __mouseUpHandler);
				_root.removeEventListener(MouseEvent.MOUSE_WHEEL, __mouseWheelHandler);
			}
		}
		
		protected function getIEventDispatcher(o:DisplayObject):DisplayObject
		{
			var x:Number = o.stage.mouseX, y:Number = o.stage.mouseY;
			if (x < 0 || y < 0 || x > o.stage.stageWidth || y > o.stage.stageHeight) {
				o = null;
				return null;
			}
			var c:DisplayObjectContainer = (o is DisplayObjectContainer && (o as DisplayObjectContainer).mouseChildren === true) ? o as DisplayObjectContainer : o.parent;
			var b:Boolean = c.mouseEnabled, i:uint = c === o ? c.numChildren : c.getChildIndex(o) + 1, j:uint, k:uint, l:uint, v:Vector.<uint> = new Vector.<uint>(), v2:Vector.<uint> = new Vector.<uint>();
			while (i > 0) {
				i--;
				o = c.getChildAt(i);
				if (o.visible === true) {
					if (o is DisplayObjectContainer && (o as DisplayObjectContainer).mouseChildren === true && (o as DisplayObjectContainer).numChildren !== 0) {
						if (o.hitTestPoint(x, y, shapeFlag) === true) {
							v[j++] = i;
							c = o as DisplayObjectContainer;
							b = c.mouseEnabled;
							i = c.numChildren;
							v2[k++] = l;
							l = 0;
							continue;
						}
					}
					else if (o.hasOwnProperty("mouseEnabled") === true) {
						if (o["mouseEnabled"] === true && o.hitTestPoint(x, y, shapeFlag) === true) {
							if (!(o is Bitmap) || bitmapFlag === false || null === (o as Bitmap).bitmapData || ((o as Bitmap).bitmapData.getPixel32(o.mouseX, o.mouseY) >> 24) !== 0) {
								c = null;
								v = null;
								v2 = null;
								return o;
							}
						}
					}
					else if (b === true) {
						v2[k++] = i;
						l++;
					}
				}
				if (i === 0) {
					b = j !== 0;
					while (j !== 0 && c.mouseEnabled === false) {
						i = v[--j];
						v.length = j;
						c = c.parent;
					}
					if (c !== _root) {
						if (c.mouseEnabled === true) {
							while (l > 0) {
								l--;
								o = c.getChildAt(v2[--k]);
								if (o.hitTestPoint(x, y, shapeFlag) === true) {
									if (!(o is Bitmap) || bitmapFlag === false || null === (o as Bitmap).bitmapData || (o as Bitmap).bitmapData.getPixel(o.mouseX, o.mouseY) !== 0) {
										o = null;
										v = null;
										v2 = null;
										return c;
									}
								}
							}
							if (c.hasOwnProperty("graphics") === true && (b === true || c.hitTestPoint(x, y, shapeFlag) === true)) {
								_shap.graphics.copyFrom(c["graphics"]);
								c.stage.addChild(_shap);
								if (_shap.hitTestPoint(c.mouseX, c.mouseY, shapeFlag) === true) {
									c.stage.removeChildAt(c.stage.numChildren - 1);
									_shap.graphics.clear();
									o = null;
									v = null;
									v2 = null;
									return c;
								}
								c.stage.removeChildAt(c.stage.numChildren - 1);
								_shap.graphics.clear();
							}
						}
						while (i === 0 && c !== _root) {
							if (j !== 0) {
								i = v[--j];
								v.length = j;
							}
							else {
								i = c.parent.getChildIndex(c);
							}
							c = c.parent;
							l = k !== 0 ? v2[--k] : 0;
							v2.length = k;
						}
					}
					b = c.mouseEnabled;
				}
			}
			o = null;
			v = null;
			v2 = null;
			return c;
		}
		
		protected function dispatchEventRool(o:DisplayObject, e:UMouseEvent):void
		{
			o.dispatchEvent(e);
			var o2:DisplayObject = e.relatedObject2;
			while (null !== (o = o.parent) && o !== o2 && (null === o2 || (null !== o2.parent && o !== o2.parent && (o as DisplayObjectContainer).contains(o2.parent) === false))) {
				e.localX = o.mouseX;
				e.localY = o.mouseY;
				o.dispatchEvent(e);
			}
			o2 = null;
			o = null;
			e = null;
		}
		
		protected function __rollOutHandler(e:MouseEvent):void
		{
			cursor = null;
			if (_event === true && null !== _lastMoveObj) {
				_lastMoveObj.dispatchEvent(new UMouseEvent(_lastMoveObj, UMouseEvent.MOUSE_OUT, true, e.cancelable, _lastMoveObj.mouseX, _lastMoveObj.mouseY, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta));
				dispatchEventRool(_lastMoveObj, new UMouseEvent(_lastMoveObj, UMouseEvent.ROLL_OUT, false, e.cancelable, _lastMoveObj.mouseX, _lastMoveObj.mouseY, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta));
			}
			_lastMoveObj = null;
			_lastDownObj = null;
			_lastClickObj = null;
			e = null;
		}
		
		protected function __mouseMoveHandler(e:MouseEvent):void
		{
			var o:DisplayObject = getIEventDispatcher(e.target as DisplayObject);
			if (null !== _lastMoveObj) {
				if (o !== _lastMoveObj) {
					if (_event === true) {
						_lastMoveObj.dispatchEvent(new UMouseEvent(_lastMoveObj, UMouseEvent.MOUSE_OUT, e.bubbles, e.cancelable, _lastMoveObj.mouseX, _lastMoveObj.mouseY, o, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta));
					}
					if (null === o || !(_lastMoveObj is DisplayObjectContainer) || (_lastMoveObj as DisplayObjectContainer).contains(o) === false) {
						cursor = o;
						if (_event === true) {
							dispatchEventRool(_lastMoveObj, new UMouseEvent(_lastMoveObj, UMouseEvent.ROLL_OUT, false, e.cancelable, _lastMoveObj.mouseX, _lastMoveObj.mouseY, o, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta));
						}
					}
				}
			}
			if (_event === true && null !== o) {
				o.dispatchEvent(new UMouseEvent(o, UMouseEvent.MOUSE_MOVE, e.bubbles, e.cancelable, o.mouseX, o.mouseY, _lastMoveObj, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta));
			}
			if (o !== _lastMoveObj && null !== o) {
				if (null === _lastMoveObj || !(o is DisplayObjectContainer) || (o as DisplayObjectContainer).contains(_lastMoveObj) === false) {
					cursor = o;
					if (_event === true) {
						dispatchEventRool(o, new UMouseEvent(o, UMouseEvent.ROLL_OVER, false, e.cancelable, o.mouseX, o.mouseY, _lastMoveObj, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta));
					}
				}
				if (_event === true) {
					o.dispatchEvent(new UMouseEvent(o, UMouseEvent.MOUSE_OVER, e.bubbles, e.cancelable, o.mouseX, o.mouseY, _lastMoveObj, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta));
				}
			}
			_lastMoveObj = o;
			o = null;
			e = null;
		}
		
		protected function __mouseDownHandler(e:MouseEvent):void
		{
			_lastDownObj = getIEventDispatcher(e.target as DisplayObject);
			if (null !== _lastDownObj) {
				_lastDownObj.dispatchEvent(new UMouseEvent(_lastDownObj, UMouseEvent.MOUSE_DOWN, e.bubbles, e.cancelable, _lastDownObj.mouseX, _lastDownObj.mouseY, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta));
			}
		}
		
		protected function __mouseUpHandler(e:MouseEvent):void
		{
			var o:DisplayObject = getIEventDispatcher(e.target as DisplayObject);
			if (null !== o) {
				o.dispatchEvent(new UMouseEvent(o, UMouseEvent.MOUSE_UP, e.bubbles, e.cancelable, o.mouseX, o.mouseY, _lastDownObj, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta));
				if (o === _lastDownObj) {
					if (doubleClickTime !== 0) {
						var t:int = getTimer();
						if (o === _lastClickObj) {
							if ((doubleClickTime > 0 ? doubleClickTime : -doubleClickTime) > t - _lastTime) {
								if (doubleClickTime < 0) {
									o.dispatchEvent(new UMouseEvent(o, UMouseEvent.CLICK, e.bubbles, e.cancelable, o.mouseX, o.mouseY, _lastDownObj, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta));
								}
								o.dispatchEvent(new UMouseEvent(o, UMouseEvent.DOUBLE_CLICK, e.bubbles, e.cancelable, o.mouseX, o.mouseY, _lastDownObj, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta));
								_lastDownObj = null;
							}
						}
						_lastTime = t;
					}
					if (null !== _lastDownObj) {
						o.dispatchEvent(new UMouseEvent(o, UMouseEvent.CLICK, e.bubbles, e.cancelable, o.mouseX, o.mouseY, _lastDownObj, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta));
					}
					_lastClickObj = o;
				}
			}
			_lastDownObj = null;
			o = null;
			e = null;
		}
		
		protected function __mouseWheelHandler(e:MouseEvent):void
		{
			var o:DisplayObject = getIEventDispatcher(e.target as DisplayObject);
			if (null !== o) {
				o.dispatchEvent(new UMouseEvent(o, UMouseEvent.MOUSE_WHEEL, e.bubbles, e.cancelable, o.mouseX, o.mouseY, e.relatedObject, e.ctrlKey, e.altKey, e.shiftKey, e.buttonDown, e.delta));
			}
			o = null;
			e = null;
		}
		
		public function clear():void
		{
			__removeEvent();
			_root = null;
			_lastMoveObj = null;
			_lastDownObj = null;
			_lastClickObj = null;
			_shap = null;
			_cursors = null;
		}
	}
}