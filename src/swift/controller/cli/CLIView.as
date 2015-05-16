package swift.controller.cli
{
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	
	import org.ais.system.Ais;
	import org.aisy.display.USprite;
	
	import swift.core.shell.Executor;
	import swift.core.shell.ExecutorEnum;
	import swift.core.shell.Shell;
	import swift.core.shell.ShellController;
	import swift.core.shell.ShellControllerEnum;
	import swift.core.shell.ShellObject;
	
	use namespace shell_internal;

	public class CLIView extends USprite
	{
		shell_internal var _shellController:ShellController
		shell_internal var _scroller:Object;
		shell_internal var _messageTextField:TextField;
		shell_internal var _inputTextField:TextField;
		shell_internal var _tipTextField:TextField;
		shell_internal var _history:Vector.<String>;
		shell_internal var _historyIndex:uint;
		shell_internal var _maxMessage:uint = 30;
		shell_internal var _width:Number = 0;
		shell_internal var _height:Number = 0;
		shell_internal var _x:Number = 0;
		shell_internal var _y:Number = 0;
		shell_internal var _color:uint = uint.MAX_VALUE;
		shell_internal var _messageColor:uint = 0xE9E9E9;
		shell_internal var _messageBgColor:uint = 0x222222;
		shell_internal var _inputColor:uint = 0xE9E9E9;
		shell_internal var _inputBgColor:uint = 0x333333;
		shell_internal var _tipColor:uint = 0xFF0000;
		shell_internal var _textV:Vector.<uint>;
		shell_internal var _textVLength:uint;
		shell_internal var _colorType:Object;
		shell_internal var _filterType:int = -1;
		shell_internal var _filterF:Function;
		/**
		 * tabChildren tabEnabled 的属性记录
		 */
		shell_internal var _tabChildrenList:Dictionary;
		
		public function CLIView(shellController:ShellController)
		{
			_shellController = shellController;
		}
		
		shell_internal function init():void
		{
			_textV = new Vector.<uint>();
			_textVLength = 0;
			
//			3F9A42
//			579B46
//			e9e9e9
			var tf:TextFormat = new TextFormat("Menlo Regular,Monaco,Consolas,Lucida Console,Courier New,_serif", 13, _messageColor);
			tf.leading = 3;
			tf.indent = 5;
			
			_tipTextField = new TextField();
			_tipTextField.defaultTextFormat = tf;
			_tipTextField.textColor = _tipColor;
			_tipTextField.mouseEnabled = _tipTextField.mouseWheelEnabled = _tipTextField.tabEnabled = false;
			_tipTextField.selectable = false;
			_tipTextField.width = 20;
			
			tf.indent = 20;
			
			_inputTextField = new InputTextField();
			_inputTextField.defaultTextFormat = tf;
			_inputTextField.type = TextFieldType.INPUT;
			_inputTextField.multiline = true;
//			333333
//			f3f3f3
			_inputTextField.backgroundColor = _inputBgColor;
			_inputTextField.background = true;
			
			_messageTextField = new TextField();
			_messageTextField.defaultTextFormat = tf;
			_messageTextField.multiline = true;
			_messageTextField.wordWrap = true;
//			222222
//			f9f9f9f
			_messageTextField.backgroundColor = _messageBgColor;
			_messageTextField.background = true;
			
			addChild(_messageTextField);
			addChild(_inputTextField);
			addChild(_tipTextField);
			
			tf = null;
		}
		
		shell_internal function __addEvent():void
		{
			_inputTextField.addEventListener(KeyboardEvent.KEY_DOWN, __inputKeyHandler);
			_inputTextField.addEventListener(KeyboardEvent.KEY_UP, __inputKeyHandler);
			_inputTextField.addEventListener(Event.CHANGE, __inputHandler);
			_inputTextField.addEventListener(FocusEvent.FOCUS_OUT, __inputHandler);
			
			Ais.IMain.stage.addEventListener(Event.RESIZE, __stageHandler);
		}
		
		shell_internal function __removeEvent():void
		{
			if (null === _inputTextField) return;
			_inputTextField.removeEventListener(KeyboardEvent.KEY_DOWN, __inputKeyHandler);
			_inputTextField.removeEventListener(KeyboardEvent.KEY_UP, __inputKeyHandler);
			_inputTextField.removeEventListener(Event.CHANGE, __inputHandler);
			_inputTextField.removeEventListener(FocusEvent.FOCUS_OUT, __inputHandler);
			
			Ais.IMain.stage.removeEventListener(Event.RESIZE, __stageHandler);
		}
		
		shell_internal function __layout():void
		{
			if (null === _inputTextField) return;
			var w:Number = Ais.IMain.stage.stageWidth, h:Number = Ais.IMain.stage.stageHeight;
			x = (_x > 0 && _x < 1) ? w * _x : _x;
			y = (_y > 0 && _y < 1) ? h * _y : _y;
			if (_width > 0) {
				w = _width < 1 ? w * _width : _width;
			}
			else if (_width < 0) {
				w = _width > -1 ? w * (1 + _width) : w + _width;
			}
			if (_height > 0) {
				h = _height < 1 ? h * _height : _height;
			}
			else if (_height < 0) {
				h = _height > -1 ? h * (1 + _height) : h + _height;
			}
			
			_inputTextField.width = w;
			_inputTextField.height = _tipTextField.height = _inputTextField.textHeight / _inputTextField.numLines * 2;
			if (null == _scroller) {
				_messageTextField.width = w;
				_messageTextField.height = h - _inputTextField.height;
			}
			else {
				var sh:int = _messageTextField.scrollH;
				var sv:int = _messageTextField.scrollV;
				_scroller.setSize(w, h - _inputTextField.height);
				_messageTextField.scrollH = sh;
				_messageTextField.scrollV = sv;
			}
			_inputTextField.y = _tipTextField.y = h - _inputTextField.height;
			
			var tf:TextFormat = _inputTextField.defaultTextFormat;
			if (tf.color !== _inputColor) {
				tf.color = _inputColor;
				_inputTextField.defaultTextFormat = tf;
			}
			tf = _messageTextField.defaultTextFormat;
			if (tf.color !== _messageColor) {
				var color:uint;
				var type:uint;
				var start:uint;
				var end:uint;
				for (var i:uint = 0, l:uint = _textVLength; i < l; i++) {
					type = _textV[i++];
					color = _textV[i++];
					if (color === uint.MAX_VALUE) {
						if (null !== _colorType && _colorType.hasOwnProperty(type) === true) color = _colorType[type];
						else color = _messageColor;
					}
					tf.color = color;
					start = end;
					end = _textV[i];
					_messageTextField.setTextFormat(tf, start, end);
				}
				tf.color = _messageColor;
				_messageTextField.defaultTextFormat = tf;
			}
			tf = _tipTextField.defaultTextFormat;
			if (tf.color !== _tipColor) {
				tf.color = _tipColor;
				_tipTextField.defaultTextFormat = tf;
			}
			if (_inputBgColor !== _inputTextField.backgroundColor) {
				_inputTextField.backgroundColor = _inputBgColor;
			}
			if (_messageBgColor !== _messageTextField.backgroundColor) {
				_messageTextField.backgroundColor = _messageBgColor;
			}
			tf = null;
		}
		
		shell_internal function __setTabChildren(value:Boolean):void
		{
			if (value === false && null === _tabChildrenList) _tabChildrenList = new Dictionary(true);
			var view:DisplayObjectContainer = parent;
			var i:uint, len:uint = view.numChildren, obj:Object;
			for (i = 0; i < len; i++) {
				obj = view.getChildAt(i);
				if (value === false) {
					if (!_tabChildrenList[obj]) _tabChildrenList[obj] = [obj.hasOwnProperty("tabChildren") === true ? obj.tabChildren : false, obj.hasOwnProperty("tabEnabled") === true ? obj.tabEnabled : false];
					if (obj.hasOwnProperty("tabChildren") === true) obj.tabChildren = false;
					if (obj.hasOwnProperty("tabEnabled") === true) obj.tabEnabled = false;
				}
				else if (null !== _tabChildrenList && _tabChildrenList[obj]) {
					if (obj.hasOwnProperty("tabChildren") === true) obj.tabChildren = _tabChildrenList[obj][0];
					if (obj.hasOwnProperty("tabEnabled") === true) obj.tabEnabled = _tabChildrenList[obj][1];
				}
			}
			if (value === true) _tabChildrenList = null;
			tabChildren = true;
			tabEnabled = false;
			view = null;
			obj = null;
		}
		
		shell_internal function __getPath(shell:Shell = null):String
		{
			if (null === shell) shell = _shellController.currentShell;
			var p:String = shell.name;
			while (shell = shell.parent) p = shell.name + "/" + p;
			shell = null;
			return p;
		}
		
		shell_internal function __appendLine(path:String, source:String, message:String, color:uint = uint.MAX_VALUE, type:uint = ShellControllerEnum.TYPE_DEFAULT, tag:uint = 1, format:Object = null):void
		{
			var b:Boolean = true;
			if (null !== _filterF) {
				var arr:Array = [path, source, message, color, type, tag, format, this];
				arr = _filterF.apply(null, arr.slice(0, _filterF.length));
				b = arr[0];
				format = arr[1];
				arr = null;
			}
			else if (_filterType !== -1 && _filterType !== type) {
				b = false;
			}
			if (b === true) {
				var m:int = null !== format ? format.message : 1, s:int = null !== format ? format.source : 1, p:int = null !== format ? format.path : 1;
				var str:String = (_textVLength === 0 ? "" : "\n");
				if (p != 0) {
					str += path;
					if (m + s != 0) {
						str += " % ";
					}
				}
				if (s != 0) {
					str += source;
					if (m != 0) {
						str += ":  ";
					}
				}
				if (m != 0) {
					str += message;
				}
				appendText(str, color, type, tag);
				str = null;
			}
			path = null;
			source = null;
			message = null;
			format = null;
		}
		
		shell_internal function __inputKeyHandler(e:KeyboardEvent):void
		{
			switch (e.type) {
				case KeyboardEvent.KEY_DOWN:
					if (e.keyCode === Keyboard.ENTER) {
						if (_inputTextField.text.replace(/[\s\t\n\r]/g, "") !== "") {
							if (null === _history) _history = new Vector.<String>();
							_historyIndex = _history.length;
							_history[_historyIndex++] = _inputTextField.text;
							_shellController.executor = String(this);
							appendLine([_shellController.parseShell(_inputTextField.text, null, null, true, ShellControllerEnum.TYPE_INPUT)], uint.MAX_VALUE, ShellControllerEnum.TYPE_RETURN);
							_inputTextField.text = "";
						}
					}
					else if (e.keyCode === Keyboard.TAB) {
						if (_inputTextField.type === TextFieldType.INPUT) {
							_inputTextField.type = TextFieldType.DYNAMIC;
						}
					}
					else if (e.keyCode === Keyboard.UP) {
						if (null !== _history) {
							if (_historyIndex !== 0) _historyIndex--;
							_inputTextField.text = _history[_historyIndex];
							if (_inputTextField.type === TextFieldType.INPUT) {
								_inputTextField.type = TextFieldType.DYNAMIC;
							}
						}
					}
					else if (e.keyCode === Keyboard.DOWN) {
						if (null !== _history) {
							_historyIndex = _historyIndex < _history.length - 1 ? ++_historyIndex : _history.length - 1;
							_inputTextField.text = _history[_historyIndex];
						}
					}
					break;
				case KeyboardEvent.KEY_UP:
					if (e.keyCode === Keyboard.ENTER || e.keyCode === Keyboard.ESCAPE) {
						_inputTextField.text = "";
					}
					else if (e.keyCode === Keyboard.TAB) {
						var len:uint, r:RegExp = /[^\s\"\']+|\".*?\"$|\'.*?\'$/, o:Object = r.exec(_inputTextField.text);
						if (null !== o) {
							var cmdL:uint, cmdsL:uint, cmd:String = o[0], cmds:Array = [], shell:Shell = _shellController.currentShell, shell2:Shell;
							cmdL = cmd.length;
							if (null === shell.getShellByCommand(cmd, true)) {
								while (null !== shell) {
									for each (shell2 in shell._shellData._commands) {
										if (shell2.command.substr(0, cmdL) === cmd && cmds.lastIndexOf(shell2.command) === -1) {
											cmds[cmdsL] = shell2.command;
											cmdsL++;
										}
									}
									shell = shell.parent;
								}
								if (cmdsL === 1) {
									if (cmd !== cmds[0]) {
										_inputTextField.text = cmds[0];
									}
								}
								else if (cmdsL > 1) {
									appendText("\n    " + cmds.join(" "), uint.MAX_VALUE, ShellControllerEnum.TYPE_TIP);
									if (cmdL > 1) {
										cmds.sort(Array.UNIQUESORT);
										_inputTextField.text = cmds[0];
									}
								}
							}
							else {
								_inputTextField.text = _inputTextField.text.replace(/(\s\-)([^\s\"\'\-]+)$/, function ():String
								{
									shell = shell.getShellByCommand(cmd, true);
									if (null !== shell) {
										if (null !== shell.option) {
											var opt0:Vector.<String> = shell.option[0] as Vector.<String>;
											cmd = arguments[2];
											cmdL = cmd.length;
											for (var i:uint = 0, l:uint = opt0.length; i < l; i++) {
												if (opt0[i].substr(0, cmdL) === cmd) {
													cmds[cmdsL] = opt0[i];
													cmdsL++;
												}
											}
											if (cmdsL === 1) {
												if (cmd !== cmds[0]) {
													opt0 = null;
													return arguments[1] + cmds[0];
												}
											}
											else if (cmdsL > 1) {
												appendText("\n    - " + cmds.join(" "), uint.MAX_VALUE, ShellControllerEnum.TYPE_TIP2);
												if (cmdL > 1) {
													cmds.sort(Array.UNIQUESORT);
													return arguments[1] + cmds[0];
												}
											}
											opt0 = null;
										}
									}
									return arguments[0];
								});
							}
							cmd = null;
							cmds = null;
							shell = null;
							shell2 = null;
						}
						len = _inputTextField.text.length;
						_inputTextField.setSelection(len, len);
						r = null;
						o = null;
					}
					else if (e.keyCode === Keyboard.UP || e.keyCode === Keyboard.DOWN) {
						if (null !== _history) {
							len = _inputTextField.text.length;
							_inputTextField.setSelection(len, len);
						}
					}
					if (_inputTextField.type !== TextFieldType.INPUT) {
						_inputTextField.type = TextFieldType.INPUT;
					}
					break;
			}
			e = null;
		}
		
		shell_internal function __inputHandler(e:Event):void
		{
			switch (e.type) {
				case Event.CHANGE:
					_tipTextField.text = _inputTextField.numLines > 1 ? "*" : "";
					break;
				case FocusEvent.FOCUS_OUT:
					if (_inputTextField.type !== TextFieldType.INPUT) {
						_inputTextField.type = TextFieldType.INPUT;
					}
					break;
			}
			e = null;
		}
		
		shell_internal function __stageHandler(e:Event):void
		{
			__layout();
			_messageTextField.scrollV = _messageTextField.maxScrollV;
			e = null;
		}
		
		public function getShell():Shell
		{
			return new Shell_cli(this);
		}
		
		public function show(view:DisplayObjectContainer = null):Boolean
		{
			if (null !== parent) {
				__removeEvent();
				cacheAsBitmap = false;
				_messageTextField.text = "";
				_inputTextField.text = "";
				_tipTextField.text = "";
				__setTabChildren(true);
				Ais.IMain.stage.focus = null;
				if (null !== parent) parent.removeChild(this);
				return false;
			}
			
			if (null !== _history) _historyIndex = _history.length;
			
			if (null === _messageTextField) init();
			
			cacheAsBitmap = true;
			
			view = null !== view ? view : Ais.IMain.stage;
			view.addChild(this);
			if (null !== stage) stage.focus = _inputTextField;
			__setTabChildren(false);
			
			clearScreen();
			
			showMessage();
			
			__layout();
			__addEvent();
			return true;
		}
		
		public function showMessage():void
		{
			var executors:Vector.<Executor> = _shellController._shellControllerData._executors;
			if (null === executors) return;
			var i:uint, j:uint, k:uint, type:int, str:String, source:String, msg:String, path:String, v:Array, arr:Vector.<Array> = new Vector.<Array>(), message:Vector.<Array>, executor:Executor;
			for (i = executors.length; i > 0; i--) {
				i--;
				executor = executors[i];
				message = executor._message;
				if (null !== message) {
					source = executor.source.toString();
					for (j = message.length; j > 0; j--) {
						j--;
						if (message[j][0][0] is ExecutorEnum) {
							path = __getPath(message[j][0][1]);
							msg = (message[j][0][2] as Shell).command;
							type = message[j][0][3];
							str = message[j][0][4][0];
							if (null !== str && str.length !== 0) {
								msg += " " + str;
							}
						}
						else {
							path = __getPath();
							type = ShellControllerEnum.TYPE_DEFAULT;
							msg = message[j].toString();
						}
						arr[k] = [path, source, msg, uint.MAX_VALUE, type, _shellController._shellControllerData._tag];
						k++;
						if (_maxMessage !== 0 && k === _maxMessage) break;
						j++;
					}
					if (_maxMessage !== 0 && k === _maxMessage) break;
				}
				i++;
			}
			for (; k > 0; k--) {
				k--;
				__appendLine.apply(null, arr[k]);
				k++;
			}
			str = null;
			executors = null;
			executor = null;
			path = null;
			source = null;
			msg = null;
			message = null;
			arr = null;
		}
		
		public function clearScreen(time:Boolean = true):void
		{
			if (null === _messageTextField) return;
			_textV = new Vector.<uint>();
			_textVLength = 0;
			_messageTextField.text = "";
			if (null != _scroller) {
				_scroller.updateView();
			}
			if (time == true) {
				appendText("Last login: " + (new Date()).toString());
			}
			_inputTextField.text = "";
			_tipTextField.text = "";
		}
		
		public function appendLine(message:Array, color:uint = uint.MAX_VALUE, type:uint = ShellControllerEnum.TYPE_DEFAULT, tag:uint = 1):void
		{
			if (null === _messageTextField) return;
			var executors:Vector.<Executor> = _shellController._shellControllerData._executors;
			if (null === executors) return;
			var shell:Shell, executor:Executor = executors[executors.length - 1];
			var str:String, msg:String, source:String = executor.source.toString();
			var b:Boolean = true;
			if (message[0] is ExecutorEnum) {
				shell = message[1];
				msg = (message[2] as Shell).command;
				type = message[3];
				str = message[4][0];
				if (null !== str && str.length !== 0) {
					msg += " " + str;
				}
			}
			else if (message.length === 1 && message[0] is ShellObject && message[0].type === -2) {
				b = false;
				var arr:* = message[0].obj[0];
				for (var i:int = 0, l:int = arr.length; i < l; i++) {
					__appendLine.apply(null, arr[i]);
				}
				arr = null;
			}
			else {
				if (message.length === 1) {
					if (null === message[0]) {
						return;
					}
					else if (0 === message[0]) {
						msg = "";
					}
					else {
						msg = message.toString();
					}
				}
				else {
					msg = message.toString();
				}
			}
			if (b === true) __appendLine(__getPath(shell), source, msg, color, type, tag);
			executors = null;
			executor = null;
			str = null;
			msg = null;
			source = null;
			shell = null;
			message = null;
		}
		
		public function appendText(text:String, color:uint = uint.MAX_VALUE, type:uint = ShellControllerEnum.TYPE_DEFAULT, tag:uint = 1):void
		{
			if (null === _messageTextField) return;
			var i:uint = _textVLength !== 0 ? _textV[_textVLength - 1] : 0;
			var l:uint = i + text.length;
			_textV[_textVLength++] = type;
			_textV[_textVLength++] = color;
			_textV[_textVLength++] = l;
			_messageTextField.appendText(text);
			if (color === uint.MAX_VALUE) {
				if (_color !== uint.MAX_VALUE) color = _color;
				if (null !== _colorType && _colorType.hasOwnProperty(type) === true) color = _colorType[type];
				else color = _messageColor;
			}
			var tf:TextFormat = _messageTextField.defaultTextFormat;
			tf.color = color;
			_messageTextField.setTextFormat(tf, i, l);
			if (null != _scroller) {
				_scroller.updateView();
			}
			_messageTextField.scrollV = _messageTextField.maxScrollV;
			tf = null;
			text = null;
		}
		
		override public function set tabChildren(enable:Boolean):void
		{
			super.tabChildren = enable;
		}
		
		override public function set tabEnabled(enabled:Boolean):void
		{
			super.tabEnabled = false;
		}
		
		override public function clear():void
		{
			__removeEvent();
			super.clear();
			_shellController = null;
			_scroller = null;
			_messageTextField = null;
			_inputTextField = null;
			_tipTextField = null;
			_textV = null;
			_colorType = null;
			_filterF = null;
		}
		
	}
}
import flash.events.Event;
import flash.system.System;
import flash.text.TextField;

import swift.controller.cli.CLIView;
import swift.core.shell.Shell;
import swift.core.shell.ShellControllerEnum;

internal class InputTextField extends TextField
{
	override public function set text(value:String):void
	{
		super.text = value;
		dispatchEvent(new Event(Event.CHANGE));
		value = null;
	}
}

use namespace shell_internal;

internal class Shell_cli extends Shell
{
	protected var _cliView:CLIView;
	protected var _filterStr:String;
	
	public function Shell_cli(cliView:CLIView)
	{
		_cliView = cliView;
		name = command = ".cli";
		callback = __exec;
		
		description = "目录 控制台设置 （包含子命令）";
		
		var shell:Shell = new Shell();
		shell.name = shell.command = "history";
		shell.option = ["c", 2, "cy", 1];
		shell.callback = __historyExec;
		addShell(shell);
		
		shell = new Shell();
		shell.name = shell.command = "maxmessage";
		shell.callback = __maxMessageExec;
		shell.description = "显示的记录个数";
		addShell(shell);
		
		shell = new Shell();
		shell.name = shell.command = "clearscreen";
		shell.callback = __clearScreenExec;
		shell.description = "清屏";
		addShell(shell);
		
		shell = new Shell();
		shell.name = shell.command = "set";
		shell.option = [
			"x", 1,
			"y", 1,
			"width", 1,
			"height", 1,
			"color", 1,
			"messageColor", 1,
			"messageBgColor", 1,
			"inputColor", 1,
			"inputBgColor", 1,
			"tipColor", 1,
			"alpha", 1,
			"type", 1,
			"filter", 2
		];
		shell.callback = __setExec;
		shell.description = "显示设置 当 0 < x y width height < 1 时，按百分比计算\n" +
			"    type：过滤指定数字的 type\n" +
			"    filter：设置一个过滤函数或根据字符串过滤\n" +
			"        m 返回的记录只包含消息部分\n" +
			"        s 返回的记录只包含执行对象部分\n" +
			"        p 返回的记录只包含路径部分\n" +
		addShell(shell);
		
		shell = null;
		cliView = null;
	}
	
	protected function __exec(str:String):Object
	{
		if (null !== _cliView) {
			shellController._shellControllerData._messageType = ShellControllerEnum.MESSAGE_NO;
			shellController.parseShell(str, null, this, false, ShellControllerEnum.TYPE_DEFAULT);
			shellController._shellControllerData._messageType = ShellControllerEnum.MESSAGE_DEFAULT;
		}
		str = null;
		return null;
	}
	
	protected function __historyExec(str:String, args:Vector.<Array>):Object
	{
		var i:uint = 0, len:uint = args[1].length, cy:String;
		for (i = 0; i < len; i++) {
			switch (args[1][i][0]) {
				case "c":
					_cliView._history = null;
					break;
				case "cy":
					cy = args[1][i][1];
					break;
			}
		}
		if (null !== cy) {
			var v:Vector.<String> = _cliView._history;
			if (null !== v) {
				str = "";
				for (i = 0, len = v.length; i < len; i++) {
					str += i === 0 ? v[i] : "\n" + v[i];
				}
				v = null;
				if (cy.lastIndexOf("y") !== -1) {
					System.setClipboard(str);
				}
				if (cy.lastIndexOf("r") !== -1) {
					cy = null;
					args = null;
					return str;
				}
				cy = null;
			}
		}
		str = null;
		args = null;
		return null;
	}
	
	protected function __maxMessageExec(str:String):Object
	{
		_cliView._maxMessage = uint(str);
		return null;
	}
	
	protected function __clearScreenExec(str:String):Object
	{
		_cliView.clearScreen();
		return null;
	}
	
	protected function __setExec(str:String, args:Vector.<Array>):Object
	{
		var i:uint = 0, len:uint = args[1].length, b:int;
		for (i = 0; i < len; i++) {
			switch (args[1][i][0]) {
				case "x":
				case "y":
				case "width":
				case "height":
				case "color":
				case "messageColor":
				case "messageBgColor":
				case "inputColor":
				case "inputBgColor":
				case "tipColor":
				case "alpha":
					_cliView["_" + args[1][i][0]] = Number(args[1][i][1]);
					b = 1;
					break;
				case "type":
					_cliView._filterType = parseInt(args[1][i][1]);
					b = 2;
					break;
				case "filter":
					_filterStr = null;
					_cliView._filterF = null;
					if (args[2] && args[2][0].obj is Function) {
						_cliView._filterF = args[2][0].obj;
					}
					else if (args[1][i][1]) {
						_filterStr = args[1][i][1];
						_cliView._filterF = __filter;
					}
					b = 2;
					break;
			}
		}
		switch (b) {
			case 1:
				_cliView.__layout();
				break;
			case 2:
				_cliView.clearScreen();
				_cliView.showMessage();
				break;
		}
		str = null;
		args = null;
		return null;
	}
	
	protected function __filter(path:String, source:String, message:String, color:uint = uint.MAX_VALUE, type:uint = ShellControllerEnum.TYPE_DEFAULT, tag:uint = 1, format:Object = null, cli:CLIView = null):Array
	{
		var b:Boolean = true;
		if (cli._filterType !== -1 && cli._filterType !== type) {
			b = false;
		}
		if (b === true) {
			var _m:int = _filterStr.indexOf("m") == -1 ? 0 : 1, _s:int = _filterStr.indexOf("s") == -1 ? 0 : 1, _p:int = _filterStr.indexOf("p") == -1 ? 0 : 1;
			var m:int = null !== format ? format.message : _m, s:int = null !== format ? format.source : _s, p:int = null !== format ? format.path : _p;
			var str:String = (cli._textVLength === 0 ? "" : "\n");
			if (p != 0) {
				str += path;
				if (m + s != 0) {
					str += " % ";
				}
			}
			if (s != 0) {
				str += source;
				if (m != 0) {
					str += ":  ";
				}
			}
			if (m != 0) {
				str += message;
			}
			cli.appendText(str, color, type, tag);
			str = null;
		}
		path = null;
		source = null;
		message = null;
		format = null;
		return [false];
	}
	
	override public function clear():void
	{
		super.clear();
		_cliView = null;
		_filterStr = null;
	}
	
}

internal namespace shell_internal = "1500821a06f913bd7c019689e2f34c6dcb4b3e0bce0b241c206edb0bdbf6462f";