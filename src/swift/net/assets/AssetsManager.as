package swift.net.assets
{
	import flash.net.URLRequest;

	public class AssetsManager extends AssetsCache
	{
		static protected var instance:AssetsManager;
		
		public function AssetsManager()
		{
		}
		
		static public function put(key:Object, asset:Object, useWeakReference:Boolean = false):void
		{
			getInstance().put(key, asset, useWeakReference);
			key = null;
			asset = null;
		}
		
		static public function get(key:Object, useWeakReference:Boolean = false):Object
		{
			return getInstance().get(key, useWeakReference);
		}
		
		static public function remove(key:Object, useWeakReference:Boolean = false, destroy:int = AssetsCacheEnum.DESTROY_ALL):void
		{
			getInstance().remove(key, useWeakReference, destroy);
			key = null;
		}
		
		static public function has(key:Object, useWeakReference:Boolean = false):Boolean
		{
			return getInstance().has(key, useWeakReference);
		}
		
		static public function getCache(request:Object, parser:Function = null, type:int = 1, bufferMax:int = 0, override:Boolean = false):Object
		{
			return getInstance().getCache(request, parser, type, bufferMax, override);
		}
		
		static public function getRequest(url:String = null, request:URLRequest = null, key:Object = null, useWeakReference:Boolean = false, destroy:int = AssetsCacheEnum.DESTROY_AUTO_DEFAULT, pack:Boolean = false, sUrl:String = null, sRequest:URLRequest = null, sKey:Object = null, sUseWeakReference:Boolean = false, sDestroy:int = AssetsCacheEnum.DESTROY_AUTO_DEFAULT):Object
		{
			return getInstance().getRequest(url, request, key, useWeakReference, destroy, pack, sUrl, sRequest, sKey, sUseWeakReference, sDestroy);
		}
		
		static public function clear():void
		{
			if (null !== instance) {
				instance.clear();
				instance = null;
			}
		}
		
		static protected function getInstance():AssetsManager
		{
			return null === instance ? instance = new AssetsManager() : instance;
		}
	}
}