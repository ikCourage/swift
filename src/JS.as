package 
{
	import flash.utils.describeType;

	public final class JS
	{
		static protected const S:Vector.<int> = new Vector.<int>(161, true);
		S[9] = 1;// \t
		S[10] = 1;// \n
		S[13] = 1;// \r
		S[32] = 1;// " "
		S[160] = 1;// &#160;
		
		static protected const T:Vector.<int> = new Vector.<int>(161, true);
		T[9] = 1;// \t
		T[10] = 1;// \n
		T[13] = 1;// \r
		T[32] = 1;// " "
		T[160] = 1;// &#160;
		T[34] = 1;// "
		T[40] = 1;// (
		T[41] = 1;// )
		T[64] = 1;// @
		T[91] = 1;// [
		T[93] = 1;// ]
		T[123] = 1;// {
		T[125] = 1;// }
		T[44] = 1;// ,
		T[58] = 1;// :
		T[47] = 1;// /
		
		protected var _position:int;
		protected var _position2:int;
		protected var _length:int;
		protected var _vIndex:int;
		protected var _v:Array;
		protected var _vk:Object;
		protected var _vkLength:int;
		protected var _vAt:Object;
		protected var _vAt2:Array;
		protected var _vAt2Index:int;
		protected var _t:int;
		protected var _ot:int;
		protected var _firstObj:Object;
		protected var _str:String;
		protected var _replace:Object;
		protected var _error:Object;
		
		static public function parse(text:String, replace:Object = null, error:Object = null):*
		{
			return (new JS()).parse(text, replace, error).getValue();
		}
		
		static public function stringify(value:Object):String
		{
			return (new JS()).stringify(value);
		}
		
		static public function parseXML(value:Object, useAt:Boolean = true, useAttribute:Boolean = true, useLocalName:Boolean = true, contentName:String = "_"):*
		{
			return (new JS()).parseXML(value, useAt, useAttribute, useLocalName, contentName);
		}
		
		public function parse(str:String, replace:Object = null, error:Object = null):JS
		{
			if (null !== str) {
				_str = str;
				_replace = replace;
				_error = error;
				_length = _str.length;
				_v = [];
				_vk = {};
				str = null;
				replace = null;
				error = null;
				parseString();
				_str = null;
			}
			else {
				_position = -1;
			}
			return this;
		}
		
		public function stringify(value:Object):String
		{
			return convertToString(value);
		}
		
		public function parseXML(value:Object, useAt:Boolean = true, useAttribute:Boolean = true, useLocalName:Boolean = true, contentName:String = "_"):*
		{
			value = xmlToJSON(value, useAttribute, useLocalName, contentName);
			if (useAt == true) value = parse(JSON.stringify(value)).getValue();
			contentName = null;
			return value;
		}
		
		// parse
		
		public function getValue():Object
		{
			var obj:Object;
			if (_position != -1) {
				_length = 0;
				_position = 1;
				_vAt = {};
				obj = parseValue();
				if (_position != -1) {
					if (_vkLength) {
						checkVK2();
					}
				}
				else {
					obj = null;
				}
			}
			_firstObj = null;
			_v = null;
			_vk = null;
			_vAt = null;
			_vAt2 = null;
			_str = null;
			_replace = null;
			_error = null;
			return obj;
		}
		
		protected function parseString():void
		{
			var a:int, i:int, j:int, k:int, l:int, m:int, n:int;
			var c:String, d:String, e:String, str:String, str2:String;
			while (_position < _length) {
				while ((a = _str.charCodeAt(_position)) < 161 && S[a]) if (++_position >= _length) return;
				if (a < 161 && T[a]) {
					switch (a) {
						case JT.STRING:
							_position++;
							i = _position;
							do {
								i = _str.indexOf('\"', i);
								// Find the next quote in the input stream
								if (i != -1) {
									// We found the next double quote character in the string, but we need
									// to make sure it is not part of an escape sequence.
									// Keep looping backwards while the previous character is a backslash
									j = 0;
									k = i - 1;
									while (_str.charAt(k) == '\\') {
										j++;
										k--;
									}
									// If we have an even number of backslashes, that means this is the ending quote
									if ((j & 1) == 0) break;
									// At this point, the quote was determined to be part of an escape sequence
									// so we need to move past the quote index to look for the next one
									i++;
								}
								else {
									// There are no more quotes in the string and we haven't found the end yet
									parseError("Unterminated string literal", _position);
									return;
								}
							} while (true);
							str = _str.substring(_position, i);
							l = 0;
							if ((j = str.indexOf('\\')) != -1) {
								l = str.length;
								k = 0;
								str2 = "";
								while (k < l) {
									str2 += str.substring(k, j);
									// Move past the backslash and next character (all escape sequences are
									// two characters, except for \u, which will advance this further)
									k = j + 2;
									// Check the next character so we know what to escape
									c = str.charAt(++j);
									switch (c) {
										// Try to list the most common expected cases first to improve performance
										case '"':
										case '\\':
											str2 += c;
											break;	
										case 'n':
											str2 += '\n';
											break; // newline
										case 'r':
											str2 += '\r';
											break; // carriage return
										case 't':
											str2 += '\t';
											break; // horizontal tab
										// Convert a unicode escape sequence to it's character value
										case 'u':
											// Save the characters as a string we'll convert to an int
											m = k + 4;
											// Make sure there are enough characters in the string leftover
											if (m > l) {
												parseError("Unexpected end of input.  Expecting 4 hex digits after \\u.", i + k);
												return;
											}
											d = "";
											// Try to find 4 hex characters
											for (n = k; n < m; n++) {
												// get the next character and determine
												// if it's a valid hex digit or not
												e = str.charAt(n);
												if (!((e >= '0' && e <= '9') || (e >= 'A' && e <= 'F') || (e >= 'a' && e <= 'f'))) {
													parseError("Excepted a hex digit, but found: " + e, i + k);
													return;
												}
												// Valid hex digit, add it to the value
												d += e;
											}
											// Convert hex string to an integer, and use that
											// integer value to create a character to add
											// to our string.
											str2 += String.fromCharCode(parseInt(d, 16));
											d = null;
											e = null;
											// Move past the 4 hex digits that we just read
											k = m;
											break;
										case 'f':
											str2 += '\f';
											break; // form feed
										case '/':
											str2 += '/';
											break; // solidus
										case 'b':
											str2 += '\b';
											break; // bell
										default:
											str2 += '\\' + c; // Couldn't unescape the sequence, so just pass it through
											break;
									}
									c = null;
									j = str.indexOf('\\', k);
									if (j == -1) {
										str2 += str.substring(k);
										break;
									}
								}
								j = str2.length;
								_position2 = _position + l - j;
								l = j;
								str = str2;
								str2 = null;
							}
							else {
								_position2 = _position;
							}
							if ((j = str.indexOf("@[")) != -1) {
								if (j != 0) {
									_v[_vIndex++] = _position2;
									_v[_vIndex++] = JT.STRING_2;
									_v[_vIndex++] = str.substring(0, j);
								}
								k = j;
								if (l == 0) {
									l = str.length;
								}
								while (true) {
									k = parseStringAt(j + 2, 0, l, str, JT.STRING_AT);
									if (k < l) {
										j = str.indexOf("@[", k);
										if (j != -1) {
											if (k < j) {
												_v[_vIndex++] = _position2 + k;
												_v[_vIndex++] = JT.STRING_2;
												_v[_vIndex++] = str.substring(k, j);
											}
										}
										else {
											if (k < l) {
												_v[_vIndex++] = _position2 + k;
												_v[_vIndex++] = JT.STRING_2;
												_v[_vIndex++] = str.substring(k);
											}
											break;
										}
									}
									else {
										break;
									}
								}
							}
							else {
								_v[_vIndex++] = _position2;
								_v[_vIndex++] = JT.STRING;
								_v[_vIndex++] = str;
							}
							str = null;
							// Move past the closing quote in the input string.  This updates the next
							// character in the input stream to be the character one after the closing quote
							_position = ++i;
							break;
						case JT.COLON:
						case JT.COMMA:
						case JT.OPEN_BRACE:
						case JT.OPEN_BRACKET:
						case JT.CLOSE_BRACE:
						case JT.CLOSE_BRACKET:
							_v[_vIndex++] = ++_position;
							_v[_vIndex++] = a;
							break;
						case JT.OPEN_PARENTHESIS:
							_v[_vIndex++] = ++_position;
							_v[_vIndex++] = a;
							if ((c = _str.charAt(_position)) == '[') {
								k = ++_position;
								l = 1;
								do {
									l--;
									i = _str.indexOf("])", k);
									if (i != -1) {
										j = _str.indexOf("([", k);
										if (j != -1 && j < i) {
											k = i + 2;
											l++;
										}
										else if (l == 0) {
											_v[_vIndex++] = _str.substring(_position, i);
											_position = i + 2;
										}
									}
									else {
										parseError("Unterminated string literal", _position);
										return;
									}
								} while (l > 0);
							}
							else {
								parseError("Expecting [ but found " + c, _position);
								return;
							}
							c = null;
							break;
						case JT.AT:
							if ((c = _str.charAt(++_position)) == '[') {
								if ((_position = parseAt(++_position, 0, _length, _str, JT.AT)) == -1) {
									return;
								}
							}
							else {
								parseError("Expecting [ but found " + c, _position);
								return;
							}
							c = null;
							break;
						case JT.COMMENT:
							_v[_vIndex++] = ++_position;
							_v[_vIndex++] = a;
							i = _str.indexOf('\n', _position);
							j = _str.indexOf("*/", _position);
							i = i < j ? j + 2 : i;
							if (i == -1) {
								i = _length;
							}
							_v[_vIndex++] = _str.substring(_position - 1, i);
							_position = i;
							break;
					}
				}
				else {
					i = _position;
					while (a) {
						if (++_position >= _length || (a < 161 && T[a])) {
							_v[_vIndex++] = (a < 161 && T[a]) ? --_position : _position - 1;
							_v[_vIndex++] = JT.OTHER;
							_v[_vIndex++] = _str.substring(i, _position);
							break;
						}
						a = _str.charCodeAt(_position);
					}
				}
			}
		}
		
		protected function parseAt(strIndex:int, atEnd:int, len:int, str:String, t:int):int
		{
			var atStart:int = strIndex, atStart2:int = str.indexOf("@[", strIndex);
			if (atEnd == 0) atEnd = str.indexOf(']', strIndex);
			while (atStart2 != -1 && atStart2 < atEnd) {
				strIndex = parseAt(atStart2 + 2, atEnd, len, str, JT.AT2);
				atStart2 = str.indexOf("@[", strIndex);
				atEnd = str.indexOf(']', strIndex);
			}
			if (atEnd != -1) {
				str = str.substring(atStart, atEnd);
				t = t == JT.AT ? t : (str.indexOf('@') == -1 ? JT.AT3 : JT.AT2);
				_v[_vIndex++] = strIndex;
				if (t == JT.AT3 || (t == JT.AT && str.indexOf('@') == -1)) {
					if (_vk.hasOwnProperty(str) == false) {
						_vk[str] = [_vIndex];
						_vkLength++;
					}
					else {
						var vKT:Array = _vk[str];
						vKT[vKT.length] = _vIndex;
						vKT = null;
					}
				}
				_v[_vIndex++] = t;
				_v[_vIndex++] = str;
				strIndex = ++atEnd;
			}
			else {
				parseError("Unterminated macro", atStart);
				return -1;
			}
			str = null;
			return strIndex;
		}
		
		protected function parseStringAt(strIndex:int, atEnd:int, len:int, str:String, t:int):int
		{
			var vIndex2:int = _vIndex, atStart:int = strIndex, atStart2:int = str.indexOf("@[", strIndex), atStart3:int = atStart2;
			if (atEnd == 0) atEnd = str.indexOf(']', strIndex);
			while (atStart2 != -1 && atStart2 < atEnd) {
				strIndex = parseStringAt(atStart2 + 2, atEnd, len, str, JT.STRING_AT2);
				atStart2 = str.indexOf("@[", strIndex);
				atEnd = str.indexOf(']', strIndex);
			}
			if (atEnd != -1) {
				var str2:String = str.substring(atStart, atEnd);
				_v[_vIndex++] = strIndex + _position2;
				t = t == JT.STRING_AT ? t : (str2.indexOf('@') == -1 ? JT.STRING_AT3 : JT.STRING_AT2);
				if (t == JT.STRING_AT3 || (t == JT.STRING_AT && str2.indexOf('@') == -1)) {
					if (_vk.hasOwnProperty(str2) == false) {
						_vk[str2] = [_vIndex];
						_vkLength++;
					}
					else {
						var vKT:Array = _vk[str2];
						vKT[vKT.length] = _vIndex;
						vKT = null;
					}
				}
				_v[_vIndex++] = t;
				_v[_vIndex++] = str2;
				strIndex = ++atEnd;
				str2 = null;
			}
			else {
				atStart -= 2;
				_v.length = _vIndex = vIndex2;
				str2 = str.substring(atStart, atStart3);
				if (_vIndex != 0 && _v[_vIndex - 2] == JT.STRING_2) {
					_v[_vIndex - 1] += str2;
				}
				else {
					_v[_vIndex++] = atStart + _position2;
					_v[_vIndex++] = JT.STRING_2;
					_v[_vIndex++] = str2;
				}
				str2 = null;
				strIndex = parseStringAt(atStart3 + 2, 0, len, str, JT.STRING_AT);
			}
			str = null;
			return strIndex;
		}
		
		protected function parseValue():Object
		{
			var a:int, obj:Object;
			for (; _position < _vIndex; _position += 3) {
				a = _v[_position];
				switch (a) {
					case JT.OPEN_BRACE:
						_length++;
						obj = parseObject();
						_length--;
						return obj;
						break;
					case JT.OPEN_BRACKET:
						return parseArray();
						break;
					case JT.STRING:
					case JT.OPEN_PARENTHESIS:
					case JT.STRING_2:
						if (null == obj) {
							obj = _v[_position + 1];
						}
						else {
							obj += _v[_position + 1];
						}
						break;
					case JT.STRING_AT:
					case JT.AT:
						if (null == obj) {
							obj = "@[" + _v[_position + 1] + ']';
						}
						else {
							obj += "@[" + _v[_position + 1] + ']';
						}
						break;
					case JT.COMMA:
					case JT.COLON:
						_position--;
						break;
					case JT.OTHER:
						if (null == obj) {
							obj = parseOther();
						}
						else {
							obj += parseOther();
						}
						break;
				}
			}
			return obj;
		}
		
		protected function parseValue2():Object
		{
			_position2 = _position;
			_t = JT.BASE;
			_vAt2Index = 0;
			_vAt2 = [];
			var a:int, i:int, b:Boolean, r:Boolean, arr:Array = [];
			for (; _position < _vIndex; _position += 3) {
				a = _v[_position];
				switch (a) {
					case JT.STRING:
					case JT.STRING_2:
					case JT.OPEN_PARENTHESIS:
						if (_t < JT.STRING) {
							_t = JT.STRING;
						}
						else if (_t == JT.AT) {
							_t = JT.EXPRESSION;
						}
						arr[i++] = _v[_position + 1];
						break;
					case JT.OPEN_BRACE:
					case JT.CLOSE_BRACE:
					case JT.OPEN_BRACKET:
					case JT.CLOSE_BRACKET:
					case JT.COMMA:
					case JT.COLON:
						b = true;
						break;
					case JT.BASE_2:
						_position--;
						if (_t < JT.BASE_2) {
							_t = JT.BASE_2;
						}
						else if (_t < JT.STRING) {
							_t = JT.STRING;
						}
						else if (_t == JT.AT) {
							_t = JT.EXPRESSION;
						}
						arr[i++] = _v[_position + 1];
						break;
					case JT.OTHER:
						_v[_position + 1] = arr[i++] = parseOther();
						if (_t < _ot) {
							_t = _ot;
						}
						else if (_t == JT.AT) {
							_t = JT.EXPRESSION;
						}
						break;
					case JT.REPLACE:
						if (_t < JT.STRING) {
							_t = JT.STRING;
						}
						else if (_t == JT.AT) {
							_t = JT.EXPRESSION;
						}
						arr[i++] = _v[_position + 1];
						r = true;
						break;
					case JT.STRING_AT:
					case JT.STRING_AT2:
					case JT.STRING_AT3:
					case JT.AT:
					case JT.AT2:
					case JT.AT3:
						if (_t < JT.AT) {
							_t = JT.AT;
						}
						_vAt2[_vAt2Index++] = _position;
						break;
				}
				if (b == true) {
					break;
				}
			}
			if (_t >= JT.AT) {
				arr = null;
				return null;
			}
			else if (i == 1) {
				return r ? parseOther2(arr[0]) : arr[0];
			}
			else {
				return r ? parseOther2(arr.join("")) : arr.join("");
			}
			return null;
		}
		
		protected function parseValue3(start:int, end:int):Object
		{
			var a:int, i:int, b:Boolean, arr:Array = [];
			for (; start < end; start += 3) {
				a = _v[start];
				switch (a) {
					case JT.STRING:
					case JT.STRING_2:
					case JT.BASE_2:
					case JT.OPEN_PARENTHESIS:
					case JT.REPLACE:
						arr[i++] = _v[start + 1];
						break;
					case JT.OTHER:
						arr[i++] = parseOther2(_v[start + 1]);
						if (_ot != JT.BASE) {
							_v[start] = _ot;
						}
						break;
				}
				if (b == true) {
					break;
				}
			}
			if (i == 1) {
				return parseOther2(arr[0]);
			}
			else {
				return parseOther2(arr.join(""));
			}
			return null;
		}
		
		protected function parseObject():Object
		{
			_position += 2;
			var a:int, vMIndex:int, vM:Array, key:String, obj:Object = {}, o:Object;
			if (_length == 1) {
				_firstObj = obj;
			}
			while (_position < _vIndex) {
				a = _v[_position];
				switch (a) {
					case JT.COMMA:
						_position += 2;
						break;
					case JT.CLOSE_BRACE:
						_position += 2;
						return obj;
						break;
					case JT.OPEN_BRACE:
					case JT.OPEN_BRACKET:
					case JT.CLOSE_BRACKET:
					case JT.COLON:
						parseError("Unexpected " + String.fromCharCode(a), _v[_position - 1]);
						return null;
						break;
					default:
						o = parseValue2();
						switch (_t) {
							case JT.STRING:
							case JT.NUMBER:
							case JT.BASE_2:
							case JT.AT:
							case JT.EXPRESSION:
								if (_t < JT.AT) {
									key = o is String ? o as String : String(o);
								}
								else {
									vM = [obj, 1, _vAt2[0], _vAt2[_vAt2Index - 1], _position2, _position];
									for (vMIndex = 0; vMIndex < _vAt2Index; vMIndex++) {
										_vAt[_vAt2[vMIndex]] = vM;
									}
								}
								a = _v[_position];
								switch (a) {
									case JT.COLON:
										_position += 2;
										a = _v[_position];
										switch (a) {
											case JT.OPEN_BRACE:
											case JT.OPEN_BRACKET:
												obj[key] = o = parseValue();
												if (_length == 1) {
													if (null != _replace && _replace.hasOwnProperty(key)) {
														obj[key] = o = _replace[key];
													}
													if (_vk.hasOwnProperty(key)) {
														checkVK(key, o);
													}
												}
												break;
											default:
												o = parseValue2();
												switch (_t) {
													case JT.STRING:
													case JT.NUMBER:
													case JT.BASE_2:
													case JT.AT:
													case JT.EXPRESSION:
														if (_t < JT.AT) {
															if (null == vM) {
																obj[key] = o;
																if (_length == 1) {
																	if (null != _replace && _replace.hasOwnProperty(key)) {
																		obj[key] = o = _replace[key];
																	}
																	if (_vk.hasOwnProperty(key)) {
																		checkVK(key, o);
																	}
																}
															}
															else {
																vM[7] = 0;
																vM[8] = o;
															}
														}
														else {
															if (null == vM) {
																if (_length == 1 && null != _replace && _replace.hasOwnProperty(key)) {
																	obj[key] = o = _replace[key];
																	if (_vk.hasOwnProperty(key)) {
																		checkVK(key, o);
																	}
																	_vAt2Index = 0;
																}
																else {
																	vM = [obj, 0, key, _vAt2[0], _vAt2[_vAt2Index - 1], _position2, _position];
																}
															}
															else {
																vM[7] = 1;
																vM[9] = _vAt2[0];
																vM[10] = _vAt2[_vAt2Index - 1];
																vM[11] = _position2;
																vM[12] = _position;
															}
															for (vMIndex = 0; vMIndex < _vAt2Index; vMIndex++) {
																_vAt[_vAt2[vMIndex]] = vM;
															}
														}
														break;
												}
												break;
										}
										break;
									default:
										parseError("Expecting : but found " + ((a < 161 && T[a]) ? String.fromCharCode(a) : _position < _vIndex ? _v[_position + 1] : "end of input"), _position < _vIndex ? _v[_position - 1] : -1);
										return null;
										break;
								}
								break;
						}
						break;
				}
				key = null;
				o = null;
				vM = null;
				_vAt2 = null;
			}
			return obj;
		}
		
		protected function parseArray():Array
		{
			_position += 2;
			var a:int, key:int, vMIndex:int, obj:Array = [], vM:Array, o:Object;
			while (_position < _vIndex) {
				a = _v[_position];
				switch (a) {
					case JT.COMMA:
						_position += 2;
						break;
					case JT.CLOSE_BRACKET:
						_position += 2;
						return obj;
						break;
					case JT.OPEN_BRACE:
					case JT.OPEN_BRACKET:
						obj[key++] = parseValue();
						break;
					case JT.COLON:
						parseError("Unexpected " + String.fromCharCode(a), _v[_position - 1]);
						return null;
						break;
					default:
						o = parseValue2();
						switch (_t) {
							case JT.STRING:
							case JT.NUMBER:
							case JT.BASE_2:
							case JT.AT:
							case JT.EXPRESSION:
								if (_t < JT.AT) {
									obj[key++] = o;
								}
								else {
									vM = [obj, key++, _vAt2[0], _vAt2[_vAt2Index - 1], _position2, _position];
									for (vMIndex = 0; vMIndex < _vAt2Index; vMIndex++) {
										_vAt[_vAt2[vMIndex]] = vM;
									}
								}
						}
						break;
				}
				o = null;
				vM = null;
				_vAt2 = null;
			}
			return obj;
		}
		
		protected function parseOther():Object
		{
			_ot = JT.BASE;
			var str:String = _v[_position + 1];
			var l:int = str.length;
			if (l == 0) return str;
			var i:int, ot:int, b:Boolean, colon:Boolean;
			var a:String = str.charAt(i++), n:String, t:String;
			while (i < 3 && i < l) {
				switch (a) {
					case 'u':
					case 'U':
					case 'f':
					case 'F':
						if (null == t) t = a.toUpperCase();
						else t += a.toUpperCase();
						break;
					default:
						if (a < '0' || a > '9') {
							switch (a) {
								case '-':
								case '+':
								case 'x':
								case '.':
									break;
								default:
									ot = -1;
									break;
							}
						}
						b = true;
						break;
				}
				if (b == true) {
					break;
				}
				a = str.charAt(i++);
			}
			if (ot != -1) {
				n = "";
				switch (a) {
					case '-':
					case '+':
						n += a;
						if (i < l) {
							a = str.charAt(i++);
							switch (a) {
								// 是否为小数或 16 进制
								case '0':
									n += a;
									if (i < l) {
										n += a = str.charAt(i++);
										switch (a) {
											case '.':
												colon = true;
												break;
											case 'x':
												ot = 1;
												break;
											default:
												ot = -1;
												break;
										}
									}
									break;
								case '.':
									n += a;
									colon = true;
									break;
								case 'x':
									n += "0x";
									ot = 1;
									break;
								default:
									n += a;
									// 不为数字
									if (a < '0' || a > '9') {
										ot = -1;
									}
									break;
							}
						}
						else {
							ot = -1;
						}
						break;
					case '0':
						n += a;
						if (i < l) {
							n += a = str.charAt(i++);
							switch (a) {
								case '.':
									colon = true;
									break;
								case 'x':
									ot = 1;
									break;
								default:
									// 不为数字
									if (a < '0' || a > '9') {
										ot = -1;
									}
									break;
							}
						}
						break;
					case '.':
						n += a;
						colon = true;
						break;
					case 'x':
						n += "0x";
						ot = 1;
						break;
					default:
						n += a;
						// 不为数字
						if (a < '0' || a > '9') {
							ot = -1;
						}
						break;
				}
			}
			// 此处为数字
			if (ot != -1) {
				switch (ot) {
					// 十进制
					case 0:
						for (; i < l; i++) {
							n += a = str.charAt(i);
							// 应该只有一个小数点
							if (a < '0' || a > '9') {
								if (a == '.') {
									if (colon == false) {
										colon = true;
									}
									else {
										ot = -1;
										break;
									}
								}
								else if (a == 'e' || a == 'E') {
									n += a = str.charAt(++i);
									if (a == '+' || a == '-') {
										
									}
									else if (a < '0' || a > '9') {
										ot = -1;
										break;
									}
								}
								else {
									ot = -1;
									break;
								}
							}
						}
						break;
					// 十六进制
					case 1:
						for (; i < l; i++) {
							n += a = str.charAt(i);
							if (!((a >= '0' && a <= '9') || (a >= 'A' && a <= 'F') || (a >= 'a' && a <= 'f'))) {
								ot = -1;
								break;
							}
						}
						break;
				}
			}
			a = null;
			// 不为数字
			if (ot == -1) {
				n = null;
				switch (str) {
					case "true":
						_v[_position] = _ot = JT.BASE_2;
						return true;
						break;
					case "false":
						_v[_position] = _ot = JT.BASE_2;
						return false;
						break;
					case "null":
						_v[_position] = _ot = JT.BASE_2;
						return null;
						break;
					case "NaN":
						_v[_position] = _ot = JT.BASE_2;
						return NaN;
						break;
				}
				_ot = JT.STRING;
				return str;
			}
			else {
				str = null;
				_v[_position] = _ot = JT.NUMBER;
				if (ot == 0) {
					// 十进制
					if (null == t) {
						if (colon || n.indexOf('e') != -1 || n.indexOf('E') != -1) {
							return Number(n);
						}
						else if (n.charAt(0) != '-') {
							return uint(n);
						}
						else {
							return int(n);
						}
					}
					else {
						if (t.indexOf("F") != -1) {
							return Number(n);
						}
						else {
							if (colon || n.indexOf('e') != -1 || n.indexOf('E') != -1) {
								return Number(n);
							}
							else {
								return uint(n);
							}
						}
					}
				}
				else {
					if (n.charAt(0) != '-') {
						return uint(n);
					}
					else {
						return int(n);
					}
				}
			}
			return 0;
		}
		
		protected function parseOther2(obj:Object):Object
		{
			_ot = JT.BASE;
			if ((obj is String) == false) {
				return obj;
			}
			var str:String = String(obj);
			var l:int = str.length;
			if (l == 0) {
				return obj;
			}
			obj = null;
			var i:int, ot:int, b:Boolean, colon:Boolean;
			var a:String = str.charAt(i++), n:String, t:String;
			while (i < 3 && i < l) {
				switch (a) {
					case 'f':
					case 'F':
					case 'u':
					case 'U':
						if (null == t) t = a.toUpperCase();
						else t += a.toUpperCase();
						break;
					default:
						if (a < '0' || a > '9') {
							switch (a) {
								case '-':
								case '+':
								case 'x':
								case '.':
									break;
								default:
									ot = -1;
									break;
							}
						}
						b = true;
						break;
				}
				if (b == true) {
					break;
				}
				a = str.charAt(i++);
			}
			if (ot != -1) {
				n = "";
				switch (a) {
					case '-':
					case '+':
						n += a;
						if (i < l) {
							a = str.charAt(i++);
							switch (a) {
								// 是否为小数或 16 进制
								case '0':
									n += a;
									if (i < l) {
										n += a = str.charAt(i++);
										switch (a) {
											case '.':
												colon = true;
												break;
											case 'x':
												ot = 1;
												break;
											default:
												ot = -1;
												break;
										}
									}
									break;
								case '.':
									n += a;
									colon = true;
									break;
								case 'x':
									n += "0x";
									ot = 1;
									break;
								default:
									n += a;
									// 不为数字
									if (a < '0' || a > '9') {
										ot = -1;
									}
									break;
							}
						}
						else {
							ot = -1;
						}
						break;
					case '0':
						n += a;
						if (i < l) {
							n += a = str.charAt(i++);
							switch (a) {
								case '.':
									colon = true;
									break;
								case 'x':
									ot = 1;
									break;
								default:
									// 不为数字
									if (a < '0' || a > '9') {
										ot = -1;
									}
									break;
							}
						}
						break;
					case '.':
						n += a;
						colon = true;
						break;
					case 'x':
						n += "0x";
						ot = 1;
						break;
					default:
						n += a;
						// 不为数字
						if (a < '0' || a > '9') {
							ot = -1;
						}
						break;
				}
			}
			// 此处为数字
			if (ot != -1) {
				switch (ot) {
					// 十进制
					case 0:
						for (; i < l; i++) {
							n += a = str.charAt(i);
							// 应该只有一个小数点
							if (a < '0' || a > '9') {
								if (a == '.') {
									if (colon == false) {
										colon = true;
									}
									else {
										ot = -1;
										break;
									}
								}
								else if (a == 'e' || a == 'E') {
									n += a = str.charAt(++i);
									if (a == '+' || a == '-') {
										
									}
									else if (a < '0' || a > '9') {
										ot = -1;
										break;
									}
								}
								else {
									ot = -1;
									break;
								}
							}
						}
						break;
					// 十六进制
					case 1:
						for (; i < l; i++) {
							n += a = str.charAt(i);
							if (!((a >= '0' && a <= '9') || (a >= 'A' && a <= 'F') || (a >= 'a' && a <= 'f'))) {
								ot = -1;
								break;
							}
						}
						break;
				}
			}
			a = null;
			// 不为数字
			if (ot == -1) {
				n = null;
				switch (str) {
					case "true":
						_ot = JT.BASE_2;
						return true;
						break;
					case "false":
						_ot = JT.BASE_2;
						return false;
						break;
					case "null":
						_ot = JT.BASE_2;
						return null;
						break;
					case "NaN":
						_ot = JT.BASE_2;
						return NaN;
						break;
				}
				_ot = JT.STRING;
				return str;
			}
			else {
				str = null;
				_ot = JT.NUMBER;
				if (ot == 0) {
					// 十进制
					if (null == t) {
						if (colon || n.indexOf('e') != -1 || n.indexOf('E') != -1) {
							return Number(n);
						}
						else if (n.charAt(0) != '-') {
							return uint(n);
						}
						else {
							return int(n);
						}
					}
					else {
						if (t.indexOf("F") != -1) {
							return Number(n);
						}
						else {
							if (colon || n.indexOf('e') != -1 || n.indexOf('E') != -1) {
								return Number(n);
							}
							else {
								return uint(n);
							}
						}
					}
				}
				else {
					if (n.charAt(0) != '-') {
						return uint(n);
					}
					else {
						return int(n);
					}
				}
			}
			return 0;
		}
		
		protected function checkVK(key:String, obj:Object):void
		{
			var arr:Array = _vk[key], arr2:Array, vKT:Array;
			var a:int, i:int = arr.length, j:int, k:int, b:Boolean, key2:String, key3:String, o:Object;
			for (; i > 0;) {
				j = k = arr[--i];
				a = _v[j];
				switch (a) {
					case JT.STRING_AT:
					case JT.STRING_AT2:
					case JT.STRING_AT3:
					case JT.AT:
					case JT.AT2:
					case JT.AT3:
						arr.length--;
						switch (a) {
							case JT.STRING_AT:
							case JT.AT:
								_v[j] = JT.REPLACE;
								_v[j + 1] = obj;
								break;
							default:
								_v[j] = JT.SKIP;
								key2 = key;
								o = obj;
								j += 3;
								b = false;
								while (true) {
									a = _v[j];
									if (a == JT.STRING_AT || a == JT.AT) {
										key3 = _v[j + 1];
										key2 = _v[j + 1] = key3.replace("@[" + key2 + "]", o);
										if (_firstObj.hasOwnProperty(key2)) {
											_v[j] = JT.REPLACE;
											_v[j + 1] = _firstObj[key2];
											if (_vk.hasOwnProperty(key2)) {
												arr2 = _vk[key2];
												if (arr2.length == 1) {
													_vkLength--;
													delete _vk[key2];
												}
												else {
													arr2.length--;
												}
											}
										}
										else if (key2.indexOf("@[") == -1) {
											if (_vk.hasOwnProperty(key2) == false) {
												_vk[key2] = [j];
												_vkLength++;
											}
											else {
												arr2 = _vk[key2];
												arr2[arr2.length] = j;
											}
										}
										break;
									}
									else if (b == false && (a == JT.STRING_AT2 || a == JT.AT2)) {
										b = true;
										key3 = _v[j + 1];
										key2 = _v[j + 1] = key3.replace("@[" + key2 + "]", o);
										o = "@[" + key2 + "]";
										if (key2.indexOf("@[") == -1) {
											// 继续替换后面的，直到 AT
											if (_firstObj.hasOwnProperty(key2)) {
												_v[j] = JT.SKIP;
												o = _firstObj[key2];
												key2 = key3;
											}
											else {
												if (_vk.hasOwnProperty(key2) == false) {
													_vk[key2] = [j];
													_vkLength++;
												}
												else {
													arr2 = _vk[key2];
													arr2[arr2.length] = j;
												}
											}
											key2 = key3;
										}
										else {
											break;
										}
									}
									j += 3;
								}
								break;
						}
						if (_vAt.hasOwnProperty(k)) {
							arr2 = _vAt[k];
							if (arr2[0] is Array) {
								o = getKValue(arr2, 2);
								if (_t) {
									arr2[0][arr2[1]] = o;
								}
							}
							else {
								// key 为字符串
								if (arr2[1] == 0) {
									o = getKValue(arr2, 3);
									if (_t) {
										key2 = arr2[2];
										arr2[0][key2] = o;
										if (arr2[0] == _firstObj && _vk.hasOwnProperty(key2)) {
											checkVK(key2, o);
										}
									}
								}
								else {
									if (arr2[7] == 1) {
										o = getKValue(arr2, 7);
										if (_t) {
											arr2[7] = 0;
											arr2[8] = o;
											arr2.length = 9;
										}
									}
									o = getKValue(arr2, 2);
									if (_t) {
										if (arr2[0] == _firstObj && null != _replace && _replace.hasOwnProperty(o)) {
											arr2[0][o] = _replace[o];
										}
										else {
											if (arr2[7] == 0) {
												arr2[0][o] = arr2[8];
											}
											else {
												arr2[1] = 0;
												arr2[2] = o;
												arr2.splice(3, 4);
											}
										}
									}
								}
							}
						}
						break;
				}
				o = null;
				arr2 = null;
				key2 = null;
				key3 = null;
			}
			if (arr.length == 0) {
				_vkLength--;
				delete _vk[key];
			}
			arr = null;
			key = null;
			obj = null;
		}
		
		protected function checkVK2():void
		{
			var i:int, j:int, l:int, arr:Array;
			for each (arr in _vk) {
				for (i = 0, l = arr.length; i < l; i++) {
					j = arr[i];
					switch (_v[j]) {
						case JT.STRING_AT:
						case JT.AT:
							_v[j] = JT.STRING;
							_v[j + 1] = "@[" + _v[j + 1] + "]";
							break;
					}
				}
			}
			for each (arr in _vAt) {
				if (arr[0] is Array) {
					if (!arr[0][arr[1]]) {
						for (i = arr[2], l = arr[3]; i < l; i++) {
							delete _vAt[i];
						}
						arr[0][arr[1]] = parseValue3(arr[4], arr[5]);
					}
				}
				else {
					if (arr[1] == 0) {
						for (i = arr[3], l = arr[4]; i < l; i++) {
							delete _vAt[i];
						}
						arr[0][arr[2]] = parseValue3(arr[5], arr[6]);
					}
					else {
						for (i = arr[2], l = arr[3]; i < l; i++) {
							delete _vAt[i];
						}
						if (arr[6] != 0) {
							for (i = arr[7], l = arr[8]; i < l; i++) {
								delete _vAt[i];
							}
							arr[7] = parseValue3(arr[9], arr[10]);
							arr.length = 8;
						}
						arr[0][parseValue3(arr[4], arr[5])] = arr[7];
					}
				}
			}
			arr = null;
		}
		
		protected function getKValue(arr:Array, index:int):Object
		{
			_t = 0;
			var kStartIndex:int = index++, kEndIndex:int = index++, startIndex:int = index++, endIndex:int = index++, start:int = arr[kStartIndex], end:int = arr[kEndIndex], b:Boolean;
			for (; start < end; start += 3) {
				switch (_v[start]) {
					case JT.STRING_AT:
					case JT.STRING_AT2:
					case JT.STRING_AT3:
					case JT.AT:
					case JT.AT2:
					case JT.AT3:
						b = true;
						break;
					default:
						if (_vAt.hasOwnProperty(start)) {
							delete _vAt[start];
						}
						break;
				}
				if (b == true) {
					break;
				}
			}
			if (_v[end] == JT.REPLACE) {
				_t = 1;
				if (_vAt.hasOwnProperty(start)) {
					delete _vAt[start];
				}
				return parseValue3(arr[startIndex], arr[endIndex]);
			}
			else {
				arr[kStartIndex] = start;
			}
			arr = null;
			return null;
		}
		
		protected function parseError(message:String, position:int):void
		{
			_position = -1;
			var error:ParseError = new ParseError(message + " at " + position, position);
			if (null == _error) {
				throw error;
			}
			else {
				if (_error is Function) {
					_error(error);
				}
				else if (_error is Array) {
					_error.push(error);
				}
				else {
					_error[0] = error;
				}
			}
			error = null;
			message = null;
		}
		
		// parse end
		
		/**
		 * Converts a value to it's JSON string equivalent.
		 *
		 * @param value The value to convert.  Could be any
		 *		type (object, number, array, etc)
		 */
		protected function convertToString(value:Object):String
		{
			// determine what value is and convert it based on it's type
			if (value is String) {
				// escape the string so it's formatted correctly
				return escapeString(value as String);
			}
			else if (value is Number) {
				// only encode numbers that finate
				return isFinite(value as Number) ? value.toString() : "null";
			}
			else if (value is Boolean) {
				// convert boolean to string easily
				return value ? "true" : "false";
			}
			else if (value is Array) {
				// call the helper method to convert an array
				return arrayToString(value as Array);
			}
			else if (value is Object && value != null) {
				// call the helper method to convert an object
				return objectToString(value);
			}
			return "null";
		}
		
		/**
		 * Escapes a string accoding to the JSON specification.
		 *
		 * @param str The string to be escaped
		 * @return The string with escaped special characters
		 * 		according to the JSON specification
		 */
		protected function escapeString(str:String):String
		{
			// create a string to store the string's jsonstring value
			var s:String = "";
			// current character in the string we're processing
			var ch:String;
			var hexCode:String, zeroPad:String;
			// loop over all of the characters in the string
			for (var i:int = 0, l:int = str.length; i < l; i++) {
				// examine the character to determine if we have to escape it
				ch = str.charAt(i);
				switch (ch) {
					case '"': // quotation mark
						s += "\\\"";
						break;
					//case '/':	// solidus
					//	s += "\\/";
					//	break;
					case '\\': // reverse solidus
						s += "\\\\";
						break;
					case '\b': // bell
						s += "\\b";
						break;
					case '\f': // form feed
						s += "\\f";
						break;
					case '\n': // newline
						s += "\\n";
						break;
					case '\r': // carriage return
						s += "\\r";
						break;
					case '\t': // horizontal tab
						s += "\\t";
						break;
					default: // everything else
						// check for a control character and escape as unicode
						if (ch < ' ') {
							// get the hex digit(s) of the character (either 1 or 2 digits)
							hexCode = ch.charCodeAt(0).toString(16);
							// ensure that there are 4 digits by adjusting
							// the # of zeros accordingly.
							zeroPad = hexCode.length == 2 ? "00" : "000";
							// create the unicode escape sequence with 4 hex digits
							s += "\\u" + zeroPad + hexCode;
						}
						else {
							// no need to do any special encoding, just pass-through
							s += ch;
						}
				} // end switch
			} // end for loop
			return "\"" + s + "\"";
		}
		
		/**
		 * Converts an array to it's JSON string equivalent
		 *
		 * @param a The array to convert
		 * @return The JSON string representation of <code>a</code>
		 */
		protected function arrayToString(a:Object):String
		{
			// create a string to store the array's jsonstring value
			var b:Boolean, s:String = "";
			// loop over the elements in the array and add their converted
			// values to the string
			for (var i:int = 0, l:int = a.length; i < l; i++) {
				// when the length is 0 we're adding the first item so
				// no comma is necessary
				// we've already added an item, so add the comma separator
				b == true ? (s += ",") : (b = true);
				// convert the value to a string
				s += convertToString(a[i]);
			}
			// KNOWN ISSUE:  In ActionScript, Arrays can also be associative
			// objects and you can put anything in them, ie:
			//		myArray["foo"] = "bar";
			//
			// These properties aren't picked up in the for loop above because
			// the properties don't correspond to indexes.  However, we're
			// sort of out luck because the JSON specification doesn't allow
			// these types of array properties.
			//
			// So, if the array was also used as an associative object, there
			// may be some values in the array that don't get properly encoded.
			//
			// A possible solution is to instead encode the Array as an Object
			// but then it won't get decoded correctly (and won't be an
			// Array instance)
			// close the array and return it's string value
			return "[" + s + "]";
		}
		
		/**
		 * Converts an object to it's JSON string equivalent
		 *
		 * @param o The object to convert
		 * @return The JSON string representation of <code>o</code>
		 */
		protected function objectToString(o:Object):String
		{
			// create a string to store the object's jsonstring value
			var b:Boolean, s:String = "";
			// determine if o is a class instance or a plain object
			var classInfo:XML = describeType(o);
			if (classInfo.@name.toString() == "Object") {
				// the value of o[key] in the loop below - store this 
				// as a variable so we don't have to keep looking up o[key]
				// when testing for valid values to convert
				var value:Object;
				// loop over the keys in the object and add their converted
				// values to the string
				for (var key:String in o) {
					// assign value to a variable for quick lookup
					value = o[key];
					// don't add function's to the JSON string
					if (value is Function) {
						// skip this key and try another
						continue;
					}
					// when the length is 0 we're adding the first item so
					// no comma is necessary
					// we've already added an item, so add the comma separator
					b == true ? (s += ",") : (b = true);
					s += escapeString(key) + ":" + convertToString(value);
				}
			}
			else if (classInfo.@name.toString().indexOf("__AS3__.vec") == 0) {
				return arrayToString(o);
			}
			else {
				// o is a class instance
				// Loop over all of the variables and accessors in the class and 
				// serialize them along with their values.
				b = s.length > 0 ? true : false;
				for each (var v:XML in classInfo..*.(
					name() == "variable"
					||
					(
						name() == "accessor"
						// Issue #116 - Make sure accessors are readable
						&& attribute("access").charAt(0) == "r")
				))
				{
					if (v.attribute("uri").length()) continue;
					// Issue #110 - If [Transient] metadata exists, then we should skip
					if (v.metadata && v.metadata.(@name == "Transient").length() > 0) {
						continue;
					}
					// when the length is 0 we're adding the first item so
					// no comma is necessary
					// we've already added an item, so add the comma separator
					b == true ? (s += ",") : (b = true);
					s += escapeString(v.@name.toString()) + ":" + convertToString(o[v.@name]);
				}
			}
			return "{" + s + "}";
		}
		
		protected function xmlToJSON(value:Object, useAttribute:Boolean = true, useLocalName:Boolean = true, contentName:String = "_"):Object
		{
			if (null === value) return value;
			if ((value is XML) == false && (value is XMLList) == false) value = new XML(value);
			var obj:Object, a:Object = value.attributes(), c:Object = value.children(), n:String, v:Object;
			var i:int, j:int, l:int = useAttribute == true ? a.length() : 0, m:int = c.length();
			if (l != 0) {
				obj = {};
				for (; i < l; i++) {
					v = a[i];
					n = useLocalName == true ? v.localName() : v.name();
					obj[n] = parseOther2(v.toString());
				}
			}
			a = null;
			if (m == 1 && null == (v = c[0]).localName()) {
				c = null;
				value = null;
				v = parseOther2(v.toString());
				if (l == 0) {
					contentName = null;
					return v;
				}
				else {
					n = contentName;
					if (obj.hasOwnProperty(n) == false) obj[n] = v;
					else if (obj[n] is Array) obj[n].push(v);
					else obj[n] = [obj[n], v];
				}
				n = null;
				v = null;
				contentName = null;
				return obj;
			}
			else if (null == obj) obj = m != 0 ? {} : parseOther2(value.toString());
			var obj2:Object, c2:Object, v2:Object, v3:Object;
			for (i = 0; i < m; i++) {
				v = c[i];
				c2 = v.children();
				l = c2.length();
				if (l == 1 && null == (v2 = c2[0]).localName()) {
					v2 = parseOther2(v2.toString());
					a = v.attributes();
					l = useAttribute == true ? a.length() : 0;
					if (l == 0) obj2 = v2;
					else {
						obj2 = {};
						for (j = 0; j < l; j++) {
							v3 = a[j];
							n = useLocalName == true ? v3.localName() : v3.name();
							obj2[n] = parseOther2(v3.toString());
						}
						v3 = null;
						n = contentName;
						if (obj2.hasOwnProperty(n) == false) obj2[n] = v2;
						else if (obj2[n] is Array) obj2[n].push(v2);
						else obj2[n] = [obj2[n], v2];
					}
					a = null;
				}
				else if (l != 0 || (useAttribute == true && v.attributes().length() != 0)) obj2 = xmlToJSON(v, useAttribute, useLocalName, contentName);
				else obj2 = parseOther2(v.toString());
				v2 = null;
				n = useLocalName == true ? v.localName() : v.name();
				if (null == n) n = contentName;
				if (obj.hasOwnProperty(n) == false) obj[n] = obj2;
				else if (obj[n] is Array) obj[n].push(obj2);
				else obj[n] = [obj[n], obj2];
			}
			c = null;
			v = null;
			obj2 = null;
			c2 = null;
			contentName = null;
			return obj;
		}
	}
}

internal final class JT
{
	static public const COMMA:int = 44;
	static public const COLON:int = 58;
	static public const COMMENT:int = 47;
	
	static public const OPEN_BRACE:int = 123;
	static public const CLOSE_BRACE:int = 125;
	static public const OPEN_BRACKET:int = 91;
	static public const CLOSE_BRACKET:int = 93;
	static public const OPEN_PARENTHESIS:int = 40;
	static public const CLOSE_PARENTHESIS:int = 41;
	
	static public const STRING:int = 34;
	static public const STRING_2:int = -340;
	static public const STRING_AT:int = -3400;
	static public const STRING_AT2:int = -34000;
	static public const STRING_AT3:int = -340000;
	
	static public const NUMBER:int = -123;
	
	static public const AT:int = 64;
	static public const AT2:int = -640;
	static public const AT3:int = -6400;
	
	static public const OTHER:int = -10;
	static public const SKIP:int = -100;
	static public const EXPRESSION:int = 100000000;
	
	static public const BASE:int = -100000;
	static public const BASE_2:int = -10000;
	static public const REPLACE:int = -20000;
}

internal final class ParseError extends Error
{
	public var position:int;
	
	public function ParseError(message:String, position:int)
	{
		this.position = position;
		super(message);
	}
}