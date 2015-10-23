package Core 
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import Setup.GameLoader;
	import Sound.SoundManager;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class SplashState extends State
	{
		private var splashTimer:int;
		private var splashImage:Bitmap;
		private var agLoader:Loader;
		
		public function SplashState() 
		{
			super(this);
			
			var blackBG:Shape = new Shape();
			blackBG.graphics.beginFill(0x000000);
			blackBG.graphics.drawRect(0, 0, 540, 400);
			
			splashTimer = 0;
			splashImage = new GameLoader.CreditsLogo1() as Bitmap;
			splashImage.alpha = 0;
			splashImage.x = 270 - splashImage.width / 2;
			splashImage.y = 200 - splashImage.height / 2;
			
			SoundManager.getSingleton().playSound("Tunnel", 1);
			
			var context:LoaderContext = new LoaderContext (false, ApplicationDomain.currentDomain);
			context.allowCodeImport = true;
			agLoader = new Loader ();
			agLoader.loadBytes (new GameLoader.AGIntro(), context);
			agLoader.x = -75;
			agLoader.y = 0;
			
			this.addChild(agLoader);
			//this.addChild(blackBG);
			//this.addChild(splashImage);
			this.addEventListener(Event.ENTER_FRAME, updateSplash);
			this.addEventListener(MouseEvent.MOUSE_UP, checkClick);
		}
		
		
		private function updateSplash(event:Event):void {
			
			splashTimer++;
			
			if (splashTimer > 173) {
				SoundManager.getSingleton().stopSound("Tunnel");
				
				this.removeEventListener(Event.ENTER_FRAME, updateSplash);
				agLoader.unloadAndStop();
				this.removeChild(agLoader);
				Game.popState();
				Game.pushState(new MenuState());
			}
			else if (splashTimer > 90) {
				splashImage.alpha -= .02;
			}
			else if (splashTimer == 80) {
				SoundManager.getSingleton().fadeOutAllSounds(.01);
			}
			else if (splashTimer > 20) {
				splashImage.alpha += .025;
			}
		}
		
		private function checkClick(mouse:MouseEvent):void {
			var tempRect:Rectangle = new Rectangle(splashImage.x, splashImage.y, splashImage.width, splashImage.height);
			if (tempRect.containsPoint(new Point(mouse.stageX, mouse.stageY)))
				navigateToURL(new URLRequest("http://armor.ag/MoreGames"));
				//navigateToURL(new URLRequest("http://www.peltastdesign.com"));
		}
		
	}

}