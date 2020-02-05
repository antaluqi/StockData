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
clear
clc
S=Stock('sh600118');
d=S.Indicators({'BOLL'},{[20,2]},{'2019-01-01','2019-12-03'});
d.PBOllDown20_2=[nan;d.BOllDown20_2(1:end-1)];
d.PLow=[nan;d.Low(1:end-1)];
plb=d(d.Open>d.BOllDown20_2 & d.Low<d.BOllDown20_2 & d.PLow>d.PBOllDown20_2,:);

% zs=0.15;
% zy=0.15;
% zj=0.05;
% 
% 
% for i=1:height(plb)
%    dL=d(d.Date>pld.Date(i),:);
%    for j=1:height(dL)
%        
%    end
% 
% end

%% =================================================================
clc
code='sz000528';
S=Stock(code);
data=S.HistoryDaily('2019-01-01','2020-02-01');
p3=Plan3(code,data)
p3.Loop





