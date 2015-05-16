package swift.core.magic
{
	use namespace magic_internal;

	internal class MagicFunctionUtil
	{
		public function MagicFunctionUtil()
		{
		}
		
		static magic_internal function create(exec:Function, f:MagicFunctionData, sData:Object, parentVarData:MagicVarData):Function
		{
			var l:uint = null === f.parameters ? 0 : f.parameters.length;
			switch (l) {
				case 1:
					return function (v0:*):*
					{
						return exec.apply(null, [f, sData, parentVarData, arguments.callee].concat(arguments));
					};
					break;
				case 2:
					return function (v0:*, v1:*):*
					{
						return exec.apply(null, [f, sData, parentVarData, arguments.callee].concat(arguments));
					};
					break;
				case 3:
					return function (v0:*, v1:*, v2:*):*
					{
						return exec.apply(null, [f, sData, parentVarData, arguments.callee].concat(arguments));
					};
					break;
				case 4:
					return function (v0:*, v1:*, v2:*, v3:*):*
					{
						return exec.apply(null, [f, sData, parentVarData, arguments.callee].concat(arguments));
					};
					break;
				case 5:
					return function (v0:*, v1:*, v2:*, v3:*, v4:*):*
					{
						return exec.apply(null, [f, sData, parentVarData, arguments.callee].concat(arguments));
					};
					break;
				case 6:
					return function (v0:*, v1:*, v2:*, v3:*, v4:*, v5:*):*
					{
						return exec.apply(null, [f, sData, parentVarData, arguments.callee].concat(arguments));
					};
					break;
				case 7:
					return function (v0:*, v1:*, v2:*, v3:*, v4:*, v5:*, v6:*):*
					{
						return exec.apply(null, [f, sData, parentVarData, arguments.callee].concat(arguments));
					};
					break;
				case 8:
					return function (v0:*, v1:*, v2:*, v3:*, v4:*, v5:*, v6:*, v7:*):*
					{
						return exec.apply(null, [f, sData, parentVarData, arguments.callee].concat(arguments));
					};
					break;
				case 9:
					return function (v0:*, v1:*, v2:*, v3:*, v4:*, v5:*, v6:*, v7:*, v8:*):*
					{
						return exec.apply(null, [f, sData, parentVarData, arguments.callee].concat(arguments));
					};
					break;
				default:
					return function ():*
					{
						return exec.apply(null, [f, sData, parentVarData, arguments.callee].concat(arguments));
					};
					break;
			}
			exec = null;
			f = null;
			sData = null;
			parentVarData = null;
			return null;
		}
		
	}
}

internal namespace magic_internal = "213384665b731cdf2fe17d13266786f65ceee0e1ab799e0ee704860761556606";