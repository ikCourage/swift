package swift.net.media
{
	import flash.net.NetConnection;
	import flash.net.NetStream;
	
	import org.ais.event.TEvent;
	import org.aisy.net.media.UNetStream;
	import org.aisy.utimer.UTimer;

	internal class OUNetStream extends UNetStream
	{
		public var NAME:String;
		protected var _uTimer:UTimer;
		
		public function OUNetStream(connection:NetConnection, peerID:String = "connectToFMS", timeOut:Number = 4000)
		{
			NAME = Math.random().toString();
			
			super(connection, peerID);
			
			client = {
				"onPeerConnect": __onPeerConnect
			};
			
			_uTimer = new UTimer();
			_uTimer.setRepeatCount(1);
			_uTimer.setDelay(timeOut);
			_uTimer.setComplete(__uTimerHandler);
			_uTimer.start();
			
			connection = null;
			peerID = null;
		}
		
		protected function __onPeerConnect(netStream:NetStream):Boolean
		{
			if (null !== _uTimer) {
				_uTimer.stop();
				_uTimer.reset();
			}
			else {
				_uTimer = new UTimer();
			}
			_uTimer.setRepeatCount(1);
			_uTimer.setDelay(0);
			_uTimer.setComplete(__onPeerConnect2);
			_uTimer.start();
			netStream = null;
			return true;
		}
		
		protected function __onPeerConnect2():void
		{
			clearUTimer();
			TEvent.trigger(NAME, UNetWorkGroupEvent.OUT_CONNECT_SUCCESS, this);
		}
		
		protected function __uTimerHandler():void
		{
			TEvent.trigger(NAME, UNetWorkGroupEvent.OUT_TIME_OUT, this);
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
			super.close();
			TEvent.trigger(NAME, UNetWorkGroupEvent.OUT_CLOSE, this);
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