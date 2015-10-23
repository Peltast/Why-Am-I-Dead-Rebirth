package Dialogue 
{
	/**
	 * ...
	 * @author Patrick McGrath
	 */
	public class DialogueAction 
	{
		protected var title:String;
		
		public function DialogueAction(title:String) 
		{
			this.title = title;
		}
		
		public function getTitle():String { return title; }
	}

}