package swift.core.magic
{
	import flash.utils.Dictionary;
	
	import org.aisy.interfaces.IClear;
	
	use namespace magic_internal;

	internal class MagicVarData implements IClear
	{
		magic_internal var vars:Dictionary;
		
		magic_internal var fun:MagicFunctionData;
		
		magic_internal var parent:MagicVarData;
		
		public function MagicVarData()
		{
		}
		
		magic_internal function hasKey(key:String):uint
		{
			if (null !== vars) {
				if (vars.hasOwnProperty(key) === true) {
					return 1;
				}
			}
			if (null !== fun) {
				if (null !== fun.fun) {
					if (fun.fun.hasOwnProperty(key) === true) {
						return 2;
					}
				}
			}
			key = null;
			return 0;
		}
		
		magic_internal function getVar(key:String, checkParent:Boolean = false):*
		{
			if (null !== vars && vars.hasOwnProperty(key) === true) {
				return vars[key];
			}
			if (checkParent === true) {
				var vd:MagicVarData = parent;
				while (null !== vd) {
					if (null !== vd.vars && vd.vars.hasOwnProperty(key) === true) {
						return vd.vars[key];
					}
					vd = vd.parent;
				}
				vd = null;
			}
			key = null;
			return null;
		}
		
		magic_internal function getFun(key:String, checkParent:Boolean = false):MagicFunctionData
		{
			if (null !== fun.fun && fun.fun.hasOwnProperty(key) === true) {
				return fun.fun[key];
			}
			if (checkParent === true) {
				var vd:MagicVarData = parent;
				while (null !== vd) {
					if (null !== vd.fun.fun && vd.fun.fun.hasOwnProperty(key) === true) {
						return vd.fun.fun[key];
					}
					vd = vd.parent;
				}
				vd = null;
			}
			return null;
		}
		
		magic_internal function getObj(key:String, checkParent:Boolean = false):*
		{
			var i:uint = hasKey(key);
			if (i === 1) {
				return vars[key];
			}
			else if (i === 2) {
				return fun.fun[key];
			}
			if (checkParent === true) {
				var vd:MagicVarData = parent;
				while (null !== vd) {
					i = vd.hasKey(key);
					if (i === 1) {
						return vd.vars[key];
					}
					else if (i === 2) {
						return vd.fun.fun[key];
					}
					vd = vd.parent;
				}
				vd = null;
			}
			key = null;
			return null;
		}
		
		magic_internal function getVars(key:String, checkParent:Boolean = false):Dictionary
		{
			if (null !== vars && vars.hasOwnProperty(key) === true) {
				key = null;
				return vars;
			}
			if (checkParent === true) {
				var vd:MagicVarData = parent;
				while (null !== vd) {
					if (null !== vd.vars && vd.vars.hasOwnProperty(key) === true) {
						key = null;
						return vd.vars;
					}
					vd = vd.parent;
				}
				vd = null;
			}
			key = null;
			return null;
		}
		
		public function clear():void
		{
			vars = null;
			fun = null;
			parent = null;
		}
		
	}
}

internal namespace magic_internal = "213384665b731cdf2fe17d13266786f65ceee0e1ab799e0ee704860761556606";