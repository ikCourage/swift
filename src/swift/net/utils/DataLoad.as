package swift.net.utils
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import org.aisy.net.data.UByteArray;
	
	import swift.core.swift_internal;
	import swift.net.assets.AssetStream;
	import swift.net.assets.AssetStreamEvent;
	import swift.net.assets.AssetsCacheEnum;
	import swift.net.assets.AssetsManager;
	
	use namespace swift_internal;

	public class DataLoad
	{
		static swift_internal var checkURLRequest:Function = __checkURLRequest;
		
		/**
		 * 
		 * @param callback
		 * @param url (String or URLRequest or Array, [url, type, key])
		 * @param urlVariables
		 * @param dataType （0：JSON，1：XML，2：字符串）
		 * @param method
		 * 
		 */
		static public function load(callback:Function, url:Object, urlVariables:Object = null, dataType:Object = 0, method:String = URLRequestMethod.POST):void
		{
			var t:Object, k:Object;
			if (url is String) {
				t = url;
				k = Math.random();
			}
			else if (url is Array) {
				t = url.length > 1 ? url[1] : url[0];
				k = url.lehgth > 2 ? url[2] : Math.random();
			}
			else if (url is URLRequest) {
				t = url.url;
				k = Math.random();
			}
			var f:Function = function (e:Event):void
			{
				var arr:Array;
				switch (e.type) {
					case AssetStreamEvent.COMPLETE:
						arr = [(e as AssetStreamEvent).getAsset(), t, e];
						break;
					case IOErrorEvent.IO_ERROR:
						trace(String(DataLoad), (e as IOErrorEvent).text);
						AssetsManager.remove(k);
						arr = [null, t, e];
						break;
				}
				
				if (null !== callback) {
					callback.apply(null, arr.slice(0, callback.length));
					callback = null;
					t = null;
				}
				arr = null;
				e = null;
				f = null;
				t = null;
				k = null;
			};
			
			var urlRrequest:URLRequest;
			if (url is URLRequest) {
				urlRrequest = url as URLRequest;
			}
			else {
				urlRrequest = new URLRequest();
				urlRrequest.url = url is String ? url as String : url[0];
			}
			urlRrequest.method = method;
			
			var v:URLVariables;
			if (urlVariables is URLVariables) {
				v = urlVariables as URLVariables;
			}
			else {
				v = new URLVariables();
				if (urlVariables is String) {
					v.decode(urlVariables as String);
				}
				else {
					for (var i:String in urlVariables) {
						v[i] = urlVariables[i];
					}
				}
			}
			urlRrequest.data = v;
			if (null !== checkURLRequest) checkURLRequest(urlRrequest);
			
			var request:Object = AssetsManager.getRequest(null, urlRrequest, k, false, AssetsCacheEnum.DESTROY_ALL);
			
			var assetStream:AssetStream = AssetsManager.getCache(request, dataType is Function ? dataType as Function : function (ubyteArray:UByteArray, callback:Function):Object
			{
				var str:String = ubyteArray.toString();
				var obj:Object;
				switch (dataType) {
					case 0:
						obj = JS.parse(str);
						break;
					case 1:
						obj = new XML(str);
						break;
					case 2:
						obj = str;
						break;
				}
				ubyteArray.clear();
				callback(obj);
				ubyteArray = null;
				str = null;
				callback = null;
				return null;
			}) as AssetStream;
			assetStream.addEventListener(AssetStreamEvent.COMPLETE, f);
			assetStream.addEventListener(IOErrorEvent.IO_ERROR, f);
			
			v = null;
			urlRrequest = null;
			request = null;
			assetStream = null;
			url = null;
			urlVariables = null;
			method = null;
		}
		
		static protected function __checkURLRequest(urlRequest:URLRequest):void
		{
			urlRequest.data["rnd"] = (new Date()).time.toString().substr(0, 10);
			urlRequest = null;
		}
		
	}
}