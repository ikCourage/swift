package swift.controller.mg
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import org.ais.event.TEvent;
	import org.ais.system.Ais;
	import org.aisy.display.USprite;
	import org.aisy.listoy.Listoy;
	
	import swift.core.magic.MagicVM;

	internal class MagicEditView extends USprite
	{
		static protected var instance:MagicEditView;
		
		protected var _listoy:Listoy;
		protected var _lineTextField:TextField;
		protected var _lineTextField2:TextField;
		protected var _editTextField:TextField;
		protected var _console:TextField;
		
		public function MagicEditView()
		{
			init();
		}
		
		protected function init():void
		{
			var tf:TextFormat = new TextFormat("Menlo Regular,Monaco,Consolas,Lucida Console,Courier New,_serif", 13, 0xe9e9e9);
			
			tf.align = TextFormatAlign.RIGHT;
			_lineTextField = new TextField();
			_lineTextField.defaultTextFormat = tf;
			_lineTextField.mouseEnabled = _lineTextField.mouseWheelEnabled = false;
			_lineTextField.tabEnabled = false;
			_lineTextField.selectable = false;
			_lineTextField.width = 0;
			
			tf.align = TextFormatAlign.LEFT;
			
			_lineTextField2 = new TextField();
			_lineTextField2.defaultTextFormat = tf;
			_lineTextField2.autoSize = TextFieldAutoSize.LEFT;
			_lineTextField2.mouseEnabled = _lineTextField2.mouseWheelEnabled = false;
			_lineTextField2.tabEnabled = false;
			_lineTextField2.selectable = false;
			_lineTextField2.width = 0;
			
			tf.indent = 9;
			_editTextField = new TextField();
			_editTextField.defaultTextFormat = tf;
			_editTextField.type = TextFieldType.INPUT;
			_editTextField.multiline = true;
			_editTextField.background = true;
			_editTextField.backgroundColor = 0x333333;
			
			_console = new TextField();
			_console.defaultTextFormat = tf;
			_console.wordWrap = true;
			_console.multiline = true;
			_console.background = true;
			_console.backgroundColor = 0x383838;
			_console.tabEnabled = false;
			_console.text = "=== Console ===\nMagic Script";
			
			addChild(_lineTextField);
			addChild(_editTextField);
			addChild(_console);
			
			var arr:Array = [
				{"op": "run", "text": "Run"},
				{"op": "clear", "text": "Clear"},
				{"op": "quit", "text": "Quit"}
			];
			
			_listoy = new Listoy();
			_listoy.setPadding(10);
			_listoy.setRowColumn(1, arr.length);
			_listoy.setItemRenderer(OpItem);
			_listoy.setDataProvider(arr);
			_listoy.initializeView();
			_listoy.x = 20;
			addChild(_listoy);
			
			tf = null;
			arr = null;
		}
		
		protected function __addEvent():void
		{
			_editTextField.addEventListener(Event.SCROLL, __editTextFieldHandler);
			_editTextField.addEventListener(Event.CHANGE, __editTextFieldHandler);
			Ais.IMain.stage.addEventListener(Event.RESIZE, __stageHandler);
			TEvent.newTrigger(_listoy.NAME, __triggerHandler);
			TEvent.newTrigger("MAGICVM", __triggerHandler);
		}
		
		protected function __removeEvent():void
		{
			_editTextField.removeEventListener(Event.SCROLL, __editTextFieldHandler);
			_editTextField.removeEventListener(Event.CHANGE, __editTextFieldHandler);
			Ais.IMain.stage.removeEventListener(Event.RESIZE, __stageHandler);
			TEvent.removeTrigger(_listoy.NAME, __triggerHandler);
			TEvent.removeTrigger("MAGICVM", __triggerHandler);
		}
		
		public function show(auto:Boolean = false):void
		{
			__removeEvent();
			if (null === parent || auto === true) {
				graphics.clear();
				graphics.beginFill(0x222222);
				graphics.drawRect(0, 0, Ais.IMain.stage.stageWidth, Ais.IMain.stage.stageHeight);
				graphics.endFill();
				_listoy.y = Ais.IMain.stage.stageHeight - _listoy.height - 7;
				if (_lineTextField.text.length === 0) {
					_lineTextField.text = _lineTextField2.text = "1";
					_lineTextField.width = _lineTextField2.width;
				}
				_editTextField.x = _lineTextField.x + _lineTextField.width + 5;
				_editTextField.width = Ais.IMain.stage.stageWidth - _editTextField.x;
				_editTextField.height = _lineTextField.height = Ais.IMain.stage.stageHeight - _listoy.height - 107;
				_console.width = Ais.IMain.stage.stageWidth;
				_console.height = 100;
				_console.y = _editTextField.height;
				Ais.IMain.stage.addChild(this);
				
				__addEvent();
			}
			else {
				parent.removeChild(this);
			}
			Ais.IMain.stage.focus = Ais.IMain.stage;
		}
		
		protected function __editTextFieldHandler(e:Event):void
		{
			switch (e.type) {
				case Event.CHANGE:
					var i:uint = _lineTextField.numLines, l:uint = _editTextField.numLines;
					if (i !== l) {
						var b:Boolean = i.toString().length !== l.toString().length;
						if (i < l) {
							for (; i < l;) {
								i++;
								_lineTextField.appendText("\n" + i.toString());
							}
						}
						else {
							_lineTextField.text = _lineTextField.text.substr(0, _lineTextField.getLineOffset(l) - 1);
						}
						if (b === true) {
							_lineTextField2.text = l.toString();
							if (_lineTextField.width != _lineTextField2.width) {
								_lineTextField.width = _lineTextField2.width;
								_editTextField.x = _lineTextField.x + _lineTextField.width + 5;
								_editTextField.width = Ais.IMain.stage.stageWidth - _editTextField.x;
							}
						}
					}
					break;
			}
			if (_lineTextField.scrollV !== _editTextField.scrollV) _lineTextField.scrollV = _editTextField.scrollV;
			e = null;
		}
		
		protected function __stageHandler(e:Event):void
		{
			switch (e.type) {
				case Event.RESIZE:
					if (null !== parent) {
						show(true);
					}
					break;
			}
			e = null;
		}
		
		protected function __triggerHandler(type:String, data:* = null):void
		{
			switch (type) {
				case "p":
					_console.appendText(data + "\n");
					_console.scrollV = _console.numLines;
					break;
				case "OP":
					switch (data.op) {
						case "run":
							_console.text = "";
							var fb:* = MagicVM.compile(_editTextField.text);
							if (fb is String) {
								_console.appendText(fb);
							}
							else {
								MagicVM.exec(fb);
							}
							fb = null;
							break;
						case "clear":
							_console.text = "";
							break;
						case "quit":
							clear();
							break;
					}
					break;
			}
			type = null;
			data = null;
		}
		
		override public function clear():void
		{
			__removeEvent();
			super.clear();
			_lineTextField = null;
			_lineTextField2 = null;
			_editTextField = null;
			_listoy = null;
			instance = null;
		}
		
		static public function getInstance():MagicEditView
		{
			if (null === instance) instance = new MagicEditView();
			return instance;
		}
		
	}
}
import flash.events.MouseEvent;

import org.ais.event.TEvent;
import org.aisy.listoy.ListoyItem;
import org.aisy.textview.TextView;

internal class OpItem extends ListoyItem
{
	public function OpItem(name:String, index:uint, data:*):void
	{
		super(name, index, data);
		init();
	}
	
	protected function init():void
	{
		var tv:TextView = new TextView();
		tv.setColor(0xFFFFFF);
		tv.setText(itemInfo.text);
		tv.dynamic = {"mouseEnabled": false};
		tv.buttonMode = true;
		tv.addEventListener(MouseEvent.CLICK, __mouseHandler);
		addChild(tv);
		tv = null;
	}
	
	protected function __mouseHandler(e:MouseEvent):void
	{
		switch (e.type) {
			case MouseEvent.CLICK:
				TEvent.trigger(NAME, "OP", itemInfo);
				break;
		}
		e = null;
	}
	
}