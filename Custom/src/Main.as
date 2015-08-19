package
{
	import flash.display.Sprite;
	import com.ankamagames.dofus.kernel.Kernel;
	
	public class Main extends Sprite 
	{
		public function Main() 
		{
			Kernel.getWorker().addFrame(new CustomFrame());
		}
	}
}