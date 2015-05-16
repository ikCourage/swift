package swift.view.core
{
	import flash.display.BitmapData;
	
	import org.aisy.interfaces.IClear;
	
	import swift.core.swift_internal;
	import swift.net.assets.AssetStream;
	import swift.net.assets.AssetStreamEvent;
	import swift.net.assets.AssetsManager;
	import swift.utils.assets.parser.ParserUtil;
	import swift.utils.assets.parser.Parser_com;
	
	use namespace swift_internal;

	internal class Flag implements IClear
	{
		public var name:String;
		public var key:String;
		public var src:String;
		public var frameStart:uint;
		public var frameEnd:uint;
		public var bitmapData:BitmapData;
		
		public function Flag(data:Object)
		{
			if (null !== data) {
				var voMap:Vector.<Vector.<String>> = Vector.<Vector.<String>>([
					Vector.<String>(["name"]),
					Vector.<String>(["k", "key"]),
					Vector.<String>(["s", "src"])
				]);
				ParserUtil.assignData(data, this, voMap);				
				voMap = null;
				data = null;
			}
		}
		
		swift_internal function set k(value:String):void
		{
			if (value) {
				key = value;
				var asset:Object = AssetsManager.get(key);
				if (asset is AssetStream) AssetStream(asset).addEventListener(AssetStreamEvent.COMPLETE, __assetStreamHandler);
				else if (asset is BitmapData) bitmapData = asset as BitmapData;
				asset = null;
			}
			value = null;
		}
		
		swift_internal function set s(value:String):void
		{
			if (value) {
				src = value;
				if (null === bitmapData) {
					var asset:Object = AssetsManager.getCache(AssetsManager.getRequest(src, null, key), Parser_com.parseBitmapData);
					if (asset is AssetStream) AssetStream(asset).addEventListener(AssetStreamEvent.COMPLETE, __assetStreamHandler);
					else if (asset is BitmapData) bitmapData = asset as BitmapData;
					asset = null;
				}
			}
			value = null;
		}
		
		protected function __assetStreamHandler(e:AssetStreamEvent):void
		{
			bitmapData = e.getAsset() as BitmapData;
			e = null;
		}
		
		public function clear():void
		{
			name = null;
			key = null;
			src = null;
			bitmapData = null;
		}
		
	}
}