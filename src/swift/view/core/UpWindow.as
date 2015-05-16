package swift.view.core
{
	import org.ais.event.TEvent;
	import org.ais.system.Ais;
	import org.aisy.autoclear.AisyAutoClear;
	import org.aisy.display.USprite;
	
	import swift.utils.view.WinEffect;
	import swift.utils.view.WinManager;

	public class UpWindow extends USprite
	{
		protected var NAME:String;
		protected var GROUP_NAME:String;
		protected var _autoClear:AisyAutoClear;
		
		public function UpWindow()
		{
		}
		
		protected function __show(mode:Array = null, index:int = -1, options:Array = null):void
		{
			if (null === NAME) {
				NAME = Math.random().toString();
			}
			if (null === GROUP_NAME) {
				GROUP_NAME = Math.random().toString();
			}
			if (null === mode) {
				mode = [WinManager.CLEAR_OTHER_GROUP, WinManager.ADD_ELEMENT];
			}
			var arr:Array = [0, false, true, true, 0, 0, 1, false];
			if (null === options) {
				options = arr;
			}
			else if (options.length < arr.length) {
				options = options.concat(arr.slice(options.length));
			}
			TEvent.newTrigger("UP_WINDOW_M", __winHandler);
			TEvent.trigger("UP_WINDOW_AIS", "SHOW", [this, NAME].concat(options));
			TEvent.newTrigger("UP_WINDOW_NEW", __upWindowHandler);
			if (null !== parent) {
				WinManager.exec(GROUP_NAME, NAME, parent, mode, index);
				__showEffect();
			}
		}
		
		protected function __show2():void
		{
			
		}
		
		protected function __showEffect():void
		{
			WinEffect.show(parent, null, __show2);
		}
		
		protected function __hideEffect():void
		{
			WinEffect.hide(parent, null, __clearWindow2);
		}
		
		protected function __winHandler(type:String, data:* = null):void
		{
			switch (type) {
				case "CLEAR":
					if (NAME === data.name) {
						__clearWindow();
					}
					break;
			}
		}
		
		protected function __upWindowHandler(type:String, data:* = null):void
		{
			switch (type) {
				case "RESIZE_ALL":
					if (null !== GROUP_NAME) {
						parent.x = (Ais.IMain.stage.stageWidth - parent.width) >> 1;
						parent.y = (Ais.IMain.stage.stageHeight - parent.height) >> 1;
						parent.alpha = 1;
						WinEffect.show(parent, null, __show2);
					}
					break;
			}
		}
		
		protected function __clearWindow():void
		{
			if (null === parent) return;
			parent.mouseChildren = parent.mouseEnabled = false;
			__hideEffect();
		}
		
		protected function __clearWindow2():void
		{
			TEvent.trigger("UP_WINDOW_NEW", "CLEAR", {"name": NAME});
		}
		
		public function clearWindow():void
		{
			if (null !== GROUP_NAME && null !== NAME) {
				var groupName:String = GROUP_NAME;
				GROUP_NAME = null;
				WinManager.exec(groupName, NAME, null, [WinManager.CLEAR_ELEMENT]);
			}
		}
		
		override public function clear():void
		{
			TEvent.removeTrigger("UP_WINDOW_M", __winHandler);
			TEvent.removeTrigger("UP_WINDOW_NEW", __upWindowHandler);
			if (null !== _autoClear) {
				_autoClear.clear();
				_autoClear = null;
			}
			super.clear();
			clearWindow();
			NAME = null;
			GROUP_NAME = null;
		}
		
	}
}
