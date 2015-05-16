package swift.view.core
{
	import flash.display.BitmapData;
	
	import org.aisy.utimer.UTimer;

	public class AnimationBitmap extends UBitmap
	{
		protected var _play:Boolean;
		protected var _texture:AnimationBitmapTexture;
		protected var _utimer:UTimer;
		protected var _frameRate:Number;
		protected var _currentFrame:uint;
		protected var _currentFlag:Flag;
		
		public function AnimationBitmap(bitmapData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false)
		{
			super(bitmapData, pixelSnapping, smoothing);
			_frameRate = 0;
			bitmapData = null;
			pixelSnapping = null;
		}
		
		protected function __gotoAndStop(frame:*):void
		{
			if (frame is String && null !== _texture) {
				var i:int = _texture.getFlagByName(String(frame));
				if (i !== -1) currentFlag = _texture.flags[i];
			}
			else currentFrame = uint(frame);
			frame = null;
		}
		
		public function setTexture(texture:AnimationBitmapTexture):void
		{
			_texture = texture;
			_currentFrame = 1;
		}
		
		public function set frameRate(value:Number):void
		{
			_frameRate = value;
			if (null !== _utimer) {
				_utimer.clear();
				_utimer = null;
			}
			if (_frameRate > 0) {
				_utimer = new UTimer();
				_utimer.setDelay(1000 / _frameRate);
				_utimer.setTimer(update);
			}
		}
		
		public function get frameRate():Number
		{
			return _frameRate;
		}
		
		public function set currentFrame(value:uint):void
		{
			_currentFrame = value === 0 ? 1 : value;
			if (null !== _texture) {
				if (null !== _currentFlag && _currentFrame > _currentFlag.frameEnd) _currentFrame = _currentFlag.frameStart + 1;
				else if (_currentFrame > _texture.totalFrames) _currentFrame = 1;
			}
		}
		
		public function get currentFrame():uint
		{
			return _currentFrame;
		}
		
		public function set currentFlag(flag:Flag):void
		{
			_currentFlag = flag;
			currentFrame = _currentFlag.frameStart + 1;
		}
		
		public function get currentFlag():Flag
		{
			return _currentFlag;
		}
		
		public function play():void
		{
			_play = true;
			if (null !== _utimer) {
				_utimer.reset();
				_utimer.start();
			}
			update();
		}
		
		public function stop():void
		{
			_play = false;
			if (null !== _utimer) {
				_utimer.reset();
				_utimer.stop();
			}
		}
		
		public function gotoAndPlay(frame:*):void
		{
			__gotoAndStop(frame);
			play();
			frame = null;
		}
		
		public function gotoAndStop(frame:*):void
		{
			__gotoAndStop(frame);
			_play = true;
			update();
			stop();
			frame = null;
		}
		
		public function update():void
		{
			if (_play === false) return;
			if (null !== _texture) {
				if (null === bitmapData) bitmapData = new BitmapData(_texture.rect.width, _texture.rect.height, true, 0);
				if (_texture.update(_currentFrame - 1, bitmapData) === true) currentFrame++;
			}
		}
		
		override public function clear():void
		{
			super.clear();
			_frameRate = 0;
			_play = false;
			_texture = null;
		}
		
	}
}