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
% socket 测试
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
% fread(t,[1, t.BytesAvailable]);
fwrite(t,setup2);
% fread(t,[1, t.BytesAvailable]);
fwrite(t,setup3);
fread(t,909);

% (268, 16868360, 28, 28, 1325, 0, b'000001', 9, 1, 0, 10, 0, 0, 0)
cmd=[12,1,8,100,1,1,28,0,28,0,45,5,0,0,48,48,48,48,48,49,9,0,1,0,0,0,10,0,0,0,0,0,0,0,0,0,0,0];
fwrite(t,cmd);
receive = fread(t, 16)'


% %fid=fopen('C:\Users\hccb\Desktop\test.bin','w');
% fid=fopen('C:\Users\antal\Desktop\test.bin','w');
% fwrite(fid,receive);
% fclose(fid);
% %fid=fopen('C:\Users\hccb\Desktop\test.bin','r');
% fid=fopen('C:\Users\antal\Desktop\test.bin','r');
% value=fread(fid,'uint16');
% zipsize=value(end-1);
% unzipsize=value(end);
% fclose(fid);
% receive=uint8(fread(t,zipsize)');
% % receive = zlibdecode(uint8(fread(t,zipsize)'));
% %fid=fopen('C:\Users\hccb\Desktop\test.bin','w');
% fid=fopen('C:\Users\antal\Desktop\test.bin','w');
% fwrite(fid,receive);
% fclose(fid);
fclose(t);



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
% socket 二进制文件读取
clear
clc
value=[];
%fid=fopen('C:\Users\antal\Desktop\test.bin','r');
fid=fopen('C:\Users\hccb\Desktop\test.bin','r');
type='HIHHHHSSSSSSHHHHIIH';
for i=1:length(type)
  if type(i)=='H'
      value=[value,fread(fid,1,'uint16')'];
   elseif type(i)=='I'
      value=[value,fread(fid,1,'uint32')'];
   elseif type(i)=='S'
      value=[value,fread(fid,1,'uint8')'];
   end
end
fclose(fid);
value
%% =================================================================================
% socket 二进制文件写入
clear
clc
fid=fopen('C:\Users\antal\Desktop\test.bin','w');
%fid=fopen('C:\Users\hccb\Desktop\test.bin','w');
cmd=[268, 16868360, 28, 28, 1325, 0, double('000001'), 9, 1, 0, 10, 0, 0, 0];
type='HIHHHHSSSSSSHHHHIIH';
if length(cmd)~=length(type)
    error('数据与格式规范的长度不同')
end
for i=1:length(cmd)
   if type(i)=='H'
      fwrite(fid,cmd(i),'uint16',0,'l');
   elseif type(i)=='I'
      fwrite(fid,cmd(i),'uint32',0,'l');
   elseif type(i)=='S'
      fwrite(fid,cmd(i),'char',0,'l');
   end
end
fclose(fid);
fid=fopen('C:\Users\antal\Desktop\test.bin','r');
fread(fid)'
fclose(fid);
%% =================================================================================
% socket response 信息读取
clear
clc
%fid=fopen('C:\Users\antal\Desktop\test.bin','w');
fid=fopen('C:\Users\hccb\Desktop\test.bin','r');
fseek(fid,2,'bof');
value=fread(fid,1,'uint32')'
fclose(fid)

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
fwrite(t,setup2);
fwrite(t,setup3);
fread(t,907)';

cmd=[20161214,1,double('600118')];
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
    %prices = [];
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

