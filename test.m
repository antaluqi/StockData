%% read from postgresql
% ===============================================================================================================

clc
clear
connection=database('testDB','postgres','123456','org.postgresql.Driver','jdbc:postgresql://localhost:5432/testDB');
curs = exec(connection, 'select distinct code from aa;');
row = fetch(curs);
code_list = row.Data;

query = 'select * from information_schema.columns where table_schema=''public'' and table_name=''aa''; ';
curs = exec(connection, query);
row = fetch(curs);
colume_name=row.Data(:,4);


tic
for i=1:length(code_list)
     code = code_list{i};
     query=['select * from aa where code=''', code,''';'];
     curs = exec(connection, query);
     row = fetch(curs);
     data=row.Data;
     %cell2table([cellstr(datestr(data(:,1),'yyyy-mm-dd')),num2cell(data(:,2:end))],'VariableNames',colume_name);
     
 

     store_data=[datenum(data(:,1),'yyyy-mm-dd'),cell2mat(data(:,[2:6,8:end]))];
     stroe_code=['k',data{1,7}];
     eval([stroe_code,'=store_data;'])
     DatafileName='Data';
     if i==1
            save([DatafileName,'.mat'],stroe_code,'-v6')
        else
            save([DatafileName,'.mat'],stroe_code,'-append','-v6')
     end
     i
end
colume_name={'date', 'open', 'close', 'high', 'low', 'volume'}; 
save([DatafileName,'.mat'],'colume_name','-append','-v6')

toc
close(curs)
close(connection)


%% write to postgresql
% ===============================================================================================================
clc
clear


code='603605';
disp('载入数据....')
load('Data.mat',['k',code])
disp('数据载入完成')
eval(['d=k',code,';']);
data=[num2cell(d),cellstr(repmat(code,[size(d,1),1]))];





% 计算结果存储表名
storeTable='cc';
% 判断表是否存在
connection=database('testDB','postgres','123456','org.postgresql.Driver','jdbc:postgresql://localhost:5432/testDB');
query= ['select 1 from information_schema.tables where table_schema = ''public'' and table_name = ''',storeTable,''''];
curs = exec(connection, query);
row = fetch(curs);
% 如果表存在则删除
if row.Data{1}==1
    query=['drop table ',storeTable];
    curs = exec(connection, query);
    row = fetch(curs);
end
query='create table public.cc (date date,open real,close real,high real,low real,volume real,ma5 real,ma10 real,ma20 real,ma30 real,code text)';
curs = exec(connection, query);
row = fetch(curs);


tic


colnames={'date','open','close','high','low','volume','ma5','ma10','ma20','ma30','code'};
fastinsert(connection,storeTable,colnames,data)
toc



close(curs)
close(connection)

%% ==============================================================================================
clc
clear
connection=database('testDB','postgres','123456','org.postgresql.Driver','jdbc:postgresql://localhost:5432/testDB');
curs = exec(connection, 'select distinct code from aa;');
row = fetch(curs);
code_list = row.Data;
%% ================================================================================================
% 傅里叶滤波研判趋势
addpath([cd,'\stock']);
clear
clc
conn=database('testDB','postgres','123456','org.postgresql.Driver','jdbc:postgresql://localhost:5432/testDB');
dbds=databaseDatastore(conn,'select * from findtop(''sh600118'') where top<>0');
k=dbds.readall;
t=datenum(k.date);
c=max([k.high,-k.low].*k.top,[],2);
y=fft(c);
y(10:end)=0;
plot(t,abs(ifft(y)))
hold on
plot(t,c)
hold off
close(conn)

%% ==============================================================================
% 顶点查看
addpath([cd,'\stock']);
clear
clc
conn=database('testDB','postgres','123456','org.postgresql.Driver','jdbc:postgresql://localhost:5432/testDB');
dbds=databaseDatastore(conn,'select * from findtop(''sz002415'') where abs(rl)>7 and abs(rr)>7');
k=dbds.readall;
t=datetime(datenum(k.date),'ConvertFrom','datenum');
c=k.val;
S=Stock('sz002415');
kdata=S.HistoryDaily('2016-01-01','2019-06-13');
candle(kdata)
hold on 
plot(t,c,'ro')
hold off

close(conn)


%% ==============================================================================
% 另一种顶点找寻的思路
addpath([cd,'\stock']);
clear
clc
S=Stock('sz002415');
kdata=S.HistoryDaily('2016-01-01','2019-06-13');
m=(kdata.High+kdata.Low)/2;
top=[m,m>[nan;m(1:end-1)]&m>[m(2:end);nan],-1*(m<[nan;m(1:end-1)]&m<[m(2:end);nan])];
t=top(:,2).*kdata.High+top(:,3).*kdata.Low*(-1);

candle(kdata);
hold on 
plot(kdata.Date(t>0),t(t>0),'ro')
hold off

%% ==============================================================================
addpath([cd,'\stock']);
clear
clc
S=Stock('sz002415');
kdata=S.HistoryDaily('2016-01-01','2019-06-13');
top0i=(kdata.High>[nan;kdata.High(1:end-1)] & kdata.High>[kdata.High(2:end);nan])-(kdata.Low<[nan;kdata.Low(1:end-1)] & kdata.Low<[kdata.Low(2:end);nan]);
m=(kdata.High+kdata.Low)/2;
top=[m,m>[nan;m(1:end-1)]&m>[m(2:end);nan],-1*(m<[nan;m(1:end-1)]&m<[m(2:end);nan])];





%% =================================================================================
% socket 跨平台传输
clc
clear
t = tcpip('localhost', 50007,'NetworkRole','Client');
set(t,'InputBufferSize',4500);
set(t,'Timeout',10);
fopen(t);
while(1)
    t.BytesAvailable
    receive = fread(t,[1, t.BytesAvailable])
    cmdstr=input('cmd=:');
    if cmdstr=='q'
        fwrite(t,double(cmdstr));
        break
    elseif cmdstr=='a'
        fwrite(t,'a');
        fwrite(t,'a');
    end 
    fwrite(t,double(cmdstr));
end
fclose(t);


%% =================================================================================
% socket response 信息读取
clc
clear
t = tcpip('119.147.212.81', 7709,'NetworkRole','Client');%连接这个ip和这个端口的TCP服务器，60秒超时，缓冲大小10240
set(t,'InputBufferSize',4500);
set(t,'Timeout',10);
fopen(t);
setup1=[12 2 24 147 0 1 3 0 3 0 13 0 1];
setup2=[12 2 24 148 0 1 3 0 3 0 13 0 2];
setup3=[12 3 24 153 0 1 32 0 32 0 219 15 213 208 201 204 214 164 168 175 0 0 0 143 194 37 64 19 0 0 213 0 201 204 189 240 215 234 0 0 0 2];
fwrite(t,setup1);
receive = fread(t, 16)';
zipsize=double(typecast(uint8(receive(end-3:end-2)),'uint16'));
unzipsize=double(typecast(uint8(receive(end-1:end)),'uint16'));
body_buf = zlibdecode(uint8(fread(t,zipsize)'));

fclose(t);

%% =================================================================================
% pytdx 历史分钟函数 get_history_minute_time_data(self, market, code, date) 模拟
clc
clear
t = tcpip('119.147.212.81', 7709,'NetworkRole','Client');%连接这个ip和这个端口的TCP服务器，60秒超时，缓冲大小10240
set(t,'InputBufferSize',4500);
set(t,'Timeout',10);
fopen(t);

setup1=[12 2 24 147 0 1 3 0 3 0 13 0 1];
setup2=[12 2 24 148 0 1 3 0 3 0 13 0 2];
setup3=[12 3 24 153 0 1 32 0 32 0 219 15 213 208 201 204 214 164 168 175 0 0 0 143 194 37 64 19 0 0 213 0 201 204 189 240 215 234 0 0 0 2];
fwrite(t,setup1);
receive = fread(t, 16)';
zipsize=double(typecast(uint8(receive(end-3:end-2)),'uint16'));
unzipsize=double(typecast(uint8(receive(end-1:end)),'uint16'));
body_buf = zlibdecode(uint8(fread(t,zipsize)'));

fwrite(t,setup2);
receive = fread(t, 16)';
zipsize=double(typecast(uint8(receive(end-3:end-2)),'uint16'));
unzipsize=double(typecast(uint8(receive(end-1:end)),'uint16'));
body_buf = zlibdecode(uint8(fread(t,zipsize)'));

fwrite(t,setup3);
receive = fread(t, 16)';
zipsize=double(typecast(uint8(receive(end-3:end-2)),'uint16'));
unzipsize=double(typecast(uint8(receive(end-1:end)),'uint16'));
body_buf = zlibdecode(uint8(fread(t,zipsize)'));
%fread(t,2048)';

cmd=[20190621,0,double('000858')];
type='IBSSSSSS';
cmd=[12,1,48,0,1,1,13,0,13,0,180,15,park(cmd,type)];
fwrite(t,cmd);
receive = fread(t, 16)';

zipsize=double(typecast(uint8(receive(end-3:end-2)),'uint16'));
unzipsize=double(typecast(uint8(receive(end-1:end)),'uint16'));


if zipsize<16
    out=[];
else
    body_buf = zlibdecode(uint8(fread(t,zipsize)'));
    pos=1;
    num=double(typecast(body_buf(1:2),'uint16'));
    last_price = 0;
    pos=pos+ 6;
    out=[];
    for i=1:num
        [price_raw, pos] = get_price(body_buf, pos);
        [reversed1, pos] = get_price(body_buf, pos);
        [vol, pos] = get_price(body_buf, pos);
        last_price = last_price + price_raw;
        price=double(last_price)/100;
        out=[out;[price,double(vol)]];
    end
end
out
%% =================================================================================
% 黄金交易软件的一些登陆实验
clear
clc

%--------------------------------------------------------------------------
% 发送的信息 最前面的是时间，精确到毫秒(凌晨会有错误，貌似时间长度缩短了，整个长度要保持在230) 
sMsg='        180061032 1021805322                                    #bank_no=0015#login_ip=192.168.137.1#net_agent=1#net_envionment=2#oper_flag=1#user_id=1021805322#user_id_type=1#user_pwd=80d2f4983572a7d5f8f96a924c18368d#user_type=2#';
%sMsg=[lower(dec2hex(int32(str2num(char(System.DateTime.Now.ToString("HHmmssfff")))))),'1',sMsgTail];
sMsgNow=[lower(dec2hex(int32(str2num(datestr(now,'HHMMSSFFF'))))),'1'];
sMsgTail(1:length(sMsgNow))=sMsgNow;
vSrcBuff=uint8(double(sMsg)); % 数据二进制化
%--------------------------------------------------------------------------
% RSA加密解密的各个对象建立（C#）,各编程语言会有区别
provider=System.Security.Cryptography.RSACryptoServiceProvider();
provider2=System.Security.Cryptography.RSACryptoServiceProvider();
certificate=System.Security.Cryptography.X509Certificates.X509Certificate2(".\\GessTrader\\cert\\server.crt");
xmlString = certificate.PublicKey.Key.ToXmlString(false);
provider2.FromXmlString(xmlString);
%--------------------------------------------------------------------------

%stream=System.IO.MemoryStream;
streamArr=[];
for i=1:100:length(vSrcBuff)
    %rgb=NET.convertArray(vSrcBuff(i:min(i+99,length(vSrcBuff))));
    rgb=vSrcBuff(i:min(i+99,length(vSrcBuff)));
    buffer=provider2.Encrypt(NET.convertArray(rgb), false);
    %stream.Write(buffer, 0, buffer.Length);
    streamArr=[streamArr,buffer.int16];
end


v_sHost="119.145.36.50";
v_iPort=int16(20443);
remoteEP=System.Net.IPEndPoint(System.Net.IPAddress.Parse(v_sHost),v_iPort);
socket=System.Net.Sockets.Socket(System.Net.Sockets.AddressFamily.InterNetwork,System.Net.Sockets.SocketType.Stream,System.Net.Sockets.ProtocolType.Tcp);
socket.ReceiveTimeout=3000;
socket.Connect(remoteEP)
socket.Send(System.Text.Encoding.Default.GetBytes("00000384"), System.Net.Sockets.SocketFlags.None);
%socket.Send(stream.ToArray(), System.Net.Sockets.SocketFlags.None);
socket.Send(NET.convertArray(streamArr,'System.Byte'), System.Net.Sockets.SocketFlags.None);
% RecvByLen
buffer4=NET.createArray('System.Byte', 8);
socket.Receive(buffer4,8,System.Net.Sockets.SocketFlags.None);
num=str2num(char(buffer4.int8));
buffer5=NET.createArray('System.Byte',num );
socket.Receive(buffer5,num,System.Net.Sockets.SocketFlags.None);
certificate=System.Security.Cryptography.X509Certificates.X509Certificate2(".\\GessTrader\\cert\\client.pfx","123456",System.Security.Cryptography.X509Certificates.X509KeyStorageFlags.Exportable);
str2 = certificate.PrivateKey.ToXmlString(true);
provider.FromXmlString(str2);
stream=System.IO.MemoryStream;
b5=buffer5.int16;
for i=1:128:buffer5.Length
    buffer6=NET.convertArray(b5(i:i+127),'System.Byte');
    buffer7 = provider.Decrypt(buffer6, false);
    stream.Write(buffer7, 0, buffer7.Length);
end
System.Text.Encoding.Default.GetString(stream.ToArray())

%----------
socket.Close()

%% =========================================================================================================================
% 登陆接口matlab化
clear
clc
% 发送的信息 最前面的是时间，精确到毫秒(凌晨会有错误，貌似时间长度缩短了，整个长度要保持在230) 
sMsg='        180061032 1021805322                                    #bank_no=0015#login_ip=192.168.137.1#net_agent=1#net_envionment=2#oper_flag=1#user_id=1021805322#user_id_type=1#user_pwd=80d2f4983572a7d5f8f96a924c18368d#user_type=2#';
sMsgNow=[lower(dec2hex(int32(str2num(datestr(now,'HHMMSSFFF'))))),'1'];
sMsgTail(1:length(sMsgNow))=sMsgNow;
vSrcBuff=uint8(double(sMsg)); % 数据二进制化

% RSA加密解密的各个对象建立（C#）,各编程语言会有区别
provider=System.Security.Cryptography.RSACryptoServiceProvider();
provider2=System.Security.Cryptography.RSACryptoServiceProvider();
certificate=System.Security.Cryptography.X509Certificates.X509Certificate2(".\\GessTrader\\cert\\server.crt");
xmlString = certificate.PublicKey.Key.ToXmlString(false);
provider2.FromXmlString(xmlString);

% 数据加密
streamArr=[];
for i=1:100:length(vSrcBuff)
    rgb=vSrcBuff(i:min(i+99,length(vSrcBuff)));
    buffer=provider2.Encrypt(NET.convertArray(rgb), false);% C#
    streamArr=[streamArr,buffer.int16];
end

t = tcpip('119.145.36.50', 20443,'NetworkRole','Client');
set(t,'InputBufferSize',4500);
set(t,'Timeout',5);
fopen(t);
fwrite(t,num2str(length(streamArr),'%08d'));
fwrite(t,streamArr);
buffer4 = fread(t, 8)';
buffer5 = int16(fread(t,str2num(char(buffer4)))');
fclose(t)
% RSA 解密的各个对象建立(C#)
certificate=System.Security.Cryptography.X509Certificates.X509Certificate2(".\\GessTrader\\cert\\client.pfx","123456",System.Security.Cryptography.X509Certificates.X509KeyStorageFlags.Exportable);
xmlString2 = certificate.PrivateKey.ToXmlString(true);
provider.FromXmlString(xmlString2);

streamArr=[];
% 数据解密
for i=1:128:length(buffer5)
    buffer6=buffer5(i:i+127);
    buffer7 = provider.Decrypt(NET.convertArray(buffer6,'System.Byte'), false); %C#
    streamArr=[streamArr,buffer7.int16];
end
str=native2unicode(streamArr)
