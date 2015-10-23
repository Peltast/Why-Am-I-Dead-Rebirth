package Interface 
{
	import Core.IntroState;
	import flash.display.DisplayObject;
	import Sound.SoundManager;
	import SpectralGraphics.SpectralImage;
	/**
	 * ...
	 * @author Peltast
	 */
	public class CinematicScreen extends OverlayItem
	{
		private var currentSpectralImages:Vector.<SpectralImage>;
		private var currentSounds:Vector.<String>;
		
		public function CinematicScreen() 
		{
			super(this, true);
			
			currentSpectralImages = new Vector.<SpectralImage>();
			currentSounds = new Vector.<String>();
		}
		
		public function addSound(soundName:String):void {
			currentSounds.push(soundName);
		}
		public function removeSound(soundName:String):void {
			for (var i:int = 0; i < currentSounds.length; i++)
				if (currentSounds[i] == soundName) currentSounds.splice(i, 1);
		}
		
		override public function addChild(child:DisplayObject):DisplayObject 
		{
			if (child is SpectralImage)
				currentSpectralImages.push(child);
			return super.addChild(child);
		}
		override public function removeChild(child:DisplayObject):DisplayObject 
		{
			if (child is SpectralImage) {
				for (var i:int = 0; i < currentSpectralImages.length; i++)
					if (currentSpectralImages[i] == child)
						currentSpectralImages.splice(i, 1);
			}
			return super.removeChild(child);
		}
		
		override public function activateOverlayItem():void 
		{
			super.activateOverlayItem();
			
			for each(var specImg:SpectralImage in currentSpectralImages)
				specImg.beginImage();
			for each(var sound:String in currentSounds)
				SoundManager.getSingleton().resumeSound(sound);
		}
		
		override public function deactivateOverlayItem():void 
		{
			super.deactivateOverlayItem();
			
			for each(var specImg:SpectralImage in currentSpectralImages)
				specImg.stopImage();
			for each(var sound:String in currentSounds)
				SoundManager.getSingleton().pauseSound(sound);
		}
		
	}

}