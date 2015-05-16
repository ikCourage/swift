package swift.core.shell.sbin
{
	import flash.system.System;
	
	import swift.core.shell.Executor;
	import swift.core.shell.ExecutorEnum;
	import swift.core.shell.Shell;
	import swift.core.shell.ShellControllerEnum;
	import swift.core.shell.ShellObject;
	
	use namespace shell_internal;

	public class Shell_history extends Shell
	{
		public function Shell_history()
		{
			name = command = "history";
			option = [
				"c", 2,
				"cy", 1,
				"s", 1,
				"e", 1,
				"l", 1,
				"f", 1
			];
			callback = __exec;
			description = "历史记录\n" +
				"c 清空\n" +
				"cy 拷贝记录 二级参数（可以包含这以下字符或只含一个）：\n" +
				"    r 返回历史记录\n" +
				"    y 复制到剪切版\n" +
				"    m 返回的记录只包含消息部分\n" +
				"    s 返回的记录只包含执行对象部分\n" +
				"    p 返回的记录只包含路径部分\n" +
				"s 开始记录序号\n" +
				"e 结束记录序号\n" +
				"l 记录个数\n" +
				"f 过滤条件：\n" +
				"    默认不区分大小写\n" +
				"    ([a b c]) 这样来包含空格\n" +
				"    ([$abc ig]) 这样来设置正则匹配方式\n" +
				"    默认只查找消息部分\n" +
				"    :1 过滤指定数字的 type\n" +
				"    =abc 或 =$abc 来查找执行对象部分\n" +
				"    ~ 来查找路径部分（貌似根本用不到）\n" +
				"    + 来查找全部 消息 执行对象 路径";
		}
		
		protected function __exec(str:String, args:Vector.<Array>):Object
		{
			str = "";
			var i:int, s:int, l:int, m:int, n:int, len:int = args[1].length, cy:String, str2:String, filter:Array, filterObj:*, filterObj2:*;
			var executors:Vector.<Executor> = shellController._shellControllerData._executors;
			for (i = 0; i < len; i++) {
				switch (args[1][i][0]) {
					case "c":
						shellController._shellControllerData._messageType = ShellControllerEnum.MESSAGE_NO;
						shellController.parseShell(".cli " + command + " -c" + ((args[1][i] as Array).length === 1 ? "" : " " + args[1][i][1]));
						shellController._shellControllerData._messageType = ShellControllerEnum.MESSAGE_DEFAULT;
						shellController._shellControllerData._executors = null;
						return null;
						break;
					case "s":
						s = int(args[1][i][1]);
						break;
					case "e":
						l = int(args[1][i][1]) - s;
						break;
					case "l":
						l = int(args[1][i][1]);
						break;
					case "cy":
						cy = (null !== cy ? cy : "") + args[1][i][1];
						break;
					case "f":
						filterObj = null;
						str2 = args[1][i][1].replace(/^\s+|\s+$/ig, "");
						switch (str2.charAt(0)) {
							case "=":
							case "+":
							case "~":
							case ":":
								filterObj = {"mode": str2.charAt(0)};
								str2 = str2.substring(1).replace(/^\s+|\s+$/ig, "");
								break;
						}
						switch (str2.charAt(0)) {
							case "$":
								str2 = str2.substring(1).replace(/^\s+|\s+$/ig, "");
								if (str2.length) {
									filterObj2 = str2.split(/\s+/);
									filterObj2 = new RegExp(filterObj2[0], filterObj2[1] ? filterObj2[1] : "i");
									if (null === filterObj) filterObj = filterObj2;
									else filterObj.reg = filterObj2;
								}
								break;
							default:
								filterObj2 = new RegExp(str2, "i");
								if (null === filterObj) filterObj = filterObj2;
								else filterObj.reg = filterObj2;
								break;
						}
						if (null !== filterObj) {
							if (null === filter) filter = [];
							filter[n++] = filterObj;
						}
						filterObj = null;
						filterObj2 = null;
						str2 = null;
						break;
				}
			}
			if (null !== cy) {
				if (null === executors) return null;
				var b:int, j:int, k:int, type:int, mLen:int, source:String, msg:String, path:String = __getPath(), arr:Vector.<Array> = new Vector.<Array>(), message:Vector.<Array>, executor:Executor, format:Object;
				var _m:int = cy.indexOf("m") == -1 ? 0 : 1, _s:int = cy.indexOf("s") == -1 ? 0 : 1, _p:int = cy.indexOf("p") == -1 ? 0 : 1;
				len = executors.length;
				if (_m + _s + _p == 0) {
					_m = _s = _p = 1;
				}
				format = {"message": _m, "source": _s, "path": _p};
				for (i = 0; i < len; i++) {
					executor = executors[i];
					message = executor._message;
					if (null !== message) {
						source = executor.source.toString();
						for (j = 0, mLen = message.length; j < mLen; j++) {
							if (s === 0) {
								b = 1;
								if (message[j][0][0] is ExecutorEnum) {
									path = __getPath(message[j][0][1]);
									msg = (message[j][0][2] as Shell).command;
									type = message[j][0][3];
									str2 = message[j][0][4][0];
									if (null !== str2 && str2.length !== 0) {
										msg += " " + str2;
									}
								}
								else {
									path = __getPath();
									type = ShellControllerEnum.TYPE_DEFAULT;
									msg = message[j].toString();
								}
								if (n !== 0) {
									b = 0;
									for (m = 0; m < n; m++) {
										filterObj = filter[m];
										if (filterObj is RegExp) {
											if (filterObj.test(msg)) b++;
										}
										else if (filterObj is Object) {
											switch (filterObj.mode) {
												case "=":
													if (filterObj.reg.test(source)) b++;
													break;
												case "+":
													if (filterObj.reg.test(msg) || filterObj.reg.test(source) || filterObj.reg.test(path)) b++;
													break;
												case "~":
													if (filterObj.reg.test(path)) b++;
													break;
												case ":":
													if (filterObj.reg.test(String(type))) b++;
													break;
												default:
													if (filterObj.reg.test(msg)) b++;
													break;
											}
										}
									}
									b = b == n ? 1 : 0;
									filterObj = null;
								}
								if (b === 1) {
									arr[k] = [path, source, msg, uint.MAX_VALUE, type, shellController._shellControllerData._tag, format];
									if (k !== 0) str += "\n";
									if (_p != 0) {
										str += path;
										if (_m + _s != 0) {
											str += " % ";
										}
									}
									if (_s != 0) {
										str += source;
										if (_m != 0) {
											str += ":  ";
										}
									}
									if (_m != 0) {
										str += msg;
									}
									k++;
								}
								if (l !== 0) if (k === l) break;
							}
							else {
								s--;
							}
						}
						if (l !== 0) if (k === l) break;
					}
				}
				filter = null;
				str2 = null;
				executors = null;
				executor = null;
				format = null;
				source = null;
				path = null;
				msg = null;
				message = null;
				if (cy.indexOf("y") !== -1) {
					System.setClipboard(str);
				}
				if (cy.indexOf("r") !== -1) {
					cy = null;
					args = null;
					return ShellObject.newObj([arr, str], -2);
				}
				cy = null;
			}
			filter = null;
			executors = null;
			str = null;
			args = null;
			return null;
		}
		
		protected function __getPath(shell:Shell = null):String
		{
			if (null === shell) shell = shellController.currentShell;
			var p:String = shell.name;
			while (shell = shell.parent) p = shell.name + "/" + p;
			shell = null;
			return p;
		}
		
	}
}

internal namespace shell_internal = "1500821a06f913bd7c019689e2f34c6dcb4b3e0bce0b241c206edb0bdbf6462f";