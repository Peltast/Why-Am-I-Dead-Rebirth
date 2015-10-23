package Setup 
{
	import Characters.CharacterManager;
	import Characters.Player;
	import Dialogue.DialogueLibrary;
	import flash.display.Bitmap;
	import flash.utils.getDefinitionByName;
	import Interface.GUIManager;
	import Maps.MapManager;
	import Props.PropManager;
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class GameLoader 
	{
		
		
		
		// Embed UI graphics
		[Embed(source = "../../lib/UI/MenuSkin.png")]
		public static const MenuSkin:Class;
		[Embed(source = "../../lib/UI/MenuSkinLight.png")]
		public static const MenuSkinLight:Class;
		[Embed(source = "../../lib/UI/SoundOff.png")]
		public static const SoundOff:Class;
		[Embed(source = "../../lib/UI/SoundOn.png")]
		public static const SoundOn:Class;
		[Embed(source = "../../lib/UI/PauseButton.png")]
		public static const PauseButton:Class;
		[Embed(source = "../../lib/UI/DialogueOption.png")]
		public static const DialogueOption:Class;
		[Embed(source = "../../lib/UI/DialogueOptionAnim.png")]
		public static const DialogueOptionAnim:Class;
		
		[Embed(source = "../../lib/UI/TitleSplash.png")]
		public static const TitleSplash:Class;
		[Embed(source = "../../lib/UI/TitleSplash2.png")]
		public static const TitleSplash2:Class;
		[Embed(source = "../../lib/UI/TitleSplash3.png")]
		public static const TitleSplash3:Class;
		[Embed(source = "../../lib/UI/TitleText1.png")]
		public static const TitleText1:Class;
		[Embed(source = "../../lib/UI/TitleText2.png")]
		public static const TitleText2:Class;
		[Embed(source = "../../lib/UI/OptionsButton.png")]
		public static const OptionsButton:Class;
		[Embed(source = "../../lib/UI/CreditsButton.png")]
		public static const CreditsButton:Class;
		[Embed(source = "../../lib/UI/NewGameButton.png")]
		public static const NewGameButton:Class;
		[Embed(source = "../../lib/UI/ContinueButton.png")]
		public static const ContinueButton:Class;
		
		[Embed(source = "../../lib/UI/XButton.png")]
		public static const XButton:Class;
		[Embed(source = "../../lib/UI/CreditsText3.png")]
		public static const CreditsText3:Class;
		[Embed(source = "../../lib/UI/CreditsLogo1.png")]
		public static const CreditsLogo1:Class;
		[Embed(source = "../../lib/UI/CreditsLogo2.png")]
		public static const CreditsLogo2:Class;
		[Embed(source = "../../lib/UI/CreditsImage.png")]
		public static const CreditsImage:Class;
		[Embed(source = "../../lib/UI/GreenlightButton.png")]
		public static const GreenlightButton:Class;
		[Embed(source = "../../lib/UI/PromoLogo.png")]
		public static const PromoLogo:Class;
		
		[Embed(source = "../../lib/UI/Crosspromo.png")]
		public static const CrossPromo:Class;
		[Embed(source = "../../lib/UI/Crosspromo2.png")]
		public static const CrossPromo2:Class;
		[Embed(source = "../../lib/UI/CrosspromoSmall.png")]
		public static const CrossPromoSmall:Class;
		[Embed(source = "../../lib/UI/CrosspromoSmall2.png")]
		public static const CrossPromoSmall2:Class;
		
		[Embed(source = "../../lib/UI/RedEnding.png")]
		public static const RedEnding:Class;
		[Embed(source = "../../lib/UI/BlueEnding.png")]
		public static const BlueEnding:Class;
		[Embed(source = "../../lib/UI/GrayEnding.png")]
		public static const GrayEnding:Class;
		[Embed(source = "../../lib/UI/BlackEnding.png")]
		public static const BlackEnding:Class;
		
		[Embed(source = "../../lib/ag_intro_2011.swf", mimeType="application/octet-stream")]
		public static const AGIntro:Class;
		
		
		// Embed character graphics
		[Embed(source = "../../lib/Characters/Ghost.png")]
		public static const Ghost:Class;
		[Embed(source = "../../lib/Characters/Cricket.png")]
		public static const Cricket:Class;
		[Embed(source = "../../lib/Characters/Randy.png")]
		public static const Randy:Class;
		[Embed(source = "../../lib/Characters/Ted.png")]
		public static const Ted:Class;
		[Embed(source = "../../lib/Characters/Lucille.png")]
		public static const Lucille:Class;
		[Embed(source = "../../lib/Characters/Morgan.png")]
		public static const Morgan:Class;
		[Embed(source = "../../lib/Characters/Iblis.png")]
		public static const Iblis:Class;
		[Embed(source = "../../lib/Characters/Rose.png")]
		public static const Rose:Class;
		[Embed(source = "../../lib/Characters/Orval.png")]
		public static const Orval:Class;
		
		[Embed(source = "../../lib/Characters/Shadow1.png")]
		public static const Shadow1:Class;
		[Embed(source = "../../lib/Characters/Shadow2.png")]
		public static const Shadow2:Class;
		
		
		
		// Embed prop graphics
		[Embed(source = "../../lib/Props/Clipboard.png")]
		public static const Clipboard:Class;
		
		[Embed(source = "../../lib/Props/BoothEnd.png")]
		public static const BoothEnd:Class;
		[Embed(source = "../../lib/Props/BoothFront.png")]
		public static const BoothFront:Class;
		[Embed(source = "../../lib/Props/BoothCorner.png")]
		public static const BoothCorner:Class;
		[Embed(source = "../../lib/Props/BoothMid.png")]
		public static const BoothMid:Class;
		[Embed(source = "../../lib/Props/BoothTop.png")]
		public static const BoothTop:Class;
		
		[Embed(source = "../../lib/Props/Owner.png")]
		public static const Owner:Class;
		[Embed(source = "../../lib/Props/Door.png")]
		public static const Door:Class;
		[Embed(source = "../../lib/Props/Liquor1.png")]
		public static const Liquor1:Class;
		[Embed(source = "../../lib/Props/Liquor2.png")]
		public static const Liquor2:Class;
		[Embed(source = "../../lib/Props/BedsideTable.png")]
		public static const BedsideTable:Class;
		[Embed(source = "../../lib/Props/Doll.png")]
		public static const Doll:Class;
		[Embed(source = "../../lib/Props/BrokenFlowers.png")]
		public static const BrokenFlowers:Class;
		[Embed(source = "../../lib/Props/BloodyMirror.png")]
		public static const BloodyMirror:Class;
		[Embed(source = "../../lib/Props/Mirror.png")]
		public static const Mirror:Class;
		[Embed(source = "../../lib/Props/TableBroken.png")]
		public static const TableBroken:Class;
		[Embed(source = "../../lib/Props/Television.png")]
		public static const Television:Class;
		
		[Embed(source = "../../lib/Props/BloodyBed.png")]
		public static const BloodyBed:Class;
		[Embed(source = "../../lib/Props/MessyBed.png")]
		public static const MessyBed:Class;
		[Embed(source = "../../lib/Props/Bed.png")]
		public static const Bed:Class;
		[Embed(source = "../../lib/Props/Drawer.png")]
		public static const Drawer:Class;
		[Embed(source = "../../lib/Props/TableFlowers.png")]
		public static const TableFlowers:Class;
		
		[Embed(source = "../../lib/Props/HiddenDoor.png")]
		public static const HiddenDoor:Class;
		[Embed(source = "../../lib/Props/BlackDoor.png")]
		public static const BlackDoor:Class;
		[Embed(source = "../../lib/Props/BlackDesk.png")]
		public static const BlackDesk:Class;
		[Embed(source = "../../lib/Props/Tenant1.png")]
		public static const Tenant1:Class;
		[Embed(source = "../../lib/Props/Tenant2.png")]
		public static const Tenant2:Class;
		[Embed(source = "../../lib/Props/Tenant3.png")]
		public static const Tenant3:Class;
		[Embed(source = "../../lib/Props/Tenant4.png")]
		public static const Tenant4:Class;
		[Embed(source = "../../lib/Props/Tenant5.png")]
		public static const Tenant5:Class;
		[Embed(source = "../../lib/Props/Tenant6.png")]
		public static const Tenant6:Class;
		
		[Embed(source = "../../lib/Props/Tutorial1.png")]
		public static const Tutorial1:Class;
		[Embed(source = "../../lib/Props/Tutorial2.png")]
		public static const Tutorial2:Class;
		[Embed(source = "../../lib/Props/Tutorial3.png")]
		public static const Tutorial3:Class;
		[Embed(source = "../../lib/Props/Tutorial4.png")]
		public static const Tutorial4:Class;
		
		
		// Embed map graphics
		[Embed(source = "../../lib/Tiles/Mainsheet.png")]
		public static const MainTileSheet:Class;
		[Embed(source = "../../lib/Tiles/Bathroomsheet.png")]
		public static const BathroomTileSheet:Class;
		[Embed(source = "../../lib/Tiles/Hallway.png")]
		public static const DarkHallwayTileSheet:Class;
		[Embed(source = "../../lib/Tiles/BlackRoom.png")]
		public static const BlackRoomTileSheet:Class;
		
		
		// Embed map information
		[Embed(source = "../../lib/Maps/OwnersRoom.tmx", mimeType = "application/octet-stream")]
		public static const OwnersRoom:Class;
		[Embed(source = "../../lib/Maps/Lobby.tmx", mimeType = "application/octet-stream")]
		public static const Lobby:Class;
		[Embed(source = "../../lib/Maps/RandysRoom.tmx", mimeType = "application/octet-stream")]
		public static const RandysRoom:Class;
		[Embed(source = "../../lib/Maps/Hallway.tmx", mimeType = "application/octet-stream")]
		public static const Hallway:Class;
		[Embed(source = "../../lib/Maps/Bathroom.tmx", mimeType = "application/octet-stream")]
		public static const Bathroom:Class;
		
		[Embed(source = "../../lib/Maps/RosesRoom.tmx", mimeType = "application/octet-stream")]
		public static const RosesRoom:Class;
		[Embed(source = "../../lib/Maps/MorgansRoom.tmx", mimeType = "application/octet-stream")]
		public static const MorgansRoom:Class;
		[Embed(source = "../../lib/Maps/CricketsRoom.tmx", mimeType = "application/octet-stream")]
		public static const CricketsRoom:Class;
		[Embed(source = "../../lib/Maps/LucillesRoom.tmx", mimeType = "application/octet-stream")]
		public static const LucillesRoom:Class;
		[Embed(source = "../../lib/Maps/TedsRoom.tmx", mimeType = "application/octet-stream")]
		public static const TedsRoom:Class;
		[Embed(source = "../../lib/Maps/OrvalsRoom.tmx", mimeType = "application/octet-stream")]
		public static const OrvalsRoom:Class;
		
		[Embed(source = "../../lib/Maps/DarkHallway.tmx", mimeType = "application/octet-stream")]
		public static const DarkHallway:Class;
		[Embed(source = "../../lib/Maps/BlackRoom.tmx", mimeType = "application/octet-stream")]
		public static const BlackRoom:Class;
		
		
		
		// Dialogue files
		[Embed(source = "../../lib/Dialogue/Cricket Dialogues.txt", mimeType = "application/octet-stream")]
		public static const CricketDialogues:Class;
		[Embed(source = "../../lib/Dialogue/Randy Dialogues.txt", mimeType = "application/octet-stream")]
		public static const RandyDialogues:Class;
		[Embed(source = "../../lib/Dialogue/Lucille Dialogues.txt", mimeType = "application/octet-stream")]
		public static const LucilleDialogues:Class;
		[Embed(source = "../../lib/Dialogue/Ted Dialogues.txt", mimeType = "application/octet-stream")]
		public static const TedDialogues:Class;
		
		[Embed(source = "../../lib/Dialogue/Morgan Dialogues.txt", mimeType = "application/octet-stream")]
		public static const MorganDialogues:Class;
		[Embed(source = "../../lib/Dialogue/Iblis Dialogues.txt", mimeType = "application/octet-stream")]
		public static const IblisDialogues:Class;
		[Embed(source = "../../lib/Dialogue/Rose Dialogues.txt", mimeType = "application/octet-stream")]
		public static const RoseDialogues:Class;
		[Embed(source = "../../lib/Dialogue/Orval Dialogues.txt", mimeType = "application/octet-stream")]
		public static const OrvalDialogues:Class;
		[Embed(source = "../../lib/Dialogue/Sarah Dialogues.txt", mimeType = "application/octet-stream")]
		public static const SarahDialogues:Class;
		
		[Embed(source = "../../lib/Dialogue/Prop Dialogues.txt", mimeType = "application/octet-stream")]
		public static const PropDialogues:Class;
		
		[Embed(source = "../../lib/Dialogue/Ending2 Dialogues.txt", mimeType = "application/octet-stream")]
		public static const Ending2Dialogues:Class;
		[Embed(source = "../../lib/Dialogue/Ending3 Dialogues.txt", mimeType = "application/octet-stream")]
		public static const Ending3Dialogues:Class;
		[Embed(source = "../../lib/Dialogue/Ending4 Dialogues.txt", mimeType = "application/octet-stream")]
		public static const Ending4Dialogues:Class;
		
		
		// Cinematic files
		[Embed(source = "../../lib/Cinematics/Core.txt", mimeType = "application/octet-stream")]
		public static const CoreTriggers:Class;
		[Embed(source = "../../lib/Cinematics/Plot Triggers.txt", mimeType = "application/octet-stream")]
		public static const PlotTriggers:Class;
		[Embed(source = "../../lib/Cinematics/Plot Triggers 2.txt", mimeType = "application/octet-stream")]
		public static const PlotTriggers2:Class;
		[Embed(source = "../../lib/Cinematics/Plot Triggers 3.txt", mimeType = "application/octet-stream")]
		public static const PlotTriggers3:Class;
		[Embed(source = "../../lib/Cinematics/Plot Triggers 4.txt", mimeType = "application/octet-stream")]
		public static const PlotTriggers4:Class;
		
		
		[Embed(source="../../lib/Sounds/Static.mp3")]
		public static const Static:Class;
		[Embed(source="../../lib/Sounds/Thunder.mp3")]
		public static const Thunder:Class;
		[Embed(source="../../lib/Sounds/Tunnel.mp3")]
		public static const Tunnel:Class;
		[Embed(source="../../lib/Sounds/Wind.mp3")]
		public static const Wind:Class;
		[Embed(source="../../lib/Sounds/Melody2.mp3")]
		public static const Melody:Class;
		
		[Embed(source="../../lib/Sounds/CinematicBoom.mp3")]
		public static const cinematicBoom:Class;
		[Embed(source="../../lib/Sounds/Revolver.mp3")]
		public static const revolver:Class;
		
		[Embed(source="../../lib/Sounds/Possess.mp3")]
		public static const Possess:Class;
		[Embed(source="../../lib/Sounds/Unpossess.mp3")]
		public static const Unpossess:Class;
		[Embed(source="../../lib/Sounds/Footstep.mp3")]
		public static const Footstep:Class;
		[Embed(source="../../lib/Sounds/Light Footstep.mp3")]
		public static const LightFootstep:Class;
		[Embed(source="../../lib/Sounds/Slow Footstep.mp3")]
		public static const SlowFootstep:Class;
		[Embed(source="../../lib/Sounds/RandyText.mp3")]
		public static const RandyText:Class;
		[Embed(source="../../lib/Sounds/TedText.mp3")]
		public static const TedText:Class;
		[Embed(source="../../lib/Sounds/NormalText.mp3")]
		public static const NormalText:Class;
		
		
		
		private static var singleton:GameLoader;
			
		private var mapManager:MapManager;
		private var characterManager:CharacterManager;
		private var dialogueLibrary:DialogueLibrary;
		private var guiManager:GUIManager;
		private var propManager:PropManager;
		
		private static var loadPercent:Number;
		
		public static function getSingleton():GameLoader {
			if (singleton == null)
				singleton = new GameLoader();
			return singleton;
		}
		public static function clearSingleton():void {
			singleton = null;
		}
		
		public function GameLoader() 
		{
			
		}
		
		public static function getSpriteByName(name:String):Bitmap {
			if (name == null) return null;
			
			var definition:Bitmap = new GameLoader[name]() as Bitmap;
			return definition;
		}
		
		public function addLoadPercent(addition:Number):void { loadPercent += addition; }
		public function getLoadPercent():Number { return loadPercent; }
		
	}

}