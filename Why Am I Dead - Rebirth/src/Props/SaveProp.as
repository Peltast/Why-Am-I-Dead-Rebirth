package Props 
{
	import Characters.Character;
	import Dialogue.Dialogue;
	import flash.display.Bitmap;
	import flash.display.Shape;
	import Setup.SaveManager;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class SaveProp extends Prop
	{
		
		
		public function SaveProp(propImg:Bitmap, propTag:String, collidable:Boolean = true, xCoord:int = 0, yCoord:int = 0, 
									permissions:Vector.<String> = null, sucDia:Dialogue = null, failDia:Dialogue = null) 
		{
			super(propImg, propTag, collidable, xCoord, yCoord, null, permissions, sucDia, failDia);
			
		}
		
		override public function effect(character:Character, isPlayer:Boolean = true, charName:String = ""):void 
		{
			SaveManager.getSingleton().saveGame();
		}
		
		override public function hasEffect():Boolean 
		{
			return true;
		}
		
	}

}