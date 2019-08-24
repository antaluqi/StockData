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
            user_type
            sSSLServerHost
            iSSLServerPort
            timeout
            ServerInfo
            CustomInfo
            Quote
            FieldName
    end
    
    properties(Access=private)
          user_pwd 
    end
    
    
    methods
        function obj = GessTrader(user_id,user_pwd)
            addpath('.\Trans\')
            addpath('.\Comm\')
            
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
            obj.FieldName=containers.Map('KeyType','double','ValueType','any');
            obj.Quote=struct;
            obj.setFieldName
        end
        
        function islogin=login(obj)
            % 数据头
            GReqHead=ReqHead;
            GReqHead.exch_code='8006';
            GReqHead.msg_type='1';
            GReqHead.msg_flag='1';
            GReqHead.term_type='03';
            GReqHead.user_type='2';
            GReqHead.user_id=obj.user_id;     
            % 数据体
            v_reqMsg=ReqT8006;
            v_reqMsg.bank_no=obj.bank_no;
            v_reqMsg.login_ip=GessTrader.getLocalIP();
            v_reqMsg.net_agent='1';
            v_reqMsg.net_envionment='2';
            v_reqMsg.oper_flag='1';
            v_reqMsg.user_id=obj.user_id;
            v_reqMsg.user_id_type='1';
            v_reqMsg.user_pwd=obj.user_pwd;
            v_reqMsg.user_type='2';
            v_sMsg=[GReqHead.ToString(),v_reqMsg.ToString()];
            vSrcBuff=uint8(double(v_sMsg)); % 数据二进制化
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
        
        function getCustomInfo(obj)
            % 数据头
            GReqHead=ReqHead;
            GReqHead.exch_code='1020';
            GReqHead.msg_type='1';
            GReqHead.msg_flag='1';
            GReqHead.term_type='03';
            GReqHead.user_type='2';
            GReqHead.user_id=obj.user_id;     
            % 数据体
            v_reqMsg=ReqT1020;
            v_reqMsg.acct_no=obj.user_id;
            v_reqMsg.is_check_stat='1';
            v_reqMsg.oper_flag='1';
            v_reqMsg.qry_cust_info='1';
            v_reqMsg.qry_defer='1'; 
            v_reqMsg.qry_forward='1';
            v_reqMsg.qry_fund='1';
            v_reqMsg.qry_storage='1';
            v_reqMsg.qry_surplus='1';  
            v_sMsg=[GReqHead.ToString(),v_reqMsg.ToString()];
            % 建立Socket连接,发送和接受数据
            socket = tcpip(obj.ServerInfo.htm_server_list.trans_ip, str2double(obj.ServerInfo.htm_server_list.trans_port),'NetworkRole','Client');
            set(socket,'InputBufferSize',4500);
            set(socket,'Timeout',3);
            fopen(socket);
            obj.SendGoldMsg(socket,v_sMsg);
            str=obj.RecvGoldMsg(socket);
            fclose(socket);
            obj.splitCunstomInfo(str);
            
        end
        
        function getQuote(obj)
            v_reqMsg=GBcMsgReqLink;
            v_reqMsg.RspCode='';	
            v_reqMsg.RspMsg='';
            v_reqMsg.again_flag='0';
            v_reqMsg.branch_id=obj.ServerInfo.branch_id;
            v_reqMsg.cust_type_id='C01';
            v_reqMsg.is_lfv='1';
            v_reqMsg.lan_ip=obj.login_ip;
            v_reqMsg.term_type='';
            v_reqMsg.user_id=obj.user_id;
            v_reqMsg.user_key=datestr(now,'HHMMSSFFF');
            v_reqMsg.user_pwd=obj.user_pwd;
            v_reqMsg.user_type=obj.user_type;
            v_reqMsg.www_ip='';
            
            v_sMsg=v_reqMsg.ToString;
            % 建立Socket连接,发送和接受数据
            socket = tcpip(obj.ServerInfo.htm_server_list.broadcast_ip, str2double(obj.ServerInfo.htm_server_list.broadcast_port),'NetworkRole','Client');
            set(socket,'InputBufferSize',4500);
            set(socket,'Timeout',3);
            fopen(socket);
            
            obj.SendGoldMsg(socket,v_sMsg);
            for i=1:44
                str=obj.RecvGoldMsg(socket);
                obj.splitQuoteInfo(str);
            end
             fclose(socket);
        end
        
        function str=trade(obj)
            % 数据头
            GReqHead=ReqHead;
            GReqHead.exch_code='4041';
            GReqHead.msg_type='1';
            GReqHead.msg_flag='1';
            GReqHead.term_type='03';
            GReqHead.user_type='2';
            GReqHead.user_id=obj.user_id;     
            % 数据体
            v_reqMsg=ReqT4041;            
            v_reqMsg.acct_no=obj.user_id;
            v_reqMsg.client_serial_no=[obj.user_id,num2str(floor(System.DateTime.Now.TimeOfDay.TotalSeconds)*10)];               %'1021805322584010';
            v_reqMsg.cust_id=obj.user_id;
            v_reqMsg.entr_amount = 1;      % 交易数量
            v_reqMsg.entr_price = 4025; % 交易价格
            v_reqMsg.prod_code = 'Ag(T+D)'; % 交易品种      
            % 合并消息字符串
            v_sMsg=[GReqHead.ToString,v_reqMsg.ToString];
           % 建立Socket连接,发送和接受数据
            socket = tcpip(obj.ServerInfo.htm_server_list.trans_ip, str2double(obj.ServerInfo.htm_server_list.trans_port),'NetworkRole','Client');
            set(socket,'InputBufferSize',4500);
            set(socket,'Timeout',3);
            fopen(socket);
            obj.SendGoldMsg(socket,v_sMsg);
            str=obj.RecvGoldMsg(socket);
            fclose(socket);           
        end
    end
    
    

    
    methods(Access=private)
        
        function SendGoldMsg(obj,socket,v_sMsg)
            v_sMsg=[GessTrader.fill(num2str(length(v_sMsg)),'0',8,'L'),v_sMsg];
            bSrcMsgBuff=int8(v_sMsg);
            buffer=obj.TripleDes_encryptMsg(2, bSrcMsgBuff);
            fwrite(socket,buffer);     % 发送请求数据
        end
        
        function str=RecvGoldMsg(obj,socket)
%             if socket==''
%                 str=''
%                return
%             end
              num=str2double(char(obj.RecvByLen(socket,8)));
              vReadBytes=obj.RecvByLen(socket,num);
              arrLfvMsg=obj.TripleDes_decryptMsg(obj.unzipReadBytes(vReadBytes));
              if length(arrLfvMsg)>8 && arrLfvMsg(1)==35 && arrLfvMsg(2)==76 && arrLfvMsg(3)==102 && arrLfvMsg(4)==118 && arrLfvMsg(5)==77 && arrLfvMsg(6)==115 && arrLfvMsg(7)==103 && arrLfvMsg(8)==61
                  str=obj.GlobalLfvTransfer_lfvToKv(arrLfvMsg,9,length(arrLfvMsg)-2);
              else
                  str=native2unicode(arrLfvMsg); 
              end
        
        
        end
         
        function buffer=RecvByLen(obj,socket,v_iRecvLen)
            num=0;
            buffer=[];
            while num<v_iRecvLen
                size = v_iRecvLen - num;
                if size>1024
                    size=1024;
                end
                buffer2=fread(socket,size);
                num3=length(buffer2);
                if num3>0
                   buffer=[buffer,buffer2];
                   num=num+num3;
                else
                    error('无数据，可能被远程主机强制关闭')
                end
            end
            buffer=int16(buffer);
        end
        
        function buffer=TripleDes_encryptMsg(obj,iEncryptMode, bSrcMsgBuff)
            if iEncryptMode==2 || iEncryptMode==3 
                SESSION_KEY='240262447423713749922240'; % 为什么用这个？
                if iEncryptMode==3 && isempty(obj.CustomInfo.SESSION_KEY)
                    SESSION_KEY=obj.CustomInfo.SESSION_KEY;
                end
                IV_DEFAULT='12345678';
                sourceArray=obj.encrypt(SESSION_KEY,IV_DEFAULT,bSrcMsgBuff);
                destinationArray_len=8+1+10+length(sourceArray); % 8位数据长度，1位iEncryptMode=2，10位SESSION_KEY长度，其余是数据本提sourceArray的长度
                destinationArray=[int16(GessTrader.fill(num2str(destinationArray_len-8),'0',8,'L')),...
                                  int16(2),...
                                  int16(GessTrader.fill(obj.ServerInfo.session_id,' ',10,'R')),...
                                  sourceArray]; 
                buffer=destinationArray;
                return;
            end
            buffer=bSrcMsgBuff;
        end
        
        function buffer=TripleDes_decryptMsg(obj,bDecryptMsgBuff)
            ENCRYPT_MODEL_LEN=1;
            SESSION_LEN=10;
            IV_DEFAULT='12345678';
            num=bDecryptMsgBuff(ENCRYPT_MODEL_LEN);
            switch num
                case 1

                case 2
                    str='240262447423713749922240';
                    vStartIndex=ENCRYPT_MODEL_LEN+SESSION_LEN+1;
                    buffer=bDecryptMsgBuff(vStartIndex:end);
                    vSrcBuff=obj.decrypt(str,IV_DEFAULT,buffer);
                    buffer=vSrcBuff(9:end);
                    return;
            end
            buffer=bDecryptMsgBuff;
        end
        
        function arrLfvMsg=unzipReadBytes(obj,vReadBytes)
            if length(vReadBytes)>1 && vReadBytes(1)==1
                bytes=vReadBytes(2:end);
                buffer2=gzipdecode(uint8(bytes));
                arrLfvMsg=buffer2(9:end);
            else
                arrLfvMsg=int16(vReadBytes);
            end
        end
        
        function sourceArray=encrypt(obj,key,ivByte,value)
            key=NET.convertArray(int8(key),"System.Byte");   %SESSION_KEY
            ivByte=NET.convertArray(int8(ivByte),"System.Byte"); %加密密码？
            value=NET.convertArray(value,"System.Byte");       %要加密的值
            stream = System.IO.MemoryStream;
            TDS=System.Security.Cryptography.TripleDESCryptoServiceProvider;
            stream2=System.Security.Cryptography.CryptoStream(stream,TDS.CreateEncryptor(key, ivByte),System.Security.Cryptography.CryptoStreamMode.Write);
            stream2.Write(value, 0, value.Length);
            stream2.FlushFinalBlock();
            sourceArray=stream.ToArray().int16;
            stream.Close();
            stream2.Close();            
        end
        
        function vSrcBuff=decrypt(obj,key,ivByte,value)
            key=NET.convertArray(int8(key),"System.Byte");   %SESSION_KEY
            ivByte=NET.convertArray(int8(ivByte),"System.Byte"); %加密密码？
            value=NET.convertArray(value,"System.Byte");       %要加密的值   
            stream = System.IO.MemoryStream(value);
            TDS=System.Security.Cryptography.TripleDESCryptoServiceProvider;
            stream2=System.Security.Cryptography.CryptoStream(stream,TDS.CreateDecryptor(key, ivByte),System.Security.Cryptography.CryptoStreamMode.Read);
            buffer=NET.createArray('System.Byte', value.Length);
            stream2.Read(buffer, 0, buffer.Length);
            vSrcBuff=buffer.int16;
            stream.Close();
            stream2.Close();            

        end
        
        function str=GlobalLfvTransfer_lfvToKv(obj,arrLfvMsg,iStartIndex,iEndIndex)
            iOffset=iStartIndex;
            str=[];
            while iOffset<iEndIndex
                num2=GessTrader.byteToInt(arrLfvMsg,iOffset,2);
                iOffset=iOffset+2;
                idx=GessTrader.byteToInt(arrLfvMsg,iOffset,2);
                iOffset=iOffset+2;
                str2=native2unicode(arrLfvMsg(iOffset:iOffset+num2-2)');
                iOffset=iOffset+num2-2;
                str=[str,'#',obj.FieldName(idx),'=:',str2];
            end
            
        end
        
        
        
        function setFieldName(obj)
             obj.FieldName(31)='ApiName';
             obj.FieldName(49)='RspCode';
             obj.FieldName(54)='Ts_NodeID';
             obj.FieldName(650)='instID';
             obj.FieldName(1170)='state';
             obj.FieldName(785)='marketID';
             obj.FieldName(786)='marketState';
             obj.FieldName(48)='RootID';
             obj.FieldName(50)='RspMsg';
             obj.FieldName(483)='effectDate';
             obj.FieldName(549)='feeRate';
             obj.FieldName(1086)='sys_date  ';
             obj.FieldName(504)='exch_date';
             obj.FieldName(773)='m_sys_stat';
             obj.FieldName(253)='b_sys_stat';
             obj.FieldName(951)='quoteDate';
             obj.FieldName(1006)='sZipBuff';
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
        
        function  splitCunstomInfo(obj,str)
            scell0=strsplit(str,{'#','='});
            scell=scell0(2:end-1);
            for i=1:2:length(scell)
                name=scell{i};
                value=scell{i+1};
                eval(['obj.CustomInfo.',name,'=','value;']);
            end
        end
        
        function splitQuoteInfo(obj,str)
            if contains(str,'sZipBuff')==0
                return;
            end
            namecell={};
            valuecell={};
             instID='';
             strcell=split(str,{'#','=:'});
             strcell=strcell(2:end-1);
             for i=1:2:length(strcell)
                 name=deblank(strcell{i});
                 value=deblank(strcell{i+1});
                 if strcmp(name,'instID')
                     instID=lower(replace(value,{'+','(',')','.'},''));
                 end
                 if strcmp(name,'sZipBuff')
                    [name,value]=GessTrader.unzipQuote(value);
                 end
                 namecell=[namecell,name];
                 valuecell=[valuecell,value];

             end
             if ~isempty(instID)
                 Quote=cell2struct(valuecell',namecell,1);
                 eval(['obj.Quote.',instID,'=','Quote;']);
             end
        end
                
    end
    
    methods(Static)
        
        function [namecell,valuecell]=unzipQuote(sZipBuff)
            namecell={};
            valuecell={};
            mNeedZipFields={'lastSettle', 'lastClose', 'open', 'high', 'low', 'last', 'close', 'settle', 'bid1', 'bidLot1', 'bid2', 'bidLot2', 'bid3', 'bidLot3', 'bid4', 'bidLot4',...
            'bid5', 'bidLot5', 'ask1', 'askLot1', 'ask2', 'askLot2', 'ask3', 'askLot3', 'ask4', 'askLot4', 'ask5', 'askLot5', 'volume', 'weight', 'highLimit', 'lowLimit',...
            'Posi', 'upDown', 'turnOver', 'average', 'sequenceNo', 'quoteTime', 'upDownRate'};
             if ~isempty(sZipBuff)
                buffer=matlab.net.base64decode(sZipBuff);
                i=1;
                while i<=length(buffer)
                    i;
                    num2=buffer(i);
                    str=dec2bin(num2,8);
                    if length(str)>8
                        str=str(end-7:end);
                    end
                    index=bin2dec(str(1:6));
                    num4=3+bin2dec(str(7:end));
                    if i>=length(buffer)-1
                        break;
                    end

                    bytes=double([buffer(i+1:i+num4)]);

                    i=i+num4+1;
                    name=mNeedZipFields{index+1};
                    namecell=[namecell,name];
                    %toLongByBytes
                    value=0;
                    L=length(bytes);
                    for ii=1:L
                        value=value+bitshift(bytes(ii),8*(L-ii));
                    end
                    value=value/1000;
                    % Parse
                    if strcmp(name,'quoteTime')
                        value=num2str(value*1000);
                        if length(value)==6
                           value=[value(1:2),':',value(3:4),':',value(5:6)];
                        end
                    end
                    if strcmp(name,'upDownRate')
                        value=value/10000;
                    end
                    valuecell=[valuecell,value];
                end

            end
        end

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
        
        function num=byteToInt(arrLfvMsg,iOffset,iLen)
             num = 0;
             for i=iOffset:iOffset+iLen-1
                 num=num+bitshift(bitand(arrLfvMsg(i),255),(8 * ((iLen - 1) - (i - iOffset))));
             end
        end
        
        function ip=getLocalIP()
            [~,result]=dos('ipconfig');
            [~,token]=regexp(result,['IPv4 地址 . . . . . . . . . . . . : (.*?)',newline] ,'match', 'tokens');
            ip=token{1}{:};
        end
        
        function str=struct2str(struc)
            str='#';
            fn=fieldnames(struc);
            for i=1:length(fn)
                name=fn{i};
                value=getfield(struc,name);
                if ~isempty(value)
                  str=[str,name,'=',num2str(value),'#'] ;
                end
            end
            
        end
    end
    
end

