classdef GessTrader< handle
    %GessTrader黄金交易
    
    properties
            bank_no
            login_ip
            net_agent
            net_envionment
            oper_flag
            user_id
            user_id_type
            user_pwd
            user_type
            sSSLServerHost
            iSSLServerPort
            timeout
            ServerInfo
    end
    
    methods
        function obj = GessTrader(user_id,user_pwd)
            obj.bank_no='0015';
            obj.login_ip='192.168.137.1';
            obj.net_agent='1';
            obj.net_envionment='2';
            obj.oper_flag='1';
            obj.user_id=user_id;
            obj.user_id_type='1';
            obj.user_pwd=char(mlreportgen.utils.hash(user_pwd));
            obj.user_type='2';
            obj.sSSLServerHost='119.145.36.50';
            obj.iSSLServerPort=20443;
            obj.timeout=5;
        end
        
        function islogin = Connect(obj)
            % 连接登陆服务器
            sMsg=obj.getsMsg;
            vSrcBuff=uint8(double(sMsg)); % 数据二进制化
            % RSA加密解密的各个对象建立（C#）,各编程语言会有区别
            provider=System.Security.Cryptography.RSACryptoServiceProvider();
            provider2=System.Security.Cryptography.RSACryptoServiceProvider();
            certificate=System.Security.Cryptography.X509Certificates.X509Certificate2(".\\cert\\server.crt");
            xmlString = certificate.PublicKey.Key.ToXmlString(false);
            provider2.FromXmlString(xmlString);
            % 数据加密
            streamArr=[];
            for i=1:100:length(vSrcBuff)
                rgb=vSrcBuff(i:min(i+99,length(vSrcBuff)));
                buffer=provider2.Encrypt(NET.convertArray(rgb), false);% C#
                streamArr=[streamArr,buffer.int16];
            end
            % 建立Socket连接
            socket = tcpip(obj.sSSLServerHost, obj.iSSLServerPort,'NetworkRole','Client');
            set(socket,'InputBufferSize',4500);
            set(socket,'Timeout',obj.timeout);
            fopen(socket);
            % 传送登陆信息
            fwrite(socket,num2str(length(streamArr),'%08d'));
            fwrite(socket,streamArr);
            buffer4 = fread(socket, 8)';
            buffer5 = int16(fread(socket,str2num(char(buffer4)))');
            fclose(socket)
            % RSA 解密的各个对象建立(C#)
            certificate=System.Security.Cryptography.X509Certificates.X509Certificate2(".\\cert\\client.pfx","123456",System.Security.Cryptography.X509Certificates.X509KeyStorageFlags.Exportable);
            xmlString2 = certificate.PrivateKey.ToXmlString(true);
            provider.FromXmlString(xmlString2);
            % 数据解密
            streamArr=[];
            for i=1:128:length(buffer5)
                buffer6=buffer5(i:i+127);
                buffer7 = provider.Decrypt(NET.convertArray(buffer6,'System.Byte'), false); %C#
                streamArr=[streamArr,buffer7.int16];
            end
            str=native2unicode(streamArr);
            obj.splitServerInfo(str);
            if isfield(obj.ServerInfo,'rsp_msg') && strcmp(obj.ServerInfo.rsp_msg,'处理成功')
                 islogin=1;
            else
                 islogin=0;
                 disp(str);
            end

        end

        function sMsg=getsMsg(obj)
            % 组合登陆字符串
            sMsgHead='        180061032 1021805322                                    ';
            sMsg=[sMsgHead,'#bank_no=',obj.bank_no,'#login_ip=',obj.login_ip,'#net_agent=',obj.net_agent,'#net_envionment=',obj.net_envionment,'#oper_flag=',obj.oper_flag,'#user_id=',obj.user_id,'#user_id_type=',obj.user_id_type,'#user_pwd=',obj.user_pwd,'#user_type=',obj.user_type,'#'];
            sMsgNow=[lower(dec2hex(int32(str2num(datestr(now,'HHMMSSFFF'))))),'1'];
            sMsg(1:length(sMsgNow))=sMsgNow;
            
        end
        
        function splitServerInfo(obj,str)
            scell0=strsplit(str,{'#','='});
            scell=scell0(2:end-1);
            for i=1:2:length(scell)
                name=scell{i};
                value=scell{i+1};
                if strcmp(name,'htm_server_list')
                    htm_server_list_cell=split(value,{'ˇ','｜','∧'});
                    htm_server_list_cell=htm_server_list_cell([1:14,16:end-3]);
                    for j=1:length(htm_server_list_cell)/2
                        eval(['v.',htm_server_list_cell{j},'=''',htm_server_list_cell{j+14},''';']);
                    end
                    value=v;
                end
                eval(['obj.ServerInfo.',name,'=','value;']);
            end
            
        end
    end
end

