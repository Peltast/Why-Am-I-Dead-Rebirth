package Props 
{
	import Characters.Character;
	import Core.Game;
	import Core.SpectralState;
	import flash.display.Bitmap;
	/**
	 * ...
	 * @author Peltast
	 */
	public class SpectralProp extends Prop
	{
		
		public function SpectralProp(propImg:Bitmap, propTag:String, collidable:Boolean = true, xCoord:int = 0, yCoord:int = 0) 
		{
			super(propImg, propTag, collidable, xCoord, yCoord);
		}
		
		override public function effect(character:Character, isPlayer:Boolean = true):void 
		{
			if (character.getName() == "Ghost")
				Game.pushState(new SpectralState("Test", true));
		}
		
		override public function hasEffect():Boolean 
		{
			return true;
		}
	}

}