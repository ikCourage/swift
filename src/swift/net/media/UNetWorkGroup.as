package swift.net.media
{
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;
	
	import org.ais.event.TEvent;
	import org.aisy.interfaces.IClear;
	import org.aisy.net.media.UNetConnection;
	import org.aisy.net.media.UNetGroup;
	import org.aisy.net.media.UNetStream;

	public class UNetWorkGroup implements IClear
	{
		public var NAME:String;
		protected var _uNetConnection:UNetConnection;
		protected var _uNetGroup:UNetGroup;
		protected var _publishUNetStream:UNetStream;
		protected var _outUNetStreamV:Vector.<UNetStream>;
		protected var _inUNetStreamV:Vector.<UNetStream>;
		protected var _receiveUNetStreamV:Vector.<UNetStream>;
		protected var _publishNetStreamV:Vector.<NetStream>;
		protected var _connectedNetStreamV:Vector.<NetStream>;
		protected var _publishUNetStreamPeerConnect:Boolean;
		protected var _outTimeOut:Number;
		protected var _inTimeOut:Number;
		protected var _receiveTimeOut:Number;
		
		public function UNetWorkGroup(name:String = null)
		{
			NAME = name !== null ? name : Math.random().toString();
			
			_outTimeOut = _inTimeOut = _receiveTimeOut = 4000;
			
			name = null;
		}
		
		protected function __onRelay(...parameters):void
		{
			TEvent.trigger(NAME, "onRelay", parameters);
			parameters = null;
		}
		
		protected function __onPublishUNetStreamPeerConnect(netStream:NetStream):Boolean
		{
			if (null === _publishNetStreamV) _publishNetStreamV = new Vector.<NetStream>();
			_publishNetStreamV[_publishNetStreamV.length] = netStream;
			TEvent.trigger(NAME, UNetWorkGroupEvent.PUBLISH_PEER_CONNECT, netStream);
			netStream = null;
			return _publishUNetStreamPeerConnect;
		}
		
		protected function __netStatusHandler(e:NetStatusEvent):void
		{
//			switch (e.info["code"]) {
//				case "NetGroup.Posting.Notify":
//					trace(e.info.message);
//					break;
//				case "NetConnection.Connect.Success":
//					initNetGroup();
//					break;
//				case "NetGroup.Connect.Success":
//					_isConnected = true;
//					break;
//			}
			if (null === NAME) {
				e = null;
				return;
			}
			TEvent.trigger(NAME, e.type, e);
			switch (e.info["code"]) {
				case "NetStream.Connect.Success":
					var netStream:NetStream = e.info["stream"] as NetStream;
					if (null === _connectedNetStreamV) {
						_connectedNetStreamV = new Vector.<NetStream>();
						_connectedNetStreamV[0] = netStream;
					}
					else if (_connectedNetStreamV.indexOf(netStream) === -1) {
						_connectedNetStreamV[_connectedNetStreamV.length] = netStream;
					}
					netStream = null;
					break;
				case "NetStream.Connect.Closed":
					netStream = e.info["stream"] as NetStream;
					if (netStream is UNetStream) {
						removeUNetStream(netStream as UNetStream);
					}
					else {
						netStream.dispose();
						var i:int = hasPublishNetStreamByNetStream(netStream);
						if (i !== -1) {
							if (null !== _publishNetStreamV) {
								_publishNetStreamV.splice(i, 1);
								if (_publishNetStreamV.length === 0) {
									_publishNetStreamV = null;
								}
							}
							if (null !== _connectedNetStreamV) {
								i = _connectedNetStreamV.indexOf(netStream);
								if (i !== -1) {
									_connectedNetStreamV.splice(i, 1);
									if (_connectedNetStreamV.length === 0) {
										_connectedNetStreamV = null;
									}
								}
							}
						}
						else {
							if (null !== _connectedNetStreamV) {
								i = _connectedNetStreamV.indexOf(netStream);
								if (i !== -1) {
									_connectedNetStreamV.splice(i, 1);
									if (_connectedNetStreamV.length === 0) {
										_connectedNetStreamV = null;
									}
								}
							}
							if (i !== -1) {
								var uNetStream:UNetStream = getOutUNetStreamByNetStream(netStream);
								if (null !== uNetStream) {
									removeUNetStream(uNetStream);
									uNetStream = getInUNetStreamByPeerID(netStream.farID);
									if (null !== uNetStream) {
										removeUNetStream(uNetStream);
										uNetStream = null;
									}
								}
							}
						}
						if (netStream is UNetStream) {
							(netStream as UNetStream).clear();
						}
					}
					netStream = null;
					break;
				case "NetStream.Play.UnpublishNotify":
					netStream = e.target as NetStream;
					if (netStream is UNetStream) {
						uNetStream = e.target as UNetStream;
						removeUNetStream(uNetStream);
						uNetStream = getOutUNetStreamByPeerID(uNetStream.farID);
						if (null !== uNetStream) {
							removeUNetStream(uNetStream);
							uNetStream = null;
						}
					}
					else {
						netStream.dispose();
						if (null !== _connectedNetStreamV) {
							i = _connectedNetStreamV.indexOf(netStream);
							if (i !== -1) {
								_connectedNetStreamV.splice(i, 1);
								if (_connectedNetStreamV.length === 0) {
									_connectedNetStreamV = null;
								}
							}
						}
					}
					netStream = null;
					break;
				case "NetStream.Unpublish.Success":
				case "NetStream.Play.Stop":
					netStream = e.target as NetStream;
					if (netStream is UNetStream) {
						removeUNetStream(netStream as UNetStream);
						if (netStream is OUNetStream) {
							uNetStream = getInUNetStreamByPeerID(netStream.farID);
						}
						else if (netStream is IUNetStream) {
							uNetStream = getOutUNetStreamByPeerID(netStream.farID);
						}
						if (null !== uNetStream) {
							removeUNetStream(uNetStream);
							uNetStream = null;
						}
					}
					else {
						netStream.dispose();
						if (null !== _connectedNetStreamV) {
							i = _connectedNetStreamV.indexOf(netStream);
							if (i !== -1) {
								_connectedNetStreamV.splice(i, 1);
								if (_connectedNetStreamV.length === 0) {
									_connectedNetStreamV = null;
								}
							}
						}
					}
					netStream = null;
					break;
				case "NetConnection.Connect.Closed":
					clear();
					break;
			}
			e = null;
		}
		
		protected function __uNetStreamHandler(type:String, uNetStream:UNetStream):void
		{
			switch (type) {
				case UNetWorkGroupEvent.OUT_CONNECT_SUCCESS:
				case UNetWorkGroupEvent.IN_CONNECT_SUCCESS:
					TEvent.removeTrigger(uNetStream["NAME"], __uNetStreamHandler);
					break;
				default:
					removeUNetStream(uNetStream);
					break;
			}
			type = null;
			uNetStream = null;
		}
		
		public function setReceiveTimeOut(value:Number):void
		{
			_receiveTimeOut = value;
		}
		
		public function setOutTimeOut(value:Number):void
		{
			_outTimeOut = value;
		}
		
		public function setInTimeOut(value:Number):void
		{
			_inTimeOut = value;
		}
		
		public function setUNetConnection(uNetConnection:UNetConnection):void
		{
			_uNetConnection = uNetConnection;
			_uNetConnection.addEventListener(NetStatusEvent.NET_STATUS, __netStatusHandler);
			_uNetConnection.client = {
				"onRelay": __onRelay
			};
			uNetConnection = null;
		}
		
		public function setUNetGroup(uNetGroup:UNetGroup):void
		{
			_uNetGroup = uNetGroup;
			_uNetGroup.addEventListener(NetStatusEvent.NET_STATUS, __netStatusHandler);
			_uNetGroup = null;
		}
		
		public function setPublishUNetStream(uNetStream:UNetStream):void
		{
			_publishUNetStream = uNetStream;
			_publishUNetStream.addEventListener(NetStatusEvent.NET_STATUS, __netStatusHandler);
			_publishUNetStream.client = {
				"onPeerConnect": __onPublishUNetStreamPeerConnect
			};
			uNetStream = null;
		}
		
		public function setPublishUNetStreamPeerConnect(value:Boolean):void
		{
			_publishUNetStreamPeerConnect = value;
		}
		
		public function getUNetConnection():UNetConnection
		{
			return _uNetConnection;
		}
		
		public function getUNetGroup():UNetGroup
		{
			return _uNetGroup;
		}
		
		public function addReceiveUNetStream(name:String, peerID:String, repeatCount:int = 1):UNetStream
		{
			var uNetStream:ReceiveUNetStream = new ReceiveUNetStream(getUNetConnection(), peerID, _receiveTimeOut);
			TEvent.newTrigger(uNetStream.NAME, function (type:String, uNetStream:UNetStream):void
			{
				if (null !== NAME) {
					switch (type) {
						case UNetWorkGroupEvent.RECEIVE_TIME_OUT:
							if (repeatCount !== 1) {
								if (repeatCount !== 0) repeatCount--;
								TEvent.trigger(NAME, type, [uNetStream, addReceiveUNetStream(name, peerID, repeatCount)]);
							}
							else {
								TEvent.trigger(NAME, type, uNetStream);
								TEvent.trigger(NAME, UNetWorkGroupEvent.RECEIVE_CONNECT_FAILED, uNetStream);
							}
							break;
						default:
							TEvent.trigger(NAME, type, uNetStream);
							break;
					}
					removeUNetStream(uNetStream);
				}
				name = null;
				peerID = null;
				type = null;
				uNetStream = null;
			});
			uNetStream.play(name);
			if (null === _receiveUNetStreamV) _receiveUNetStreamV = new Vector.<UNetStream>();
			_receiveUNetStreamV[_receiveUNetStreamV.length] = uNetStream;
			return uNetStream;
		}
		
		public function addOutUNetStream(name:String):UNetStream
		{
			var uNetStream:OUNetStream = new OUNetStream(getUNetConnection(), NetStream.DIRECT_CONNECTIONS, _outTimeOut);
			TEvent.newTrigger(uNetStream.NAME, __uNetStreamHandler);
			uNetStream.addEventListener(NetStatusEvent.NET_STATUS, __netStatusHandler);
			uNetStream.publish(name);
			if (null === _outUNetStreamV) _outUNetStreamV = new Vector.<UNetStream>();
			_outUNetStreamV[_outUNetStreamV.length] = uNetStream;
			name = null;
			return uNetStream;
		}
		
		public function addOutUNetStream2(name:String, repeatCount:int = 1):UNetStream
		{
			var uNetStream:OUNetStream = addOutUNetStream(name) as OUNetStream;
			TEvent.newTrigger(uNetStream.NAME, function (type:String, uNetStream:UNetStream):void
			{
				if (null !== NAME) {
					switch (type) {
						case UNetWorkGroupEvent.OUT_TIME_OUT:
						case UNetWorkGroupEvent.OUT_CLOSE:
							if (repeatCount !== 1) {
								if (repeatCount !== 0) repeatCount--;
								TEvent.trigger(NAME, type, [uNetStream, addOutUNetStream2(name, repeatCount)]);
							}
							else {
								TEvent.trigger(NAME, type, uNetStream);
								TEvent.trigger(NAME, UNetWorkGroupEvent.OUT_CONNECT_FAILED, uNetStream);
							}
							removeUNetStream(uNetStream);
							break;
						case UNetWorkGroupEvent.OUT_CONNECT_SUCCESS:
							TEvent.removeTrigger((uNetStream as OUNetStream).NAME, arguments.callee);
							TEvent.trigger(NAME, type, uNetStream);
							break;
						default:
							TEvent.trigger(NAME, type, uNetStream);
							break;
					}
				}
				name = null;
				type = null;
				uNetStream = null;
			});
			return uNetStream;
		}
		
		public function addInUNetStream(name:String, peerID:String):UNetStream
		{
			var uNetStream:IUNetStream = new IUNetStream(getUNetConnection(), peerID, _inTimeOut);
			TEvent.newTrigger(uNetStream.NAME, __uNetStreamHandler);
			uNetStream.addEventListener(NetStatusEvent.NET_STATUS, __netStatusHandler);
			uNetStream.play(name);
			if (null === _inUNetStreamV) _inUNetStreamV = new Vector.<UNetStream>();
			_inUNetStreamV[_inUNetStreamV.length] = uNetStream;
			name = null;
			peerID = null;
			return uNetStream;
		}
		
		public function addInUNetStream2(name:String, peerID:String, repeatCount:int = 1):UNetStream
		{
			var uNetStream:IUNetStream = addInUNetStream(name, peerID) as IUNetStream;
			TEvent.newTrigger(uNetStream.NAME, function (type:String, uNetStream:UNetStream):void
			{
				if (null !== NAME) {
					switch (type) {
						case UNetWorkGroupEvent.IN_TIME_OUT:
						case UNetWorkGroupEvent.IN_CLOSE:
							if (repeatCount !== 1) {
								if (repeatCount !== 0) repeatCount--;
								TEvent.trigger(NAME, type, [uNetStream, addInUNetStream2(name, peerID, repeatCount)]);
							}
							else {
								TEvent.trigger(NAME, type, uNetStream);
								TEvent.trigger(NAME, UNetWorkGroupEvent.IN_CONNECT_FAILED, uNetStream);
							}
							removeUNetStream(uNetStream);
							break;
						case UNetWorkGroupEvent.IN_CONNECT_SUCCESS:
							TEvent.removeTrigger((uNetStream as IUNetStream).NAME, arguments.callee);
							TEvent.trigger(NAME, type, uNetStream);
							break;
						default:
							TEvent.trigger(NAME, type, uNetStream);
							break;
					}
				}
				name = null;
				peerID = null;
				type = null;
				uNetStream = null;
			});
			return uNetStream;
		}
		
		public function addIOUNetstream(inName:String, outName:String, peerID:String = null, repeatCount:int = 1, io:int = 0):void
		{
			if (null === peerID) peerID = outName;
			var i:int, l:int, v:Array, inV:Vector.<Array>, inF:Function, inUNetStream:IUNetStream, outUNetStream:OUNetStream;
			TEvent.newTrigger(NAME, function (type:String, data:Object):void
			{
				switch (type) {
					case UNetWorkGroupEvent.IN_TIME_OUT:
					case UNetWorkGroupEvent.IN_CLOSE:
						if (data is Array && inUNetStream === data[0]) {
							if (io !== 0) io--;
							inUNetStream = data[1] as IUNetStream;
						}
						break;
					case UNetWorkGroupEvent.IN_CONNECT_FAILED:
						if (inUNetStream === data) {
							if (io !== 0) io--;
							TEvent.trigger(NAME, UNetWorkGroupEvent.IO_CONNECT_FAILED, [inName, outName, peerID, inUNetStream, outUNetStream]);
							TEvent.removeTrigger(NAME, arguments.callee);
							if (null !== inF) {
								TEvent.removeTrigger(inUNetStream.NAME, inF);
								inV = null;
								inF = null;
							}
							if (null !== outUNetStream) {
								removeUNetStream(outUNetStream);
								outUNetStream = null;
							}
							inUNetStream = null;
							inName = null;
							outName = null;
							peerID = null;
						}
						break;
					case UNetWorkGroupEvent.IN_CONNECT_SUCCESS:
						if (inUNetStream === data) {
							if (null === outUNetStream) {
								outUNetStream = addOutUNetStream2(outName, repeatCount) as OUNetStream;
								inF = function (type:String, inUNetStream:IUNetStream, data:Object = null):void
								{
									if (null === inV) inV = new Vector.<Array>();
									inV[l++] = null === data ? [type] : [type, data];
									type = null;
									inUNetStream = null;
									data = null;
								};
								TEvent.newTrigger(inUNetStream.NAME, inF);
							}
							else {
								TEvent.trigger(NAME, UNetWorkGroupEvent.IO_CONNECT_SUCCESS, [inName, outName, peerID, inUNetStream, outUNetStream]);
								TEvent.removeTrigger(NAME, arguments.callee);
								if (null !== inF) {
									TEvent.removeTrigger(inUNetStream.NAME, inF);
									if (null !== inV) {
										for (i = 0; i < l; i++) {
											v = inV[i];
											v.length === 0 ? TEvent.trigger(inUNetStream.NAME, v[0], inUNetStream) : TEvent.trigger(inUNetStream.NAME, v[0], inUNetStream, v[1]);
										}
										v = null;
										inV = null;
									}
									inF = null;
								}
								inUNetStream = null;
								outUNetStream = null;
								inName = null;
								outName = null;
								peerID = null;
							}
						}
						break;
					case UNetWorkGroupEvent.OUT_TIME_OUT:
					case UNetWorkGroupEvent.OUT_CLOSE:
						if (data is Array && outUNetStream === data[0]) {
							if (io !== 0) io--;
							outUNetStream = data[1] as OUNetStream;
						}
						break;
					case UNetWorkGroupEvent.OUT_CONNECT_FAILED:
						if (outUNetStream === data) {
							if (io !== 0) io--;
							TEvent.trigger(NAME, UNetWorkGroupEvent.IO_CONNECT_FAILED, [inName, outName, peerID, inUNetStream, outUNetStream]);
							TEvent.removeTrigger(NAME, arguments.callee);
							if (null !== inF) {
								TEvent.removeTrigger(inUNetStream.NAME, inF);
								inV = null;
								inF = null;
							}
							if (null !== inUNetStream) {
								removeUNetStream(inUNetStream);
								inUNetStream = null;
							}
							outUNetStream = null;
							inName = null;
							outName = null;
							peerID = null;
						}
						break;
					case UNetWorkGroupEvent.OUT_CONNECT_SUCCESS:
						if (outUNetStream === data) {
							if (null === inUNetStream) {
								inUNetStream = addInUNetStream2(inName, peerID, repeatCount) as IUNetStream;
							}
							else {
								TEvent.trigger(NAME, UNetWorkGroupEvent.IO_CONNECT_SUCCESS, [inName, outName, peerID, inUNetStream, outUNetStream]);
								TEvent.removeTrigger(NAME, arguments.callee);
								if (null !== inF) {
									TEvent.removeTrigger(inUNetStream.NAME, inF);
									if (null !== inV) {
										for (i = 0; i < l; i++) {
											v = inV[i];
											v.length === 0 ? TEvent.trigger(inUNetStream.NAME, v[0], inUNetStream) : TEvent.trigger(inUNetStream.NAME, v[0], inUNetStream, v[1]);
										}
										v = null;
										inV = null;
									}
									inF = null;
								}
								inUNetStream = null;
								outUNetStream = null;
								inName = null;
								outName = null;
								peerID = null;
							}
						}
						break;
				}
				type = null;
				data = null;
			});
			if (io === 0) inUNetStream = addInUNetStream2(inName, peerID, repeatCount) as IUNetStream;
			else outUNetStream = addOutUNetStream2(outName, repeatCount) as OUNetStream;
		}
		
		public function getOutUNetStreamByPeerID(peerID:String):UNetStream
		{
			var i:int = hasOutUNetStreamByPeerID(peerID);
			peerID = null;
			return i === -1 ? null : _outUNetStreamV[i];
		}
		
		public function getOutUNetStreamByUNetStream(uNetStream:UNetStream):UNetStream
		{
			var i:int = hasOutUNetStreamByUNetStream(uNetStream);
			uNetStream = null;
			return i === -1 ? null : _outUNetStreamV[i];
		}
		
		public function getOutUNetStreamByNetStream(netStream:NetStream):UNetStream
		{
			var i:int = hasOutUNetStreamByNetStream(netStream);
			netStream = null;
			return i === -1 ? null : _outUNetStreamV[i];
		}
		
		public function getInUNetStreamByPeerID(peerID:String):UNetStream
		{
			var i:int = hasInUNetStreamByPeerID(peerID);
			peerID = null;
			return i === -1 ? null : _inUNetStreamV[i];
		}
		
		public function getInUNetStreamByUNetStream(uNetStream:UNetStream):UNetStream
		{
			var i:int = hasInUNetStreamByUNetStream(uNetStream);
			uNetStream = null;
			return i === -1 ? null : _inUNetStreamV[i];
		}
		
		public function getPublishNetStreamByPeerID(peerID:String):NetStream
		{
			var i:int = hasPublishNetStreamByPeerID(peerID);
			peerID = null;
			return i === -1 ? null : _publishNetStreamV[i];
		}
		
		public function getPublishNetStreamByUNetStream(netStream:NetStream):NetStream
		{
			var i:int = hasPublishNetStreamByNetStream(netStream);
			netStream = null;
			return i === -1 ? null : _publishNetStreamV[i];
		}
		
		public function getReceiveUNetStreamByPeerID(peerID:String):UNetStream
		{
			var i:int = hasReceiveUNetStreamByPeerID(peerID);
			peerID = null;
			return i === -1 ? null : _receiveUNetStreamV[i];
		}
		
		public function getReceiveUNetStreamByUNetStream(uNetStream:UNetStream):UNetStream
		{
			var i:int = hasReceiveUNetStreamByUNetStream(uNetStream);
			uNetStream = null;
			return i === -1 ? null : _receiveUNetStreamV[i];
		}
		
		public function hasOutUNetStreamByPeerID(peerID:String):int
		{
			if (null !== _outUNetStreamV) {
				var i:int = _outUNetStreamV.length, j:int, v:Array, uNetStream:UNetStream, netStream:NetStream;
				while (i > 0 && null !== _outUNetStreamV) {
					i--;
					uNetStream = _outUNetStreamV[i];
					if (null !== uNetStream) {
						v = uNetStream.peerStreams;
						j = v.length;
						while (j > 0) {
							j--;
							netStream = v[j];
							if (null !== netStream && netStream.farID === peerID) {
								v = null;
								uNetStream = null;
								netStream = null;
								peerID = null;
								return i;
							}
						}
					}
				}
				v = null;
				uNetStream = null;
				netStream = null;
			}
			peerID = null;
			return -1;
		}
		
		public function hasOutUNetStreamByUNetStream(uNetStream:UNetStream):int
		{
			if (null !== _outUNetStreamV) {
				return _outUNetStreamV.lastIndexOf(uNetStream);
			}
			uNetStream = null;
			return -1;
		}
		
		public function hasOutUNetStreamByNetStream(netStream:NetStream):int
		{
			if (null !== _outUNetStreamV) {
				var i:int = _outUNetStreamV.length, j:int, v:Array, uNetStream:UNetStream;
				while (i > 0 && null !== _outUNetStreamV) {
					i--;
					uNetStream = _outUNetStreamV[i];
					if (null !== uNetStream) {
						v = uNetStream.peerStreams;
						j = v.length;
						while (j > 0) {
							j--;
							if (v[j] === netStream) {
								v = null;
								uNetStream = null;
								netStream = null;
								return i;
							}
						}
					}
				}
				v = null;
				uNetStream = null;
			}
			netStream = null;
			return -1;
		}
		
		public function hasInUNetStreamByPeerID(peerID:String):int
		{
			if (null !== _inUNetStreamV) {
				var i:int = _inUNetStreamV.length, uNetStream:UNetStream;
				while (i > 0 && null !== _inUNetStreamV) {
					i--;
					uNetStream = _inUNetStreamV[i];
					if (null !== uNetStream && uNetStream.farID === peerID) {
						uNetStream = null;
						peerID = null;
						return i;
					}
				}
				uNetStream = null;
			}
			peerID = null;
			return -1;
		}
		
		public function hasInUNetStreamByUNetStream(uNetStream:UNetStream):int
		{
			if (null !== _inUNetStreamV) {
				return _inUNetStreamV.lastIndexOf(uNetStream);
			}
			uNetStream = null;
			return -1;
		}
		
		public function hasPublishNetStreamByPeerID(peerID:String):int
		{
			if (null !== _publishNetStreamV) {
				var i:int = _publishNetStreamV.length, netStream:NetStream;
				while (i > 0 && null !== _publishNetStreamV) {
					i--;
					netStream = _publishNetStreamV[i];
					if (null !== netStream && netStream.farID === peerID) {
						netStream = null;
						peerID = null;
						return i;
					}
				}
				netStream = null;
			}
			peerID = null;
			return -1;
		}
		
		public function hasPublishNetStreamByNetStream(netStream:NetStream):int
		{
			if (null !== _publishNetStreamV) {
				return _publishNetStreamV.lastIndexOf(netStream);
			}
			netStream = null;
			return -1;
		}
		
		public function hasReceiveUNetStreamByPeerID(peerID:String):int
		{
			if (null !== _receiveUNetStreamV) {
				var i:int = _receiveUNetStreamV.length, uNetStream:UNetStream;
				while (i > 0 && null !== _receiveUNetStreamV) {
					i--;
					uNetStream = _receiveUNetStreamV[i];
					if (null !== uNetStream && uNetStream.farID === peerID) {
						uNetStream = null;
						peerID = null;
						return i;
					}
				}
				uNetStream = null;
			}
			peerID = null;
			return -1;
		}
		
		public function hasReceiveUNetStreamByUNetStream(uNetStream:UNetStream):int
		{
			if (null !== _receiveUNetStreamV) {
				return _receiveUNetStreamV.lastIndexOf(uNetStream);
			}
			uNetStream = null;
			return -1;
		}
		
		public function sendToAll(filter:Object, ...parameters):void
		{
			if (null !== _outUNetStreamV) {
				var i:int = _outUNetStreamV.length, uNetStream:UNetStream;
				while (i > 0 && null !== _outUNetStreamV) {
					i--;
					uNetStream = _outUNetStreamV[i];
					if (null !== uNetStream) {
						if (null === filter) {
							_outUNetStreamV[i].send.apply(null, parameters);
						}
						else if (filter.lastIndexOf(i) === -1) {
							_outUNetStreamV[i].send.apply(null, parameters);
						}
					}
				}
				uNetStream = null;
			}
			filter = null;
			parameters = null;
		}
		
		public function sendToPeer(peerID:String, ...parameters):void
		{
			var uNetStream:UNetStream = getOutUNetStreamByPeerID(peerID);
			if (null !== uNetStream) {
				uNetStream.send.apply(null, parameters);
				uNetStream = null;
			}
			peerID = null;
			parameters = null;
		}
		
		public function publishSend(...parameters):void
		{
			_publishUNetStream.send.apply(null, parameters);
			parameters = null;
		}
		
		public function getOutUNetStreamV():Vector.<UNetStream>
		{
			return _outUNetStreamV;
		}
		
		public function getInUNetStreamV():Vector.<UNetStream>
		{
			return _inUNetStreamV;
		}
		
		public function getReceiveUNetStreamV():Vector.<UNetStream>
		{
			return _receiveUNetStreamV;
		}
		
		public function getPublishUNetStreamV():Vector.<NetStream>
		{
			return _publishNetStreamV;
		}
		
		public function getConnectedNetStreamV():Vector.<NetStream>
		{
			return _connectedNetStreamV;
		}
		
		public function removeUNetStream(uNetStream:UNetStream):Boolean
		{
			var i:int;
			if (uNetStream is IUNetStream) {
				if (null !== _inUNetStreamV) {
					i = _inUNetStreamV.lastIndexOf(uNetStream);
					if (i !== -1) {
						_inUNetStreamV.splice(i, 1);
						if (_inUNetStreamV.length === 0) {
							_inUNetStreamV = null;
						}
						uNetStream.clear();
						uNetStream = null;
						return true;
					}
				}
			}
			else if (uNetStream is OUNetStream) {
				if (null !== _outUNetStreamV) {
					i = _outUNetStreamV.lastIndexOf(uNetStream);
					if (i !== -1) {
						_outUNetStreamV.splice(i, 1);
						if (null !== _connectedNetStreamV) {
							var j:int, v:Array = uNetStream.peerStreams, netStream:NetStream;
							j = v.length;
							while (j > 0) {
								j--;
								netStream = v[j] as NetStream;
								netStream.dispose();
								i = _connectedNetStreamV.indexOf(netStream);
								if (i !== -1) {
									_connectedNetStreamV.splice(i, 1);
								}
							}
							if (_connectedNetStreamV.length === 0) {
								_connectedNetStreamV = null;
							}
							v = null;
							netStream = null;
						}
						if (_outUNetStreamV.length === 0) {
							_outUNetStreamV = null;
						}
						uNetStream.clear();
						uNetStream = null;
						return true;
					}
				}
			}
			else if (uNetStream is ReceiveUNetStream) {
				if (null !== _receiveUNetStreamV) {
					i = _receiveUNetStreamV.lastIndexOf(uNetStream);
					if (i !== -1) {
						_receiveUNetStreamV.splice(i, 1);
						if (_receiveUNetStreamV.length === 0) {
							_receiveUNetStreamV = null;
						}
						uNetStream.clear();
						uNetStream = null;
						return true;
					}
				}
			}
			uNetStream = null;
			return false;
		}
		
		public function clearOutUNetStream():void
		{
			if (null !== _outUNetStreamV) {
				var i:int, j:int = _outUNetStreamV.length, k:int, v:Array, uNetStream:UNetStream, netStream:NetStream;
				while (j > 0 && null !== _outUNetStreamV) {
					j--;
					uNetStream = _outUNetStreamV[j];
					if (null !== uNetStream) {
						if (null !== _connectedNetStreamV) {
							v = uNetStream.peerStreams;
							k = v.length;
							while (k > 0) {
								k--;
								netStream = v[k] as NetStream;
								netStream.dispose();
								i = _connectedNetStreamV.indexOf(netStream);
								if (i !== -1) {
									_connectedNetStreamV.splice(i, 1);
								}
							}
							if (_connectedNetStreamV.length === 0) {
								_connectedNetStreamV = null;
							}
						}
						uNetStream.clear();
					}
				}
				v = null;
				uNetStream = null;
				netStream = null;
				_outUNetStreamV = null;
			}
		}
		
		public function clearInUNetStream():void
		{
			if (null !== _inUNetStreamV) {
				var i:int = _inUNetStreamV.length, uNetStream:UNetStream;
				while (i > 0 && null !== _inUNetStreamV) {
					i--;
					if (null !== (uNetStream = _inUNetStreamV[i])) uNetStream.clear();
				}
				uNetStream = null;
				_inUNetStreamV = null;
			}
		}
		
		public function clearPublishUNetStream():void
		{
			_publishUNetStreamPeerConnect = false;
			if (null !== _publishNetStreamV) {
				if (null !== _connectedNetStreamV) {
					var i:int, j:int = _publishNetStreamV.length, netStream:NetStream;
					while (j > 0 && null !== _publishNetStreamV) {
						j--;
						netStream = _publishNetStreamV[j] as NetStream;
						netStream.dispose();
						i = _connectedNetStreamV.indexOf(netStream);
						if (i !== -1) {
							_connectedNetStreamV.splice(i, 1);
						}
					}
					if (_connectedNetStreamV.length === 0) {
						_connectedNetStreamV = null;
					}
					netStream = null;
				}
				_publishNetStreamV = null;
			}
			if (null === _publishUNetStream) return;
			_publishUNetStream.clear();
			_publishUNetStream = null;
		}
		
		public function clearReceiveUNetStream():void
		{
			if (null !== _receiveUNetStreamV) {
				var i:int = _receiveUNetStreamV.length, uNetStream:UNetStream;
				while (i > 0 && null !== _receiveUNetStreamV) {
					i--;
					if (null !== (uNetStream = _receiveUNetStreamV[i])) uNetStream.clear();
				}
				uNetStream = null;
				_receiveUNetStreamV = null;
			}
		}
		
		public function clear():void
		{
			if (null !== _uNetConnection) {
				_uNetConnection.clear();
				_uNetConnection = null;
			}
			if (null !== _uNetGroup) {
				_uNetGroup.clear();
				_uNetGroup = null;
			}
			if (null !== NAME) {
				TEvent.clearTrigger(NAME);
				NAME = null;
			}
			_connectedNetStreamV = null;
			clearOutUNetStream();
			clearInUNetStream();
			clearPublishUNetStream();
			clearReceiveUNetStream();
		}
		
	}
}