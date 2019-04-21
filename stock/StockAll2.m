classdef StockAll2<handle
    properties
        CodeList
        KDataAll
        FlashData
        
    end %  properties
    
    properties(Access='private')

    end  % properties(Access='private')
    
    properties(Dependent)
        
    end  % properties(Dependent) 
    
    methods
        function obj=StockAll2 % 构造函数
            
        end % StockAll
        
        function DLk2psql_py(obj,startD,endD,if_exist)
            if nargin == 1
                startD='2016-01-01';
                endD=datestr(today,'yyyy-mm-dd');
                if_exist='append';
            elseif nargin == 2
                endD=datestr(today,'yyyy-mm-dd');
                if_exist='append';
            elseif nargin == 3
                if_exist='replace';
            end
            DL_obj=py.py2matlab.DownLode_TS_thread();
            DL_obj.download(startD,endD,if_exist)
        end
        
        function DLreal(obj,check)
            if nargin == 1
               check=0;
            end
            if check==1
                szzs=StockAll.Handicap('sh000001');
                lastDay=szzs.LastTime{:};
                if datenum([lastDay(1:4),'-',lastDay(5:6),'-',lastDay(7:8)])~=today
                    warning('不在交易日，不运行DLreal')
                    obj.FlashData=[];
                    return
                end  
            end
            if isempty(obj.CodeList)
                 tic
                 StockList=obj.StockList; % 下载代码列表
                 toc
                 obj.CodeList=StockList(:,1); % 代码标准化
            end
            %codelist=obj.CodeCheck(obj.CodeList)';
            obj.FlashData=StockAll3.Handicap(obj.CodeList);
            
        end
        
        function psql2mat(obj,type)
            if nargin == 1 | (nargin == 2 & strcmp(type,'py'))
                tic
                py.py2matlab.save_Mat()
                toc
                return
            end
            if nargin == 2 & strcmp(type,'m')
                    connection=database('testDB','postgres','123456','org.postgresql.Driver','jdbc:postgresql://localhost:5432/testDB');
                    curs = exec(connection, 'select distinct code from aa;');
                    row = fetch(curs);
                    code_list = row.Data;

                    query = 'select * from information_schema.columns where table_schema=''public'' and table_name=''aa''; ';
                    curs = exec(connection, query);
                    row = fetch(curs);
                    colume_name=row.Data(:,4);


                    hwait=waitbar(0,'下载K线>>>>>>>>'); % 时间统计开始
                    tic
                    len_CL=length(code_list);
                    for i=1:len_CL
                         code = code_list{i};
                         query=['select * from aa where code=''', code,''';'];
                         curs = exec(connection, query);
                         row = fetch(curs);
                         data=row.Data;
                         %cell2table([cellstr(datestr(data(:,1),'yyyy-mm-dd')),num2cell(data(:,2:end))],'VariableNames',colume_name);


                         store_data=[datenum(data(:,1),'yyyy-mm-dd'),cell2mat(data(:,[2:6,8:end]))];
                         stroe_code=data{1,7};
                         eval([stroe_code,'=store_data;'])
                         DatafileName='Data';
                         if i==1
                                save(['../Data/',DatafileName,'.mat'],stroe_code,'-v6')
                            else
                                save(['../Data/',DatafileName,'.mat'],stroe_code,'-append','-v6')
                         end
                         waitbar(i/len_CL,hwait,['下载K线',code,':  ',num2str(i),'/',num2str(len_CL)]);% 进度条
                    end
                    close(hwait);% 关闭进度条
                    colume_name={'date', 'open', 'close', 'high', 'low', 'volume'}; 
                    save(['../Data/',DatafileName,'.mat'],'colume_name','-append','-v6')

                    toc
                    close(curs)
                    close(connection)
                    return
            end
            error('psql2mat 参数输入不正确，应为 py 或 m，默认（py） ')
        end
        
        function importData(obj,typeList)
            if ismember('k',typeList)
                 if ~exist('../Data/Data.mat')
                     obj.psql2mat
                 end
                 obj.KDataAll=open('../Data/Data.mat');
            end        
            if ismember('r',typeList)
                obj.DLreal
            end
                
        end
        
        function Val=Indicators(obj,type,ParameterList)
            if isempty(obj.KDataAll)
                obj.importData('k');   
            end
            Data=obj.KDataAll;
            fn=fieldnames(Data); % 代码列表
            fnL=length(fn);      % 代码个数
            
            hwait=waitbar(0,'计算指标>>>>>>>>'); % 时间统计开始
            tic
            
            for i=1:fnL % 每个股票循环
                Code=fn{i};
                if Code(1)~='s'
                    continue
                end
                KData=eval(['Data.',Code]);  % 获取当前股票K线数据% 获取代码
                if  isempty(KData)  % 如果K线数据不为空，则输出的第一列为日期
                    outData=[];
                else
                    outData=KData(:,1);
                end
                name={'date'};
                for j=1:length(type) % 循环计算指标
                    switch type{j}
                            case 'MA'
                                Len=ParameterList{j};
                                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                                mai=MAi(FieldData,Len);
                                outData=[outData,mai];
                                name{end+1}=['ma_',num2str(Len)];
                                
                                case 'STD'
                                Len=ParameterList{j};
                                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                                stdi=STDi(FieldData,Len);
                                outData=[outData,stdi];
                                name{end+1}=['std_',num2str(Len)];
                                
                            case 'HHigh'
                                Len=ParameterList{j};
                                FieldData=KData(:,4); % 最高价
                                hhighi=HHighi(FieldData,Len);
                                outData=[outData,hhighi];
                                name{end+1}=['hhigh_',num2str(Len)];
                                
                            case 'LLow'
                                Len=ParameterList{j};
                                FieldData=KData(:,5); % 最低价
                                llowi=LLow(FieldData,Len);
                                outData=[outData,llowi];
                                name{end+1}=['llow_',num2str(Len)];
                                
                            case 'EMA'
                                Len=ParameterList{j};
                                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                                emai=EMAi(FieldData,Len);
                                outData=[outData,emai];
                                name{end+1}=['ema_',num2str(Len)];
                                
                            case 'SMA'
                                Len=ParameterList{j};
                                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                                emai=SMAi(FieldData,Len);
                                outData=[outData,emai];
                                name{end+1}=['sma_',num2str(Len)];
                                
                            case 'MACD'
                                if length(ParameterList{j})~=3
                                    error('MACD 参数个数不对')
                                end
                                LeadLen=ParameterList{j}(1);
                                LagLen=ParameterList{j}(2);
                                DIFFLen=ParameterList{j}(3);
                                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                                macdi=MACDi(FieldData,LeadLen,LagLen,DIFFLen);
                                outData=[outData,macdi];
                                name{end+1}=['diff_',num2str(LeadLen),'_',num2str(LagLen),'_',num2str(DIFFLen)];
                                name{end+1}=['dea_',num2str(LeadLen),'_',num2str(LagLen),'_',num2str(DIFFLen)];
                                name{end+1}=['macd_',num2str(LeadLen),'_',num2str(LagLen),'_',num2str(DIFFLen)];
                                
                            case 'BOLL'
                                if length(ParameterList{j})==1
                                    Len=ParameterList{j}(1);
                                    Width=2;
                                elseif length(ParameterList{j})==2
                                    Len=ParameterList{j}(1);
                                    Width=ParameterList{j}(2);
                                else
                                    error('BOLL 参数个数不对')
                                end   
                                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                                bolli=BOLLi(FieldData,Len,Width);
                                outData=[outData,bolli];
                                name{end+1}=['mid_',num2str(Len),'_',num2str(Width)];
                                name{end+1}=['up_',num2str(Len),'_',num2str(Width)];
                                name{end+1}=['down_',num2str(Len),'_',num2str(Width)];
                                
                            case 'BIAS'
                                if length(ParameterList{j})==1
                                    LeadLen=1;
                                    LagLen=ParameterList{j}(1);
                                elseif length(ParameterList{j})==2
                                    LeadLen=ParameterList{j}(1);
                                    LagLen=ParameterList{j}(2);
                                else
                                    error('BIAS 参数个数不对')
                                end
                                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                                biasi=BIASi(FieldData,LeadLen,LagLen);
                                outData=[outData,biasi];
                                name{end+1}=['bias_',num2str(LeadLen),'_',num2str(LagLen)];
                                
                                
                            case 'KDJ'
                                if length(ParameterList{j})~=3
                                    error('KDJ 参数输入有误')
                                end
                                Len= ParameterList{j}(1);
                                M1=ParameterList{j}(2);
                                M2=ParameterList{j}(3);
                                kdji=KDJi(KData,Len,M1,M2);
                                outData=[outData,kdji];
                                name{end+1}=['k_',num2str(Len),'_',num2str(M1),'_',num2str(M2)];
                                name{end+1}=['d_',num2str(Len),'_',num2str(M1),'_',num2str(M2)];
                                name{end+1}=['j_',num2str(Len),'_',num2str(M1),'_',num2str(M2)];
                                
                                
                            case 'RSI'
                                Len= ParameterList{j};
                                FieldData=KData(:,3); % 收盘价
                                rsii=RSIi(FieldData,Len);
                                outData=[outData,rsii];
                                name{end+1}=['rsi_',num2str(Len)];
                                
                            case 'OBV'
                                
                            case 'LB'
                                if isempty( ParameterList{j})
                                    Len=5;
                                else
                                    Len= ParameterList{j};
                                end
                                FieldData=KData(:,6); % 成交量
                                lbi=LBi(FieldData,Len);
                                outData=[outData,lbi];
                                name{end+1}=['LB_',num2str(Len)];
                                
                            case'SAR'
                                Len= ParameterList{j};
                                sari=SARi(KData,Len);
                                outData=[outData,sari];
                                name{end+1}=['SAR_',num2str(Len)];
                                
                            case 'DMI'
                                if length(ParameterList{j})~=2
                                    error('DMI 参数输入有误')
                                end
                                N= ParameterList{j}(1);
                                M= ParameterList{j}(2);
                                dmii=DMIi(KData,N,M);
                                outData=[outData,dmii];
                                name{end+1}=['pdi_',num2str(N),'_',num2str(M)];
                                name{end+1}=['mdi_',num2str(N),'_',num2str(M)];
                                name{end+1}=['adx_',num2str(N),'_',num2str(M)];
                                name{end+1}=['adxr_',num2str(N),'_',num2str(M)];
                                
                            case 'CCI'
                                Len= ParameterList{j};
                                ccii=CCIi(KData,Len);
                                outData=[outData,ccii];
                                name{end+1}=['cci_',num2str(Len)];
                                
                            case 'PSY'
                                Len= ParameterList{j};
                                FieldData=KData(:,3); % 成交量
                                psyi=PSYi(FieldData,Len);
                                outData=[outData,psyi];
                                name{end+1}=['psy_',num2str(Len)];
                            otherwise
                    end % switch
                    
                end
                eval(['Val.',Code,'=outData;']) %合并到Struct变量中
                Val.name=name;
               % waitbar(i/fnL,hwait,[num2str(i/fnL*100),'%',':',Code,',',num2str(i),'/',num2str(fnL)]);% 进度条
                waitbar(i/fnL,hwait);% 进度条
            end
            close(hwait);% 关闭进度条
            toc
        end
        
        function Val=add_RealData(obj)
            obj.DLreal()
            if ~isempty(obj.FlashData)
                fn=fieldnames(obj.KDataAll); % 代码列表
                fnL=length(fn);
                date=cellfun(@(x) datenum(x(1:8),'yyyymmdd'),table2array(obj.FlashData(:,{'LastTime'})));
                dcell=obj.FlashData(:,{'OpenPrice','RealPrice','High','Low','Volume'});
                d=cellfun(@str2double,table2array(dcell));
                data=[date,d];
                codelist=obj.FlashData.Code;
                hwait=waitbar(0,'计算指标>>>>>>>>'); % 时间统计开始
                tic
                for i=1:fnL % 每个股票循环
                    code=fn{i};
                    d_before=eval(['obj.KDataAll.',code,';']);
                    d_add=data(strcmp(codelist,code),:);
                    d_affter=[d_before;d_add];
                    eval(['Val.',code,'=d_affter;'])
                                        
                    waitbar(i/fnL,hwait);% 进度条
                end
                close(hwait);% 关闭进度条
                toc
             end
                
            
        end
    end %  methods
    
    methods (Access='private')
        
    end % methods (Access='private')
    
    methods (Static)
        function List=StockList % 下载股票代码名称对照表
            % e.g.: List=Stock.StockList
            %----------------------------------------------读取接口数据
            [sourcefile, status] =urlread(sprintf('http://quote.eastmoney.com/stocklist.html'),'Charset','GBK');
            if ~status
                error('读取错误\n')
            end
            %----------------------------------------------分析重组数据
            expr1='<li><a target="_blank" href="http://quote.eastmoney.com/.*?">(.*?)\((\d+)\)</a></li>';
            [~, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
            a=[date_tokens{:}];
            %----------------------------------------------数据输出
            List=[a(2:2:end);a(1:2:end)]';
        end % StockList
        function out=C(in) % 标准化输入代码
            if ~iscell(in) % 转换成为cell数组输入 '600001'转变为{'600001'}输入
                in={in};
            end
            out=[];
                  for i=1:length(in) % 对cell数组中的每一个成员进行遍历操作
                      C=in{i};
                      if ~ischar(C)
                          error('输入必须为字符串')
                      end
                      if  length(C)==6 && (strcmp(C(1),'6') || strcmp(C,'000001')) % 沪市代码
                          out{i}= ['sh',C];
                      elseif length(C)==6 && (strcmp(C(1),'0') || strcmp(C(1),'3')) && ~strcmp(C,'000001') % 深市代码
                          out{i}= ['sz',C];
                      else % 其余按原样输出
                          out{i}=[C];
                      end
                  end
            
        end % CodeCheck
        function info=Handicap(Code)%盘口信息
            Code=Stock.CodeCheck(Code);
            % 腾讯数据接口地址开头
            urlHead='http://qt.gtimg.cn/q=';
            %--------------------------------------------------------------
            sourcefileall=[];
            b=1;
            e=60;% 限制一次读取的代码数量（URL限制）
            len=length(Code); % 代码个数
            hwait=waitbar(0,'请等待>>>>>>>>');
            while b<=len 
                C=strcat(Code(b:min(e,len)),',');
                urlAddress=strcat(urlHead,[C{:}]);
                % 读取网页信息
                [sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
                if ~status
                    error('读取错误\n')
                end
                sourcefileall=[sourcefileall,sourcefile];
                b=b+60;
                e=e+60; 
                waitbar(b/len,hwait,[num2str(b/len*100),'%',':',num2str(b),'/',num2str(len)]);% 进度条
            end
            close(hwait);% 关闭进度条
            expr1='(?<=v_)(.*?)(?=";)';
            [datefile, date_tokens]= regexp(sourcefileall, expr1, 'match', 'tokens');
            sourcefile=[date_tokens{:}]';
            % 逐行提取信息
            S={};
            for i=1:length(sourcefile)
                % 正则表达式(提取关键内容)
                expr1='(?<==")(.*)';
                [datefile, date_tokens]= regexp(sourcefile{i}, expr1, 'match', 'tokens');
                sourcefile2=date_tokens{:};
                % 分割信息
                ss=regexp(sourcefile2, '~', 'split');
                % 组合提取的信息
                if length(ss{:})~=1
                   S(end+1,:)=ss{:};
                end
            end

            % 标题
            Explain={'市场','名字','代码','当前价格','昨收','今开','成交量（手）','外盘','内盘','买一','买一量（手）','买二','买二量（手）','买三'...
                ,'买三量（手）','买四','买四量（手）','买五','买五量（手）','卖一','卖一量（手）','卖二','卖二量（手）','卖三','卖三量（手）'...
                ,'卖四','卖四量（手）','卖五','卖五量（手）','最近逐笔成交','时间','涨跌','涨跌%','最高','最低','价格/成交量（手）/成交额','成交量（手）'...
                ,'成交额（万）','换手率','市盈率','[blank]','最高','最低','振幅','流通市值','总市值','市净率','涨停价','跌停价','[blank]'};
            Name={'Market','Name','Code','RealPrice','YClosePrice','OpenPrice','Volume','B','S','Buy1Price','Buy1Volume','Buy2Price','Buy2Volume','Buy3Price','Buy3Volume','Buy4Price','Buy4Volume','Buy5Price','Buy5Volume','Sell1Price','Sell1Volume','Sell2Price','Sell2Volume','Sell3Price','Sell3Volume','Sell4Price','Sell4Volume','Sell5Price','Sell5Volume','LastTransaction','LastTime','Rise','Yield','HighPrice','LowPrice','Price_Volume_Amount','Volume2','Amount','HSL','PE','State','High','Low','Amplitude','CirculationMarketValue','TotalMarketValue','PB','HardenPrice','LimitPrice','blank2','blank3','blank4','blank5','blank6'};
             
            % 将标题与信息组合
              info=cell2table(S,'VariableNames',Name');
              info.Code=StockAll.CodeCheck(info.Code)';
             
            %--------------------------------------------------------------
        end% Handicap
    end  % methods (Static)
end % classdef