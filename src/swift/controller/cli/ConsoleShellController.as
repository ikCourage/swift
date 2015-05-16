package swift.controller.cli
{
	import flash.display.DisplayObjectContainer;
	
	import swift.core.shell.Shell;
	import swift.core.shell.ShellController;
	import swift.core.shell.ShellControllerEnum;
	import swift.core.shell.ShellObject;
	import swift.core.shell.sbin.Shell_cd;
	import swift.core.shell.sbin.Shell_help;
	import swift.core.shell.sbin.Shell_history;
	import swift.core.shell.sbin.Shell_mcl;
	import swift.core.shell.sbin.Shell_print;
	import swift.core.shell.sbin.Shell_stree;

	use namespace shell_internal;

	public class ConsoleShellController extends ShellController
	{
		shell_internal var _view:CLIView;
		
		public function ConsoleShellController()
		{
			_view = new CLIView(this);
			var shell:Shell = new Shell();
			shell.name = "~";
			shell.addShell(_view.getShell());
			shell.addShell(new Shell_cd());
			shell.addShell(new Shell_history());
			shell.addShell(new Shell_print());
			shell.addShell(new Shell_help());
			shell.addShell(new Shell_mcl());
			shell.addShell(new Shell_stree());
			rootShell = shell;
			currentShell = shell;
			shell = null;
		}
		
		public function show(view:DisplayObjectContainer = null):Boolean
		{
			return _view.show(view);
		}
		
		public function exec(...parameters):Object
		{
			var type:int = _shellControllerData._type, tag:int = _shellControllerData._tag, str:String = "", obj:Object, shellObjectArr:Array;
			for (var i:uint = 0, j:uint = 0, l:uint = parameters.length; i < l; i++) {
				obj = parameters[i];
				if (!(obj is ShellObject)) str += i === 0 ? obj : (" " + obj);
				else {
					if (obj.type !== -1) {
						if (j === 0) shellObjectArr = [];
						shellObjectArr[j++] = obj;
					}
					else {
						type = obj.obj;
					}
				}
			}
			obj = null;
			parameters = null;
			return parseShell(str, shellObjectArr, null, true, type, tag);
		}
		
		public function print(...parameters):Object
		{
			return exec.apply(null, ["print"].concat(parameters));
		}
		
		override public function addMessage(...parameters):void
		{
			if (_shellControllerData._messageType !== ShellControllerEnum.MESSAGE_NO) {
				_view.appendLine(parameters, uint.MAX_VALUE, _shellControllerData._type, _shellControllerData._tag);
			}
			super.addMessage.apply(null, parameters);
			parameters = null;
		}
		
		override public function clear():void
		{
			super.clear();
			if (null !== _view) _view.clear();
			_view = null;
		}
	}
}

internal namespace shell_internal = "1500821a06f913bd7c019689e2f34c6dcb4b3e0bce0b241c206edb0bdbf6462f";