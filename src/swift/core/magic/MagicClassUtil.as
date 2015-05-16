package swift.core.magic
{
	import flash.utils.getDefinitionByName;
	
	use namespace magic_internal;

	internal class MagicClassUtil
	{
		public function MagicClassUtil()
		{
		}
		
		static magic_internal function create(className:String, v:Array):*
		{
			switch (v.length) {
				case 0:
					v = null;
					return new (getDefinitionByName(className) as Class)();
					break;
				case 1:
					return new (getDefinitionByName(className) as Class)(v[0]);
					break;
				case 2:
					return new (getDefinitionByName(className) as Class)(v[0], v[1]);
					break;
				case 3:
					return new (getDefinitionByName(className) as Class)(v[0], v[1], v[2]);
					break;
				case 4:
					return new (getDefinitionByName(className) as Class)(v[0], v[1], v[2], v[3]);
					break;
				case 5:
					return new (getDefinitionByName(className) as Class)(v[0], v[1], v[2], v[3], v[4]);
					break;
				case 6:
					return new (getDefinitionByName(className) as Class)(v[0], v[1], v[2], v[3], v[4], v[5]);
					break;
				case 7:
					return new (getDefinitionByName(className) as Class)(v[0], v[1], v[2], v[3], v[4], v[5], v[6]);
					break;
				case 8:
					return new (getDefinitionByName(className) as Class)(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7]);
					break;
				case 9:
					return new (getDefinitionByName(className) as Class)(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8]);
					break;
				case 10:
					return new (getDefinitionByName(className) as Class)(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9]);
					break;
				case 11:
					return new (getDefinitionByName(className) as Class)(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10]);
					break;
				case 12:
					return new (getDefinitionByName(className) as Class)(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11]);
					break;
				case 13:
					return new (getDefinitionByName(className) as Class)(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12]);
					break;
				case 14:
					return new (getDefinitionByName(className) as Class)(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12], v[13]);
					break;
				case 15:
					return new (getDefinitionByName(className) as Class)(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12], v[13], v[14]);
					break;
				case 16:
					return new (getDefinitionByName(className) as Class)(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12], v[13], v[14], v[15]);
					break;
				case 17:
					return new (getDefinitionByName(className) as Class)(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12], v[13], v[14], v[15], v[16]);
					break;
				case 18:
					return new (getDefinitionByName(className) as Class)(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12], v[13], v[14], v[15], v[16], v[17]);
					break;
				case 19:
					return new (getDefinitionByName(className) as Class)(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12], v[13], v[14], v[15], v[16], v[17], v[18]);
					break;
			}
			className = null;
			v = null;
			return null;
		}
		
	}
}

internal namespace magic_internal = "213384665b731cdf2fe17d13266786f65ceee0e1ab799e0ee704860761556606";