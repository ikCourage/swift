package swift.net.media
{
	import flash.events.NetStatusEvent;
	import flash.net.GroupSpecifier;
	import flash.net.NetConnection;
	import flash.net.NetGroup;
	
	import org.ais.event.TEvent;
	import org.aisy.interfaces.IClear;
	import org.aisy.net.media.UNetConnection;

	public class LanGroup implements IClear
	{
		public var NAME:String;
		protected var _netConnection:NetConnection;
		protected var _netGroup:NetGroup;
		
		protected var _groupName:String;
		protected var _address:String;
		protected var _port:*;
		protected var _source:String;
		
		public function LanGroup(name:String = null)
		{
			NAME = name !== null ? name : Math.random().toString();
		}
		
		public function connect(groupName:String, address:String = "225.225.0.1:30303", port:* = null, source:String = null):void
		{
			_groupName = groupName;
			_address = address;
			_port = port;
			_source = source;
			_netConnection = new UNetConnection();
			_netConnection.addEventListener(NetStatusEvent.NET_STATUS, __netStatusHandler);
			_netConnection.connect("rtmfp:");
			groupName = null;
			address = null;
			port = null;
			source = null;
			TEvent.newTrigger(NAME, function (e:NetStatusEvent):void
			{
				switch (e.info["code"]) {
					case "NetConnection.Connect.Success":
						initNetGroup();
						break;
				}
			});
		}
		
		public function getNetConnection():NetConnection
		{
			return _netConnection;
		}
		
		public function getNetGroup():NetGroup
		{
			return _netGroup;
		}
		
		protected function initNetGroup():void
		{
			var _groupSpec:GroupSpecifier = new GroupSpecifier(_groupName);
			_groupSpec.routingEnabled = true;
			_groupSpec.postingEnabled = true;
			_groupSpec.multicastEnabled = true;
			_groupSpec.ipMulticastMemberUpdatesEnabled = true;
			_groupSpec.addIPMulticastAddress(_address, _port, _source);
			
			_netGroup = new NetGroup(_netConnection, _groupSpec.groupspecWithAuthorizations());
			_netGroup.addEventListener(NetStatusEvent.NET_STATUS, __netStatusHandler);
			_groupSpec = null;
		}
		
		protected function __netStatusHandler(e:NetStatusEvent):void
		{
			switch (e.info["code"]) {
//				case "NetGroup.Posting.Notify":
//					trace(e.info.message);
//					break;
//				case "NetConnection.Connect.Success":
//					initNetGroup();
//					break;
//				case "NetGroup.Connect.Success":
//					_isConnected = true;
//					break;
			}
			TEvent.trigger(NAME, e);
			e = null;
		}
		
		public function clear():void
		{
			if (null !== _netConnection) {
				_netConnection.removeEventListener(NetStatusEvent.NET_STATUS, __netStatusHandler);
				_netConnection.close();
			}
			if (null !== _netGroup) {
				_netGroup.removeEventListener(NetStatusEvent.NET_STATUS, __netStatusHandler);
				_netGroup.close();
				_netGroup = null;
			}
			TEvent.clearTrigger(NAME);
			_netConnection = null;
			_groupName = null;
			_address = null;
			_port = null;
			_source = null;
			NAME = null;
		}
		
	}
}