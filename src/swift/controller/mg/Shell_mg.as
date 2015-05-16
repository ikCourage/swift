package swift.controller.mg
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import org.aisy.net.utils.DataStream;
	
	import swift.core.magic.MagicVM;
	import swift.core.shell.Shell;

	public class Shell_mg extends Shell
	{
		protected var _dataStream:DataStream;
		protected var _file:FileReference;
		
		public function Shell_mg()
		{
			name = command = "mg";
			callback = __exec;
		}
		
		protected function __exec(str:String):Object
		{
			var r:RegExp = /[^\s\"\']+|\".*?\"|\'.*?\'/g;
			var arr:Array = r.exec(str);
			if (null != arr) {
				switch (arr[0]) {
					case ":":
						MagicEditView.getInstance().show(true);
						break;
					case "?":
						__load(str.substr(r.lastIndex + 1).replace(/^\s+|\s+$/g, ""));
						break;
					case "~":
						__browse();
						break;
					default:
						__magicRun(str);
						break;
				}
			}
			r = null;
			arr = null;
			str = null;
			return null;
		}
		
		protected function __removeFileEvent():void
		{
			if (null === _file) return;
			_file.removeEventListener(Event.SELECT, __fileHandler);
			_file.removeEventListener(Event.CANCEL, __fileHandler);
			_file.removeEventListener(Event.COMPLETE, __fileHandler);
			_file.removeEventListener(IOErrorEvent.IO_ERROR, __fileHandler);
			_file = null;
		}
		
		protected function __magicRun(str:String):void
		{
			var f:* = MagicVM.compile(str);
			if (f is String) {
				shellController.executor = String(this);
				shellController.parseShell("print " + f);
			}
			else {
				MagicVM.exec(f);
			}
			f = null;
			str = null;
		}
		
		protected function __load(url:String):void
		{
			if (!url) return;
			if (null !== _dataStream) _dataStream.clear();
			_dataStream = new DataStream();
			_dataStream.addEventListener(Event.COMPLETE, __dataStreamHandler);
			_dataStream.addEventListener(IOErrorEvent.IO_ERROR, __dataStreamHandler);
			_dataStream.addEventListener(SecurityErrorEvent.SECURITY_ERROR, __dataStreamHandler);
			_dataStream.load(new URLRequest(url));
			url = null;
		}
		
		protected function __browse():void
		{
			__removeFileEvent();
			_file = new FileReference();
			_file.addEventListener(Event.SELECT, __fileHandler);
			_file.addEventListener(Event.CANCEL, __fileHandler);
			_file.addEventListener(Event.COMPLETE, __fileHandler);
			_file.addEventListener(IOErrorEvent.IO_ERROR, __fileHandler);
			_file.browse();
		}
		
		protected function __dataStreamHandler(e:Event):void
		{
			switch (e.type) {
				case Event.COMPLETE:
					var b:ByteArray = new ByteArray();
					_dataStream.readBytes(b, 0, _dataStream.bytesAvailable);
					__magicRun(b.toString().replace(/\r/g, ""));
					b.clear();
					b = null;
					break;
				default:
					shellController.executor = String(this);
					shellController.parseShell("print " + e);
					break;
			}
			_dataStream.clear();
			_dataStream = null;
			e = null;
		}
		
		protected function __fileHandler(e:Event):void
		{
			switch (e.type) {
				case Event.SELECT:
					_file.load();
					break;
				case Event.COMPLETE:
					__magicRun(_file.data.toString().replace(/\r/g, ""));
					__removeFileEvent();
					break;
				default:
					__removeFileEvent();
					break;
			}
			e = null;
		}
		
		override public function clear():void
		{
			__removeFileEvent();
			if (null !== _dataStream) {
				_dataStream.clear();
				_dataStream = null;
			}
			super.clear();
		}
		
	}
}