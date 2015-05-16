package swift.net.media
{
	import flash.events.NetStatusEvent;
	import flash.net.NetConnection;
	
	import org.ais.event.TEvent;
	import org.aisy.net.media.UNetStream;
	import org.aisy.utimer.UTimer;

	internal class ReceiveUNetStream extends UNetStream
	{
		public var NAME:String;
		protected var _uTimer:UTimer;
		protected var _close:Boolean;
		
		public function ReceiveUNetStream(connection:NetConnection, peerID:String = "connectToFMS", timeOut:Number = 4000)
		{
			NAME = Math.random().toString();
			
			super(connection, peerID);
			
			addEventListener(NetStatusEvent.NET_STATUS, __netStatusHandler);
			
			_uTimer = new UTimer();
			_uTimer.setRepeatCount(1);
			_uTimer.setDelay(timeOut);
			_uTimer.setComplete(__uTimerHandler);
			_uTimer.start();
			
			connection = null;
			peerID = null;
		}
		
		protected function __netStatusHandler(e:NetStatusEvent):void
		{
			removeEventListener(e.type, __netStatusHandler);
			if (_close === false) {
				TEvent.trigger(NAME, UNetWorkGroupEvent.RECEIVE_CONNECT_SUCCESS, this);
				clear();
			}
			e = null;
		}
		
		protected function __uTimerHandler():void
		{
			TEvent.trigger(NAME, UNetWorkGroupEvent.RECEIVE_TIME_OUT, this);
			clear();
		}
		
		protected function clearUTimer():void
		{
			if (null !== _uTimer) {
				_uTimer.clear();
				_uTimer = null;
			}
		}
		
		override public function close():void
		{
			_close = true;
			super.close();
			TEvent.trigger(NAME, UNetWorkGroupEvent.RECEIVE_CLOSE, this);
		}
		
		override public function clear():void
		{
			super.clear();
			clearUTimer();
			TEvent.clearTrigger(NAME);
			NAME = null;
		}
		
	}
}