package Cinematics 
{
	import Characters.CharacterManager;
	import Characters.Player;
	import Maps.MapManager;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class Cinematic 
	{
		private var title:String;
		private var status:int;
		
		// The trigger that needs to be active for this cinematic to initiate.
		private var prereqList:Vector.<Trigger>;
		
		// The list of triggers that this cinematic, in turn, activates.
		private var triggerList:Vector.<Trigger>;
		
		public function Cinematic(title:String, prereqList:Vector.<Trigger>, triggerList:Vector.<Trigger>) 
		{
			this.title = title;
			this.status = 0;
			this.prereqList = prereqList;
			this.triggerList = triggerList;
			
			for each(var trigger:Trigger in triggerList)
				trigger.sleepTrigger();
			
		}
		
		public function sleepCinematic():void {
			if (status >= 0)
				status = -1;
		}
		public function wakeUpCinematic():void {
			if (status < 0)
				status = 0;
		}
		public function activateCinematic():void { 
			if (status == 0) status = 1;
		}
		public function deactivateCinematic():void {
			if (status == 1)
				status = 0;
		}
		public function isOn():Boolean { return (status > 0); }
		public function isAwake():Boolean { return (status == 0); }
		public function isAsleep():Boolean { return (status < 0); }
		
		public function updateCinematic():void {
			if (status == -1) return;
			
			if (status == 1) {
				for each(var trigger:Trigger in triggerList) {
					if (trigger.isOn()) continue;
					else if (trigger.isAwake()) break;
					else if (trigger.isAsleep()) {
						trigger.wakeUpTrigger();
						break;
					}
				}
			}
			else {				
				var allTriggersOn:Boolean = true;
				for each(trigger in prereqList)
					if (!trigger.isOn()) allTriggersOn = false;
				if (allTriggersOn)
					status = 1;
			}
			
		}
		
	}

}