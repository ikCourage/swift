package swift.core.magic
{
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	import org.ais.event.TEvent;
	import org.aisy.interfaces.IClear;
	
	use namespace magic_internal;

	public class MagicVM
	{
		public function MagicVM()
		{
		}
		
		static magic_internal function compileCastObj(cmds:Array, i:uint, l:uint):void
		{
			var key:String, obj:*;
			for (; i < l; i++) {
				key = cmds[i] as String;
				switch (key) {
					case "true":
						cmds[i] = true;
						break;
					case "false":
						cmds[i] = false;
						break;
					case "null":
						cmds[i] = null;
						break;
					case "undefined":
						cmds[i] = undefined;
						break;
					case "NaN":
						cmds[i] = NaN;
						break;
					default:
						if (/^[\+|\-]?\d+$/g.test(key) === true) {
							obj = parseInt(key);
							if (obj > int.MAX_VALUE) {
								cmds[i] = uint(obj);
							}
							else {
								cmds[i] = int(obj);
							}
						}
						else if (/^[\+\-]?\d*\.?\d+(e|e\+\d+)?$/g.test(key) === true) {
							cmds[i] = parseFloat(key);
						}
						else if (/^[\+\-]?0?[xX][\da-fA-F]+$/.test(key) === true) {
							switch (key.charAt(0)) {
								case "+":
									obj = parseInt(key.charAt(1) !== "0" ? ("0" + key.substr(1)) : key);
									break;
								case "-":
									obj = parseInt(key.charAt(1) !== "0" ? ("-0" + key.substr(1)) : key);
									break;
								default:
									obj = parseInt(key.charAt(0) !== "0" ? ("0" + key) : key);
									break;
							}
							if (obj > int.MAX_VALUE) {
								cmds[i] = uint(obj);
							}
							else {
								cmds[i] = int(obj);
							}
						}
						break;
				}
			}
			key = null;
			obj = null;
			cmds = null;
		}
		
		static magic_internal function delObj(sData:Dictionary, currentVarData:MagicVarData, values:Array):void
		{
			var i:uint = 1, j:uint, l:uint = values.length, n:uint, key:String, v:Vector.<String>, obj:*;
			switch (values[0]) {
				case "!":
					for (; i < l; i++) {
						key = values[i];
						switch (key.charAt(0)) {
							case "$":
								v = Vector.<String>(key.substr(1).split("."));
								n = v.length - 1;
								if (n === 0) {
									key = getObj(sData, currentVarData, v[0]);
									obj = currentVarData.getVars(key, true);
								}
								else {
									obj = currentVarData.getVars(getObj(sData, currentVarData, v[0]), true);
									if (null !== obj) {
										for (j = 1; j < n; j++) {
											obj = obj[getObj(sData, currentVarData, v[j])];
										}
										key = getObj(sData, currentVarData, v[j]);
									}
								}
								if (null !== obj) {
									delete obj[key];
								}
								break;
						}
					}
					break;
				case "!!":
					var o:Object;
					for (; i < l; i++) {
						key = values[i];
						switch (key.charAt(0)) {
							case "$":
								v = Vector.<String>(key.substr(1).split("."));
								n = v.length - 1;
								if (n === 0) {
									key = getObj(sData, currentVarData, v[0]);
									obj = currentVarData.getVars(key, true);
								}
								else {
									obj = currentVarData.getVars(getObj(sData, currentVarData, v[0]), true);
									if (null !== obj) {
										for (j = 1; j < n; j++) {
											obj = obj[getObj(sData, currentVarData, v[j])];
										}
										key = getObj(sData, currentVarData, v[j]);
									}
								}
								if (null !== obj) {
									o = obj[key];
									if (o is IClear) IClear(o).clear();
									delete obj[key];
									o = null;
								}
								break;
						}
					}
					o = null;
					break;
			}
			key = null;
			v = null;
			obj = null;
			sData = null;
			currentVarData = null;
			values = null;
		}
		
		static magic_internal function setObj(sData:Dictionary, currentVarData:MagicVarData, key:String, value:*):void
		{
			var i:uint = 1, l:uint, v:Vector.<String> = Vector.<String>(key.substr(1).split(".")), obj:*;
			l = v.length - 1;
			switch (key.charAt(0)) {
				case "$":
					if (l === 0) {
						key = getObj(sData, currentVarData, v[0]);
						obj = currentVarData.getVars(key, true);
						if (null === obj) {
							if (null === currentVarData.vars) {
								currentVarData.vars = new Dictionary();
							}
							obj = currentVarData.vars;
						}
						obj[key] = value;
					}
					else {
						obj = currentVarData.getVar(getObj(sData, currentVarData, v[0]), true);
						for (; i < l; i++) {
							obj = obj[getObj(sData, currentVarData, v[i])];
						}
						obj[getObj(sData, currentVarData, v[i])] = value;
					}
					break;
				case "@":
					if (null !== sData) {
						if (l === 0) {
							sData[getObj(sData, currentVarData, v[0])] = value;
						}
						else {
							obj = sData[getObj(sData, currentVarData, v[0])];
							for (; i < l; i++) {
								obj = obj[getObj(sData, currentVarData, v[i])];
							}
							obj[getObj(sData, currentVarData, v[i])] = value;
						}
					}
					break;
			}
			v = null;
			obj = null;
			sData = null;
			currentVarData = null;
			key = null;
			value = null;
		}
		
		static magic_internal function getPro(sData:Dictionary, currentVarData:MagicVarData, obj:Object, pros:Vector.<String>):*
		{
			var j:int, l_2:uint, s:String, ns:Namespace;
			for (var i:uint, l:uint = pros.length; i < l; i++) {
				s = pros[i];
				l_2 = s.length;
				if (l_2 > 3) {
					j = s.indexOf("::");
					if (j > 0 && j + 2 < l_2) {
						ns = getObj(sData, currentVarData, s.substr(0, j)) as Namespace;
						if (null !== ns) {
							obj = obj.ns::[getObj(sData, currentVarData, s.substr(j + 2))];
							ns = null;
							continue;
						}
					}
				}
				obj = obj[getObj(sData, currentVarData, s)];
			}
			s = null;
			ns = null;
			sData = null;
			currentVarData = null;
			pros = null;
			return obj;
		}
		
		static magic_internal function getObj(sData:Dictionary, currentVarData:MagicVarData, key:*, ...parameters):*
		{
			if ((key is String) === false) {
				if (parameters.length !== 0) {
					for (i = 0, l = parameters.length; i < l; i++) {
						parameters[i] = getObj(sData, currentVarData, parameters[i]);
					}
					parameters.reverse();
					parameters[l] = key;
					parameters.reverse();
					sData = null;
					currentVarData = null;
					key = null;
					return parameters;
				}
				sData = null;
				currentVarData = null;
				parameters = null;
				return key;
			}
			var i:int, k:String = key, obj:* = null;
			switch (k.charAt(0)) {
				case "$":
					i = k.indexOf(".");
					obj = currentVarData.getVar(k.substring(1, i === -1 ? k.length : i), true);
					if (i !== -1) {
						obj = getPro(sData, currentVarData, obj, Vector.<String>(k.substr(i + 1).split(".")));
					}
					break;
				case "@":
					if (null !== sData) {
						i = k.indexOf(".");
						obj = k.substring(1, i === -1 ? k.length : i);
						if (sData.hasOwnProperty(obj) === true) {
							obj = sData[obj];
							if (i !== -1) {
								obj = getPro(sData, currentVarData, obj, Vector.<String>(k.substr(i + 1).split(".")));
							}
						}
						else {
							obj = null;
						}
					}
					break;
				case "^":
					obj = currentVarData.getFun(getObj(sData, currentVarData, k.substr(1)), true);
					if (null !== obj) {
						obj = MagicFunctionUtil.create(exec, obj as MagicFunctionData, sData, currentVarData);
					}
					break;
				case "~":
					k = k.substr(1);
					i = k.indexOf(":");
					obj = getDefinitionByName(getObj(sData, currentVarData, i === -1 ? k : k.substring(0, i)));
					if (i !== -1) {
						obj = getPro(sData, currentVarData, obj, Vector.<String>(k.substr(i + 1).split(".")));
					}
					break;
				case "#":
					var l:uint = parameters.length;
					for (i = 0; i < l; i++) {
						parameters[i] = getObj(sData, currentVarData, parameters[i]);
					}
					obj = MagicClassUtil.create(getObj(sData, currentVarData, k.substr(1)), parameters);
					break;
				default:
					switch (k) {
						case "true":
							obj = true;
							break;
						case "false":
							obj = false;
							break;
						case "null":
							obj = null;
							break;
						case "undefined":
							obj = undefined;
							break;
						case "NaN":
							obj = NaN;
							break;
						default:
							if (/^[\+|\-]?\d+$/g.test(k) === true) {
								obj = parseInt(k);
								if (obj > int.MAX_VALUE) {
									obj = uint(obj);
								}
								else {
									obj = int(obj);
								}
							}
							else if (/^[\+\-]?\d*\.?\d+(e|e\+\d+)?$/g.test(k) === true) {
								obj = parseFloat(k);
							}
							else if (/^[\+\-]?0?[xX][\da-fA-F]+$/.test(k) === true) {
								switch (k.charAt(0)) {
									case "+":
										obj = parseInt(k.charAt(1) !== "0" ? ("0" + k.substr(1)) : k);
										break;
									case "-":
										obj = parseInt(k.charAt(1) !== "0" ? ("-0" + k.substr(1)) : k);
										break;
									default:
										obj = parseInt(k.charAt(0) !== "0" ? ("0" + k) : k);
										break;
								}
								if (obj > int.MAX_VALUE) {
									obj = uint(obj);
								}
								else {
									obj = int(obj);
								}
							}
							else {
								obj = k.replace(/^[\"\']|[\"\']$/g, "");
								if (parameters.length !== 0) {
									for (i = 0, l = parameters.length; i < l; i++) {
										parameters[i] = getObj(sData, currentVarData, parameters[i]);
									}
									parameters.reverse();
									parameters[l] = obj;
									parameters.reverse();
									obj = parameters;
								}
							}
							break;
					}
					break;
			}
			k = null;
			sData = null;
			currentVarData = null;
			key = null;
			parameters = null;
			return obj;
		}
		
		static magic_internal function setOp(sData:Dictionary, currentVarData:MagicVarData, values:Array):void
		{
			var i:uint = 2, l:uint = values.length, o:* = getObj(sData, currentVarData, values[1]);
			switch (values[0]) {
				case "+":
					for (; i < l; i++) {
						o += getObj(sData, currentVarData, values[i]);
					}
					setObj(sData, currentVarData, values[1], o);
					break;
				case "-":
					for (; i < l; i++) {
						o -= getObj(sData, currentVarData, values[i]);
					}
					setObj(sData, currentVarData, values[1], o);
					break;
				case "*":
					for (; i < l; i++) {
						o *= getObj(sData, currentVarData, values[i]);
					}
					setObj(sData, currentVarData, values[1], o);
					break;
				case "/":
					for (; i < l; i++) {
						o /= getObj(sData, currentVarData, values[i]);
					}
					setObj(sData, currentVarData, values[1], o);
					break;
				case "%":
					for (; i < l; i++) {
						o %= getObj(sData, currentVarData, values[i]);
					}
					setObj(sData, currentVarData, values[1], o);
					break;
				case "++":
					setObj(sData, currentVarData, values[1], o + 1);
					for (; i < l; i++) {
						setObj(sData, currentVarData, values[i], getObj(sData, currentVarData, values[i]) + 1);
					}
					break;
				case "--":
					setObj(sData, currentVarData, values[1], o - 1);
					for (; i < l; i++) {
						setObj(sData, currentVarData, values[i], getObj(sData, currentVarData, values[i]) - 1);
					}
					break;
				case "^":
					for (; i < l; i++) {
						o ^= getObj(sData, currentVarData, values[i]);
					}
					setObj(sData, currentVarData, values[1], o);
					break;
				case "~":
					if (l > 2) {
						o = doOp(sData, currentVarData, values.slice(2));
					}
					setObj(sData, currentVarData, values[1], ~o);
					break;
				case "|":
					for (; i < l; i++) {
						o |= getObj(sData, currentVarData, values[i]);
					}
					setObj(sData, currentVarData, values[1], o);
					break;
				case "&":
					for (; i < l; i++) {
						o &= getObj(sData, currentVarData, values[i]);
					}
					setObj(sData, currentVarData, values[1], o);
					break;
				case "<<":
					for (; i < l; i++) {
						o <<= getObj(sData, currentVarData, values[i]);
					}
					setObj(sData, currentVarData, values[1], o);
					break;
				case ">>":
					for (; i < l; i++) {
						o >>= getObj(sData, currentVarData, values[i]);
					}
					setObj(sData, currentVarData, values[1], o);
					break;
				case ">>>":
					for (; i < l; i++) {
						o = o >>> getObj(sData, currentVarData, values[i]);
					}
					setObj(sData, currentVarData, values[1], o);
					break;
				case "||":
					for (; i < l; i++) {
						o ||= getObj(sData, currentVarData, values[i]);
					}
					setObj(sData, currentVarData, values[1], o);
					break;
				case "&&":
					for (; i < l; i++) {
						o &&= getObj(sData, currentVarData, values[i]);
					}
					setObj(sData, currentVarData, values[1], o);
					break;
				case "as":
					setObj(sData, currentVarData, values[1], o as doOp(sData, currentVarData, values.slice(2)));
					break;
				case "cast":
					setObj(sData, currentVarData, values[1], doOp(sData, currentVarData, values.slice(2))(o));
					break;
				case "typeof":
					if (l > 2) {
						o = doOp(sData, currentVarData, values.slice(2));
					}
					setObj(sData, currentVarData, values[1], typeof(o));
					break;
			}
			o = null;
			sData = null;
			currentVarData = null;
			values = null;
		}
		
		static magic_internal function doOp(sData:Dictionary, currentVarData:MagicVarData, values:Array):*
		{
			if (values.length === 0) return void;
			var o:* = void;
			switch (values[0]) {
				case "=":
					setObj(sData, currentVarData, values[1], doOp(sData, currentVarData, values.slice(2)));
					break;
				case "+":
				case "-":
				case "*":
				case "/":
				case "%":
				case "++":
				case "--":
				case "^":
				case "~":
				case "|":
				case "&":
				case "<<":
				case ">>":
				case ">>>":
				case "||":
				case "&&":
				case "as":
				case "cast":
				case "typeof":
					setOp(sData, currentVarData, values);
					break;
				case "!":
				case "!!":
					delObj(sData, currentVarData, values);
					break;
				case "fi":
					o = doOp(sData, currentVarData, values.slice(2));
					if (null !== o) {
						var i:uint, arr:Array = [], k:*;
						for (k in o) {
							arr[i++] = k;
						}
						setObj(sData, currentVarData, values[1], arr);
						arr = null;
						k = null;
						o = null;
					}
					break;
				case "fe":
					o = doOp(sData, currentVarData, values.slice(2));
					if (null !== o) {
						i = 0;
						arr = [];
						for each (k in o) {
							arr[i++] = k;
						}
						setObj(sData, currentVarData, values[1], arr);
						arr = null;
						k = null;
						o = null;
					}
					break;
				case "fei":
					o = doOp(sData, currentVarData, values.slice(2));
					if (null !== o) {
						i = 0;
						arr = [];
						for (k in o) {
							arr[i++] = [k, o[k]];
						}
						setObj(sData, currentVarData, values[1], arr);
						arr = null;
						k = null;
						o = null;
					}
					break;
				case "p":
					TEvent.trigger("MAGICVM", "p", doOp(sData, currentVarData, values.slice(1)));
					break;
				case "throw":
					throw Error(doOp(sData, currentVarData, values.slice(1)));
					break;
				default:
					if (values[0] is String) {
						switch ((values[0] as String).charAt(0)) {
							case ":":
								i = 1;
								arr = [];
								for (var j:uint, l:uint = values.length; i < l; i++, j++) {
									arr[j] = getObj(sData, currentVarData, values[i]);
								}
								o = getObj(sData, currentVarData, (values[0] as String).substr(1));
								if (o is Function) {
									o = (o as Function).apply(null, arr);
								}
								else {
									o = currentVarData.getFun(getObj(sData, currentVarData, o), true);
									if (null !== o) {
										o = exec.apply(null, [o, sData, currentVarData, o].concat(arr));
									}
									else {
										o = void;
									}
								}
								arr = null;
								break;
							default:
								o = getObj.apply(null, [sData, currentVarData].concat(values));
								break;
						}
					}
					else if (values.length === 1) {
						o = values[0];
					}
					else {
						o = getObj.apply(null, [sData, currentVarData].concat(values));
					}
					break;
			}
			sData = null;
			currentVarData = null;
			values = null;
			return o;
		}
		
		static magic_internal function doIf(sData:Dictionary, currentVarData:MagicVarData, values:Array):Boolean
		{
			var b:Boolean, o:* = getObj(sData, currentVarData, values[2]);
			switch (values[1]) {
				case "=":
				case "==":
					if (values.length === 3) {
						if (o) {
							b = true;
						}
					}
					else {
						b = true;
						for (var i:uint = 3, l:uint = values.length; i < l; i++) {
							if (o != getObj(sData, currentVarData, values[i])) {
								b = false;
								break;
							}
						}
					}
					break;
				case "===":
					if (values.length === 3) {
						if (o) {
							b = true;
						}
					}
					else {
						b = true;
						for (i = 3, l = values.length; i < l; i++) {
							if (o !== getObj(sData, currentVarData, values[i])) {
								b = false;
								break;
							}
						}
					}
					break;
				case "!":
				case "!=":
					if (values.length === 3) {
						if (!o) {
							b = true;
						}
					}
					else {
						b = true;
						for (i = 3, l = values.length; i < l; i++) {
							if (o == getObj(sData, currentVarData, values[i])) {
								b = false;
								break;
							}
						}
					}
					break;
				case "!==":
					if (values.length === 3) {
						if (!o) {
							b = true;
						}
					}
					else {
						b = true;
						for (i = 3, l = values.length; i < l; i++) {
							if (o === getObj(sData, currentVarData, values[i])) {
								b = false;
								break;
							}
						}
					}
					break;
				case "<":
					b = true;
					var o2:*;
					for (i = 3, l = values.length; i < l; i++) {
						o2 = getObj(sData, currentVarData, values[i]);
						if (o >= o2) {
							b = false;
							break;
						}
						else {
							o = o2;
						}
					}
					o2 = null;
					break;
				case ">":
					b = true;
					for (i = 3, l = values.length; i < l; i++) {
						o2 = getObj(sData, currentVarData, values[i]);
						if (o <= o2) {
							b = false;
							break;
						}
						else {
							o = o2;
						}
					}
					o2 = null;
					break;
				case "<=":
					b = true;
					for (i = 3, l = values.length; i < l; i++) {
						o2 = getObj(sData, currentVarData, values[i]);
						if (o > o2) {
							b = false;
							break;
						}
						else {
							o = o2;
						}
					}
					o2 = null;
					break;
				case ">=":
					b = true;
					for (i = 3, l = values.length; i < l; i++) {
						o2 = getObj(sData, currentVarData, values[i]);
						if (o < o2) {
							b = false;
							break;
						}
						else {
							o = o2;
						}
					}
					o2 = null;
					break;
				case "is":
					b = true;
					for (i = 3, l = values.length; i < l; i++) {
						if (!(o is getObj(sData, currentVarData, values[i]))) {
							b = false;
							break;
						}
					}
					break;
			}
			o = null;
			sData = null;
			currentVarData = null;
			values = null;
			return b;
		}
		
		static public function exec(f:Object, sData:Dictionary = null, parentVarData:MagicVarData = null, callee:Object = null, ...parameters):*
		{
			var currentFB:MagicFunctionData = f as MagicFunctionData;
			f = null;
			if (null === sData) sData = new Dictionary();
			parameters["callee"] = callee;
			callee = null;
			sData["this"] = currentFB;
			sData["arguments"] = parameters;
			var fromIndex:uint, bIndex:uint, indexVLen:uint, indexV:Vector.<uint> = currentFB.indexV, cmds:Vector.<Array> = currentFB.cmds, args:Array, bk:MagicBlockData = currentFB, bV:Vector.<MagicBlockData>, wV:Vector.<MagicBlockData>, tV:Vector.<MagicBlockData>, tE:Error, sw:*, currentVarData:MagicVarData = new MagicVarData(), tb:MagicTempBlock = new MagicTempBlock(), tbd:MagicTempBlockData;
			currentVarData.fun = currentFB;
			if (null !== parentVarData) {
				currentVarData.parent = parentVarData;
				parentVarData = null;
			}
			bIndex = parameters.length;
			if (bIndex !== 0) {
				currentVarData.vars = new Dictionary();
				for (var j:uint; j < bIndex; j++) {
					currentVarData.vars[currentFB.parameters[j]] = parameters[j];
				}
			}
			if (null !== indexV) {
				indexVLen = indexV.length;
				bIndex = indexV[0];
			}
			else {
				bIndex = uint.MAX_VALUE;
			}
			
			parameters = null;
			
			tbd = tb.getBlockData(bk);
			tbd.flag = true;
			
			for (var i:uint = currentFB.start, l:uint = currentFB.end !== 0 ? currentFB.end : cmds.length; i < l;) {
				if (i === bIndex) {
					i = indexV[fromIndex + 1] + 1;
					fromIndex += 2;
					if (fromIndex === indexVLen) {
						bIndex = uint.MAX_VALUE;
					}
					else {
						bIndex = indexV[fromIndex];
					}
					continue;
				}
				else if (i > bIndex) {
					for (; fromIndex < indexVLen; fromIndex += 2) {
						if (i <= indexV[fromIndex]) {
							bIndex = indexV[fromIndex];
							break;
						}
					}
					if (i === bIndex) {
						i = indexV[fromIndex + 1] + 1;
						fromIndex += 2;
						if (fromIndex === indexVLen) {
							bIndex = uint.MAX_VALUE;
						}
						else {
							bIndex = indexV[fromIndex];
						}
						continue;
					}
					else if (i > bIndex) {
						bIndex = uint.MAX_VALUE;
					}
				}
				args = cmds[i];
				if (null === tV) {
					switch (args[0]) {
						case "if":
							if (null !== bk.blockV) {
								bk = bk.blockV[tbd.blockIndex];
								tbd = tb.getBlockData(bk);
								tbd.clear();
								tbd.flag = false;
								if (doIf(sData, currentVarData, args) === true) {
									tbd.flag = true;
								}
								else if (null !== bk.next) {
									bk = bk.next[tbd.nextIndex++];
									tbd = tb.getBlockData(bk);
									tbd.clear();
									tbd.flag = false;
									i = bk.start;
									continue;
								}
								else {
									i = bk.end;
									bk = bk.parent;
									tbd = tb.getBlockData(bk);
									continue;
								}
							}
							break;
						case "elseif":
							if (tbd.flag === true) {
								tbd.flag = false;
								if (bk.type === MagicEnum.TYPE_ELSE) {
									bk = bk.parent;
								}
								i = bk.end;
								bk = bk.parent;
								tbd = tb.getBlockData(bk);
								continue;
							}
							else {
								if (doIf(sData, currentVarData, args) === true) {
									tbd.flag = true;
								}
								else {
									bk = bk.parent;
									tbd = tb.getBlockData(bk);
									if (tbd.nextIndex !== bk.next.length) {
										bk = bk.next[tbd.nextIndex];
										tbd = tb.getBlockData(bk);
										tbd.clear();
										tbd.flag = false;
										i = bk.start;
										continue;
									}
									else {
										i = bk.end;
										bk = bk.parent;
										tbd = tb.getBlockData(bk);
										continue;
									}
								}
							}
							break;
						case "else":
							if (tbd.flag === true) {
								tbd.flag = false;
								if (bk.type === MagicEnum.TYPE_ELSE) {
									bk = bk.parent;
								}
								i = bk.end;
								bk = bk.parent;
								tbd = tb.getBlockData(bk);
								continue;
							}
							else {
								tbd.flag = true;
							}
							break;
						case "switch":
							if (null !== bk.blockV) {
								bk = bk.blockV[tbd.blockIndex];
								tbd = tb.getBlockData(bk);
								tbd.clear();
								tbd.flag = false;
								if (null !== bk.next) {
									sw = doOp(sData, currentVarData, args.slice(1));
									if (null === bV) {
										bV = new Vector.<MagicBlockData>();
									}
									bV[bV.length] = bk;
									bk = bk.next[tbd.nextIndex++];
									tbd = tb.getBlockData(bk);
									tbd.clear();
									tbd.flag = false;
									i = bk.start;
								}
								else {
									i = bk.end;
									bk = bk.parent;
									tbd = tb.getBlockData(bk);
									tbd.blockIndex++;
								}
								continue;
							}
							break;
						case "case":
							if (tbd.flag === false) {
								if (sw === doOp(sData, currentVarData, args.slice(1))) {
									tbd.flag = true;
									sw = null;
								}
								else {
									bk = bk.parent;
									tbd = tb.getBlockData(bk);
									if (tbd.nextIndex !== bk.next.length) {
										bk = bk.next[tbd.nextIndex++];
										tbd = tb.getBlockData(bk);
										tbd.clear();
										tbd.flag = false;
										i = bk.start;
									}
									else {
										i = bk.end;
										bk = bk.parent;
										tbd = tb.getBlockData(bk);
										tbd.blockIndex++;
										if (bV.length === 1) {
											bV = null;
										}
										else {
											bV.length--;
										}
										sw = null;
									}
									continue;
								}
							}
							break;
						case "default":
							if (tbd.flag === false) {
								tbd.flag = true;
								sw = null;
							}
							break;
						case "while":
							if (null !== bk.blockV) {
								bk = bk.blockV[tbd.blockIndex];
								tbd = tb.getBlockData(bk);
								tbd.clear();
								tbd.flag = false;
								if (doIf(sData, currentVarData, args) === true) {
									tbd.flag = true;
									if (null === bV) {
										bV = new Vector.<MagicBlockData>();
									}
									if (null === wV) {
										wV = new Vector.<MagicBlockData>();
									}
									bV[bV.length] = wV[wV.length] = bk;
									if (bIndex >= bk.end) {
										bIndex = 0;
										fromIndex = 0;
									}
								}
								else {
									i = bk.end;
									bk = bk.parent;
									tbd = tb.getBlockData(bk);
									tbd.blockIndex++;
									continue;
								}
							}
							break;
						case "break":
							bk = bV[bV.length - 1];
							if (bV.length === 1) {
								bV = null;
								wV = null;
							}
							else {
								bV.length--;
								if (null !== wV) {
									if (bk === wV[wV.length - 1]) {
										if (wV.length === 1) {
											wV = null;
										}
										else {
											wV.length--;
										}
									}
								}
							}
							i = bk.end;
							bk = bk.parent;
							tbd = tb.getBlockData(bk);
							tbd.blockIndex++;
							continue;
							break;
						case "continue":
							bk = wV[wV.length - 1];
							while (bk !== bV[bV.length - 1]) {
								bV.length--;
							}
							if (bV.length === 1) {
								bV = null;
								wV = null;
							}
							else {
								bV.length--;
								if (wV.length === 1) {
									wV = null;
								}
								else {
									wV.length--;
								}
							}
							i = bk.start;
							bk = bk.parent;
							tbd = tb.getBlockData(bk);
							continue;
							break;
						case "return":
							if (tbd.flag === true) {
								tb.clear();
								tb = null;
								tbd = null;
								indexV = null;
								cmds = null;
								bk = null;
								bV = null;
								wV = null;
								tV = null;
								tE = null;
								sw = null;
								currentFB = null;
								if (args.length === 1) return null;
								else return doOp(sData, currentVarData, args.slice(1));
							}
							break;
						case "try":
							if (null !== bk.blockV) {
								bk = bk.blockV[tbd.blockIndex];
								tbd = tb.getBlockData(bk);
								tbd.clear();
								tbd.flag = true;
								if (null === tV) {
									tV = new Vector.<MagicBlockData>();
								}
								tV[tV.length] = bk;
							}
							break;
						case "catch":
							if (tbd.flag === true) {
								i = bk.end;
								bk = bk.parent;
								tbd = tb.getBlockData(bk);
								tbd.blockIndex++;
								if (null !== tV) {
									if (tV.length === 1) {
										tV = null;
									}
									else {
										tV.length--;
									}
								}
							}
							else {
								tbd.flag = true;
								if (args.length !== 1) {
									if (null === currentVarData.vars) {
										currentVarData.vars = new Dictionary();
									}
									currentVarData.vars[(args[1] as String).charAt(0) === "$" ? (args[1] as String).substr(1) : args[1]] = tE;
								}
								else {
									tE = null;
								}
							}
							break;
						case "end":
						case "endif":
						case "endswitch":
						case "endwhile":
						case "endtrycatch":
							while (bk.type === MagicEnum.TYPE_ELSE) {
								bk = bk.parent;
							}
							switch (bk.type) {
								case MagicEnum.TYPE_WHILE:
									i = bk.start;
									bk = bk.parent;
									tbd = tb.getBlockData(bk);
									if (bV.length === 1) {
										bV = null;
										wV = null;
									}
									else {
										bV.length--;
										if (wV.length === 1) {
											wV = null;
										}
										else {
											wV.length--;
										}
									}
									continue;
									break;
								default:
									switch (bk.type) {
										case MagicEnum.TYPE_SWITCH:
											if (bV.length === 1) {
												bV = null;
											}
											else {
												bV.length--;
											}
											break;
										case MagicEnum.TYPE_TRY:
											if (null !== tV) {
												if (tV.length === 1) {
													tV = null;
												}
												else {
													tV.length--;
												}
											}
											tE = null;
											break;
									}
									bk = bk.parent;
									tbd = tb.getBlockData(bk);
									tbd.blockIndex++;
									break;
							}
							break;
						default:
							if (tbd.flag === true) {
								doOp(sData, currentVarData, args);
							}
							break;
					}
				}
				else {
					try {
						switch (args[0]) {
							case "if":
								if (null !== bk.blockV) {
									bk = bk.blockV[tbd.blockIndex];
									tbd = tb.getBlockData(bk);
									tbd.clear();
									tbd.flag = false;
									if (doIf(sData, currentVarData, args) === true) {
										tbd.flag = true;
									}
									else if (null !== bk.next) {
										bk = bk.next[tbd.nextIndex++];
										tbd = tb.getBlockData(bk);
										tbd.clear();
										tbd.flag = false;
										i = bk.start;
										continue;
									}
									else {
										i = bk.end;
										bk = bk.parent;
										tbd = tb.getBlockData(bk);
										continue;
									}
								}
								break;
							case "elseif":
								if (tbd.flag === true) {
									tbd.flag = false;
									if (bk.type === MagicEnum.TYPE_ELSE) {
										bk = bk.parent;
									}
									i = bk.end;
									bk = bk.parent;
									tbd = tb.getBlockData(bk);
									continue;
								}
								else {
									if (doIf(sData, currentVarData, args) === true) {
										tbd.flag = true;
									}
									else {
										bk = bk.parent;
										tbd = tb.getBlockData(bk);
										if (tbd.nextIndex !== bk.next.length) {
											bk = bk.next[tbd.nextIndex];
											tbd = tb.getBlockData(bk);
											tbd.clear();
											tbd.flag = false;
											i = bk.start;
											continue;
										}
										else {
											i = bk.end;
											bk = bk.parent;
											tbd = tb.getBlockData(bk);
											continue;
										}
									}
								}
								break;
							case "else":
								if (tbd.flag === true) {
									tbd.flag = false;
									if (bk.type === MagicEnum.TYPE_ELSE) {
										bk = bk.parent;
									}
									i = bk.end;
									bk = bk.parent;
									tbd = tb.getBlockData(bk);
									continue;
								}
								else {
									tbd.flag = true;
								}
								break;
							case "switch":
								if (null !== bk.blockV) {
									bk = bk.blockV[tbd.blockIndex];
									tbd = tb.getBlockData(bk);
									tbd.clear();
									tbd.flag = false;
									if (null !== bk.next) {
										sw = doOp(sData, currentVarData, args.slice(1));
										if (null === bV) {
											bV = new Vector.<MagicBlockData>();
										}
										bV[bV.length] = bk;
										bk = bk.next[tbd.nextIndex++];
										tbd = tb.getBlockData(bk);
										tbd.clear();
										tbd.flag = false;
										i = bk.start;
									}
									else {
										i = bk.end;
										bk = bk.parent;
										tbd = tb.getBlockData(bk);
										tbd.blockIndex++;
									}
									continue;
								}
								break;
							case "case":
								if (tbd.flag === false) {
									if (sw === doOp(sData, currentVarData, args.slice(1))) {
										tbd.flag = true;
										sw = null;
									}
									else {
										bk = bk.parent;
										tbd = tb.getBlockData(bk);
										if (tbd.nextIndex !== bk.next.length) {
											bk = bk.next[tbd.nextIndex++];
											tbd = tb.getBlockData(bk);
											tbd.clear();
											tbd.flag = false;
											i = bk.start;
										}
										else {
											i = bk.end;
											bk = bk.parent;
											tbd = tb.getBlockData(bk);
											tbd.blockIndex++;
											if (bV.length === 1) {
												bV = null;
											}
											else {
												bV.length--;
											}
											sw = null;
										}
										continue;
									}
								}
								break;
							case "default":
								if (tbd.flag === false) {
									tbd.flag = true;
									sw = null;
								}
								break;
							case "while":
								if (null !== bk.blockV) {
									bk = bk.blockV[tbd.blockIndex];
									tbd = tb.getBlockData(bk);
									tbd.clear();
									tbd.flag = false;
									if (doIf(sData, currentVarData, args) === true) {
										tbd.flag = true;
										if (null === bV) {
											bV = new Vector.<MagicBlockData>();
										}
										if (null === wV) {
											wV = new Vector.<MagicBlockData>();
										}
										bV[bV.length] = wV[wV.length] = bk;
										if (bIndex >= bk.end) {
											bIndex = 0;
											fromIndex = 0;
										}
									}
									else {
										i = bk.end;
										bk = bk.parent;
										tbd = tb.getBlockData(bk);
										tbd.blockIndex++;
										continue;
									}
								}
								break;
							case "break":
								bk = bV[bV.length - 1];
								if (bV.length === 1) {
									bV = null;
									wV = null;
								}
								else {
									bV.length--;
									if (null !== wV) {
										if (bk === wV[wV.length - 1]) {
											if (wV.length === 1) {
												wV = null;
											}
											else {
												wV.length--;
											}
										}
									}
								}
								i = bk.end;
								bk = bk.parent;
								tbd = tb.getBlockData(bk);
								tbd.blockIndex++;
								continue;
								break;
							case "continue":
								bk = wV[wV.length - 1];
								while (bk !== bV[bV.length - 1]) {
									bV.length--;
								}
								if (bV.length === 1) {
									bV = null;
									wV = null;
								}
								else {
									bV.length--;
									if (wV.length === 1) {
										wV = null;
									}
									else {
										wV.length--;
									}
								}
								i = bk.start;
								bk = bk.parent;
								tbd = tb.getBlockData(bk);
								continue;
								break;
							case "return":
								if (tbd.flag === true) {
									tb.clear();
									tb = null;
									tbd = null;
									indexV = null;
									cmds = null;
									bk = null;
									bV = null;
									wV = null;
									tV = null;
									tE = null;
									sw = null;
									currentFB = null;
									if (args.length === 1) return null;
									else return doOp(sData, currentVarData, args.slice(1));
								}
								break;
							case "try":
								if (null !== bk.blockV) {
									bk = bk.blockV[tbd.blockIndex];
									tbd = tb.getBlockData(bk);
									tbd.clear();
									tbd.flag = true;
									if (null === tV) {
										tV = new Vector.<MagicBlockData>();
									}
									tV[tV.length] = bk;
								}
								break;
							case "catch":
								if (tbd.flag === true) {
									i = bk.end;
									bk = bk.parent;
									tbd = tb.getBlockData(bk);
									tbd.blockIndex++;
									if (null !== tV) {
										if (tV.length === 1) {
											tV = null;
										}
										else {
											tV.length--;
										}
									}
								}
								else {
									tbd.flag = true;
									if (args.length !== 1) {
										if (null === currentVarData.vars) {
											currentVarData.vars = new Dictionary();
										}
										currentVarData.vars[(args[1] as String).charAt(0) === "$" ? (args[1] as String).substr(1) : args[1]] = tE;
									}
									else {
										tE = null;
									}
								}
								break;
							case "end":
							case "endif":
							case "endswitch":
							case "endwhile":
							case "endtrycatch":
								while (bk.type === MagicEnum.TYPE_ELSE) {
									bk = bk.parent;
								}
								switch (bk.type) {
									case MagicEnum.TYPE_WHILE:
										i = bk.start;
										bk = bk.parent;
										tbd = tb.getBlockData(bk);
										if (bV.length === 1) {
											bV = null;
											wV = null;
										}
										else {
											bV.length--;
											if (wV.length === 1) {
												wV = null;
											}
											else {
												wV.length--;
											}
										}
										continue;
										break;
									default:
										switch (bk.type) {
											case MagicEnum.TYPE_SWITCH:
												if (bV.length === 1) {
													bV = null;
												}
												else {
													bV.length--;
												}
												break;
											case MagicEnum.TYPE_TRY:
												if (null !== tV) {
													if (tV.length === 1) {
														tV = null;
													}
													else {
														tV.length--;
													}
												}
												tE = null;
												break;
										}
										bk = bk.parent;
										tbd = tb.getBlockData(bk);
										tbd.blockIndex++;
										break;
								}
								break;
							default:
								if (tbd.flag === true) {
									doOp(sData, currentVarData, args);
								}
								break;
						}
					}
					catch (error:Error) {
						tE = new Error("line: " + (i + 1) + " :: " + error.message, error.errorID);
						bk = tV[tV.length - 1];
						if (null !== bk.next) {
							bk = bk.next[tbd.nextIndex];
							tbd = tb.getBlockData(bk);
							tbd.clear();
							tbd.flag = false;
							i = bk.start;
						}
						if (tV.length === 1) {
							tV = null;
						}
						else {
							tV.length--;
						}
						continue;
					}
				}
				i++;
			}
			tb.clear();
			tb = null;
			tbd = null;
			indexV = null;
			cmds = null;
			args = null;
			bk = null;
			bV = null;
			wV = null;
			tV = null;
			tE = null;
			sw = null;
			currentVarData = null;
			currentFB = null;
			sData = null;
			return void;
		}
		
		static public function compile(cmd:Object, rootBlockData:MagicFunctionData = null):Object
		{
			if (null === rootBlockData) rootBlockData = new MagicFunctionData();
			if (null === rootBlockData.cmds) rootBlockData.cmds = new Vector.<Array>();
			var str:String, cmds:Array, o:Object, r:RegExp = /[^\s\"\']+|\".*?\"|\'.*?\'/g, v:Array, currentFB:MagicFunctionData = rootBlockData, bk:MagicBlockData = currentFB, bk2:MagicBlockData, fV:Vector.<MagicFunctionData> = Vector.<MagicFunctionData>([currentFB]), error:String;
			if (cmd is String) {
				cmds = (cmd as String).split(/\r\n|\r|\n/);
			}
			else if (cmd is Array) {
				cmds = cmd as Array;
			}
			cmd = null;
			for (var i:uint, j:uint = rootBlockData.cmds.length, l:uint = cmds.length, n:uint; i < l;) {
				str = cmds[i];
				v = [];
				r.lastIndex = 0;
				n = 0;
				while (null !== (o = r.exec(str))) {
					v[n++] = o[0];
				}
				rootBlockData.cmds[j++] = v;
				if (n === 0) {
					if (null === currentFB.indexV) {
						currentFB.indexV = new Vector.<uint>();
					}
					if (currentFB.indexV.length !== 0 && currentFB.indexV[currentFB.indexV.length - 1] + 1 === i) {
						currentFB.indexV[currentFB.indexV.length - 1] = i;
					}
					else {
						currentFB.indexV[currentFB.indexV.length] = i;
						currentFB.indexV[currentFB.indexV.length] = i;
					}
					i++;
					continue;
				}
				switch (v[0]) {
					case "function":
					case "func":
						if (n === 1) {
							error = "the function has no name, at line: " + (i + 1);
							rootBlockData.clear();
							str = null;
							cmds = null;
							o = null;
							r = null;
							v = null;
							currentFB = null;
							bk = null;
							bk2 = null;
							fV = null;
							rootBlockData = null;
							return error;
						}
						currentFB = new MagicFunctionData();
						currentFB.parent = bk;
						currentFB.cmds = rootBlockData.cmds;
						currentFB.type = MagicEnum.TYPE_FUNCTION;
						currentFB.start = i + 1;
						if (n !== 2) {
							currentFB.parameters = new Vector.<String>();
							var k:String;
							for (var e:uint = 0, m:uint = 2; m < n; e++, m++) {
								k = v[m];
								currentFB.parameters[e] = k.charAt(0) === "$" ? k.substr(1) : k;
							}
							k = null;
						}
						bk = currentFB;
						currentFB = fV[fV.length - 1] as MagicFunctionData;
						if (null === currentFB.fun) {
							currentFB.fun = new Dictionary();
						}
						currentFB.fun[v[1]] = bk;
						if (null === currentFB.indexV) {
							currentFB.indexV = new Vector.<uint>();
						}
						if (currentFB.indexV.length > 1 && currentFB.indexV[currentFB.indexV.length - 1] + 1 === i) {
							currentFB.indexV.length--;
						}
						else {
							currentFB.indexV[currentFB.indexV.length] = i;
						}
						currentFB = fV[fV.length] = bk as MagicFunctionData;
						break;
					case "if":
					case "switch":
					case "while":
					case "try":
						switch (v[0]) {
							case "if":
							case "while":
								if (n < 3) {
									error = "incorrect number of arguments, at line: " + (i + 1);
									rootBlockData.clear();
									str = null;
									cmds = null;
									o = null;
									r = null;
									v = null;
									currentFB = null;
									bk = null;
									bk2 = null;
									fV = null;
									rootBlockData = null;
									return error;
								}
								else {
									switch (v[1]) {
										case "=":
										case "==":
										case "===":
										case "!":
										case "!=":
										case "!==":
										case "<":
										case ">":
										case "<=":
										case ">=":
										case "is":
											break;
										default:
											error = "operator is wrong, at line: " + (i + 1);
											rootBlockData.clear();
											str = null;
											cmds = null;
											o = null;
											r = null;
											v = null;
											currentFB = null;
											bk = null;
											bk2 = null;
											fV = null;
											rootBlockData = null;
											return error;
											break;
									}
								}
								compileCastObj(v, 2, n);
								break;
							case "switch":
								if (n === 1) {
									error = "incorrect number of arguments, at line: " + (i + 1);
									rootBlockData.clear();
									str = null;
									cmds = null;
									o = null;
									r = null;
									v = null;
									currentFB = null;
									bk = null;
									bk2 = null;
									fV = null;
									rootBlockData = null;
									return error;
								}
								compileCastObj(v, 1, n);
								break;
						}
						if (null === bk.blockV) {
							bk.blockV = new Vector.<MagicBlockData>();
						}
						bk2 = new MagicBlockData();
						bk2.type = MagicEnum.TYPE_ENUM[v[0]];
						bk2.start = i;
						bk2.parent = bk;
						bk.blockV[bk.blockV.length] = bk2;
						bk = bk2;
						break;
					case "else":
					case "elseif":
					case "case":
					case "default":
					case "catch":
						if (null === bk2) {
							error = "the block has not open, at line: " + (i + 1);
							rootBlockData.clear();
							str = null;
							cmds = null;
							o = null;
							r = null;
							v = null;
							currentFB = null;
							bk = null;
							bk2 = null;
							fV = null;
							rootBlockData = null;
							return error;
						}
						switch (v[0]) {
							case "elseif":
								if (n < 3) {
									error = "incorrect number of arguments, at line: " + (i + 1);
									rootBlockData.clear();
									str = null;
									cmds = null;
									o = null;
									r = null;
									v = null;
									currentFB = null;
									bk = null;
									bk2 = null;
									fV = null;
									rootBlockData = null;
									return error;
								}
								else {
									switch (v[1]) {
										case "=":
										case "==":
										case "===":
										case "!":
										case "!=":
										case "!==":
										case "<":
										case ">":
										case "<=":
										case ">=":
										case "is":
											break;
										default:
											error = "operator is wrong, at line: " + (i + 1);
											rootBlockData.clear();
											str = null;
											cmds = null;
											o = null;
											r = null;
											v = null;
											currentFB = null;
											bk = null;
											bk2 = null;
											fV = null;
											rootBlockData = null;
											return error;
											break;
									}
								}
								compileCastObj(v, 2, n);
								break;
							case "case":
								if (n === 1) {
									error = "incorrect number of arguments, at line: " + (i + 1);
									rootBlockData.clear();
									str = null;
									cmds = null;
									o = null;
									r = null;
									v = null;
									currentFB = null;
									bk = null;
									bk2 = null;
									fV = null;
									rootBlockData = null;
									return error;
								}
								compileCastObj(v, 1, n);
								break;
						}
						if (null === bk2.next) {
							bk2.next = new Vector.<MagicBlockData>();
						}
						bk = new MagicBlockData();
						bk.type = MagicEnum.TYPE_ELSE;
						bk.start = i;
						bk.parent = bk2;
						bk2.next[bk2.next.length] = bk;
						break;
					case "end":
					case "endfunction":
					case "endif":
					case "endswitch":
					case "endwhile":
					case "endtrycatch":
						if (bk.type === MagicEnum.TYPE_FUNCTION) {
							currentFB.end = i;
							fV.length--;
							currentFB = fV[fV.length - 1];
							currentFB.indexV[currentFB.indexV.length] = i;
						}
						else {
							if (null === bk2) {
								error = "the block has not open, at line: " + (i + 1);
								rootBlockData.clear();
								str = null;
								cmds = null;
								o = null;
								r = null;
								v = null;
								currentFB = null;
								bk = null;
								bk2 = null;
								fV = null;
								rootBlockData = null;
								return error;
							}
							bk = bk2;
							bk.end = i + 1;
							bk2 = bk2.parent;
							while (null !== bk2 && bk2.type < MagicEnum.TYPE_BLOCK_START) {
								bk2 = bk2.parent;
							}
						}
						bk = bk.parent;
						break;
					case "break":
					case "continue":
					case "++":
					case "--":
					case "!":
					case "!!":
					case "as":
					case "cast":
						switch (v[0]) {
							case "break":
								if (null === bk2 || bk2.type !== MagicEnum.TYPE_SWITCH || bk2.type !== MagicEnum.TYPE_WHILE) {
									error = "the block has not open, at line: " + (i + 1);
									rootBlockData.clear();
									str = null;
									cmds = null;
									o = null;
									r = null;
									v = null;
									currentFB = null;
									bk = null;
									bk2 = null;
									fV = null;
									rootBlockData = null;
									return error;
								}
								break;
							case "continue":
								if (null === bk2 || bk2.type !== MagicEnum.TYPE_WHILE) {
									error = "the block has not open, at line: " + (i + 1);
									rootBlockData.clear();
									str = null;
									cmds = null;
									o = null;
									r = null;
									v = null;
									currentFB = null;
									bk = null;
									bk2 = null;
									fV = null;
									rootBlockData = null;
									return error;
								}
								break;
							case "++":
							case "--":
							case "!":
							case "!!":
								if (n === 1) {
									error = "incorrect number of arguments, at line: " + (i + 1);
									rootBlockData.clear();
									str = null;
									cmds = null;
									o = null;
									r = null;
									v = null;
									currentFB = null;
									bk = null;
									bk2 = null;
									fV = null;
									rootBlockData = null;
									return error;
								}
								else {
									for (m = 1; m < n; m++) {
										switch ((v[m] as String).charAt(0)) {
											case "$":
											case "@":
												break;
											default:
												error = "the operand must be a variable, an element in an array, or a property of an object, at line: " + (i + 1);
												rootBlockData.clear();
												str = null;
												cmds = null;
												o = null;
												r = null;
												v = null;
												currentFB = null;
												bk = null;
												bk2 = null;
												fV = null;
												rootBlockData = null;
												return error;
												break;
										}
									}
								}
								break;
						}
						break;
					case "return":
						if (n !== 1) compileCastObj(v, 1, n);
						break;
					case "throw":
					case "p":
						if (n === 1) {
							error = "incorrect number of arguments, at line: " + (i + 1);
							rootBlockData.clear();
							str = null;
							cmds = null;
							o = null;
							r = null;
							v = null;
							currentFB = null;
							bk = null;
							bk2 = null;
							fV = null;
							rootBlockData = null;
							return error;
						}
						compileCastObj(v, 1, n);
						break;
					case "=":
					case "+":
					case "-":
					case "*":
					case "/":
					case "%":
					case "^":
					case "~":
					case "|":
					case "&":
					case "<<":
					case ">>":
					case ">>>":
					case "||":
					case "&&":
					case "typeof":
						switch (v[0]) {
							case "~":
							case "typeof":
								if (n === 1) {
									error = "incorrect number of arguments, at line: " + (i + 1);
									rootBlockData.clear();
									str = null;
									cmds = null;
									o = null;
									r = null;
									v = null;
									currentFB = null;
									bk = null;
									bk2 = null;
									fV = null;
									rootBlockData = null;
									return error;
								}
								break;
							default:
								if (n < 3) {
									error = "incorrect number of arguments, at line: " + (i + 1);
									rootBlockData.clear();
									str = null;
									cmds = null;
									o = null;
									r = null;
									v = null;
									currentFB = null;
									bk = null;
									bk2 = null;
									fV = null;
									rootBlockData = null;
									return error;
									break;
								}
						}
						switch ((v[1] as String).charAt(0)) {
							case "$":
							case "@":
								break;
							default:
								error = "the operand must be a variable, an element in an array, or a property of an object, at line: " + (i + 1);
								rootBlockData.clear();
								str = null;
								cmds = null;
								o = null;
								r = null;
								v = null;
								currentFB = null;
								bk = null;
								bk2 = null;
								fV = null;
								rootBlockData = null;
								return error;
								break;
						}
						compileCastObj(v, 2, n);
						break;
					case "fi":
					case "fe":
					case "fei":
						if (n < 3) {
							error = "incorrect number of arguments, at line: " + (i + 1);
							rootBlockData.clear();
							str = null;
							cmds = null;
							o = null;
							r = null;
							v = null;
							currentFB = null;
							bk = null;
							bk2 = null;
							fV = null;
							rootBlockData = null;
							return error;
						}
						switch ((v[1] as String).charAt(0)) {
							case "$":
							case "@":
								break;
							default:
								error = "the operand must be a variable, an element in an array, or a property of an object, at line: " + (i + 1);
								rootBlockData.clear();
								str = null;
								cmds = null;
								o = null;
								r = null;
								v = null;
								currentFB = null;
								bk = null;
								bk2 = null;
								fV = null;
								rootBlockData = null;
								return error;
								break;
						}
						if (n !== 3) compileCastObj(v, 3, n);
						break;
					default:
						switch ((v[0] as String).charAt(0)) {
							case "#":
							case ":":
								break;
							default:
								if (null === currentFB.indexV) {
									currentFB.indexV = new Vector.<uint>();
								}
								if (currentFB.indexV.length !== 0 && currentFB.indexV[currentFB.indexV.length - 1] + 1 === i) {
									currentFB.indexV[currentFB.indexV.length - 1] = i;
								}
								else {
									currentFB.indexV[currentFB.indexV.length] = i;
									currentFB.indexV[currentFB.indexV.length] = i;
								}
								break;
						}
						break;
				}
				i++;
			}
			
			if (bk !== rootBlockData) {
				if (fV.length !== 1) {
					bk2 = fV[fV.length - 1];
					if (bk === bk2) {
						bk = null;
					}
					null === error ? (error = "") : (error += "\n");
					error += "the function has not end, at line: " + bk2.start;
				}
				if (null !== bk) {
					null === error ? (error = "") : (error += "\n");
					error += "the block has not end, at line: " + (bk.start + 1);
				}
				rootBlockData.clear();
				rootBlockData = null;
			}
			
			str = null;
			cmds = null;
			o = null;
			r = null;
			v = null;
			currentFB = null;
			bk = null;
			bk2 = null;
			fV = null;
			return null !== error ? error : rootBlockData;
		}
		
	}
}

internal namespace magic_internal = "213384665b731cdf2fe17d13266786f65ceee0e1ab799e0ee704860761556606";