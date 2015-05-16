package swift.net.assets
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.system.System;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import org.aisy.interfaces.IClear;
	

	public class AssetsCache implements IClear
	{
		protected var _cacheDictionary:Dictionary;
		protected var _cacheDictionaryWeakReference:Dictionary;
		
		public function AssetsCache()
		{
			_cacheDictionary = new Dictionary();
			_cacheDictionaryWeakReference = new Dictionary(true);
		}
		
		public function put(key:Object, asset:Object, useWeakReference:Boolean = false):void
		{
			(useWeakReference === true ? _cacheDictionaryWeakReference : _cacheDictionary)[key] = asset;
			key = null;
			asset = null;
		}
		
		public function get(key:Object, useWeakReference:Boolean = false):Object
		{
			if (has(key, useWeakReference) === false) return null;
			return (useWeakReference === true ? _cacheDictionaryWeakReference : _cacheDictionary)[key];
		}
		
		public function remove(key:Object, useWeakReference:Boolean = false, destroy:int = AssetsCacheEnum.DESTROY_ALL):void
		{
			var asset:Object = get(key, useWeakReference);
			if (null === asset) return;
			if (destroy === AssetsCacheEnum.DESTROY_ALL) {
				if (asset is IClear) IClear(asset).clear();
				else if (asset is ByteArray) ByteArray(asset).clear();
				else if (asset is BitmapData) BitmapData(asset).dispose();
				else if (asset is Bitmap) {
					if (null !== Bitmap(asset).parent) Bitmap(asset).parent.removeChild(Bitmap(asset));
					Bitmap(asset).bitmapData.dispose();
				}
				else if (asset is XML) System.disposeXML(XML(asset));
				else if (asset is Loader) {
					if (null !== Loader(asset).parent) Loader(asset).parent.removeChild(Loader(asset));
					Loader(asset).unload();
				}
				else if (asset.hasOwnProperty("clear") === true) asset.clear();
			}
			asset = null;
			delete (useWeakReference === true ? _cacheDictionaryWeakReference : _cacheDictionary)[key];
			key = null;
		}
		
		public function has(key:Object, useWeakReference:Boolean = false):Boolean
		{
			return (useWeakReference === true ? _cacheDictionaryWeakReference : _cacheDictionary).hasOwnProperty(key);
		}
		
		public function getCache(request:Object, parser:Function = null, type:int = 1, bufferMax:int = 0, override:Boolean = false):Object
		{
			var useWeakReference:Boolean, destroy:int = AssetsCacheEnum.DESTROY_DEFAULT, urlRequest:URLRequest, assetStream:AssetStream, asset:Object, pack:Object, key:Object;
			
			if (request is String) {
				key = request;
				urlRequest = new URLRequest(String(request));
			}
			else if (request is URLRequest) {
				urlRequest = URLRequest(request);
			}
			else {
				if (request.hasOwnProperty("key") === true) {
					key = request["key"];
				}
				if (request.hasOwnProperty("url") === true) {
					urlRequest = new URLRequest(String(request["url"]));
				}
				if (request.hasOwnProperty("request") === true) {
					urlRequest = URLRequest(request["request"]);
				}
				if (request.hasOwnProperty("useWeakReference") === true) {
					useWeakReference = Boolean(request["useWeakReference"]);
				}
				if (request.hasOwnProperty("destroy") === true) {
					destroy = int(request["destroy"]);
				}
				if (request.hasOwnProperty("parser") === true) {
					parser = Function(request["parser"]);
				}
				if (request.hasOwnProperty("type") === true) {
					type = int(request["type"]);
				}
				if (request.hasOwnProperty("bufferMax") === true) {
					bufferMax = int(request["bufferMax"]);
				}
				if (request.hasOwnProperty("override") === true) {
					override = Boolean(request["override"]);
				}
				
				if (request.hasOwnProperty("pack") === true) {
					pack = request["pack"];
				}
			}
			if (null === key) key = urlRequest.url;
			
			asset = get(key, useWeakReference);
			if (null !== asset) {
				if (override === false) {
					assetStream = null;
					key = null;
					urlRequest = null;
					pack = null;
					request = null;
					parser = null;
					return asset;
				}
				else if (asset is AssetStream) {
					assetStream = AssetStream(asset);
					assetStream.close();
					assetStream.setType(type);
					assetStream.setBufferMax(bufferMax);
					assetStream.setParser(parser);
					if (null === pack) assetStream.load(urlRequest);
					asset = null;
					key = null;
					urlRequest = null;
					pack = null;
					request = null;
					parser = null;
					return assetStream;
				}
				else {
//					彻底销毁
					remove(key, useWeakReference);
				}
			}
			assetStream = AssetStream.getAssetStream(null !== pack ? null : urlRequest, parser, type, bufferMax);
			assetStream.addEventListener(AssetStreamEvent.COMPLETE, function (e:AssetStreamEvent):void
			{
				if (destroy === AssetsCacheEnum.DESTROY_NONE) {
					put(key, e.getAsset(), useWeakReference);
				}
				else {
					remove(key, useWeakReference, destroy);
				}
				assetStream.clear();
				assetStream = null;
				e = null;
				key = null;
			}, false, int.MIN_VALUE);
			put(key, assetStream, useWeakReference);
			if (null !== pack) {
				getCache(pack, parser, type, bufferMax, override);
			}
			asset = null;
			urlRequest = null;
			pack = null;
			request = null;
			parser = null;
			return assetStream;
		}
		
		public function getRequest(url:String = null, request:URLRequest = null, key:Object = null, useWeakReference:Boolean = false, destroy:int = AssetsCacheEnum.DESTROY_AUTO_DEFAULT, pack:Boolean = false, sUrl:String = null, sRequest:URLRequest = null, sKey:Object = null, sUseWeakReference:Boolean = false, sDestroy:int = AssetsCacheEnum.DESTROY_AUTO_DEFAULT):Object
		{
			if (destroy === -1) destroy = AssetsCacheEnum.DESTROY_DEFAULT;
			if (sDestroy === -1) sDestroy = AssetsCacheEnum.DESTROY_DEFAULT;
			var obj:Object = {};
			if (null !== url) obj["url"] = url;
			if (null !== request) obj["request"] = request;
			if (null !== key) obj["key"] = key;
			obj["useWeakReference"] = useWeakReference;
			obj["destroy"] = destroy;
			if (pack === true) {
				obj["pack"] = {};
				if (null !== sUrl) obj["pack"]["url"] = sUrl;
				if (null !== sRequest) obj["pack"]["request"] = sRequest;
				if (null !== sKey) obj["pack"]["key"] = sKey;
				obj["pack"]["useWeakReference"] = sUseWeakReference;
				obj["pack"]["destroy"] = sDestroy;
			}
			url = null;
			request = null;
			key = null;
			sUrl = null;
			sRequest = null;
			sKey = null;
			return obj;
		}
		
		public function clear():void
		{
			for (var i:Object in _cacheDictionary) remove(i);
			for (i in _cacheDictionaryWeakReference) remove(i, true);
			_cacheDictionary = null;
			_cacheDictionaryWeakReference = null;
		}
		
	}
}