package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import org.ais.system.Ais;
	
	import swift.controller.cli.Console;
	import swift.controller.cli.ConsoleShellController;
	
	use namespace shell_internal;

	public class P2PDemo extends Sprite
	{
		public function P2PDemo()
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			Ais.IMain = this;
			
			Console.shellController = new ConsoleShellController();
			
			Console.shellController._view._maxMessage = uint.MAX_VALUE;
			Console.shellController._view._messageColor = 0x111111;
			Console.shellController._view._messageBgColor = 0xFFFFFF;
			Console.shellController._view._inputColor = 0x111111;
			Console.shellController._view._inputBgColor = 0xDDDDDD;
			Console.shellController._view._colorType = {0: 0x111111, 1: 0x3D3D3D, 2: 0xCD5B45, 3: 0x436EEE, 4: 0x228B22};
			
			Console.rootShell.addShell(new Shell_nt());
			Console.executor = String(this);
			Console.print("P2P Demo　source: https://github.com/ikCourage/swift\n" +
				"注：此程序只做为示例　不能用于其他用途\n" +
				"请不要过渡研究 Shell 因为太复杂了 只应以学习 P2P 为目的\n" +
				"示例：\n设置 rtmfp：nt -r rtmfp://\n" +
				"与对方建立连接：nt -io PeerID 或 nt -tio PeerID\n" +
				"向对方发送消息：nt -s hello\n");
			Console.print(Console.exec("help -i nt") + "\n");
			Console.exec("nt -c");
			Console.show();
		}
	}
}

internal namespace shell_internal = "1500821a06f913bd7c019689e2f34c6dcb4b3e0bce0b241c206edb0bdbf6462f";