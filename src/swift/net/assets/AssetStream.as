package swift.net.assets
{
	import flash.events.Event;
	import flash.net.URLRequest;
	
	import org.aisy.net.data.UByteArray;
	import org.aisy.net.utils.DataStream;
	
	[Event(name="ASSET_COMPLETE", type="swift.net.assets.AssetStreamEvent")]

	public class AssetStream extends DataStream
	{
		protected var _parser:Function;
		protected var _type:int;
		protected var _bufferMax:int;
		
		public function AssetStream()
		{
		}
		
		protected function __assetComplete(asset:Object):void
		{
			dispatchEvent(new AssetStreamEvent(AssetStreamEvent.COMPLETE, false, false, asset));
			asset = null;
		}
		
		protected function __completeHandler(e:Event):void
		{
			removeEventListener(Event.COMPLETE, __completeHandler);
			var ubyteArray:UByteArray = new UByteArray(_type);
			if (_bufferMax !== 0) ubyteArray.setBufferMax(_bufferMax);
			readBytes(ubyteArray, 0, bytesAvailable);
			var asset:Object = null === _parser ? ubyteArray : _parser.apply(null, [ubyteArray, __assetComplete].slice(0, _parser.length));
			if (null !== asset) __assetComplete(asset);
			asset = null;
			ubyteArray = null;
			e = null;
		}
		
		override public function load(request:URLRequest):void
		{
			removeEventListener(Event.COMPLETE, __completeHandler);
			addEventListener(Event.COMPLETE, __completeHandler);
			super.load(request);
			request = null;
		}
		
		public function getType():int
		{
			return _type;
		}
		
		public function getBufferMax():int
		{
			return _bufferMax;
		}
		
		public function setType(value:int):void
		{
			_type = value;
		}
		
		public function setBufferMax(value:int):void
		{
			_bufferMax = value;
		}
		
		public function setParser(parser:Function):void
		{
			_parser = parser;
			parser = null;
		}
		
		override public function clear():void
		{
			_parser = null;
			super.clear();
		}
		
		static public function getAssetStream(request:Object = null, parser:Function = null, type:int = 0, bufferMax:int = 0):AssetStream
		{
			var assetStream:AssetStream = new AssetStream();
			assetStream.setType(type);
			assetStream.setBufferMax(bufferMax);
			assetStream.setParser(parser);
			if (null !== request) assetStream.load(request is String ? new URLRequest(request as String) : request as URLRequest);
			request = null;
			parser = null;
			return assetStream;
		}
		
	}
}