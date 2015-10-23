package Sound 
{
	import adobe.utils.CustomActions;
	import Cinematics.Trigger;
	import Core.Game;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.sampler.NewObjectSample;
	import flash.utils.Dictionary;
	import Misc.Tuple;
	import Setup.GameLoader;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class SoundManager 
	{
		private static var singleton:SoundManager;
		
		private var muted:Boolean;
		
		private var soundDictionary:Dictionary;
		private var musicDictionary:Dictionary;
		// Dictionaries of all existing sound/music files.  Keys are sound names (string), values are Sound instances.
		
		private var channelDictionary:Dictionary;
		// Dictionary of all open SoundChannels.  Keys are sound names (string), values are SoundChannel instances.
		// Thus if there are multiple channels playing the same sound, finding a precise SoundChannel instance 
		// is not guaranteed.
		
		private var transformDictionary:Dictionary;
		// Dictionary of SoundTransform instances in all open SoundChannels.  Keys are the SoundChannel instance, values
		// are the SoundChannel's SoundTransform instance.
		// This is necessary to keep track of a looping sound's volume
		
		private var positionDictionary:Dictionary;
		// Dictionary of positions in any paused SoundChannels.  Keys are sound channel instances, values are ints.
		// This is necessary because whenever a SoundChannel is stopped, its position is lost.  In order to resume it at the
		// same place we need an outside container.
		
		private var originVolumeDictionary:Dictionary;
		// Dictionary of original volums for SoundChannels.  Keys are sound channels, values are floats.
		
		private var endVolumeDictionary:Dictionary;
		
		private var masterVolume:Number;
		private var baseSoundVolume:Number;
		private var baseMusicVolume:Number;
		
		private var fadeInTrack:Tuple;
		private var fadeOutTrack:Tuple;
		
		public static function getSingleton():SoundManager {
			if (singleton == null)
				singleton = new SoundManager();
			return singleton;
		}
		
		public function SoundManager() 
		{	// Do NOT call directly!
			
			musicDictionary = new Dictionary();
			soundDictionary = new Dictionary();
			channelDictionary = new Dictionary();
			transformDictionary = new Dictionary();
			positionDictionary = new Dictionary();
			endVolumeDictionary = new Dictionary();
			originVolumeDictionary = new Dictionary();
			
			masterVolume = 1;
			baseMusicVolume = 1;
			baseSoundVolume = 1;
			
			
			musicDictionary["Static"] = new GameLoader.Static() as Sound;
			musicDictionary["Thunder"] = new GameLoader.Thunder() as Sound;
			musicDictionary["Tunnel"] = new GameLoader.Tunnel() as Sound;
			musicDictionary["Wind"] = new GameLoader.Wind() as Sound;
			musicDictionary["Melody"] = new GameLoader.Melody() as Sound;
			
			soundDictionary["CinematicBoom"] = new GameLoader.cinematicBoom() as Sound;
			soundDictionary["Remington"] = new GameLoader.revolver() as Sound;
			
			soundDictionary["Possess"] = new GameLoader.Possess() as Sound;
			soundDictionary["Unpossess"] = new GameLoader.Unpossess() as Sound;
			soundDictionary["Footstep"] = new GameLoader.Footstep() as Sound;
			soundDictionary["Slow Footstep"] = new GameLoader.SlowFootstep() as Sound;
			soundDictionary["Light Footstep"] = new GameLoader.LightFootstep() as Sound;
			soundDictionary["Randy Text"] = new GameLoader.RandyText() as Sound;
			soundDictionary["Ted Text"] = new GameLoader.TedText() as Sound;
			soundDictionary["Normal Text"] = new GameLoader.NormalText() as Sound;
			
			
			var root:String = Main.getSingleton().rootURL;
			
			muted = false;
		}
		
		private function loadNormalComplete(event:Event):void {
			
		}
		
		public function hasSound(soundName:String):Boolean {
			return soundDictionary[soundName] != null;
		}
		
		public function getMasterVolume():Number { return masterVolume; }
		public function getMusicVolume():Number { return baseMusicVolume; }
		public function getSoundVolume():Number { return baseSoundVolume; }
		
		public function changeMasterVolume(delta:Number):void {
			masterVolume += delta;
			if (masterVolume > 1) masterVolume = 1;
			if (masterVolume < 0) masterVolume = 0;
			
			masterPreMute = masterVolume;
			updateAllChannelVolumes();
		}
		public function changeMusicVolume(delta:Number):void {
			baseMusicVolume += delta;
			if (baseMusicVolume > 1) baseMusicVolume = 1;
			if (baseMusicVolume < 0) baseMusicVolume = 0;
			
			updateAllChannelVolumes();
		}
		public function changeSoundVolume(delta:Number):void {
			baseSoundVolume += delta;
			if (baseSoundVolume > 1) baseSoundVolume = 1;
			if (baseSoundVolume < 0) baseSoundVolume = 0;
			
			updateAllChannelVolumes();
		}
		
		private var masterPreMute:Number;
		
		public function muteSound():void {
			muted = true;
			masterPreMute = masterVolume;
			masterVolume = 0;
			
			changeAllChannelVolumes(0);
		}
		public function unMuteSound():void {
			muted = false;
			masterVolume = masterPreMute;
			
			changeAllChannelVolumes(masterVolume);
		}
		
		private function updateAllChannelVolumes():void {
			for (var key:Object in channelDictionary) {
				var originalVolume:Number = originVolumeDictionary[channelDictionary[key]];
				var finalVolume:Number = findFinalVolume(key + "", originalVolume);
				var tempTransform:SoundTransform = new SoundTransform(finalVolume);
				transformDictionary[channelDictionary[key]] = tempTransform;
				trace(finalVolume);
				channelDictionary[key].soundTransform = transformDictionary[channelDictionary[key]];
			}
		}
		private function changeAllChannelVolumes(newVolume:Number):void {
			for (var key:Object in channelDictionary) {
				var finalVolume:Number = findFinalVolume(key + "", newVolume);
				var tempTransform:SoundTransform = new SoundTransform(finalVolume);
				transformDictionary[channelDictionary[key]] = tempTransform;
				channelDictionary[key].soundTransform = transformDictionary[channelDictionary[key]];
			}
		}
		private function findFinalVolume(soundName:String, endVolume:Number):Number {
			var finalVolume:Number;
			
			if (soundDictionary[soundName] != null) finalVolume = endVolume * baseSoundVolume;
			else if (musicDictionary[soundName] != null) finalVolume = endVolume * baseMusicVolume;
			else finalVolume = endVolume;
			
			finalVolume = finalVolume * masterVolume;
			
			return finalVolume;
		}
		
		private function findSound(soundName:String):Sound {
			if (soundDictionary[soundName] != null) return soundDictionary[soundName];
			else if (musicDictionary[soundName] != null) return musicDictionary[soundName];
			return null;
		}
		
		
		public function playSound(soundName:String, volume:Number = 1, loop:Boolean = false):void {
			
			if (findSound(soundName) != null) {
				
				var finalVolume:Number = findFinalVolume(soundName, volume);
				var newChannel:SoundChannel = findSound(soundName).play();
				var soundTransform:SoundTransform = new SoundTransform(finalVolume);
				
				originVolumeDictionary[newChannel] = finalVolume;
				if (newChannel == null)
					removeOldChannels();
				newChannel.soundTransform = soundTransform;
				transformDictionary[newChannel] = soundTransform;
				
				if (loop) newChannel.addEventListener(Event.SOUND_COMPLETE, playAgain);
				
				if (channelDictionary[soundName] != null) resolveNameConflict(soundName);
				channelDictionary[soundName] = newChannel;
				
				if (muted) {
					var muteTransform:SoundTransform = new SoundTransform(0);
					newChannel.soundTransform = muteTransform;
				}
			}
		}
		public function fadeInSound(soundName:String, startVolume:Number, endVolume:Number, delta:Number, loop:Boolean):void {
			if (findSound(soundName) != null) {
				
				if (fadeInTrack != null) {
					Game.getSingleton().removeEventListener(Event.ENTER_FRAME, increaseTrackVolume);
					var oldFadeChannel:SoundChannel = fadeInTrack.former as SoundChannel;
					oldFadeChannel.stop();
					fadeInTrack = null;
				}
				
				var finalVolume:Number = findFinalVolume(soundName, startVolume);
				var newChannel:SoundChannel = findSound(soundName).play();
				originVolumeDictionary[newChannel] = endVolume;
				var soundTransform:SoundTransform = new SoundTransform(startVolume);
				if (newChannel == null) {
					removeOldChannels();
					newChannel = findSound(soundName).play();
				}
				newChannel.soundTransform = soundTransform;
				transformDictionary[newChannel] = soundTransform;
				endVolumeDictionary[newChannel] = endVolume;
				
				if (loop) newChannel.addEventListener(Event.SOUND_COMPLETE, playAgain);
				Game.getSingleton().addEventListener(Event.ENTER_FRAME, increaseTrackVolume);
				
				if (channelDictionary[soundName] != null) resolveNameConflict(soundName, endVolume);
				channelDictionary[soundName] = newChannel;
				fadeInTrack = new Tuple(newChannel, delta);
				
				if (muted) {
					var muteTransform:SoundTransform = new SoundTransform(0);
					newChannel.soundTransform = muteTransform;
				}
				
			}
		}
		private function increaseTrackVolume(soundEvent:Event):void {
			var targetChannel:SoundChannel = fadeInTrack.former as SoundChannel;
			var targetTransform:SoundTransform = transformDictionary[targetChannel] as SoundTransform;
			if (targetTransform == null) return;
			var endVolume:Number = endVolumeDictionary[targetChannel];
			
			var soundName:String;
			for (var name:String in channelDictionary)
				if (channelDictionary[name] == targetChannel) soundName = name;
			
			if (targetTransform.volume <= endVolume) {
				var delta:Number = fadeInTrack.latter as Number;
				var finalVolume:Number = findFinalVolume(soundName, targetTransform.volume + delta);
				var newTransform:SoundTransform = new SoundTransform(finalVolume);
				targetChannel.soundTransform = newTransform;
				delete(transformDictionary[targetTransform]);
				transformDictionary[targetChannel] = newTransform;
			}
			else {
				delete(endVolumeDictionary[targetChannel]);
				Game.getSingleton().removeEventListener(Event.ENTER_FRAME, increaseTrackVolume);
				fadeInTrack = null;
			}
			if (muted) {
				var muteTransform:SoundTransform = new SoundTransform(0);
				targetChannel.soundTransform = muteTransform;
			}
		}
		
		private function resolveNameConflict(soundName:String, newAlpha:Number = 1):void {
			var oldChannel:SoundChannel = channelDictionary[soundName] as SoundChannel;
			var oldTransform:SoundTransform = transformDictionary[soundName] as SoundTransform;
			var origName:String = soundName;
			while (origName.indexOf('<') >= 0)
				origName = origName.replace('<', '');
			var sound:Sound = soundDictionary[origName] as Sound;
			
			if (oldChannel.position >= sound.length) {
				oldChannel.stop();
				delete(originVolumeDictionary[channelDictionary[soundName]]);
				delete(channelDictionary[soundName]);
			}
			else if (oldTransform != null){
				if(oldTransform.volume < newAlpha) {
					oldChannel.stop();
					delete(originVolumeDictionary[channelDictionary[soundName]]);
					delete(channelDictionary[soundName]);
				}
			}
			
			else {
				if (channelDictionary[soundName + "<"] != null) resolveNameConflict(soundName + "<");
				else channelDictionary[soundName + "<"] = oldChannel;
			}
		}
		private function removeOldChannels():void {
			for (var soundName:String in channelDictionary) {
				
				var soundChannel:SoundChannel = channelDictionary[soundName] as SoundChannel;
				var origSoundName:String = soundName;
				while (origSoundName.indexOf('<') >= 0)
					origSoundName = origSoundName.replace('<', '');
				var sound:Sound = soundDictionary[origSoundName] as Sound;
				
				if (soundChannel.position >= sound.length) {
					soundChannel.stop();
					delete(originVolumeDictionary[channelDictionary[soundName]]);
					delete(channelDictionary[soundName]);
				}
			}
		}
		
		private function playAgain(soundEvent:Event):void {
			
			var targetChannel:SoundChannel = soundEvent.target as SoundChannel;
			
			// Looping sounds in Flash is pretty annoying, so this part is a bit unintuitive.  Let's take it step by step.
						
			for (var key:Object in channelDictionary) {	// Go through all the sound channels.
				if (channelDictionary[key] == targetChannel) {	// If this is the right channel....
					if (findSound(key+"") != null) {	// And if the sound actually exists...
						
						// Remove the event listener from the sound channel we're using.
						channelDictionary[key].removeEventListener(Event.SOUND_COMPLETE, playAgain);
						
						// Take a snapshot of the soundTransform instance of the channel, then remove it from the dictionary.
						var tempTransform:SoundTransform = transformDictionary[channelDictionary[key]];
						delete transformDictionary[channelDictionary[key]];
						
						// Every time we replay a sound, it creates a new instance of a soundChannel.
						// Therefore, to keep track of a channel's soundTransform (and therefore its volume info),
						// we have to remove the old instance and add the new instance into our transformDictionary.
						channelDictionary[key] = findSound(key + "").play();
						channelDictionary[key].soundTransform = tempTransform;
						transformDictionary[channelDictionary[key]] = channelDictionary[key].soundTransform;
						
						// Then add an event listener to do all of this again when the new sound is done playing.
						channelDictionary[key].addEventListener(Event.SOUND_COMPLETE, playAgain);
						
						// If the game is muted, go back and set the channel's volume to 0.  We still keep the proper
						// volume logged in the transformDictionary for later use, however.
						if (muted) {
							var muteTransform:SoundTransform = new SoundTransform(0);
							channelDictionary[key].soundTransform = muteTransform;
						}
						
					}
				}
			}
		}
		
		public function isPlayingSound(soundName:String):Boolean {
			return (channelDictionary[soundName] != null);
		}
		
		public function stopSound(soundName:String):void {
			
			if (channelDictionary[soundName] != null) {
				var targetChannel:SoundChannel = channelDictionary[soundName] as SoundChannel;
				targetChannel.stop();
				
				if (targetChannel.hasEventListener(Event.SOUND_COMPLETE)) {
					targetChannel.removeEventListener(Event.SOUND_COMPLETE, playAgain);
				}
				
				delete(originVolumeDictionary[channelDictionary[soundName]]);
				delete channelDictionary[soundName];
			}
			if (fadeInTrack != null) {
				if (fadeInTrack.former == channelDictionary[soundName])
					Game.getSingleton().removeEventListener(Event.ENTER_FRAME, increaseTrackVolume);
			}
		}
		public function fadeOutSound(soundName:String, delta:Number):void {
			if (fadeOutTrack != null) {
				Game.getSingleton().removeEventListener(Event.ENTER_FRAME, decreaseTrackVolume);
				var fadeOutChannel:SoundChannel = fadeOutTrack.former as SoundChannel;
				fadeOutChannel.stop();
				fadeOutTrack = null;
			}
			if (fadeInTrack != null) {
				if (fadeInTrack.former == channelDictionary[soundName])
					Game.getSingleton().removeEventListener(Event.ENTER_FRAME, increaseTrackVolume);
			}
			
			if (channelDictionary[soundName] != null) {
				var targetChannel:SoundChannel = channelDictionary[soundName] as SoundChannel;
				Game.getSingleton().addEventListener(Event.ENTER_FRAME, decreaseTrackVolume);
				fadeOutTrack = new Tuple(targetChannel, delta);
			}
			
			delete(originVolumeDictionary[channelDictionary[soundName]]);
			delete channelDictionary[soundName];
		}
		public function stopAllSounds():void {
			
			for (var sound:String in channelDictionary)
				this.stopSound(sound);
		}
		public function fadeOutAllSounds(delta:Number):void {
			
			for (var sound:String in channelDictionary)
				this.fadeOutSound(sound, delta);
		}
		
		public function pauseSound(soundName:String):void {
			
			if (channelDictionary[soundName] != null) {
				var targetChannel:SoundChannel = channelDictionary[soundName] as SoundChannel;
				positionDictionary[targetChannel] = targetChannel.position;
				
				targetChannel.stop();
			}
		}
		public function resumeSound(soundName:String):void {
			
			if (channelDictionary[soundName] != null) {
				var targetChannel:SoundChannel = channelDictionary[soundName] as SoundChannel;
				var tempTransform:SoundTransform = transformDictionary[targetChannel];
				var tempPosition:int = positionDictionary[targetChannel];
				
				var isLooped:Boolean = false;
				if (targetChannel.hasEventListener(Event.SOUND_COMPLETE)) {
					isLooped = true;
				}
				
				delete transformDictionary[targetChannel];
				delete positionDictionary[targetChannel];
				
				channelDictionary[soundName] = findSound(soundName).play(tempPosition);
				channelDictionary[soundName].soundTransform = tempTransform;
				
				if (muted) {
					var muteTransform:SoundTransform = new SoundTransform(0);
					channelDictionary[soundName].soundTransform = muteTransform;
				}
				
				transformDictionary[channelDictionary[soundName]] = tempTransform;
				channelDictionary[soundName].addEventListener(Event.SOUND_COMPLETE, playAgain);
			}
		}
		
		
		private function decreaseTrackVolume(soundEvent:Event):void {
			if (fadeOutTrack == null) {
				Game.getSingleton().removeEventListener(Event.ENTER_FRAME, decreaseTrackVolume);
				return;
			}
			
			var targetChannel:SoundChannel = fadeOutTrack.former as SoundChannel;
			var targetTransform:SoundTransform = transformDictionary[targetChannel] as SoundTransform;
			if (targetTransform == null) return;
			
			if (targetTransform.volume > 0) {
				var delta:Number = fadeOutTrack.latter as Number;
				var newTransform:SoundTransform = new SoundTransform(targetTransform.volume - delta);
				targetChannel.soundTransform = newTransform;
				transformDictionary[targetChannel] = newTransform;
			}
			else {
				targetChannel.stop();
				fadeOutTrack = null;
				if (targetChannel.hasEventListener(Event.SOUND_COMPLETE)) {
					targetChannel.removeEventListener(Event.SOUND_COMPLETE, playAgain);
				}
				for (var key:String in channelDictionary)
					if (channelDictionary[key] == targetChannel) {
						delete(originVolumeDictionary[channelDictionary[key]]);
						delete(channelDictionary[key]);
					}
				
			}
			
			if (muted) {
				var muteTransform:SoundTransform = new SoundTransform(0);
				targetChannel.soundTransform = muteTransform;
			}
		}
		
		
		public function listenToTrigger(parsedRequirement:Array):Boolean {
			
			return false;
		}
		
		public function performTriggerEffect(parsedEffect:Array):void {
			
			if (parsedEffect[0] == "stopAllSounds")
				for (var sound:String in channelDictionary)
					this.stopSound(sound);
			else if (parsedEffect[0] == "stopSound") {
				var soundToStop:String = parsedEffect[1];
				if (channelDictionary[soundToStop] != null)
					this.stopSound(soundToStop);
			}
			else if (parsedEffect[0] == "fadeOutAllSounds") {
				var delta:Number = parseFloat(parsedEffect[1]);
				for (sound in channelDictionary)
					this.fadeOutSound(sound, delta);
			}
			else if (parsedEffect[0] == "fadeOutSound") {
				soundToStop = parsedEffect[1];
				delta = parseFloat(parsedEffect[2]);
				if (channelDictionary[soundToStop] != null)
					this.fadeOutSound(soundToStop, delta);
			}
			else if (parsedEffect[0] == "playSound") {
				var soundToPlay:String = parsedEffect[1];
				var volume:Number = parseFloat(parsedEffect[2]);
				this.playSound(soundToPlay, volume);
			}
			else if (parsedEffect[0] == "loopSound") {
				var soundToLoop:String = parsedEffect[1];
				volume = parseFloat(parsedEffect[2]);
				this.playSound(soundToLoop, volume, true);
			}
			else if (parsedEffect[0] == "fadeInSound") {
				soundToLoop = parsedEffect[1];
				var endVolume:Number = parseFloat(parsedEffect[2]);
				delta = parseFloat(parsedEffect[3]);
				this.fadeInSound(soundToLoop, 0, endVolume, delta, true);
			}
			
		}
	}

}