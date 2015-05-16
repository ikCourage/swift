package 
{
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;
	
	import org.ais.event.TEvent;
	import org.aisy.net.media.UNetConnection;
	import org.aisy.net.media.UNetStream;
	import org.aisy.utimer.UTimer;
	
	import swift.controller.cli.Console;
	import swift.core.shell.Shell;
	import swift.net.media.UNetWorkGroup;
	import swift.net.media.UNetWorkGroupEvent;
	import swift.utils.base.Formatter;

	public class Shell_nt extends Shell
	{
		static public const COMMAND:String = "nt";
		static public const IO:String = "-" + _IO;
		
		static protected const _IO:String = "io";
		
		protected var _peerID:String;
		
		protected var _utimer:UTimer;
		
		private var _rtmfp:Array;
		
		public function Shell_nt()
		{
			name = command = COMMAND;
			option = [
				"c",
				"cl",
				_IO, 1,
				"cio", 2,
				"tio", 1,
				"p", 1,
				"s",
				"d",
				"i",
				"r"
			];
			description = "通信连接\n" +
				"    c 建立与服务器的连接\n" +
				"    cl 关闭所有连接\n" +
				"    io 与对方建立连接 参数为对方的 PeerID 示例：nt -io PeerID\n" +
				"    cio 关闭通信连接 可选参数为 0: 关闭所有对外频道  1: 关闭所有接入频道  2: 关闭所有双向频道\n" +
				"    p 将要通信的人的 PeerID（这里只做为与对方进行对话）\n" +
				"    s 与对方进行对话\n" +
				"    tio 测试建立连接\n" +
				"    r 设置 rtmfp 地址"
			callback = __exec;
		}
		
		protected function __exec(str:String, args:Vector.<Array>):Object
		{
			for (var i:uint = 0, len:uint = args[1].length; i < len; i++) {
				switch (args[1][i][0]) {
					case "c":
						__c();
						break;
					case "cl":
						__cl();
						break;
					case _IO:
						if (null !== GUNetWorkGroup) {
							__cexec("print", getTime(), ">> io");
							_peerID = String(args[1][i][1]);
							var uNetStream:UNetStream = GUNetWorkGroup.getInUNetStreamByPeerID(_peerID);
							if (null !== uNetStream) {
								GUNetWorkGroup.removeUNetStream(uNetStream);
							}
							uNetStream = GUNetWorkGroup.getOutUNetStreamByPeerID(_peerID);
							if (null !== uNetStream) {
								GUNetWorkGroup.removeUNetStream(uNetStream);
							}
							uNetStream = GUNetWorkGroup.getReceiveUNetStreamByPeerID(_peerID);
							if (null !== uNetStream) {
								GUNetWorkGroup.removeUNetStream(uNetStream);
							}
							uNetStream = null;
							GUNetWorkGroup.addReceiveUNetStream("~", _peerID, 1);
						}
						break;
					case "cio":
						if (null !== GUNetWorkGroup) {
							switch (args[1][i][1]) {
								case "0":
									GUNetWorkGroup.clearOutUNetStream();
									break;
								case "1":
									GUNetWorkGroup.clearInUNetStream();
									break;
								default:
									GUNetWorkGroup.clearOutUNetStream();
									GUNetWorkGroup.clearInUNetStream();
									break;
							}
						}
						break;
					case "p":
						_peerID = String(args[1][i][1]);
						break;
					case "s":
						if (null !== GUNetWorkGroup) {
							if (null === _peerID) {
								str = null;
								args = null;
								return new Error("no peerID");
							}
							else if (args[0].length !== 0) {
								GUNetWorkGroup.sendToPeer.apply(null, [_peerID, UNetWorkGroupEvent.AT, "::"].concat(args[0]));
							}
						}
						break;
					case "d":
						if (null !== GUNetWorkGroup) {
							if (null === _peerID) {
								str = null;
								args = null;
								return new Error("no peerID");
							}
							else if (args[0].length !== 0) {
								GUNetWorkGroup.sendToPeer.apply(null, [_peerID, UNetWorkGroupEvent.AT, "d"].concat(args[0]));
							}
						}
						break;
					case "tio":
						if (null !== GUNetWorkGroup) {
							TEvent.newTrigger(GUNetWorkGroup.NAME, function (type:String, data:Object = null):void
							{
								switch (type) {
									case UNetWorkGroupEvent.IO_CONNECT_SUCCESS:
										__cexec("print", getTime(), ">> test success, say hello");
										GUNetWorkGroup.sendToPeer(String(data[1]), UNetWorkGroupEvent.AT, "::", "hello");
										TEvent.removeTrigger(GUNetWorkGroup.NAME, arguments.callee);
										break;
									case UNetWorkGroupEvent.IO_CONNECT_FAILED:
										__cexec("print", getTime(), ">> test failed");
										TEvent.removeTrigger(GUNetWorkGroup.NAME, arguments.callee);
										break;
								}
								type = null;
								data = null;
							});
							_peerID = String(args[1][i][1]);
							uNetStream = GUNetWorkGroup.getInUNetStreamByPeerID(_peerID);
							if (null !== uNetStream) {
								GUNetWorkGroup.removeUNetStream(uNetStream);
							}
							uNetStream = GUNetWorkGroup.getOutUNetStreamByPeerID(_peerID);
							if (null !== uNetStream) {
								GUNetWorkGroup.removeUNetStream(uNetStream);
								uNetStream = null;
							}
							__cexec(COMMAND, IO, _peerID);
						}
						break;
					case "i":
						if (null !== GUNetWorkGroup && GUNetWorkGroup.getUNetConnection().connected !== false) {
							Console.executor = String(this);
							Console.exec("print", "ID:", GUNetWorkGroup.getUNetConnection().nearID);
						}
						break;
					case "r":
						if (args[0].length > 0) {
							_rtmfp = args[0];
							__c();
						}
						else {
							return new Error("no rtmfp address");
						}
						break;
				}
			}
			str = null;
			args = null;
			return null;
		}
		
		/**
		 * 开始连接
		 */
		protected function __c():void
		{
			__cl();
			if (null == _rtmfp || _rtmfp.length == 0) {
				__cexec("print no rtmfp address");
				return;
			}
			var uNetConnection:UNetConnection = new UNetConnection();
			var t:Number = 1000 * 4;
			GUNetWorkGroup = new UNetWorkGroup();
			GUNetWorkGroup.setOutTimeOut(t);
			GUNetWorkGroup.setInTimeOut(t);
			GUNetWorkGroup.setReceiveTimeOut(t);
			GUNetWorkGroup.setUNetConnection(uNetConnection);
			GUNetWorkGroup.setPublishUNetStreamPeerConnect(true);
			TEvent.newTrigger(GUNetWorkGroup.NAME, __netWorkGroupHandler);
			uNetConnection.connect.apply(null, _rtmfp);
			__initUTimer(1);
			uNetConnection = null;
		}
		
		/**
		 * 清空连接
		 */
		protected function __cl():void
		{
			//这里一定要这么写
			//在 clear 之前要将 GUnetWorkGroup 置空
			if (null !== GUNetWorkGroup) {
				TEvent.removeTrigger(GUNetWorkGroup.NAME, __netWorkGroupHandler);
				var uNetWorkGroup:UNetWorkGroup = GUNetWorkGroup;
				GUNetWorkGroup = null;
				uNetWorkGroup.clear();
				uNetWorkGroup = null;
			}
		}
		
		/**
		 * UNetWorkGroup 侦听
		 * @param type
		 * @param data
		 */
		protected function __netWorkGroupHandler(type:String, data:Object = null):void
		{
			switch (type) {
//				NetConnection NetStream 的侦听
				case NetStatusEvent.NET_STATUS:
					__netStatusHandler(NetStatusEvent(data));
					break;
//				当公共频道收到连接请求时　尝试与其建立连接
				case UNetWorkGroupEvent.PUBLISH_PEER_CONNECT:
//					获取对方的 PeerID
					var peerID:String = NetStream(data).farID;
//					如果之前存在与其的连接　则断开并清空（如果需要保证每个人只有一个对应连接的话）
					var uNetStream:UNetStream = GUNetWorkGroup.getInUNetStreamByPeerID(peerID);
					if (null !== uNetStream) {
						GUNetWorkGroup.removeUNetStream(uNetStream);
					}
					uNetStream = GUNetWorkGroup.getOutUNetStreamByPeerID(peerID);
					if (null !== uNetStream) {
						GUNetWorkGroup.removeUNetStream(uNetStream);
						uNetStream = null;
					}
					__cexec("print", getTime(), "|| publish peer connect");
//					尝试与其建立连接（利用此方法可以不通过服务器转发就可以建立连接，但服务器转发在某些情况下依然有用，如：无法穿透等）
//					对方会以自己的 PeerID 作为频道的名字　所以把自己的 PeerID 作为接收频道的名字
//					对方同时会尝试以对方的 PeerID 作为接收频道的名字　所以把对方的 PeerID 作为频道的名字
//					例如：B 先连接 A 的公共频道
//					A 收到 PUBLISH_PEER_CONNECT，同时 B 收到 RECEIVE_CONNECT_SUCCESS
//					A 尝试向 B 接收名字为 A_PeerID 的频道（有超时机制），同时 B 开通名字为 A_PeerID 的频道
//					A 接收成功 B 的频道
//					A 开通名字为 B_PeerID 的频道，同时 B 尝试向 A 接收名字为 B_PeerID 的频道
//					B 接收成功 A 的频道
//					此时双向通信连接成功
					GUNetWorkGroup.addIOUNetstream(GUNetWorkGroup.getUNetConnection().nearID, peerID, null, 1, 0);
					peerID = null;
					break;
//				当与其他人的公共频道连接成功时　尝试与其建立连接
				case UNetWorkGroupEvent.RECEIVE_CONNECT_SUCCESS:
					__cexec("print", getTime(), "|| receive connect success");
//					尝试与其建立连接
					GUNetWorkGroup.addIOUNetstream(GUNetWorkGroup.getUNetConnection().nearID, NetStream(data).farID, null, 1, 1);
					break;
//				双向通信连接成功 data 为 [inName, outName, peerID, inUNetStream, outUNetStream]
				case UNetWorkGroupEvent.IO_CONNECT_SUCCESS:
					__cexec("print", getTime(), "|| io connect success");
//					侦听接收频道的内容　即对方发过来的消息
					TEvent.newTrigger(data[3]["NAME"], __iUNetStreamHandler);
//					最后一个连接成功的人的 PeerID
					if (null == _peerID || GUNetWorkGroup.hasInUNetStreamByPeerID(_peerID) == -1) {
						_peerID = data[2];
					}
					break;
//				双向通信连接失败
				case UNetWorkGroupEvent.IO_CONNECT_FAILED:
					Console.executor = String(this);
					Console.print("io connect failed");
					__cexec("print", getTime(), "|| io connect failed");
					break;
				case UNetWorkGroupEvent.RECEIVE_CONNECT_FAILED:
					Console.executor = String(this);
					Console.print("receive connect failed");
					__cexec("print", getTime(), "|| receive connect failed");
					break;
				default:
					__cexec("print", getTime(), "******", type, data);
					break;
			}
			type = null;
			data = null;
		}
		
		protected function __netStatusHandler(e:NetStatusEvent):void
		{
			__cexec("print", getTime(), e.info["code"], e.target, e.currentTarget);
			switch (e.info["code"]) {
				case "NetConnection.Connect.Success":
					__initUTimer();
					if (null === GUNetWorkGroup || GUNetWorkGroup.getUNetConnection().connected === false) return;
					Console.executor = String(this);
					Console.exec("print", "ID:", GUNetWorkGroup.getUNetConnection().nearID);
//					公共频道
					var uNetStream:UNetStream = new UNetStream(GUNetWorkGroup.getUNetConnection(), NetStream.DIRECT_CONNECTIONS);
					uNetStream.publish("~");
					GUNetWorkGroup.setPublishUNetStream(uNetStream);
					uNetStream = null;
					break;
				case "NetStream.Connect.Closed":
//					外部的连接关闭
//					可能是与公共频道的连接（此时只是尝试而已）
//					也可能是对方断开通信频道
					__cexec("print", getTime(), "hasPublish", e.info["stream"]);
					__cexec("print", getTime(), "hasPublish", GUNetWorkGroup.hasPublishNetStreamByNetStream(NetStream(e.info["stream"])));
					__cexec("print", getTime(), "hasOut", GUNetWorkGroup.hasOutUNetStreamByNetStream(NetStream(e.info["stream"])));
					break;
				case "NetConnection.Connect.Closed":
				case "NetConnection.Connect.Failed":
//					重新连接
					__c();
					break;
			}
			e = null;
		}
		
		/**
		 * 从对方收到的消息　根据类型执行对应的方法
		 * 此处示例为输出收到的消息
		 * @param type
		 * @param uNetStream
		 * @param data
		 */
		protected function __iUNetStreamHandler(type:String, uNetStream:UNetStream, data:Object = null):void
		{
			switch (type) {
				case UNetWorkGroupEvent.AT:
					switch (data[0]) {
						case "d":
							__cexec.apply(null, ["print", getTime(), type].concat(data));
							__cexec(data.slice(1).join(" ").replace(/^\'|\'$/, ""));
							break;
						default:
							__cexec.apply(null, ["print", getTime(), type].concat(data));
							break;
					}
					break;
				default:
					__cexec.apply(null, ["print", getTime(), type].concat(data));
					break;
			}
		}
		
		/**
		 * 超时重新连接
		 */
		protected function __initUTimer(type:int = 0):void
		{
			if (null !== _utimer) {
				_utimer.clear();
				_utimer = null;
			}
			if (type === 1) {
				_utimer = new UTimer();
				_utimer.setRepeatCount(1);
				_utimer.setDelay(1000 * 10);
				_utimer.setComplete(__utimerHandler);
				_utimer.start();
			}
		}
		
		/**
		 * 超时重新连接
		 */
		protected function __utimerHandler():void
		{
			__cexec("print", getTime(), "|| netconnection time out");
			__c();
		}
		
		protected function getTime():Object
		{
			return Formatter.DateFormat(new Date(), "[MM-DD HH:NN:SS:RRR]");
		}
		
		protected function __cexec(...parameters):*
		{
			Console.executor = String(this);
			return Console.exec.apply(null, parameters);
			return null;
		}
		
	}
}