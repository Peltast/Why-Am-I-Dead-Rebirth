package Core 
{
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import Interface.MenuSystem.BmpButton;
	import Interface.MenuSystem.ButtonEffect;
	import Interface.Overlay;
	import Interface.OverlayItem;
	import Interface.OverlayStack;
	import Setup.GameLoader;
	import SpectralGraphics.EffectTypes.WaveEffect;
	import SpectralGraphics.ObjectFactory;
	import SpectralGraphics.SpectralBitmap;
	import SpectralGraphics.SpectralImage;
	import SpectralGraphics.SpectralObject;
	import SpectralGraphics.SpectralShape;
	/**
	 * ...
	 * @author Peltast
	 */
	public class CreditsPage extends OverlayItem
	{
		private var backButton:BmpButton;
		
		private var creditsImage:Bitmap;
		private var websiteButton:BmpButton;
		private var waidasButton:BmpButton;
		
		public function CreditsPage(overlayStack:OverlayStack) 
		{
			super(this, false);
			
			var backGround:Shape = new Shape();
			backGround.graphics.beginFill(0x000000, .95);
			backGround.graphics.drawRect(0, 0, 540, 400);
			backGround.graphics.endFill();
			
			backButton = new BmpButton(new GameLoader.XButton() as Bitmap, new Rectangle(0, 0, 36, 54), false,
									[new ButtonEffect("RemoveOverlay", [overlayStack])], [new GameLoader.XButton2() as Bitmap]);
			backButton.x = 470;
			backButton.y = 5;
			
			creditsImage = new GameLoader.CreditsImage() as Bitmap;
			creditsImage.y = 60;
			
			websiteButton = new BmpButton
				(new GameLoader.WebsiteLogo() as Bitmap, new Rectangle(0, 0, 90, 90), false,
				[new ButtonEffect("GoToSite", ["http://www.peltastsoftware.com"])], [new GameLoader.WebsiteLogo2() as Bitmap]);
			websiteButton.x = 85;
			websiteButton.y = 290;
			
			waidasButton = new BmpButton
				(new GameLoader.CrossPromoSmall() as Bitmap, new Rectangle(0, 0, 215, 100), false,
				[new ButtonEffect("GoToSite", ["http://www.whyamideadatsea.com"])], [new GameLoader.CrossPromoSmall2() as Bitmap]);
			waidasButton.x = 290;
			waidasButton.y = 300;
			
			this.addChild(backGround);
			this.addChild(backButton);
			this.addChild(websiteButton);
			this.addChild(waidasButton);
			
			this.addChild(creditsImage);
		}
		
		override public function activateOverlayItem():void 
		{
			super.activateOverlayItem();
			
			backButton.activateOverlayItem();
			websiteButton.activateOverlayItem();
			waidasButton.activateOverlayItem();
		}
		
		override public function deactivateOverlayItem():void 
		{
			super.deactivateOverlayItem();
			
			backButton.deactivateOverlayItem();
			websiteButton.deactivateOverlayItem();
			waidasButton.deactivateOverlayItem();
		}
		
	}

}