package swift.net.assets
{
	import flash.events.Event;

	public class AssetStreamEvent extends Event
	{
		static public const COMPLETE:String = "ASSET_COMPLETE";
		
		protected var _asset:Object;
		
		public function AssetStreamEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, asset:Object = null)
		{
			_asset = asset;
			super(type, bubbles, cancelable);
			type = null;
			asset = null;
		}
		
		public function getAsset():Object
		{
			return _asset;
		}
		
		override public function clone():Event
		{
			return new AssetStreamEvent(type, bubbles, cancelable, getAsset());
		}
		
	}
}