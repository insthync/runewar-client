package sound 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Ittipon
	 */
	public class SoundLoader 
	{
		private var loading:Boolean;
		private var ready:Boolean;
		private var s:Sound; 
		private var channel:SoundChannel;
		private var transform:SoundTransform;
		private var playing:Boolean;
		private var lastPlayed:Number;
		private var pausePoint:Number;
		private var currentVolume:Number;
		public function SoundLoader(url:String = null) 
		{
			s = new Sound();
			ready = false;
			loading = false;
			playing = false;
			pausePoint = 0;
			currentVolume = 0;
			transform = new SoundTransform(1);
			if (url != null) {
				Load(url);
			}
		}
		
		public function Load(url:String):void {
			if (loading || ready)
				return;
				
			loading = true;
			var req:URLRequest = new URLRequest(url);
			s.load(req);
			s.addEventListener(Event.COMPLETE, onLoaded);
			s.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
		}
		
		private function onLoaded(e:Event):void {
			s.removeEventListener(Event.COMPLETE, onLoaded);
			ready = true;
			loading = false;
			lastPlayed = getTimer() - s.length;
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void {
			trace("IO error occurred");
		}
		
		private function soundEnded(e:Event):void {
			playing = false;
		}
		
		public function play(starTime:Number = 0, loopTime:int = 0):void {
			if (ready && getTimer() - lastPlayed >= s.length / 2) {
				lastPlayed = getTimer();
				channel = s.play(starTime, loopTime);
				channel.soundTransform = transform;
				channel.addEventListener(Event.SOUND_COMPLETE, soundEnded);
				playing = true;
			}
		}
		
		public function continuePlay():void {
			if (ready && !playing) {
				channel = s.play(pausePoint);
				channel.soundTransform = transform;
				playing = true;
			}
		}
		
		public function pause():void {
			if (playing) {
				pausePoint = channel.position;
				channel.stop();
				playing = false;
			}
		}
		
		public function stop():void {
			if (playing) {
				lastPlayed = getTimer() - s.length;
				pausePoint = 0;
				channel.stop();
				playing = false;
			}
		}
		
		public function unMute():void {
			transform.volume = currentVolume;
		}
		
		public function mute():void {
			transform.volume = 0;
		}
		
		public function set Volume(value:Number):void {
			transform.volume = currentVolume = value;
		}
		
		public function get Volume():Number {
			return currentVolume;
		}
		
		public function get Ready():Boolean {
			return ready;
		}
		
		public function get Playing():Boolean {
			return playing;
		}
		
	}

}