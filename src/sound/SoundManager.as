package sound 
{
	import flash.utils.Dictionary;
	import flash.external.ExternalInterface;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class SoundManager 
	{
		private var keys:Vector.<String>;
		private var sounds:Vector.<SoundLoader>;
		private var currentVolume:Number;
		public function SoundManager() 
		{
			keys = new Vector.<String>();
			sounds = new Vector.<SoundLoader>();
			currentVolume = 1;
		}
		
		public function load(key:String, url:String):void {
			if (keys.indexOf(key) < 0) {
				keys.push(key);
				sounds.push(new SoundLoader(url));
			}
		}
		
		public function play(key:String, starTime:Number = 0, loopTime:int = 0):void {
			var idx:int = keys.indexOf(key);
			if (idx >= 0) {
				sounds[idx].play(starTime, loopTime);
			}
		}
		
		public function continuePlay(key:String):void {
			var idx:int = keys.indexOf(key);
			if (idx >= 0) {
				sounds[idx].continuePlay();
			}
		}
		
		public function pause(key:String):void {
			var idx:int = keys.indexOf(key);
			if (idx >= 0) {
				sounds[idx].pause();
			}
		}
		
		public function stop(key:String):void {
			var idx:int = keys.indexOf(key);
			if (idx >= 0) {
				sounds[idx].stop();
			}
		}
		
		public function unMute(key:String):void {
			var idx:int = keys.indexOf(key);
			if (idx >= 0) {
				sounds[idx].unMute();
			}
		}
		
		public function mute(key:String):void {
			var idx:int = keys.indexOf(key);
			if (idx >= 0) {
				sounds[idx].mute();
			}
		}
		
		public function pauseAll():void {
			for (var i:int = 0; i < sounds.length; ++i) {
				sounds[i].pause();
			}
		}
		
		public function stopAll():void {
			for (var i:int = 0; i < sounds.length; ++i) {
				sounds[i].stop();
			}
		}
		
		public function unMuteAll():void {
			for (var i:int = 0; i < sounds.length; ++i) {
				sounds[i].unMute();
			}
		}
		
		public function muteAll():void {
			for (var i:int = 0; i < sounds.length; ++i) {
				sounds[i].mute();
			}
		}
		
		public function set Volume(value:Number):void {
			currentVolume = value;
			for (var i:int = 0; i < sounds.length; ++i) {
				sounds[i].Volume = currentVolume;
			}
		}
		
		public function get Volume():Number {
			return currentVolume;
		}
		
		public function Ready(key:String):Boolean {
			var idx:int = keys.indexOf(key);
			if (idx >= 0) {
				return sounds[idx].Ready;
			}
			return false;
		}
		
		public function Playing(key:String):Boolean {
			var idx:int = keys.indexOf(key);
			if (idx >= 0) {
				return sounds[idx].Playing;
			}
			return false;
		}
		
	}

}