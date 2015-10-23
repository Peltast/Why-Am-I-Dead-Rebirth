package Cinematics 
{
	/**
	 * ...
	 * @author Peltast
	 */
	public class TriggerBlock 
	{
		private var blockStatus:int;
		private var blockTime:int;
		private var blockTimerCount:int;
		
		// list of strings with keywords outlining the requirements for a trigger to be activated
		private var blockRequirements:Array; 
		// list of strings with keywords outlining the effect a trigger has when activated
		private var blockEffects:Array;
		
		public function TriggerBlock(status:int, requirements:Array, effects:Array) 
		{
			this.blockStatus = status;
			this.blockRequirements = requirements;
			this.blockEffects = effects;
			if (effects == null)
				blockEffects = [];
			if (requirements == null)
				blockRequirements = [];
		}
		
		public function getReqLength():int { return blockRequirements.length; }
		public function getEffectLength():int { return blockEffects.length; }
		public function getReqAt(index:int):String {
			if (index >= 0 && index < blockRequirements.length)
				return blockRequirements[index];
			return "";
		}
		public function getEffectAt(index:int):String {
			if (index >= 0 && index < blockEffects.length)
				return blockEffects[index];
			return "";
		}
		
		public function isOn():Boolean { return (blockStatus > 0); }
		public function isAwake():Boolean { return (blockStatus == 0); }
		public function isAsleep():Boolean { return (blockStatus < 0); }
		
		public function sleepBlock():void {
			if (blockStatus >= 0) {
				blockStatus = -1;
				blockTimerCount = -1;
			}
		}
		public function wakeUpBlock():void {
			if (blockStatus < 0) {
				blockStatus = 0;
				blockTimerCount = blockTime;
			}
		}
		public function activateBlock():void { 
			if (blockStatus == 0) blockStatus = 1;
		}
		public function deactivateBlock():void {
			if (blockStatus == 1) {
				blockStatus = 0;
				blockTimerCount = -1;
			}
		}
		
		public function listenToBlock(parsedRequirement:Array):Boolean {
			if (parsedRequirement[0] == "timer") {
				
				if (blockTimerCount < 0) {
					blockTime = parseInt(parsedRequirement[1]);
					blockTimerCount = blockTime;
				}
				else blockTimerCount--;
				
				if (blockTimerCount == 0) 
					return true;
				else 
					return false;
			}
			
			return false;
		}
		
	}

}