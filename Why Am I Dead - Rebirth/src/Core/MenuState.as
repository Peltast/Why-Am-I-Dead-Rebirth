package Core 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.dns.SRVRecord;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import Interface.MenuSystem.*;
	import Interface.Overlay;
	import Interface.OverlayStack;
	import Props.AnimatedProp;
	import Setup.*;
	import SpectralGraphics.EffectTypes.BlinkEffect;
	import SpectralGraphics.EffectTypes.FadeEffect;
	import SpectralGraphics.EffectTypes.MoveEffect;
	import SpectralGraphics.EffectTypes.SpectralEffect;
	import SpectralGraphics.EffectTypes.WaveEffect;
	import SpectralGraphics.EffectTypes.ZoomEffect;
	import SpectralGraphics.*;
	
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class MenuState extends State
	{
		private var versionTag:TextField;
		
		private var mainMenu:Menu;
		
		private var startOverlay:Overlay;
		private var saveOverlay:Overlay;
		private var optionsOverlay:Overlay;
		private var creditsOverlay:Overlay;
		
		private var splashGraphic:SpectralImage;
		private var crossPromoButton:BmpButton;
		
		public function MenuState() 
		{	
			drawSplashImage();
			drawCrossPromotion();
			
			super(this);
			
			startOverlay = new Overlay();
			
			optionsOverlay = new OptionsOverlay(overlayStack, startOverlay);
			creditsOverlay = new Overlay();
			creditsOverlay.addToOverlay(new CreditsPage(overlayStack));
			
			var newGameConfirmation:Overlay = new Overlay(.9);
			generateNewGameConfirmation(newGameConfirmation);
			startOverlay.addToOverlay(generateMainMenu(newGameConfirmation));
			startOverlay.addToOverlay(crossPromoButton);
			
			this.overlayStack.pushOverlay(startOverlay);
			Main.getSingleton().stage.focus = this;
		}
		
		private function drawSplashImage():void {
			splashGraphic = new SpectralImage(4, 375, 400);
			var spectralSplash:SpectralBitmap = new SpectralBitmap(new GameLoader.TitleSplash() as Bitmap, 0, 1, 300, 200);
			var blinkingObjects:Vector.<SpectralObject> = new Vector.<SpectralObject>();
			blinkingObjects.push(spectralSplash);
			
			splashGraphic.addObject(0, new SpectralBitmap(new GameLoader.TitleSplash2(), 0, 1, 300, 200), 45, 100);
			splashGraphic.addObject(0, new SpectralBitmap(new GameLoader.TitleSplash3(), 0, 1, 540, 400), 0, 0);
			splashGraphic.addObject(1, spectralSplash, 45, 100);
			splashGraphic.addEffect(1, new BlinkEffect(blinkingObjects, 5, 100, 0, 50));
			splashGraphic.addObject(2, new SpectralBitmap(new GameLoader.TitleText1() as Bitmap, 0, 1, 290, 30), 150, 15);
			splashGraphic.addObject(3, new SpectralBitmap(new GameLoader.TitleText2() as Bitmap, 0, 1, 340, 100), 125, 50);
			
			splashGraphic.beginImage();
			this.addChild(splashGraphic);
		}
		
		private function drawCrossPromotion():void {
			
			crossPromoButton = new BmpButton
				(new GameLoader.CrossPromo() as Bitmap, new Rectangle(0, 0, 540, 100), false, 
				[new ButtonEffect("GoToSite", ["http://www.whyamideadatsea.com"])], [new GameLoader.CrossPromo2() as Bitmap]);
			crossPromoButton.y = 300;
		}
		
		private function generateMainMenu(newGameConfirmation:Overlay):Menu {
			
			var mainMenuBox:MenuBox = new MenuBox(new Rectangle(), new GameLoader.MenuSkin() as Bitmap);
			var mainMenu:Menu = new Menu(false, new Rectangle(60, 10, 10, 10), null, false, true);
			
			if (SaveManager.getSingleton().getSaveFile(0).loadData("init") != null)
				var newGameEffects:Array = [new ButtonEffect("AddOverlay", [newGameConfirmation, this.overlayStack])];
			else
				newGameEffects = [new ButtonEffect("StartNewGame", [])];
			
			var optionsEffect:ButtonEffect = new ButtonEffect("AddOverlay", new Array(optionsOverlay, this.overlayStack));
			var optionsEffect2:ButtonEffect = new ButtonEffect("RemoveOverlay", new Array(overlayStack));
			var continueEffects:Array = [new ButtonEffect("StartGame", [0, 0])];
			var creditsEffect:ButtonEffect = new ButtonEffect("AddOverlay", new Array(creditsOverlay, this.overlayStack));
			
			var optionsButton:BmpButton = new BmpButton(new GameLoader.OptionsButton() as Bitmap, 
														new Rectangle(), false, [optionsEffect],
														null, [new ZoomEffect(true, true, .001, .001, .003, .012, true)]);
			var newGameButton:BmpButton = new BmpButton(new GameLoader.NewGameButton() as Bitmap, new Rectangle(), false,
														newGameEffects, null, [new ZoomEffect(true, true, .001, .001, .003, .012, true)]);
			var continueButton:BmpButton = new BmpButton(new GameLoader.ContinueButton() as Bitmap, new Rectangle(), false,
														continueEffects, null, [new ZoomEffect(true, true, .001, .001, .003, .012, true)]);
			var creditsButton:BmpButton = new BmpButton(new GameLoader.CreditsButton() as Bitmap, 
														new Rectangle(), false, [creditsEffect],
														null, [new ZoomEffect(true, true, .001, .001, .003, .012, true)]);
			mainMenu.addMenuItem(newGameButton);
			if (SaveManager.getSingleton().getSaveFile(0).loadData("init") != null)
				mainMenu.addMenuItem(continueButton);
			mainMenu.addMenuItem(optionsButton);
			mainMenu.addMenuItem(creditsButton);
			mainMenu.resetOverlayItem();
			
			mainMenu.x = Main.getSingleton().getStageWidth() - mainMenu.getMenuWidth() - 30;
			mainMenu.y = (Main.getSingleton().getStageHeight() / 2) - (mainMenu.height / 2);
			
			return mainMenu;
		}
		
		private function generateNewGameConfirmation(overlay:Overlay):void {
			
			var confirmationMenu:Menu = new Menu(true, new Rectangle(5, 5, 5, 5), null, true, true);
			var confirm:Button = new Button("OK", 16, new Rectangle(5, 5, 5, 5), new Array(0xffffff, 0xffffff), 
						new Array(0x4F5768, 0x667187), false, [new ButtonEffect("RemoveOverlay", [overlayStack]),
						new ButtonEffect("ClearGame", [0, null]), 
						new ButtonEffect("StartNewGame", [])], true, 0xffffff);
			var cancel:Button = new Button("Cancel", 16, new Rectangle(5, 5, 5, 5), new Array(0xffffff, 0xffffff),
						new Array(0x4F5768, 0x667187), false, [new ButtonEffect("RemoveOverlay", [overlayStack])], true, 0xffffff);
			
			var confirmList:ButtonList = new ButtonList([confirm, cancel], new Rectangle(5, 5, 5, 5), true, 1, 
					"Warning: Any progress will be erased by starting a new game.\n", 18, 0xffffff, false);
			confirmationMenu.addMenuItem(confirmList);
			confirmationMenu.x = 290 - confirmationMenu.width / 5;
			confirmationMenu.y = 100 - confirmationMenu.height / 2;
			overlay.addToOverlay(confirmationMenu);
			
		}
		
		
		
		public override function drawState():void {
			//for each(var waterAnimation:AnimatedItem in waterAnimations)
			//	waterAnimation.updateItem();
			//waterBoatAnimation.updateItem();
		}
	}

}