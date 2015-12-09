package swift.net.media
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.utils.ByteArray;
	
	import org.aisy.net.media.USocket;
	import org.aisy.utimer.UTimer;

	public class CUSocket extends USocket
	{
		protected var _host:String;
		protected var _port:int;
		protected var _reConnectDelay:Number;
		/**
		 * SocketData 回调函数
		 */
		protected var _socketDataF:Function;
		/**
		 * 是否读取过头
		 */
		protected var _readedHead:Boolean;
		/**
		 * 头信息长度
		 */
		protected var _headLen:int;
		/**
		 * 数据内容长度
		 */
		protected var _msgLen:int;
		/**
		 * 数据缓存
		 */
		protected var _buffer:ByteArray;
		/**
		 * 重连计时器
		 */
		protected var _utimer:UTimer;
		
		public function CUSocket(host:String = null, port:int = 0)
		{
			_headLen = 4;
			_reConnectDelay = 10000;
			super(host, port);
			host = null;
		}
		
		override public function connect(host:String, port:int):void
		{
			_host = host;
			_port = port;
			__addEvent();
			super.connect(_host, _port);
			host = null;
		}
		
		/**
		 * 
		 * 设置 SocketData 回调函数
		 * @param value
		 * 
		 */
		public function setDataCallback(value:Function):void
		{
			_socketDataF = value;
			value = null;
		}
		
		public function setReConnectDelay(value:Number):void
		{
			_reConnectDelay = value;
		}
		
		/**
		 * 
		 * 注册事件侦听
		 * 
		 */
		protected function __addEvent():void
		{
			addEventListener(Event.CONNECT, __eventHandler);
			addEventListener(Event.CLOSE, __eventHandler);
			addEventListener(IOErrorEvent.IO_ERROR, __eventHandler);
			addEventListener(SecurityErrorEvent.SECURITY_ERROR, __eventHandler);
			addEventListener(ProgressEvent.SOCKET_DATA, __eventHandler);
		}
		
		/**
		 * 
		 * 重建连接
		 * 
		 */
		protected function __reConnect():void
		{
			if (null != _utimer) {
				_utimer.clear();
				_utimer = null;
			}
			var h:String = _host;
			var p:int = _port;
			var f:Function = _socketDataF;
			clear();
			setDataCallback(f);
			connect(h, p);
			h = null;
			f = null;
		}
		
		/**
		 * 
		 * 定时重建连接
		 * 
		 */
		protected function __utimerConnect():void
		{
			if (null != _utimer) {
				_utimer.clear();
				_utimer = null;
			}
			_utimer = new UTimer();
			_utimer.setComplete(__utimerHandler);
			_utimer.setDelay(_reConnectDelay);
			_utimer.setRepeatCount(1);
			_utimer.start();
		}
		
		/**
		 * 
		 * UTimer 侦听
		 * 
		 */
		protected function __utimerHandler():void
		{
			_utimer = null;
			__reConnect();
		}
		
		/**
		 * 
		 * 事件侦听
		 * @param e
		 * 
		 */
		protected function __eventHandler(e:Event):void
		{
			switch (e.type) {
				case ProgressEvent.SOCKET_DATA:
					__parseSocketData();
					break;
				case Event.CONNECT:
					_buffer = new ByteArray();
					break;
				case Event.CLOSE:
					clear();
					break;
				case IOErrorEvent.IO_ERROR:
				case SecurityErrorEvent.SECURITY_ERROR:
					__utimerConnect();
					break;
			}
			e = null;
		}
		
		/**
		 * 
		 * 分析 Socket 数据
		 * 
		 */
		protected function __parseSocketData():void
		{
			//如果还没有读过头
			while (_readedHead === false && bytesAvailable >= _headLen) {
				_buffer.clear();
				_readedHead = true;
				_msgLen = readInt();
			}
			if (_readedHead === true) {
				//数据流里的数据满足条件，开始读数据
				if (bytesAvailable >= _msgLen) {
					readBytes(_buffer, _buffer.bytesAvailable, _msgLen);
					if (null !== _socketDataF) {
						var b:ByteArray = new ByteArray();
						b.writeBytes(_buffer);
						b.position = 0;
						_socketDataF(b);
						b = null;
					}
					if (null !== _buffer) {
						_buffer.clear();
						_readedHead = false;
						if (bytesAvailable >= _headLen) {
							__parseSocketData();
						}
					}
				}
				else {
					_msgLen -= bytesAvailable;
					readBytes(_buffer, _buffer.bytesAvailable);
				}
			}
		}
		
		override public function close():void
		{
			_host = null;
			_socketDataF = null;
			if (null !== _buffer) {
				_buffer.clear();
				_buffer = null;
			}
			if (null != _utimer) {
				_utimer.clear();
				_utimer = null;
			}
			super.close();
		}
		
	}
}