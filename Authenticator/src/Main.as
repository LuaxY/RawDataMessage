package
{
    import flash.display.Sprite;
    import flash.utils.ByteArray;
    import __AS3__.vec.Vector;
    import com.ankamagames.jerakine.network.NetworkMessage;
    import com.hurlant.crypto.Crypto;
    import com.hurlant.crypto.symmetric.CBCMode;
    import com.hurlant.crypto.symmetric.NullPad;
    import com.ankamagames.dofus.BuildInfos;
    import com.ankamagames.jerakine.utils.system.AirScanner;
    import com.ankamagames.dofus.network.enums.ClientInstallTypeEnum;
    import com.ankamagames.jerakine.data.XmlConfig;
    import com.ankamagames.dofus.logic.connection.managers.AuthentificationManager;
    import com.ankamagames.dofus.kernel.net.ConnectionsHandler;
    import com.ankamagames.dofus.network.types.version.VersionExtended;
    import com.ankamagames.dofus.network.messages.connection.IdentificationMessage;

    public class Main extends Sprite 
    {
        private static var _cypher:CBCMode;

        public function Main() 
        {
            GenerateKey();
            NetworkMessage.CRYPT_FUNCTION = EncryptMessage;
            
            Authenticator();
        }
        
        private function GenerateKey() : void
        {
            var key:ByteArray = new ByteArray;
            
            for (var i:int = 0; i < 16; i++)
            {
                key.writeByte(i);
            }
           
            _cypher = Crypto.getCipher("aes-cbc", key, new NullPad) as CBCMode;
            _cypher.IV = key;
        }
        
        public static function EncryptMessage(output:*, data:ByteArray) : void
        {
            var dataToEncrypt:ByteArray = new ByteArray;
            dataToEncrypt.writeBytes(data, 0, data.length);
            
            _cypher.encrypt(dataToEncrypt);
            
            output.writeByte(166);
            output.writeInt(dataToEncrypt.length);
            output.writeBytes(dataToEncrypt, 0, dataToEncrypt.length);
        }
        
        private function Authenticator() : void
        {
            var username:String = AuthentificationManager.getInstance().loginValidationAction.username;
            var password:String = AuthentificationManager.getInstance().loginValidationAction.password;
            var serverId:uint   = AuthentificationManager.getInstance().loginValidationAction.serverId;
            var autoSelectServer:Boolean = AuthentificationManager.getInstance().loginValidationAction.autoSelectServer;
            
            AuthentificationManager.getInstance().initAESKey();
            var AESKey:ByteArray = AuthentificationManager.getInstance().AESKey;
            
            var version:VersionExtended = new VersionExtended;
            version.initVersionExtended(
                BuildInfos.BUILD_VERSION.major,
                BuildInfos.BUILD_VERSION.minor,
                BuildInfos.BUILD_VERSION.release,
                AirScanner.isStreamingVersion() ? 70000 : BuildInfos.BUILD_REVISION,
                BuildInfos.BUILD_PATCH,
                BuildInfos.BUILD_VERSION.buildType,
                AirScanner.isStreamingVersion() ? ClientInstallTypeEnum.CLIENT_STREAMING : ClientInstallTypeEnum.CLIENT_BUNDLE,
                0
            );
            
            var credentials:ByteArray = new ByteArray;
            credentials.writeUTF(username);
            credentials.writeUTF(password);
            credentials.writeBytes(AESKey, 0, 32);
            
            var vector:Vector.<int> = new Vector.<int>;
            credentials.position = 0;
            
            while(credentials.bytesAvailable != 0)
            {
                vector.push(credentials.readByte());
            }
            
            var im:IdentificationMessage = new IdentificationMessage;
            im.initIdentificationMessage(version, XmlConfig.getInstance().getEntry("config.lang.current"), vector, serverId, autoSelectServer, false, false, 0, new Vector.<uint>());
			
            ConnectionsHandler.getConnection().send(im);
        }
    }
}
