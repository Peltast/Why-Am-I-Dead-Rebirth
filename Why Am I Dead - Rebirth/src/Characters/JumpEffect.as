package Characters 
{
	import Maps.Map;
	import Maps.MapTransition;
	/**
	 * ...
	 * @author Peltast
	 */
	public class JumpEffect extends CharacterEffect
	{
		private var maxHeight:int;
		private var speed:Number;
		private var acceleration:Number;
		private var decelerationDistance:int;
		private var airTime:int;
		private var airTimeCounter:int;
		private var goingUp:Boolean;
		private var goingDown:Boolean;
		private var zDelta:Number;
		private var jumpAnimationFired:Boolean;
		private var fallAnimationFired:Boolean;
		
		public function JumpEffect(maxHeight:int, speed:Number, acceleration:Number, airTime:int) 
		{
			super(this, 0);
			
			this.maxHeight = maxHeight;
			this.speed = speed;
			this.acceleration = acceleration;
			this.airTime = airTime;
			this.decelerationDistance = calculateDecelerateDistance();
			zDelta = 0;
			airTimeCounter = 0;
		}
		
		public override function updateEffect(homeMap:Map):void {
			if (effectHeld || goingUp || goingDown)
				effectHold();
		}
		
		override public function getAnimationAction():String 
		{
			return currentAction;
		}
		
		override public function effectPress(host:Character):void 
		{
			super.effectPress(host);
		}
		
		override protected function drawHoldEffect():void 
		{
			super.drawHoldEffect();
			if (!goingDown && host.getElevation() == 0) {
				goingUp = true;
				zDelta = speed;
			}
		}
		override protected function undrawHoldEffect():void 
		{
			if(goingUp){
				super.undrawHoldEffect();
				goingUp = false;
				goingDown = true;
				zDelta = -speed;
			}
		}
		
		override public function resetEffect():void 
		{
			goingDown = false;
			goingUp = false;
			jumpAnimationFired = false;
			fallAnimationFired = false;
			currentAction = "";
			zDelta = 0;
			if(host != null) host.setElevation(0);
		}
		
		override protected function effectHold():void 
		{
			if(effectHeld)
				super.effectHold();
			
			if (goingUp) {
				if (host.getElevation() >= maxHeight) {
					airTimeCounter++;
					zDelta = 0;
					if (airTimeCounter >= airTime) {
						goingUp = false;
						goingDown = true;
						zDelta = 0;
						host.setAnimation("Front Fall Idle");
						currentAction = "Fall Idle";
					}
				}
				else if (goingUp && host.getElevation() + decelerationDistance >= maxHeight) {
					zDelta -= acceleration;
				}
				else if (!jumpAnimationFired) {
					jumpAnimationFired = true;
					host.setAnimation("Front Jump");
					currentAction = "Jump";
				}
				
			}
			else if (goingDown && host.getElevation() > 0) {
				if (!fallAnimationFired) {
					host.setAnimation("Front Fall Idle");
					currentAction = "Fall Idle";
				}
				
				if (zDelta > -speed)
					zDelta -= acceleration;
				if (zDelta < -speed)
					zDelta = -speed;
				
				if (!fallAnimationFired && host.getElevation() - (speed * 3) <= 0) {
					fallAnimationFired = true;
					host.setAnimation("Front Land");
					currentAction = "Land";
				}
			}
			else if (goingDown && host.getElevation() <= 0) {
				host.setElevation(0);
				airTimeCounter = 0;
				goingDown = false;
				zDelta = speed;
				jumpAnimationFired = false;
				fallAnimationFired = false;
				currentAction = "";
			}
			
			if (goingUp || goingDown)
				host.setElevation(host.getElevation() + zDelta);
			
		}
		
		private function calculateDecelerateDistance():int {
			var frames:Number = speed / acceleration;
			return recurseAdd(frames) - speed;
		}
		private function recurseAdd(dist:Number):int {
			if (dist <= 0) return dist;
			else return dist + recurseAdd(dist - acceleration);
		}
		
		override public function handleTransition(host:Character, transition:MapTransition):void 
		{
			this.host = host;
			
			if (transition.getEndHeight() != 0) {
				host.setElevation(transition.getEndHeight());
				goingDown = true;
			}
		}
	}

}