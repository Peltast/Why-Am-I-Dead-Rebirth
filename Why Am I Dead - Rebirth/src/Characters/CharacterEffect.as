package Characters 
{
	import Core.Game;
	import flash.events.Event;
	import Maps.Map;
	import Maps.MapTransition;
	/**
	 * ...
	 * @author Peltast
	 */
	public class CharacterEffect 
	{
		protected var keyHoldCounter:int;
		protected var holdEffectThreshold:int;
		protected var holdEffectDrawn:Boolean;
		protected var effectHeld:Boolean;
		protected var host:Character;
		protected var currentAction:String;
		
		public function CharacterEffect(effect:CharacterEffect, holdEffectThreshold:int) 
		{
			if (effect != this)
				throw new Error("CharacterEffect is meant to be used as an abstract class.");
			this.holdEffectThreshold = holdEffectThreshold;
			keyHoldCounter = 0;
			currentAction = "";
		}
		
		public function updateEffect(homeMap:Map):void {
			if (effectHeld)
				effectHold();
			
		}
		
		public function effectPress(host:Character):void {
			this.host = host;
			effectHeld = true;
		}
		public function effectRelease(host:Character):void {
			if (keyHoldCounter > holdEffectThreshold) {
				holdEffectDrawn = false;
				undrawHoldEffect();
			}
			else {
				drawPressEffect(host);
			}
			
			effectHeld = false;
			keyHoldCounter = 0;
		}
		protected function effectHold():void {
			keyHoldCounter++;
			
			if (keyHoldCounter > holdEffectThreshold && !holdEffectDrawn){
				drawHoldEffect();
				holdEffectDrawn = true;
			}
		}
		
		protected function drawPressEffect(host:Character):void {
			
		}
		
		protected function drawHoldEffect():void {
			
		}
		protected function undrawHoldEffect():void {
			
		}
		
		public function resetEffect():void { }
		public function handleTransition(host:Character, transition:MapTransition):void { }
		
		public function getAnimationAction():String { return ""; }
	}

}