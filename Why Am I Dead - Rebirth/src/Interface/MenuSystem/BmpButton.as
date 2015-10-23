package Interface.MenuSystem 
{
	import Core.Game;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import Setup.GameLoader;
	import SpectralGraphics.EffectTypes.SpectralEffect;
	import SpectralGraphics.SpectralBitmap;
	import SpectralGraphics.SpectralImage;
	/**
	 * ...
	 * @author Peltast
	 */
	public class BmpButton extends Button
	{
		private var bitmap:Bitmap;
		private var specBitmap:SpectralBitmap;
		private var specImage:SpectralImage;
		private var altBitmaps:Array;
		private var spectralEffects:Array;
		private var usesKeys:Boolean;
		
		public function BmpButton(bitmap:Bitmap, margins:Rectangle, toggleable:Boolean = false, buttonEffects:Array = null,
									altBitmaps:Array = null, spectralEffects:Array = null, usesKeys:Boolean = true) 
		{
			super("", 0, margins, [], [], toggleable, buttonEffects, false, 0);
			
			this.bitmap = bitmap;
			this.specBitmap = new SpectralBitmap(bitmap, 0xffffff, 1, bitmap.width, bitmap.height);
			this.specImage = new SpectralImage(1, specBitmap.width, specBitmap.height);
			this.bounds = new Rectangle(0, 0, bitmap.width, bitmap.height);
			if (altBitmaps == null) this.altBitmaps = [];
			else this.altBitmaps = altBitmaps;
			if (spectralEffects == null) this.spectralEffects = [];
			else this.spectralEffects = spectralEffects;
			this.usesKeys = usesKeys;
			
			specImage.addObject(0, specBitmap, 0, 0);
			this.addChild(specImage);
			specImage.beginImage();
			
			this.removeChild(buttonShape);
			this.removeChild(buttonText);
			this.removeEventListener(Event.ENTER_FRAME, updateBorder);
		}
		
		override public function activateOverlayItem():void 
		{
			if (usesKeys) 
				Game.getSingleton().stage.addEventListener(KeyboardEvent.KEY_UP, checkKeyboardSelect);
			this.addEventListener(MouseEvent.MOUSE_DOWN, checkMouseClick);
			this.addEventListener(MouseEvent.MOUSE_UP, checkMouseUp);
			Game.getSingleton().stage.addEventListener(MouseEvent.MOUSE_MOVE, checkMouseHover);
			buttonHover();
			active = true;
		}
		override public function deactivateOverlayItem():void 
		{
			if (usesKeys) 
				Game.getSingleton().stage.removeEventListener(KeyboardEvent.KEY_UP, checkKeyboardSelect);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, checkMouseClick);
			this.removeEventListener(MouseEvent.MOUSE_UP, checkMouseUp);
			//Game.getSingleton().stage.removeEventListener(MouseEvent.MOUSE_MOVE, checkMouseHover);
			buttonUnhover();
			active = false;
		}
		
		
		override protected function buttonHover():void 
		{
			if (active) return;
			isHovered = true;
			if (altBitmaps.length >= 1) {
				specImage.removeSpectralObject(0, specBitmap);
				specBitmap = new SpectralBitmap(altBitmaps[0], 0xffffff, 1, altBitmaps[0].width, altBitmaps[0].height);
				specImage.addObject(0, specBitmap, 0, 0);
			}
			for (var i:int = 0; i < spectralEffects.length; i++) {
				var spectralEffect:SpectralEffect = spectralEffects[i] as SpectralEffect;
				specImage.addEffect(0, spectralEffect);
			}
		}
		override protected function buttonUnhover():void 
		{
			isHovered = false;
			if (altBitmaps.length >= 1) {
				specImage.removeSpectralObject(0, specBitmap);
				specBitmap = new SpectralBitmap(bitmap, 0xffffff, 1, altBitmaps[0].width, altBitmaps[0].height);
				specImage.addObject(0, specBitmap, 0, 0);
			}
			
			for (var i:int = 0; i < spectralEffects.length; i++) {
				var spectralEffect:SpectralEffect = spectralEffects[i] as SpectralEffect;
				specImage.removeEffect(0);
			}
		}
		override protected function buttonHit():void 
		{
			if (effectList != null) {
				for each(var effect:ButtonEffect in effectList)
					effect.performEffect();
			}
		}
		override protected function hitAnimation(event:Event):void 
		{
			this.removeEventListener(Event.ENTER_FRAME, hitAnimation);
		}
		
		
		
		override protected function checkMouseHover(mouse:MouseEvent):void {
			if (!isClicked) {
				if (specImage.hitTestPoint(mouse.stageX, mouse.stageY)) {
					buttonHover();
					activateOverlayItem();
				}
				else if (isHovered) {
					deactivateOverlayItem();
					buttonUnhover();
				}
			}
			else {
				if (specImage.hitTestPoint(mouse.stageX, mouse.stageY)) 
					return;
				else
					buttonUnhover();
			}
		}
		
		override protected function checkMouseClick(mouse:MouseEvent):void {
			if (isHovered) {
				if (mouse.buttonDown && specImage.hitTestPoint(mouse.stageX, mouse.stageY)){
					isClicked = true;
				}
				else{
					isClicked = false;
				}
			}
		}
		
		override protected function checkMouseUp(mouse:MouseEvent):void {
			if (isClicked) {
				if (!mouse.buttonDown && specImage.hitTestPoint(mouse.stageX, mouse.stageY)){
					isClicked = false;
					isHovered = true;
					
					buttonHit();
				}
			}
		}
		
	}

}