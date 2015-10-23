package Setup 
{
	import flash.geom.Rectangle;
	import Interface.MenuSystem.Button;
	import Interface.MenuSystem.ButtonEffect;
	import Interface.MenuSystem.Menu;
	import Interface.MenuSystem.Slider;
	import Misc.Tuple;
	import Sound.SoundManager;
	/**
	 * ...
	 * @author Peltast
	 */
	public class AudoSlideList extends Menu
	{
		private var masterSlider:Slider;
		private var musicSlider:Slider;
		private var soundSlider:Slider;
		
		public function AudoSlideList(increments:int) 
		{
			super(false, new Rectangle(0, 0, 0, 0));
			
			var masterLabel:Button = new Button("Master Volume", 24, new Rectangle(0, 0, 0, 0), [0xffffff]);
			var increaseMaster:ButtonEffect = new ButtonEffect("ChangeMasterVolume", [1 / increments]);
			var decreaseMaster:ButtonEffect = new ButtonEffect("ChangeMasterVolume", [ -1 / increments]);
			var masterVolume:Number = SoundManager.getSingleton().getMasterVolume();
			masterSlider = new Slider(true, 300, increments, masterVolume, new Tuple(increaseMaster, decreaseMaster));
			
			var musicLabel:Button = new Button("Music Volume", 24, new Rectangle(0, 0, 0, 0), [0xffffff]);
			var increaseMusic:ButtonEffect = new ButtonEffect("ChangeMusicVolume", [1 / increments]);
			var decreaseMusic:ButtonEffect = new ButtonEffect("ChangeMusicVolume", [ -1 / increments]);
			var musicVolume:Number = SoundManager.getSingleton().getMusicVolume();
			musicSlider = new Slider(true, 300, increments, musicVolume, new Tuple(increaseMusic, decreaseMusic));
			
			var soundLabel:Button = new Button("Sound Volume", 24, new Rectangle(0, 0, 0, 0), [0xffffff]);
			var increaseSound:ButtonEffect = new ButtonEffect("ChangeSoundVolume", [1 / increments]);
			var decreaseSound:ButtonEffect = new ButtonEffect("ChangeSoundVolume", [ -1 / increments]);
			var soundVolume:Number = SoundManager.getSingleton().getSoundVolume();
			soundSlider = new Slider(true, 300, increments, soundVolume, new Tuple(increaseSound, decreaseSound));
			
			this.addMenuItem(masterLabel);
			this.addMenuItem(masterSlider);
			
			this.addMenuItem(musicLabel);
			this.addMenuItem(musicSlider);
			
			this.addMenuItem(soundLabel);
			this.addMenuItem(soundSlider);
		}
		
		override public function activateOverlayItem():void 
		{
			super.activateOverlayItem();
			
		}
		
	}

}