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
disp('��������....')
load('Data.mat',['k',code])
disp('�����������')
eval(['d=k',code,';']);
data=[num2cell(d),cellstr(repmat(code,[size(d,1),1]))];





% �������洢����
storeTable='cc';
% �жϱ��Ƿ����
connection=database('testDB','postgres','123456','org.postgresql.Driver','jdbc:postgresql://localhost:5432/testDB');
query= ['select 1 from information_schema.tables where table_schema = ''public'' and table_name = ''',storeTable,''''];
curs = exec(connection, query);
row = fetch(curs);
% ����������ɾ��
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
% ����Ҷ�˲���������
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
% ����鿴
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
% ��һ�ֶ�����Ѱ��˼·
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
% socket ��ƽ̨����
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
% socket response ��Ϣ��ȡ
clc
clear
t = tcpip('119.147.212.81', 7709,'NetworkRole','Client');%�������ip������˿ڵ�TCP��������60�볬ʱ�������С10240
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
% pytdx ��ʷ���Ӻ��� get_history_minute_time_data(self, market, code, date) ģ��
clc
clear
t = tcpip('119.147.212.81', 7709,'NetworkRole','Client');%�������ip������˿ڵ�TCP��������60�볬ʱ�������С10240
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
% �ƽ���������ܿͻ���Ϣ����(�ҵ��٣������̿��Բο�)
clear
clc

g=GessTrader('1021805322','615919');
g.login;


GReqHead.area_code='';
GReqHead.branch_id=g.ServerInfo.branch_id;           %"B00151853";
GReqHead.c_teller_id1='';
GReqHead.c_teller_id2='';	
GReqHead.exch_code='9030';	
GReqHead.msg_flag='1';	
GReqHead.msg_len='';	
GReqHead.msg_type='1';	
GReqHead.seq_no=lower(dec2hex(int32(str2num(datestr(now,'HHMMSSFFF')))));
GReqHead.term_type='03';	
GReqHead.user_id=g.user_id;	
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

v_reqMsg.oper_flag=1	;
v_reqMsg.para_desc='';	
v_reqMsg.para_id='ClientTraderAutoLockInvTime';
v_reqMsg.para_type='';	
v_reqMsg.para_value='';	
%---------------------
v_reqMsg_Str=['#oper_flag=',num2str(v_reqMsg.oper_flag),'#para_id=',v_reqMsg.para_id,'#'];

str=[GReqHead_Str,v_reqMsg_Str];
%SendGoldMsg
v_sMsg=[GessTrader.fill(num2str(length(str)),'0',8,'L'),str];
bSrcMsgBuff=int8(v_sMsg);
%TripleDes.encryptMsg
iEncryptMode=2;
%SESSION_KEY=g.ServerInfo.session_key; %		Global.SESSION_KEY="197609649728882066046320"  ||  Constant.SESSION_KEY_DEFAULT="240262447423713749922240" ??????
SESSION_KEY='240262447423713749922240'; % Ϊʲô�������
%encrypt
key=NET.convertArray(int8(SESSION_KEY),"System.Byte");
ivByte=NET.convertArray(int8('12345678'),"System.Byte");
value=NET.convertArray(bSrcMsgBuff,"System.Byte");
stream = System.IO.MemoryStream;
TDS=System.Security.Cryptography.TripleDESCryptoServiceProvider;
stream2=System.Security.Cryptography.CryptoStream(stream,TDS.CreateEncryptor(key, ivByte),System.Security.Cryptography.CryptoStreamMode.Write);
stream2.Write(value, 0, value.Length);
stream2.FlushFinalBlock();
sourceArray=stream.ToArray().int16;
stream.Close();
stream2.Close();
%encryptMsg;
%destinationArray=NET.createArray("System.Byte",8+1+10+length(sourceArray));
destinationArray_len=8+1+10+length(sourceArray);
destinationArray=[int16(GessTrader.fill(num2str(destinationArray_len-8),'0',8,'L')),...
                  int16(2),...
                  int16(GessTrader.fill(g.ServerInfo.session_id,' ',10,'R')),...
                  sourceArray];
 %SendGoldMsg
 buffer=destinationArray;
 % ����Socket����
socket = tcpip(g.ServerInfo.htm_server_list.trans_ip, str2double(g.ServerInfo.htm_server_list.trans_port),'NetworkRole','Client');
set(socket,'InputBufferSize',4500);
set(socket,'Timeout',3);
fopen(socket);
fwrite(socket,buffer);
revLen_str=fread(socket,8);
revLen=str2double(char(revLen_str)');
vReadBytes=int16(fread(socket,revLen));

if length(vReadBytes)>1 && vReadBytes(1)==1
    error('��Ҫsocketchannel �µ�unzipReadBytes����');
end
arrLfvMsg=int16(vReadBytes);
%decrypt(byte[]SESSION_KEY_DEFAULT=240262447423713749922240,byte[]12345678,buffer)
key=NET.convertArray(int8(SESSION_KEY),"System.Byte");
ivByte=NET.convertArray(int8('12345678'),"System.Byte");
value=NET.convertArray(arrLfvMsg(12:end),"System.Byte");
stream = System.IO.MemoryStream(value);
stream2=System.Security.Cryptography.CryptoStream(stream,TDS.CreateDecryptor(key, ivByte),System.Security.Cryptography.CryptoStreamMode.Read);
buffer=NET.createArray("System.Byte",value.Length);
stream2.Read(buffer, 0, buffer.Length);
fclose(socket)
stream.Close();
stream2.Close();
buffer=buffer.int16;
arrLfvMsg=buffer(9:end);
native2unicode(arrLfvMsg)

%% =================================================================================
% �ƽ���������ܿͻ���Ϣ����
clear
clc

g=GessTrader('1021805322','615919');
g.login;

% TransForNormal
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
GReqHead.branch_id=g.ServerInfo.branch_id;           %"B00151853";
GReqHead.c_teller_id1='';
GReqHead.c_teller_id2='';	
GReqHead.exch_code='1020';	
GReqHead.msg_flag='1';	
GReqHead.msg_len='';	
GReqHead.msg_type='1';	
GReqHead.seq_no=lower(dec2hex(int32(str2num(datestr(now,'HHMMSSFFF')))));
GReqHead.term_type='03';	
GReqHead.user_id=g.user_id;	
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
str=[GReqHead_Str,v_reqMsg_str];

%SendGoldMsg
v_sMsg=[GessTrader.fill(num2str(length(str)),'0',8,'L'),str];
bSrcMsgBuff=int8(v_sMsg);
%TripleDes.encryptMsg
iEncryptMode=2;
SESSION_KEY='240262447423713749922240'; % Ϊʲô�������


%---------------------------
%encrypt
key=NET.convertArray(int8(SESSION_KEY),"System.Byte");
ivByte=NET.convertArray(int8('12345678'),"System.Byte");
value=NET.convertArray(bSrcMsgBuff,"System.Byte");
stream = System.IO.MemoryStream;
TDS=System.Security.Cryptography.TripleDESCryptoServiceProvider;
stream2=System.Security.Cryptography.CryptoStream(stream,TDS.CreateEncryptor(key, ivByte),System.Security.Cryptography.CryptoStreamMode.Write);
stream2.Write(value, 0, value.Length);
stream2.FlushFinalBlock();
sourceArray=stream.ToArray().int16;
stream.Close();
stream2.Close();
%encryptMsg;
%destinationArray=NET.createArray("System.Byte",8+1+10+length(sourceArray));
destinationArray_len=8+1+10+length(sourceArray);
destinationArray=[int16(GessTrader.fill(num2str(destinationArray_len-8),'0',8,'L')),...
                  int16(2),...
                  int16(GessTrader.fill(g.ServerInfo.session_id,' ',10,'R')),...
                  sourceArray];
 %SendGoldMsg
 buffer=destinationArray;
 % ����Socket����
socket = tcpip(g.ServerInfo.htm_server_list.trans_ip, str2double(g.ServerInfo.htm_server_list.trans_port),'NetworkRole','Client');
set(socket,'InputBufferSize',4500);
set(socket,'Timeout',3);
fopen(socket);
fwrite(socket,buffer);
revLen_str=fread(socket,8);
revLen=str2double(char(revLen_str)');
vReadBytes=int16(fread(socket,revLen));
fclose(socket);
if length(vReadBytes)>1 && vReadBytes(1)==1
    bytes=vReadBytes(2:end);
    buffer2=gzipdecode(uint8(bytes));
    arrLfvMsg=buffer2(9:end);
else
    arrLfvMsg=int16(vReadBytes);
end

native2unicode(arrLfvMsg)

