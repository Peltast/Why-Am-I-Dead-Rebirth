package Core 
{
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import Interface.MenuSystem.Button;
	import Interface.MenuSystem.ButtonEffect;
	import Interface.MenuSystem.Menu;
	import Interface.MenuSystem.MenuBox;
	import Interface.MenuSystem.MenuTree;
	import Interface.Overlay;
	import Interface.OverlayItem;
	import Interface.OverlayStack;
	import Setup.AudoSlideList;
	import Setup.GameLoader;
	import Setup.KeybindList;
	/**
	 * ...
	 * @author Peltast
	 */
	public class OptionsOverlay extends Overlay
	{
		
		public function OptionsOverlay(overlayStack:OverlayStack, prevOverlay:Overlay) 
		{
			super(.9);
			
			var optionMenuBox:MenuBox = new MenuBox(new Rectangle(), new GameLoader.MenuSkin() as Bitmap);
			var optionMenu:Menu = new Menu(true, new Rectangle(10, 10, 10, 10), optionMenuBox, true, true);
			var optionsTree:MenuTree = new MenuTree(true);
			optionsTree.x = 120;
			optionsTree.y = 100;
			
			var controlsMenuBox:MenuBox = new MenuBox(new Rectangle(), new GameLoader.MenuSkin() as Bitmap);
			var controlsMenu:Menu = new Menu(true, new Rectangle(10, 10, 10, 10), null, false, true);
			
			controlsMenu.addMenuItem(new KeybindList(controlsMenu, overlayStack));
			var audioMenu:AudoSlideList = new AudoSlideList(10);			
			
			var closeControlsEffect:ButtonEffect = new ButtonEffect("RemoveMenuItem", new Array(optionMenu, controlsMenu));
			var closeOptionsEffect:ButtonEffect = new ButtonEffect("RemoveOverlay", new Array(overlayStack));
			var closeOptionsEffect2:ButtonEffect = new ButtonEffect("AddOverlay", new Array(prevOverlay, overlayStack));
			var closeOptionsEffect3:ButtonEffect = new ButtonEffect("SetMenuTree", new Array(optionsTree, null));
			var openControls:ButtonEffect = new ButtonEffect("SetMenuTree", new Array(optionsTree, controlsMenu));
			var openAudio:ButtonEffect = new ButtonEffect("SetMenuTree", new Array(optionsTree, audioMenu));
			
			optionMenu.addMenuItem(new Button("Controls", 16, new Rectangle(10, 10, 10, 10),
				new Array(0xffffff, 0xffffff), new Array(0x312121, 0x635353), false, new Array(openControls), true, 0xCBEFE7));
			optionMenu.addMenuItem(new Button("Audio", 16, new Rectangle(10, 10, 10, 10),
				new Array(0xffffff, 0xffffff), new Array(0x312121, 0x635353), false, new Array(openAudio), true, 0xCBEFE7));
			optionMenu.addMenuItem(new Button("Exit", 16, new Rectangle(10, 10, 10, 10), new Array(0xffffff, 0xffffff),
				new Array(0x312121, 0x635353), false, 
				new Array(closeOptionsEffect, closeOptionsEffect3), true, 0xCBEFE7));
			optionMenu.x = (Main.getSingleton().getStageWidth() / 2) - optionMenu.getMenuWidth() / 2;
			optionMenu.y = 20;
			
			this.addToOverlay(optionMenu);
			this.addToOverlay(optionsTree);
		}
		
	}

}