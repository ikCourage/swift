package swift.controller.mt
{
	import org.ais.system.Ais;
	
	import swift.core.shell.Shell;

	public class Shell_mt extends Shell
	{
		public function Shell_mt()
		{
			name = command = "mt";
			option = [
				"s", 2,
				"c",
			];
			callback = __exec;
			description = "监控器\n" +
				"s 显示 如果包含参数 stage 则显示在 stage 上\n" +
				"c 关闭";
		}
		
		protected function __exec(str:String, args:Vector.<Array>):Object
		{
			for (var i:uint = 0, len:uint = args[1].length; i < len; i++) {
				switch (args[1][i][0]) {
					case "s":
						switch (args[1][i][1]) {
							case "stage":
								Ais.IMain.stage.addChild(MovieMonitor.getInstance());
								break;
							default:
								Ais.IMain.addChild(MovieMonitor.getInstance());
								break;
						}
						break;
					case "c":
						MovieMonitor.getInstance().clear();
						break;
				}
			}
			str = null;
			args = null;
			return null;
		}
		
	}
}