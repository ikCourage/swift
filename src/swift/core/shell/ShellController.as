package swift.core.shell
{
	import org.aisy.interfaces.IClear;
	
	use namespace shell_internal;

	public class ShellController implements IClear
	{
		static protected const S:Vector.<int> = new Vector.<int>(161, true);
		S[9] = 1;// \t
		S[10] = 1;// \n
		S[13] = 1;// \r
		S[32] = 1;// " "
		S[160] = 1;// &#160;
		
		shell_internal var _shellControllerData:ShellControllerData;
		
		public function ShellController()
		{
			_shellControllerData = new ShellControllerData();
		}
		
		static public function parseString(str:String, tag:int = 1):Array
		{
			var a:int, i:int, j:int, k:int, l:int, p:int, p2:int, len:int = str.length, vIndex:int, vtIndex:int;
			var v:Array = [], vs:Array = [], vo:Array = [], vt:Array = [], v2:Array, v3:Array, v4:Array, str2:String;
			while (p < len) {
				while ((a = str.charCodeAt(p)) < 161 && S[a]) if (++p >= len) break;
				k = -1;
				if (a === 40) {
					if (str.charAt(++p) === '[') {
						k = ++p;
						l = 1;
						do {
							l--;
							i = str.indexOf("])", k);
							if (i !== -1) {
								j = str.indexOf("([", k);
								if (j !== -1 && j < i) {
									k = i + 2;
									l++;
								}
								else if (l === 0) {
									if (p !== i) v[vIndex++] = [p, i, 1];
									p = i + 2;
									k = -1;
								}
							}
							else {
								k = p - 2;
								break;
							}
						} while (l > 0);
					}
					else {
						k = p - 1;
					}
				}
				else {
					k = p;
				}
				if (k !== -1) {
					i = k;
					j = 0;
					while (p < len) {
						a = str.charCodeAt(p);
						if (tag === 1 && a === 60) {
							if (j === 0) j = 2;
							if (i !== p) v[vIndex++] = [i, p, j];
							i = p;
							j = 3;
						}
						else if (tag === 1 && a === 62) {
							if (j === 0) j = 2;
							if (i !== p) v[vIndex++] = [i, p, j];
							i = p;
							j = 4;
						}
						else if (a < 161 && S[a]) break;
						p++;
					}
					if (i !== p) v[vIndex++] = [i, p++, j];
				}
			}
			a = 0;
			k = 0;
			l = 0;
			p = -1;
			len = 0;
			for (i = 0; i < vIndex; i++) {
				v2 = v[i];
				a = v2[2];
				if (p === -1) {
					p = i;
				}
				if (k === 0) {
					k = a;
				}
				switch (a) {
					case 0:
						if (k === 0) {
							vs[len] = str.substring(v2[0], v2[1]);
							vo[len++] = str.substring(p2, v2[1]);
							p2 = v2[1];
							p = -1;
						}
						break;
					case 1:
						if (i !== p) {
							v3 = v[p];
							a = v3[1];
							for (j = p + 1; j < i; j++) {
								v4 = v[j];
								if (a !== v4[0]) {
									vs[len] = str.substring(v3[0], v[j - 1][1]);
									vo[len++] = str.substring(p2, v[j - 1][1]);
									p2 = v[j - 1][1];
									v3 = v4;
									a = v4[1];
									p = j;
								}
							}
							if (p < j) {
								vs[len] = str.substring(v3[0], v[j - 1][1]);
								vo[len++] = str.substring(p2, v[j - 1][1]);
								p2 = v[j - 1][1];
							}
						}
						vs[len] = str.substring(v2[0], v2[1]);
						vo[len++] = str.substring(p2, v2[1] + 2);
						p2 = v2[1] + 2;
						p = -1;
						k = 0;
						break;
					case 3:
						l++;
						a = 0;
						for (j = i + 1; j < vIndex; j++) {
							switch (v[j][2]) {
								case 4:
									l--;
									if (l === 0) {
										str2 = str.substring(v[p][0] , v2[0]);
										if (v[j][0] + 1 !== v[j][1]) {
											str2 += str.substring(v[j][0] + 1, v[j][1]);
										}
										vt[vtIndex++] = [str.substring(v2[0] + 1, v[j][0]), len];
										vs[len] = str2;
										vo[len++] = str.substring(p2, v[p][0]) + str2;
										p2 = v[j][1];
										
										i = j;
										k = 0;
										p = -1;
										a = -1;
									}
									break;
								case 3:
									l++;
									break;
								case 1:
									vs[len] = str.substring(v[p][0], v[j - 1][1]);
									vo[len++] = str.substring(p2, v[j - 1][1]);
									p2 = v[j - 1][1];
									vs[len] = str.substring(v[j][0], v[j][1]);
									vo[len++] = str.substring(p2, v[j][1]);
									p2 = v[j][1];
									i = j - 1;
									k = 0;
									l = 0;
									a = -1;
									break;
							}
							if (a === -1) break;
						}
						break;
					case 4:
						l--;
						break;
				}
			}
			if (l !== 0) {
				v3 = v[p];
				a = v3[1];
				for (j = p + 1; j < i; j++) {
					v4 = v[j];
					if (a !== v4[0]) {
						a = v4[1];
						vs[len] = str.substring(v3[0], v[j - 1][1]);
						vo[len++] = str.substring(p2, v[j - 1][1]);
						p2 = v[j - 1][1];
						v3 = v4;
						p = j;
					}
				}
				if (p < j) {
					vs[len] = str.substring(v3[0], v[j - 1][1]);
					vo[len++] = str.substring(p2, v[j - 1][1]);
					p2 = v[j - 1][1];
				}
			}
			v = null;
			v2 = null;
			v3 = null;
			v4 = null;
			str2 = null;
			str = null;
			return [vs, vo, vt];
		}
		
		/**
		 * 
		 * @param v
		 * @param shell
		 * @return Error or Object
		 * 
		 */
		static public function getopt(v:Array, shell:Shell = null):Object
		{
			var i:int, j:int, k:int, l:int = v.length, m:int, n:int, o:int, optStr:String, opt_0:Vector.<String>, opt_1:Vector.<int>, opt:Array, args_0:Array = [], args_1:Array = [];
			if (null !== shell) {
				opt = shell.option;
				if (null !== opt) {
					opt_0 = opt[0] as Vector.<String>;
					opt_1 = opt[1] as Vector.<int>;
					o = opt_1.length;
				}
				opt = null;
				shell = null;
			}
			for (; i < l;) {
				optStr = v[i++];
				if (optStr.charCodeAt(0) === 45) {
					m = 1;
					n = optStr.length;
					while (optStr.charCodeAt(m) === 45) if (++m >= n) break;
					if (m !== n) {
						optStr = optStr.substring(m);
						args_1[k] = [optStr];
						if (o !== 0) {
							for (m = 0; m < o; m++) {
								if (optStr === opt_0[m]) {
									switch (opt_1[m]) {
										case 1:
											if (i < l) {
												args_1[k][1] = v[i++];
											}
											else {
												return new Error(optStr + ": need an argument");
											}
											break;
										case 2:
											if (i < l) {
												args_1[k][1] = v[i++];
											}
											break;
									}
									break;
								}
							}
						}
						k++;
					}
				}
				else {
					args_0[j++] = optStr;
				}
			}
			var args:Vector.<Array> = new Vector.<Array>();
			args[0] = args_0;
			args[1] = args_1;
			args_0 = null;
			args_1 = null;
			opt_0 = null;
			opt_1 = null;
			optStr = null;
			v = null;
			return args;
		}
		
		/**
		 * 
		 * @param type
		 * @param str
		 * @param shellObjectArr
		 * @param shell
		 * @param transparent
		 * @return Error or Object
		 * 
		 */
		public function parseShell(str:String, shellObjectArr:Array = null, shell:Shell = null, transparent:Boolean = true, type:int = -1, tag:int = -1):Object
		{
			var result:Object;
			var v:Array = parseString(str, tag)[0];
			if (v.length !== 0) {
				var cmd:String = v[0];
				shell = null === shell ? _shellControllerData._currentShell : shell;
				shell = shell.getShellByCommand(cmd, transparent);
				if (null === shell) {
					result = new Error(cmd + ": command not found");
				}
				else {
					v.reverse();
					v.length--;
					v.reverse();
					result = getopt(v, shell);
					v = null;
					if (result is Vector.<Array>) {
						result[2] = shellObjectArr;
						var l:int = cmd.length + 1, len:int = str.length;
						if (l < len) {
							var a:int, p:int = str.indexOf(cmd) + l;
							while ((a = str.charCodeAt(p)) < 161 && S[a]) if (++p >= len) break;
							str = str.substring(p);
						}
						else {
							str = "";
						}
						result = doShell(shell, type, str, result);
					}
				}
				cmd = null;
			}
			v = null;
			str = null;
			shellObjectArr = null;
			shell = null;
			return result;
		}
		
		/**
		 * 
		 * @param shell
		 * @param type 类型
		 * @param parameters
		 * @return 
		 * 
		 */
		public function doShell(shell:Shell, type:int = 0, ...parameters):Object
		{
			var arr:Array = [parameters[0]];
			if (parameters[1] is Vector.<Array>) {
				var v:Array = parameters[1][2];
				if (null !== v) {
					var l:int = v.length;
					if (l !== 0) {
						var i:int, j:int, shellObject:ShellObject, shellObjectArr:Array;
						for (i = 0; i < l; i++) {
							shellObject = v[i];
							if (shellObject.type !== 0) {
								if (j === 0) shellObjectArr = [];
								shellObjectArr[j++] = shellObject;
							}
						}
						if (j !== 0) {
							arr[1] = shellObjectArr;
						}
						shellObject = null;
						shellObjectArr = null;
					}
					v = null;
				}
			}
			addMessage(ExecutorEnum.COMMAND, _shellControllerData._currentShell, shell, type, arr);
			arr = null;
			if (shell !== _shellControllerData._lastShell) {
				_shellControllerData._lastShell = shell;
			}
			if (null === shell.callback) return new Error("Command can not be executed");
			var len:int = shell.callback.length;
			if (len === 0) return shell.callback();
			else if (len === 1) return shell.callback(parameters[0]);
			return shell.callback.apply(null, parameters.length === len ? parameters : parameters.slice(0, len));
		}
		
		public function get rootShell():Shell
		{
			return _shellControllerData._rootShell;
		}
		
		public function set rootShell(value:Shell):void
		{
			value._shellData._shellController = this;
			_shellControllerData._rootShell = value;
			value = null;
		}
		
		public function get currentShell():Shell
		{
			return _shellControllerData._currentShell;
		}
		
		public function set currentShell(value:Shell):void
		{
			value._shellData._shellController = this;
			_shellControllerData._currentShell = value;
			value = null;
		}
		
		public function set executor(value:Object):void
		{
			if (null === value) throw new Error("executor is null");
			if (_shellControllerData._executorType === ShellControllerEnum.EXECUTOR_ADD) {
				var len:int, executor:Executor, executors:Vector.<Executor> = _shellControllerData._executors;
				if (null === executors) {
					executors = new Vector.<Executor>();
					_shellControllerData._executors = executors;
				}
				else {
					len = executors.length;
					executor = executors[len - 1];
				}
				if (null === executor || executor.source !== value) {
					executor = new Executor();
					executor._source = value;
					executors[len] = executor;
				}
				executor = null;
				executors = null;
			}
			_shellControllerData._executorType = ShellControllerEnum.EXECUTOR_DEFAULT;
			var f:Function = _shellControllerData._executorF;
			if (null !== f) {
				f();
				f = null;
			}
			value = null;
		}
		
		public function addMessage(...parameters):void
		{
			if (_shellControllerData._messageType === ShellControllerEnum.MESSAGE_ADD) {
				var executors:Vector.<Executor> = _shellControllerData._executors;
				if (null !== executors) {
					_shellControllerData._messageLength++;
					executors[executors.length - 1].addMessage(parameters);
					executors = null;
				}
			}
			_shellControllerData._messageType = ShellControllerEnum.MESSAGE_DEFAULT;
			var f:Function = _shellControllerData._messageF;
			if (null !== f) {
				f();
				f = null;
			}
			parameters = null;
		}
		
		public function clear():void
		{
			if (null !== _shellControllerData) _shellControllerData.clear();
			_shellControllerData = null;
		}
		
	}
}

internal namespace shell_internal = "1500821a06f913bd7c019689e2f34c6dcb4b3e0bce0b241c206edb0bdbf6462f";