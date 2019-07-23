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
            CustomInfo
            FieldName
    end
    
    methods
        function obj = GessTrader(user_id,user_pwd)
            obj.bank_no='0015';
            obj.login_ip= GessTrader.getLocalIP();
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
            obj.setFieldName
        end
        
        function islogin = login(obj)
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
            SInfo=GessTrader.splitServerInfo(str);
            obj.ServerInfo=SInfo;
            if isfield(obj.ServerInfo,'rsp_msg') && strcmp(obj.ServerInfo.rsp_msg,'处理成功')
                 islogin=1;
            else
                 islogin=0;
                 disp(str);
            end

        end

        function getCustomInfo(obj)
            % TransForNormal
            % 建立发送消息的字符串
            v_reqMsg.acct_no='1021805322';
            v_reqMsg.is_check_stat='1';
            v_reqMsg.oper_flag='1';
            v_reqMsg.qry_cust_info='1';
            v_reqMsg.qry_defer='1';
            v_reqMsg.qry_forward='1';
            v_reqMsg.qry_fund='1';
            v_reqMsg.qry_storage='1';
            v_reqMsg.qry_surplus='1';

            v_reqMsg_str=['#acct_no=',v_reqMsg.acct_no,...
                          '#is_check_stat=',v_reqMsg.is_check_stat,...
                          '#oper_flag=',v_reqMsg.oper_flag,...
                          '#qry_cust_info=',v_reqMsg.qry_cust_info,...
                          '#qry_defer=',v_reqMsg.qry_defer,...
                          '#qry_forward=',v_reqMsg.qry_forward,...
                          '#qry_fund=',v_reqMsg.qry_fund,...
                          '#qry_storage=',v_reqMsg.qry_storage,...
                          '#qry_surplus=',v_reqMsg.qry_surplus,'#'];


            GReqHead.area_code='';
            GReqHead.branch_id=obj.ServerInfo.branch_id;%"B00151853";
            GReqHead.c_teller_id1='';
            GReqHead.c_teller_id2='';	
            GReqHead.exch_code='1020';	% 消息类型
            GReqHead.msg_flag='1';	
            GReqHead.msg_len='';	
            GReqHead.msg_type='1';	
            GReqHead.seq_no=lower(dec2hex(int32(str2num(datestr(now,'HHMMSSFFF')))));
            GReqHead.term_type='03';	
            GReqHead.user_id=obj.user_id;	
            GReqHead.user_type='2';	
            %---------------------
            GReqHead_Str=[GessTrader.fill(GReqHead.seq_no,' ',8,'R'),...
                          GessTrader.fill(GReqHead.msg_type,' ',1,'R'),...
                          GessTrader.fill(GReqHead.exch_code,' ',4,'R'),...
                          GessTrader.fill(GReqHead.msg_flag,' ',1,'R'),...
                          GessTrader.fill(GReqHead.term_type,' ',2,'R'),...
                          GessTrader.fill(GReqHead.user_type,' ',2,'R'),...
                          GessTrader.fill(GReqHead.user_id,' ',10,'R'),...
                          GessTrader.fill(GReqHead.area_code,' ',4,'R'),...
                          GessTrader.fill(GReqHead.branch_id,' ',12,'R'),...
                          GessTrader.fill(GReqHead.c_teller_id1,' ',10,'R'),...
                          GessTrader.fill(GReqHead.c_teller_id2,' ',10,'R'),...
                          ];
            % 合并消息字符串
            str=[GReqHead_Str,v_reqMsg_str];
            %SendGoldMsg
            v_sMsg=[GessTrader.fill(num2str(length(str)),'0',8,'L'),str];
            bSrcMsgBuff=int8(v_sMsg);
            %TripleDes.encryptMsg
            iEncryptMode=2;
            SESSION_KEY='240262447423713749922240'; % 为什么用这个？
            %encrypt
            %-------------------加密（C#）
            key=NET.convertArray(int8(SESSION_KEY),"System.Byte");   %SESSION_KEY
            ivByte=NET.convertArray(int8('12345678'),"System.Byte"); %加密密码？
            value=NET.convertArray(bSrcMsgBuff,"System.Byte");       %要加密的值
            stream = System.IO.MemoryStream;
            TDS=System.Security.Cryptography.TripleDESCryptoServiceProvider;
            stream2=System.Security.Cryptography.CryptoStream(stream,TDS.CreateEncryptor(key, ivByte),System.Security.Cryptography.CryptoStreamMode.Write);
            stream2.Write(value, 0, value.Length);
            stream2.FlushFinalBlock();
            sourceArray=stream.ToArray().int16;
            stream.Close();
            stream2.Close();
            %-------------------
            %encryptMsg;
            %destinationArray=NET.createArray("System.Byte",8+1+10+length(sourceArray));
            destinationArray_len=8+1+10+length(sourceArray); % 8位数据长度，1位iEncryptMode=2，10位SESSION_KEY长度，其余是数据本提sourceArray的长度
            destinationArray=[int16(GessTrader.fill(num2str(destinationArray_len-8),'0',8,'L')),...
                              int16(2),...
                              int16(GessTrader.fill(obj.ServerInfo.session_id,' ',10,'R')),...
                              sourceArray];
                          
            %SendGoldMsg
            buffer=destinationArray;   
             % 建立Socket连接,发送和接受数据
            socket = tcpip(obj.ServerInfo.htm_server_list.trans_ip, str2double(obj.ServerInfo.htm_server_list.trans_port),'NetworkRole','Client');
            set(socket,'InputBufferSize',4500);
            set(socket,'Timeout',3);
            fopen(socket);
            fwrite(socket,buffer);     % 发送请求数据
            revLen_str=fread(socket,8);% 接受数据位数
            revLen=str2double(char(revLen_str)');
            vReadBytes=int16(fread(socket,revLen)); % 接受数据本体
            fclose(socket);
            % 是否需要解压缩
            if length(vReadBytes)>1 && vReadBytes(1)==1
                bytes=vReadBytes(2:end);
                buffer2=gzipdecode(uint8(bytes));
                arrLfvMsg=buffer2(9:end);
            else
                arrLfvMsg=int16(vReadBytes);
            end
            % 转化为字符串
            str=native2unicode(arrLfvMsg);
            obj.splitCunstomInfo(str);
        end
        
        function sMsg=getsMsg(obj)
            % 组合登陆字符串
            sMsgHead='        180061032 1021805322                                    ';
            sMsg=[sMsgHead,'#bank_no=',obj.bank_no,'#login_ip=',obj.login_ip,'#net_agent=',obj.net_agent,'#net_envionment=',obj.net_envionment,'#oper_flag=',obj.oper_flag,'#user_id=',obj.user_id,'#user_id_type=',obj.user_id_type,'#user_pwd=',obj.user_pwd,'#user_type=',obj.user_type,'#'];
            sMsgNow=[lower(dec2hex(int32(str2num(datestr(now,'HHMMSSFFF'))))),'1'];
            sMsg(1:length(sMsgNow))=sMsgNow;
            
        end
        
        function setFieldName(obj)
             obj.FieldName{31}='ApiName';
             obj.FieldName{49}='RspCode';
             obj.FieldName{54}='Ts_NodeID';
             obj.FieldName{650}='instID';
             obj.FieldName{1170}='state';
             obj.FieldName{785}='marketID';
             obj.FieldName{786}='marketState';
             obj.FieldName{48}='RootID';
             obj.FieldName{50}='RspMsg';
             obj.FieldName{483}='effectDate';
             obj.FieldName{549}='feeRate';
             obj.FieldName{1086}='sys_date  ';
             obj.FieldName{504}='exch_date';
             obj.FieldName{773}='m_sys_stat';
             obj.FieldName{253}='b_sys_stat';
             obj.FieldName{951}='quoteDate';
             obj.FieldName{1006}='sZipBuff';
        end
        
        function  splitCunstomInfo(obj,str)
            scell0=strsplit(str,{'#','='});
            scell=scell0(2:end-1);
            for i=1:2:length(scell)
                name=scell{i};
                value=scell{i+1};
                eval(['obj.CustomInfo.',name,'=','value;']);
            end
        end
    end
    methods(Static)
        function str=fill(v_sSrc,v_cFill,v_iLen,v_cDire)
            if length(v_sSrc)>=v_iLen
                str=v_sSrc;
                return;
            end
            str=repmat(v_cFill,1,v_iLen);
            if strcmp(v_cDire,'R')
                str(1:length(v_sSrc))=v_sSrc;
            elseif strcmp(v_cDire,'L')
                str(end-length(v_sSrc)+1:end)=v_sSrc;
            else
                error('fill函数的v_cDire参数输入错误，应该为R或L');
            end
            
        end
        
        function ServerInfo=splitServerInfo(str)
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
                eval(['ServerInfo.',name,'=','value;']);
            end
        end
        
        function num=byteToInt(arrLfvMsg,iOffset,iLen)
             num = 0;
             for i=iOffset:iOffset+iLen-1
                 num=num+bitshift(bitand(arrLfvMsg(i),255),(8 * ((iLen - 1) - (i - iOffset))));
             end
        end
        
        function ip=getLocalIP()
            [~,result]=dos('ipconfig');
            [~,token]=regexp(result,'IPv4 地址 . . . . . . . . . . . . : (\d+.\d.+.\d+.\d+).*?子网掩码' ,'match', 'tokens');
            ip=token{:}{:};
        end
    end
    
end

