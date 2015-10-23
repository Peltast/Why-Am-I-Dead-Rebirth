package Core 
{
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import Interface.MenuSystem.BmpButton;
	import Interface.MenuSystem.Button;
	import Interface.MenuSystem.ButtonEffect;
	import Interface.MenuSystem.Menu;
	import Interface.MenuSystem.MenuBox;
	import Interface.Overlay;
	import Interface.OverlayStack;
	import Setup.GameLoader;
	/**
	 * ...
	 * @author Peltast
	 */
	public class PauseOverlay extends Overlay
	{
		
		public function PauseOverlay(overlayStack:OverlayStack) 
		{
			super(.9);
			
			var optionsOverlay:OptionsOverlay = new OptionsOverlay(overlayStack, this);
			var creditsOverlay:Overlay = new Overlay();
			creditsOverlay.addToOverlay(new CreditsPage(overlayStack));
			
			var pauseMenuBox:MenuBox = new MenuBox(new Rectangle(5, 5, 5, 5), new GameLoader.MenuSkin());
			var pauseMenu:Menu = new Menu(false, new Rectangle(15, 10, 15, 10), pauseMenuBox, false, true);
			
			var resumeEffect:ButtonEffect = new ButtonEffect("RemoveOverlay", new Array(overlayStack));
			var optionsEffect:ButtonEffect = new ButtonEffect("AddOverlay", new Array(optionsOverlay, overlayStack));
			var creditsEffect:ButtonEffect = new ButtonEffect("AddOverlay", new Array(creditsOverlay, overlayStack));
			var popStateEffect:ButtonEffect = new ButtonEffect("PopState", []);
			var pushStateEffect:ButtonEffect = new ButtonEffect("PushState", ["Menu"]);
			
			var fontColors:Array = new Array(0xffffff, 0xffffff);
			var bgColors:Array = new Array(0x312121, 0x635353);
			var borderColor:uint = 0xCBEFE7;
			
			var resumeButton:Button = new Button("Resume Game", 16, new Rectangle(5, 2, 2, 2), fontColors, bgColors, false,
													[resumeEffect], true, borderColor);
			var optionsButton:Button = new Button("Options", 16, new Rectangle(2, 2, 2, 2), fontColors, bgColors, false,
													[optionsEffect], true, borderColor);
			var creditsButton:Button = new Button("Credits", 16, new Rectangle(2, 2, 2, 2), fontColors, bgColors, false,
													[creditsEffect], true, borderColor);
			var mainMenuButton:Button = new Button("Back to Main Menu", 16, new Rectangle(2, 2, 10, 2), fontColors, bgColors, false,
													[popStateEffect, pushStateEffect], true, borderColor);
			
			pauseMenu.addMenuItem(resumeButton);
			pauseMenu.addMenuItem(optionsButton);
			pauseMenu.addMenuItem(creditsButton);
			pauseMenu.addMenuItem(mainMenuButton);
			pauseMenu.x = (Main.getSingleton().getStageWidth() / 2) - pauseMenu.getMenuWidth() / 2;
			pauseMenu.y = 50;
			
			this.addToOverlay(pauseMenu);
		}
		
	}

}