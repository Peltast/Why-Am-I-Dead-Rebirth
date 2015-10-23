package Core 
{
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import Interface.MenuSystem.Button;
	import Interface.MenuSystem.ButtonEffect;
	import Setup.GameLoader;
	/**
	 * ...
	 * @author Peltast
	 */
	public class EndingState extends State
	{
		private var endingStatus:int;
		private var mainMenuButton:Button;
		
		public function EndingState(endingStatus:int) 
		{
			super(this);
			
			this.endingStatus = endingStatus;
			
			var endingLabel:Bitmap;
			var textColor:uint;
			var buttonColor:uint;
			
			if (endingStatus == 0) {
				endingLabel = new GameLoader.RedEnding() as Bitmap;
				textColor = 0xffffff;
				buttonColor = 0x720026;
			}
			else if (endingStatus == 1) {
				endingLabel = new GameLoader.BlueEnding() as Bitmap;
				textColor = 0xffffff;
				buttonColor = 0x17479B;
			}
			else if (endingStatus == 2) {
				endingLabel = new GameLoader.GrayEnding() as Bitmap;
				textColor = 0x4C4C4C;
				buttonColor = 0x2B2B2B;
			}
			else if (endingStatus == 3) {
				endingLabel = new GameLoader.BlackEnding() as Bitmap;
				textColor = 0x000000;
				buttonColor = 0xffffff;
			}
			
			endingLabel.x = 270 - (endingLabel.width / 2);
			endingLabel.y = 200 - (endingLabel.height / 2);
			
			mainMenuButton = new Button("Back to Main Menu", 16, new Rectangle(10, 10, 10, 10),
														[textColor], [buttonColor], false, [], true, 0xffffff);
			mainMenuButton.x = 270 - (mainMenuButton.width / 2) + 10;
			mainMenuButton.y = 400 - (mainMenuButton.height) - 50;
			
			this.addChild(endingLabel);
			this.addChild(mainMenuButton);
			
			mainMenuButton.addEventListener(MouseEvent.MOUSE_UP, backToMain);
		}
		
		private function backToMain(mouse:MouseEvent):void {
			
			if (mainMenuButton.hitTestPoint(mouse.stageX, mouse.stageY)) {
				mainMenuButton.removeEventListener(MouseEvent.MOUSE_UP, backToMain);
				Game.popState();
				Game.pushState(new MenuState());
			}
			
		}
		
		
	}

}