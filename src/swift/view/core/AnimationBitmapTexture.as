package swift.view.core
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import org.aisy.interfaces.IClear;

	public class AnimationBitmapTexture implements IClear
	{
		public var totalFrames:uint;
		public var rect:Rectangle;
		public var flags:Vector.<Flag>;
		public var frames:Vector.<Frame>;
		
		public function AnimationBitmapTexture(data:Array)
		{
			var l_0:uint = data.length, flag:Flag, frame:Frame, fArr:Array;
			rect = new Rectangle();
			flags = new Vector.<Flag>(l_0, true);
			frames = new Vector.<Frame>();
			for (var i:uint, j:uint, s:uint, l_1:uint; i < l_0; i++) {
				fArr = data[i]["frames"];
				l_1 = fArr.length;
				totalFrames += l_1;
				flag = new Flag(data[i]);
				flag.frameStart = j;
				flag.frameEnd = totalFrames;
				flags[i] = flag;
				for (j = 0; j < l_1; j++, s++) {
					frame = new Frame(fArr[j]);
					frame.flag = i;
					frames[s] = frame;
					if (rect.width < frame.rect.width + frame.point.x) rect.width = frame.rect.width + frame.point.x;
					if (rect.height < frame.rect.height + frame.point.y) rect.height = frame.rect.height + frame.point.y;
				}
			}
		}
		
		public function getFlagByName(name:String):int
		{
			for (var i:uint = 0, l:uint = flags.length; i < l; i++) {
				if (name === flags[i].name) {
					name = null;
					return i;
				}
			}
			name = null;
			return -1;
		}
		
		public function update(frame:uint, bmd:BitmapData):Boolean
		{
			var f:Frame = frames[frame], bmd2:BitmapData = flags[f.flag].bitmapData;
			if (null !== bmd2) {
				bmd.fillRect(rect, 0);
				bmd.copyPixels(bmd2, f.rect, f.point);
				f = null;
				bmd2 = null;
				return true;
			}
			f = null;
			return false;
		}
		
		public function clear():void
		{
			
		}
		
	}
}
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

import org.aisy.interfaces.IClear;

import swift.core.swift_internal;
import swift.utils.assets.parser.ParserUtil;

use namespace swift_internal;

internal class Frame implements IClear
{
	public var rect:Rectangle;
	public var point:Point;
	public var flag:uint;
	
	public function Frame(data:Object)
	{
		rect = new Rectangle();
		point = new Point();
		if (null !== data) {
			var voMap:Vector.<Vector.<String>> = Vector.<Vector.<String>>([
				Vector.<String>(["r"]),
				Vector.<String>(["p"])
			]);
			ParserUtil.assignData(data, this, voMap);				
			voMap = null;
			data = null;
		}
	}
	
	swift_internal function set r(data:Array):void
	{
		rect.x = data[0];
		rect.y = data[1];
		rect.width = data[2];
		rect.height = data[3];
		data = null;
	}
	
	swift_internal function set p(data:Array):void
	{
		point.x = data[0];
		point.y = data[1];
		data = null;
	}
	
	public function clear():void
	{
		rect = null;
		point = null;
	}
	
}