package Characters 
{
	import Core.Game;
	import Core.SpectralState;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import Interface.GameScreen;
	import Maps.Map;
	import Sound.SoundManager;
	import SpectralGraphics.SpectralImage;
	import SpectralGraphics.SpectralManager;
	/**
	 * ...
	 * @author Peltast
	 */
	public class GhostEffect extends CharacterEffect
	{
		private var characterManager:CharacterManager;
		private var ghostEffectOn:Boolean;
		private var currentMap:Map;
		private var mindReadState:SpectralState;
		
		private var gameScreen:GameScreen;
		private var mindRadar:SpectralImage;
		private var mindRadarMask:Sprite;
		private var mindRadarHaze:Sprite;
		private var mindRadarCount:int;
		
		private var hostMapSnapshot:Map;
		
		public function GhostEffect(charManager:CharacterManager, gameScreen:GameScreen)
		{
			super(this, 30);
			this.characterManager = charManager;
			this.mindRadar = new SpectralImage(3, 540, 400);
			ghostEffectOn = false;
			mindReadState = null;
			mindRadarMask = new Sprite();
			mindRadarHaze = new Sprite();
			gameScreen.addChild(mindRadarHaze);
			
			var matrix:Array = new Array();
            matrix = matrix.concat([0.5, 0.5, 0.5, 0, 0]);// red
            matrix = matrix.concat([0.5, 0.5, 0.5, 0, 0]);// green
            matrix = matrix.concat([0.5, 0.5, 0.5, 0, 0]);// blue
            matrix = matrix.concat([0, 0, 0, 1, 0]);// alpha
            var bwFilter:ColorMatrixFilter = new ColorMatrixFilter(matrix);
			//gameScreen.filters = [bwFilter];
			this.gameScreen = gameScreen;
		}
		
		public function silenceGhostEffect():void
		{
			if(host != null) undrawMindRadar();
			if (!ghostEffectOn) return;
			
			super.resetEffect();
			ghostEffectOn = false;
			effectRelease(host);
		}
		
		public override function updateEffect(homeMap:Map):void {
			if (effectHeld) {
				effectHold();
			}
			if (mindRadarCount > 0) {
				updateHoldEffect();
			}
			
			if (mindReadState != null) {
				host.endMindRead();
				mindReadState = null;
			}
			
			if (currentMap != homeMap && currentMap != null && ghostEffectOn) {
				currentMap.undrawGhostEffect(mindRadar);
				homeMap.drawGhostEffect(host, mindRadar);
				currentMap = homeMap;
			}
			else if (currentMap == null)
				currentMap = homeMap;
		}
		
		override public function effectPress(host:Character):void 
		{
			super.effectPress(host);
		}
		
		override protected function drawPressEffect(host:Character):void 
		{
			super.drawPressEffect(host);
			
			mindReadState = host.mindRead();
			if (mindReadState == null) return;
			Game.pushState(mindReadState);
			
		}
		
		override protected function drawHoldEffect():void 
		{
			super.drawHoldEffect();
			if (gameScreen.contains(mindRadar)) {
				characterManager.undrawGhostEffect(mindRadar);
				host.getCurrentMap().undrawGhostEffect(mindRadar);
				gameScreen.removeChild(mindRadar);
			}
			
			ghostEffectOn = true;
			host.getCurrentMap().drawGhostEffect(host, mindRadar);
			characterManager.drawGhostEffect(host, mindRadar);
			mindRadarCount = 1;
			SoundManager.getSingleton().playSound("ScanBegin", 1, false);
			
			hostMapSnapshot = host.getCurrentMap();
			
			gameScreen.addChild(mindRadar);
		}
		private function updateHoldEffect():void {
			
			if (ghostEffectOn) {
				
				characterManager.updateGhostEffect(host, mindRadar);
				mindRadarCount += 10;
				if (mindRadarCount > 350) 
					mindRadarCount = 350;
				drawMask(mindRadarCount);
			}
			else {
				
				mindRadarCount -= 8;
				if (mindRadarCount <= 0)
					undrawMindRadar();
				else
					drawMask(mindRadarCount);
			}
			
			if (host.getCurrentMap() != hostMapSnapshot) {
				
				characterManager.undrawGhostEffect(mindRadar);
				hostMapSnapshot.undrawGhostEffect(mindRadar);
				gameScreen.removeChild(mindRadar);
				mindRadar = new SpectralImage(3, 540, 400);
				host.getCurrentMap().drawGhostEffect(host, mindRadar);
				characterManager.drawGhostEffect(host, mindRadar);
				gameScreen.addChild(mindRadar);
			}
			
			hostMapSnapshot = host.getCurrentMap();
		}
		override protected function undrawHoldEffect():void 
		{
			super.undrawHoldEffect();
			ghostEffectOn = false;
		}
		
		private function undrawMindRadar():void {
			characterManager.undrawGhostEffect(mindRadar);
			host.getCurrentMap().undrawGhostEffect(mindRadar);
			
			if (gameScreen.contains(mindRadarHaze))
				gameScreen.removeChild(mindRadarHaze);
			mindRadarHaze = new Sprite();
			gameScreen.addChild(mindRadarHaze);
			
			if(gameScreen.contains(mindRadar))
				gameScreen.removeChild(mindRadar);
			mindRadar = new SpectralImage(3, 540, 400);
			mindRadar.cacheAsBitmap = true;
			mindRadarCount = 0;
			mindRadarMask = new Sprite();
			
			SoundManager.getSingleton().playSound("ScanEnd", 1, false);
		}
		
		private function drawMask(radius:int):void {
			
			mindRadarMask = new Sprite();
			mindRadarMask.cacheAsBitmap = true;
			mindRadarMask.graphics.beginFill(0);
			mindRadarMask.graphics.drawCircle
				(gameScreen.x + host.x + (host.width / 2), gameScreen.y + host.y + (host.height / 2), Math.log(radius) * 35);
			mindRadarMask.graphics.endFill();
			mindRadar.mask = mindRadarMask;
			
			gameScreen.removeChild(mindRadarHaze);
			mindRadarHaze = new Sprite();
			mindRadarHaze.graphics.beginFill(0x4444aa, .2);
			mindRadarHaze.graphics.drawCircle(host.x + (host.width/2), host.y + (host.height/2), Math.log(radius) * 35);
			mindRadarHaze.graphics.endFill();
			mindRadarHaze.filters = [new BlurFilter(20,20,1)];
			gameScreen.addChild(mindRadarHaze);
		}
	}

}