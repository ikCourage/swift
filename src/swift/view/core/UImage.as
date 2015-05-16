package swift.view.core
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	
	import org.ais.event.TEvent;
	import org.aisy.image.Image;
	import org.aisy.net.utils.SwfLoader;
	
	import swift.net.assets.AssetsManager;

	public class UImage extends Image
	{
		static public var useWeakReference:Boolean = true;
		protected var _url:String;
		protected var _useWeakReference:Boolean;
		
		public function UImage(request:Object = null, context:LoaderContext = null, loading:DisplayObject = null, useWeakReference:int = 0)
		{
			_useWeakReference = useWeakReference == 0 ? UImage.useWeakReference : useWeakReference == 1 ? true : false;
			super(request, context, loading);
		}
		
		override public function load(request:Object, context:LoaderContext = null, loading:DisplayObject = null):void
		{
			_isClear = false;
			_isLoaded = false;
			if (null === request) return;
			initLoading(loading);
			_url = request is String ? request as String : (request as URLRequest).url;
			_url += "UIMAGE";
			var asset:Object = AssetsManager.get(_url, _useWeakReference);
			if (null == asset) asset = AssetsManager.get(_url, !_useWeakReference);
			if (null != asset) {
				if (asset is BitmapData) {
					_isLoaded = true;
					clearView();
					addChild(new Bitmap(asset as BitmapData));
					__setSize();
					_url = null;
				}
				else {
					TEvent.newTrigger(_url, __triggerHandler);
				}
			}
			else {
				AssetsManager.put(_url, this, _useWeakReference);
				TEvent.newTrigger(_url, __triggerHandler);
				super.load(request, context, loading);
			}
			asset = null;
			request = null;
			context = null;
			loading = null;
		}
		
		public function setUseWeakReference(value:Boolean):void
		{
			_useWeakReference = value;
		}
		
		override protected function __completeHandler2(loader:Loader, e:Event):void
		{
			if (null != _url) {
				var bitmap:Bitmap = (loader.content is Bitmap ? loader.content : DisplayObjectContainer(loader.content).numChildren !== 0 ? DisplayObjectContainer(loader.content).getChildAt(0) : null) as Bitmap;
				if (null != bitmap) AssetsManager.put(_url, bitmap.bitmapData, _useWeakReference);
				else AssetsManager.remove(_url, _useWeakReference);
				TEvent.removeTrigger(_url, __triggerHandler);
				TEvent.trigger(_url, "COMPLETE", [e, null != bitmap ? bitmap.bitmapData : null]);
				bitmap = null;
			}
			super.__completeHandler2(loader, e);
			_url = null;
			loader = null;
			e = null;
		}
		
		override protected function __ioErrorHandler(e:IOErrorEvent):void
		{
			if (null != _url) {
				AssetsManager.remove(_url, _useWeakReference);
				TEvent.removeTrigger(_url, __triggerHandler);
				TEvent.trigger(_url, "IO_ERROR", e);
			}
			super.__ioErrorHandler(e);
			_url = null;
			e = null;
		}
		
		protected function __triggerHandler(type:String, data:* = null):void
		{
			switch (type) {
				case "COMPLETE":
					TEvent.removeTrigger(_url, __triggerHandler);
					_isLoaded = true;
					if (_isClear == true) return;
					clearView();
					addChild(new Bitmap(data[1] as BitmapData));
					__setSize();
					_url = null;
					break;
				case "IO_ERROR":
					TEvent.removeTrigger(_url, __triggerHandler);
					_isLoaded = true;
					if (_isClear == true) return;
					clear();
					_url = null;
					break;
				case "CLOSE":
					if (null != _swfLoader) {
						_swfLoader.clear();
						_swfLoader = null;
					}
					break;
				case "CLEAR":
					if (null != _swfLoader) {
						_swfLoader.clear();
						_swfLoader = null;
					}
					clear();
					_url = null;
					break;
			}
			type = null;
			data = null;
		}
		
		override public function clear():void
		{
			if (null != _url) TEvent.removeTrigger(_url, __triggerHandler);
			var swfLoader:SwfLoader = _swfLoader;
			_swfLoader = null;
			super.clear();
			if (null != swfLoader) {
				_swfLoader = swfLoader;
				swfLoader = null;
			}
			else if (null != _url) {
				_url = null;
			}
		}
		
	}
}