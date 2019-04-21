classdef StockAll<handle
    
    properties
        CodeList
        NameList
        KDataAll
        FlashData
        TempData
    end %  properties
    
    properties(Access='private')
        FindTemp;
    end  % properties(Access='private')
    
    properties(Dependent)
    end  % properties(Dependent) 
    
    methods
        function obj=StockAll % 构造函数
             tic
             StockList=StockAll.StockList; % 下载代码列表
             toc
             SLCode=StockAll.CodeCheck(StockList(:,1))'; % 代码标准化
             obj.CodeList=SLCode(strmatch('s',SLCode));    % 选出沪深两市sh,sz开头的股票代码
%              simpleCode=cellfun(@(x) x(3:end),obj.CodeList,'UniformOutput',0);
%              obj.NameList=StockList(ismember(StockList,simpleCode),2);
        end % StockStatistics
        function type=DownloadData(obj,DataNameList) % 下载数据
            DataNameList=cellstr(DataNameList);
            StandardName={'K','FQ','Flash'};
            L=length(DataNameList);
            if sum(ismember(DataNameList,StandardName))~=L
               error('未有相应数据可下载,请检测输入名称')
            end
            for i=1:L
               DataName = DataNameList{i};
               tic
               switch DataName
                   case 'K' % K 线数据
                       %Year=datestr(today,'yy');
                       info=StockAll.DownloadKData(obj.CodeList,1);
                   case 'FQ' % 复权数据
                       info=StockAll.DownloadFQData(obj.CodeList);         
                   case 'Flash' % 即时盘口数据
                       info=StockAll.Handicap(obj.CodeList);
                   otherwise
                       error(['未有',type,'数据可下载,请检测输入名称'])
               end
               toc
            end
            type=info;
        end % DownloadData
        function ImportData(obj,DatafileList) % 载入数据
            DatafileList=cellstr(DatafileList);
            StandardName={'K','KL','KR','Flash'};
            L=length(DatafileList);
            if sum(ismember(DatafileList,StandardName))~=L
                error('未有相应数据可载入,请检测输入名称')
            end
            for i=1:L
                DatafileName = DatafileList{i};
                tic
                switch DatafileName
                    case 'K'
                       % obj.KDataAll=open('Data.mat')
                       DataBefore=open('DataBefore.mat');
                       DataNew=open('Data.mat');
                       obj.KDataAll=StockAll.unionData(DataNew,DataBefore);
                    case 'KL'
                        obj.KDataAll=StockAll.fq('L');
                    case 'KR'
                        obj.KDataAll=StockAll.fq('R');
                    case 'Flash'
                        obj.FlashData=StockAll.Handicap(obj.CodeList);
                    otherwise
                        error(['没有',DatafileName,'的数据可以导入'])
                end
                toc
            end
            
        end % ImportData
        function Val=Indicators(obj,type,ParameterList) % 批量计算指标
            if isempty(obj.KDataAll)
                obj.ImportData('KL');   
            end
            Data=obj.KDataAll;
            fn=fieldnames(Data); % 代码列表
            fnL=length(fn);      % 代码个数
            hwait=waitbar(0,'计算指标>>>>>>>>'); % 时间统计开始
            tic
            for i=1:fnL % 每个股票循环
                Code=fn{i}                        % 获取代码
                KData=eval(['Data.',Code]);  % 获取当前股票K线数据
                if  isempty(KData)  % 如果K线数据不为空，则输出的第一列为日期
                    outData=[];
                else
                    outData=KData(:,1);
                    
                    for j=1:length(type) % 循环计算指标
                        switch type{j}
                            case 'MA'
                                Len=ParameterList{j};
                                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                                mai=MAi(FieldData,Len);
                                outData=[outData,mai];
                            case 'STD'
                                Len=ParameterList{j};
                                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                                stdi=STDi(FieldData,Len);
                                outData=[outData,stdi];
                            case 'HHigh'
                                Len=ParameterList{j};
                                FieldData=KData(:,4); % 最高价
                                hhighi=HHighi(FieldData,Len);
                                outData=[outData,hhighi];
                            case 'LLow'
                                Len=ParameterList{j};
                                FieldData=KData(:,5); % 最低价
                                llowi=LLow(FieldData,Len);
                                outData=[outData,llowi];
                            case 'EMA'
                                Len=ParameterList{j};
                                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                                emai=EMAi(FieldData,Len);
                                outData=[outData,emai];
                            case 'SMA'
                                Len=ParameterList{j};
                                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                                emai=SMAi(FieldData,Len);
                                outData=[outData,emai];
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
                            case 'KDJ'
                                if length(ParameterList{j})~=3
                                    error('KDJ 参数输入有误')
                                end
                                Len= ParameterList{j}(1);
                                M1=ParameterList{j}(2);
                                M2=ParameterList{j}(3);
                                kdji=KDJi(KData,Len,M1,M2);
                                outData=[outData,kdji];
                            case 'RSI'
                                Len= ParameterList{j};
                                FieldData=KData(:,3); % 收盘价
                                rsii=RSIi(FieldData,Len);
                                outData=[outData,rsii];
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
                            case'SAR'
                                Len= ParameterList{j};
                                sari=SARi(KData,Len);
                                outData=[outData,sari];
                            case 'DMI'
                                if length(ParameterList{j})~=2
                                    error('DMI 参数输入有误')
                                end
                                N= ParameterList{j}(1);
                                M= ParameterList{j}(2);
                                dmii=DMIi(KData,N,M);
                                outData=[outData,dmii];
                            case 'CCI'
                                Len= ParameterList{j};
                                ccii=CCIi(KData,Len);
                                outData=[outData,ccii];
                            case 'PSY'
                                Len= ParameterList{j};
                                FieldData=KData(:,3); % 成交量
                                psyi=PSYi(FieldData,Len);
                                outData=[outData,psyi];
                            otherwise
                        end % switch
                    end
                end
                eval(['Val.',Code,'=outData;']) %合并到Struct变量中
               % waitbar(i/fnL,hwait,[num2str(i/fnL*100),'%',':',Code,',',num2str(i),'/',num2str(fnL)]);% 进度条
                waitbar(i/fnL,hwait);% 进度条
            end
            close(hwait);% 关闭进度条
            toc
        end % Indicators
        function flashTodayK(obj) % 加入当天数据进KDataAll
            if isempty(obj.KDataAll)
                warning('KDataAll数据为空。')
                return
            end
            szzs=StockAll.Handicap('sh000001');
            lastDay=szzs.LastTime{:};
            if datenum([lastDay(1:4),'-',lastDay(5:6),'-',lastDay(7:8)])~=today
                warning('不在交易日，不运行flashTodayK')
                return
            end
            obj.ImportData('Flash');  % 下载最新盘口数据
         
         
             CodeAll=obj.FlashData.Code;
             DateAll=cellfun(@(x) datenum([x(1:4),'-',x(5:6),'-',x(7:8)],'yyyy-mm-dd'),obj.FlashData.LastTime);
             CloseAll=str2double(obj.FlashData.RealPrice);
             OpenAll=str2double(obj.FlashData.OpenPrice);
             LowAll=str2double(obj.FlashData.Low);
             HighAll=str2double(obj.FlashData.High);
             VolumeAll=str2double(obj.FlashData.Volume);    
             
             StateAll=containers.Map(CodeAll,cellfun(@(x) isempty(x),obj.FlashData.State));
             DataAll=containers.Map(CodeAll,mat2cell([DateAll,OpenAll,CloseAll,HighAll,LowAll,VolumeAll],ones(length(CodeAll),1),6));
             
            fn=fieldnames(obj.KDataAll);
            L=length(fn);
            hwait=waitbar(0,'合并当天数据>>>>>>>>');
            tic
            for i=1:L
                 Code=fn{i};
                 Data=DataAll(Code);
                 if Data(1)<=today && StateAll(Code)==1 && eval(['obj.KDataAll.',Code,'(end,1)<Data(1)'])
                      DataToday=Data;
                     eval(['obj.KDataAll.',Code,'(end+1,:)=DataToday;'])
                 end
                  waitbar(i/L,hwait)
%                waitbar(i/L,hwait,[num2str(i/L*100),'%; ',num2str(i),'/',num2str(L)]);% 进度条(费时间)
            end
            toc
            close(hwait)
        end
        function Val=gtyx(obj) % 寻找光头阳线
            obj.ImportData('Flash');  % 下载最新盘口数据
            FlashData=obj.FlashData; % 载入最新盘口数据
            RealPrice=str2double(FlashData.RealPrice); % 最新价格
            High=str2double(FlashData.High);           % 最高价格
            Yield=str2double(FlashData.Yield);         % 当日收益率
            HardenPrice=str2double(FlashData.HardenPrice); % 当日涨停价
            Val= sortrows(FlashData((RealPrice==High & RealPrice~=0 & Yield>0 & RealPrice<HardenPrice),{'Code','Name','RealPrice','High','Yield'}),'Yield');
        end %gtyx
        function Val=Find(obj,funName,propertie,option) % 通用查找函数
            if nargin==3
                option=[];
            end
            if isempty(obj.KDataAll)
                obj.ImportData('KL')
            end
            if obj.KDataAll.sh000001(end,1)<today-1
                startDay=obj.KDataAll.sh000001(end,1)+1;
                endDay=today;
                szzsK=StockAll.HistoryK('sh000001',startDay,endDay);
                if ~isempty(szzsK.sh000001)
                    error('K线数据不全，请先补齐数据');
                end
            end
            szzs=StockAll.Handicap('sh000001');
            if obj.KDataAll.sh000001(end,1)<today && isempty(szzs.State{:})
                obj.flashTodayK;
            end   
            indName=eval(['obj.',funName,'(''indName'');']);
            indDataAll=obj.Indicators(indName,{propertie});
            fn=fieldnames(indDataAll);
            L=length(fn);
            out=[];
            tic
            hwait=waitbar(0,'寻找股票>>>>>>>>'); % 时间统计开始            
            for i=1:L
                Code=fn{i};
                obj.FindTemp=Code;
                indData=eval(['indDataAll.',Code,';']);
                eval(['obj.',funName,'(indData,option);'])
                if eval(['obj.',funName,'(indData,option);'])==1
                    out=[out;Code];
                end;
                waitbar(i/L,hwait);% 进度条
            end
            close(hwait)
            toc
             % 去掉停牌的股票
             if ~isempty(out)
                 out=StockAll.Handicap(cellstr(out));
                 out=out(strcmp(out.State,''),:);
             end
            Val=out;
      
        end
    end %  methods
    
    methods (Access='private')
        function Val=MaCross(obj,propertie,option)
            if nargin==3 && ~ismember(option,[-1,1])
                error('option是输入格式有误')
            end                    
            if isempty(propertie)
                Val=0;
                return
            end
            if ischar(propertie) && strcmp(propertie,'indName')
               Val={'MA'};
               return
            end
            Val=0;
            if isa(propertie,'double')
                ma=propertie;
                if option==1 && size(ma,1)>=2 && ma(end-1,2)<ma(end-1,3) && ma(end,2)>=ma(end,3)
                    Val=1;
                elseif option==-1 && size(ma,1)>=2 && ma(end-1,2)>ma(end-1,3) && ma(end,2)<=ma(end,3)
                else
                    Val=0;
                end                
            end
            
        end
        function Val=BollBreak(obj,propertie,option)
            if nargin==3 && ~ismember(option,[-1,1])
                error('option是输入格式有误')
            end           
            if isempty(propertie)
                Val=0;
                return
            end
            if ischar(propertie) && strcmp(propertie,'indName')
               Val={'BOLL'};
               return
            end  
            Val=0;
            if isa(propertie,'double')
                bollmid=propertie(:,2);
                bollup=propertie(:,3);
                bolldown=propertie(:,4);
                Close=eval(['obj.KDataAll.',obj.FindTemp,'(:,3);']);   
                
                if size(Close,1)>1
                    if option==1 && Close(end)>bollup(end) && Close(end-1)<bollup(end-1)
                        Val=1;
                    elseif option==-1 && Close(end)<bolldown(end) && Close(end-1)>bolldown(end-1)
                        Val=1;
                    else
                        Val=0;
                    end
                end  
            end            
        end
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
        function out=CodeCheck(in) % 标准化输入代码
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
        function info=DownloadKData(CodeList,Y,thisYear)% 批量下载K线数据
            %-------------------------------------
            CodeList=Stock.CodeCheck(CodeList); % 代码输入标准化
            hwait=waitbar(0,'请等待>>>>>>>>');
            L=length(CodeList);
            blankdata=[];
            if nargin==2
                thisYear=str2num(datestr(today,'yy'));
            end
            if thisYear==str2num(datestr(today,'yy'));
                DatafileName='Data';
            else
                DatafileName='DataBefore';
            end
            for i=1:L % 对每一个代码遍历操作
                
                Code=CodeList{i};
                ValAll=[];
                for j=Y-1:-1:0 %每一个年份
                    %---------------------------------------读取接口信息
                    Year=num2str(thisYear-j);
                    url=['http://data.gtimg.cn/flashdata/hushen/daily/',Year,'/',Code,'.js?maxage=43201'] % 腾讯日K线数据
                    % 读取网页信息
                    [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                    if ~status
                        continue;
                    end
                    %---------------------------------------分析重组接口信息
                    Val=regexp(sourcefile, '[\s\n\\]', 'split')';
                    Val=[Val(4:8:end-3),Val(5:8:end-3),Val(6:8:end-3),Val(7:8:end-3),Val(8:8:end-3),Val(9:8:end-3)];
                    ValAll=[ValAll;Val];
                end
                if ~isempty(ValAll)
                    ValAll(:,1)=cellfun(@(x) [x(3:4),'/',x(5:6),'/',x(1:2)],ValAll(:,1),'UniformOutput',false);
                    % ValAll=[ValAll(:,1),num2cell(str2double(ValAll(:,2:6)))]; % cell输出储存
                       ValAll=[datenum(ValAll(:,1)),str2double(ValAll(:,2:6))];  %全数字输出储存                     
                    % eval([Code,'.K=ValAll;'])
                    
                    eval([Code,'=ValAll;'])
                    if i==1
                        save([DatafileName,'.mat'],Code,'-v6')
                    else
                        save([DatafileName,'.mat'],Code,'-append','-v6')
                    end
                else
                    blankdata=[blankdata;Code];
                end
                
                %------------------------------将信息存储在以Struct变量中，代码为字段名
                % eval(['info.',Code,'.K=Val;']);

                waitbar(i/length(CodeList),hwait,[num2str(i/length(CodeList)*100),'%',':',num2str(CodeList{i}),',',num2str(i),'/',num2str(length(CodeList))]);% 进度条

                info=blankdata;
            end
                close(hwait);% 关闭进度条
        end %DownloadKData
        function info=DownloadFQData(CodeList) % 批量下载复权数据
            %-------------------------------------
            CodeList=Stock.CodeCheck(CodeList); % 代码输入标准化
            hwait=waitbar(0,'请等待>>>>>>>>');
            L=length(CodeList);
            for i=1:L % 对每一个代码遍历操作
                %---------------------------------------读取接口信息
                Code=CodeList{i};
                Val=[];
                url=['http://data.gtimg.cn/flashdata/hushen/fuquan/',Code,'.js?maxage=6000000']
                % 读取网页信息
                [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                if ~status
                    Val=[];
                else
                    expr1='(?<=["~^])([\d.]+)(?=["~])';
                    [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
                    Val=[date_tokens{:}]';
                    t=cell2mat(cellfun(@(x) datenum([x(:,1:4),'/',x(5:6),'/',x(7:8)]),Val(1:3:end),'UniformOutput' ,false));
                    Val=[t,str2double([Val(2:3:end),Val(3:3:end)])];
                end
                eval([Code,'=Val;'])
                if i==1
                    save('fq.mat',Code,'-v6')
                else
                    save('fq.mat',Code,'-append','-v6')
                end
                waitbar(i/length(CodeList),hwait,[num2str(i/length(CodeList)*100),'%',':',num2str(CodeList{i}),',',num2str(i),'/',num2str(length(CodeList))]);% 进度条
            end
            info=1;
            close(hwait);% 关闭进度条
        end %DownlodeFQDate
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
            for i=1:length(sourcefile)
                % 正则表达式(提取关键内容)
                expr1='(?<==")(.*)';
                [datefile, date_tokens]= regexp(sourcefile{i}, expr1, 'match', 'tokens');
                sourcefile2=date_tokens{:};
                % 分割信息
                ss=regexp(sourcefile2, '~', 'split');
                % 组合提取的信息
                S(i,:)=ss{:};
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
        function info=fq(type) % 批量复权
            % tic;KDataAll=open('Data.mat');toc
            DataBefore=open('DataBefore.mat');
            DataNew=open('Data.mat');
            KDataAll=StockAll.unionData(DataNew,DataBefore);
            tic;fqDataAll=open('fq.mat');toc
            
            fieldK=fieldnames(KDataAll);
            fieldFQ=fieldnames(fqDataAll);
            LfieldK=size(fieldK,1);
            hwait=waitbar(0,'复权>>>>>>>>');
            for i=1: LfieldK
                Code=fieldK{i};
                if isempty(strmatch(Code,fieldFQ))
                    eval(['KDataAll',type,'.',Code,'=KDataAll.',Code,';'])
                else
                   % KData=eval(['KDataAll.',Code,'.K;']);
                    KData=eval(['KDataAll.',Code]);
                    %KData=[datenum(KData(:,1)),cell2mat(KData(:,2:end))];
                    fqData=eval(['fqDataAll.',Code,';']);
                    if ~isempty(fqData)
                        fqData(:,3)=cumprod(fqData(:,3));
                    end
                    switch type
                        case 'L'
                            for j=1:size(fqData,1)
                                if j==1
                                    dayi=KData(:,1)<fqData(j);
                                else
                                    dayi=KData(:,1)<fqData(j) & KData(:,1)>=fqData(j-1);
                                end
                                KData(dayi,2:end-1)=KData(dayi,2:end-1)*fqData(j,2);
                            end
                            
                        case 'R'
                            %--------------------------------
                            
                            for j=1:size(fqData,1)
                                if j==size(fqData,1)
                                    dayi=KData(:,1)>=fqData(j);
                                else
                                    dayi=KData(:,1)>=fqData(j) & KData(:,1)<fqData(j+1);
                                end
                                KData(dayi,2:end-1)=KData(dayi,2:end-1)*fqData(j,3);
                            end
                            %--------------------------------
                        otherwise
                    end
                    eval(['info.',Code,'=KData;'])
                    %KData=[cellstr(datestr(KData(:,1),'yyyy-mm-dd')),num2cell(KData(:,2:end))];
                    % eval(['KDataAll',type,'.',Code,'=KData;']);
%                     if i==1
%                         save(['KData',type,'.mat'],Code,'-v6')
%                     else
%                         save(['KData',type,'.mat'],Code,'-append','-v6')
%                     end
                end
                % waitbar(i/LfieldK,hwait,[num2str(i/LfieldK*100),'%',':',num2str(fieldK{i}),',',num2str(i),'/',num2str(LfieldK)]);% 进度条
                 waitbar(i/LfieldK,hwait);% 进度条
            end
            
            close(hwait);% 关闭进度条
        end % fq
        function info=unionData(DataNew,DataBefore) % 批量合并数据
            fn=fieldnames(DataNew);
            L=length(fn);
            %hwait=waitbar(0,'请等待>>>>>>>>');
            tic
            for i=1:L
                
                Code=fn{i};
                if isfield(DataBefore,Code)
                    eval(['Data.',Code,'=[DataBefore.',Code,';DataNew.',Code,'];'])
                else
                    eval(['Data.',Code,'=DataNew.',Code,';'])
                end
                %waitbar(i/L,hwait)
            end
            toc
            %close(hwait);% 关闭进度条
            info=Data;
        end % unionData
        function info=HistoryK(CodeList,BeginDate,EndDate) % 多股票K线数据输出
            %e.g. Stock.HistoryK('600123','2015-01-01','2015-01-31')
            %e.g. Stock.HistoryK({'600123','000523'},'2015-01-01','2015-01-31')
            % 输出为Struct变量，字段名为代码，数据为Cell形式
            
            %-------------------------------------
            CodeList=Stock.CodeCheck(CodeList); % 代码输入标准化
            % ------------------------------------日期输入标准化
            BeginDate=datestr(BeginDate,'yyyymmdd');
            EndDate=datestr(EndDate,'yyyymmdd');
            hwait=waitbar(0,'请等待>>>>>>>>');
            L=length(CodeList);
            for i=1:L % 对每一个代码遍历操作
                tic
                Code=CodeList{i};
                %---------------------------------------读取接口信息
                url=['http://biz.finance.sina.com.cn/stock/flash_hq/kline_data.php?symbol=',Code,'&end_date=',EndDate,'&begin_date=',BeginDate] % 新浪K线数据
                % 读取网页信息
                [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                if ~status
                    error('读取错误\n')
                end
                toc
                %---------------------------------------分析重组接口信息
                tic
                expr1='(?<=[dohclv])="(.*?)" ';
                [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
                Val=[date_tokens{:}];
                toc
                %---------------------------------------分析重组接口信息
                tic
                Name={'Date','Open','High','Close','Low','Volume'};
                if ~isempty(Val)
                    Val=reshape(Val,7,length(Val)/7)';
                    %Val=[Val(:,1),num2cell(str2double(Val(:,2:6)))];
                    Val=cell2table([Val(:,1),num2cell(str2double(Val(:,2:6)))],'VariableNames',Name);
                end
                %------------------------------将信息存储在以Struct变量中，代码为字段名
                eval(['info.',Code,'=Val;']);
                toc
                waitbar(i/length(CodeList),hwait,[num2str(i/length(CodeList)*100),'%',':',num2str(CodeList{i}),',',num2str(i),'/',num2str(length(CodeList))]);% 进度条
                
            end
            close(hwait);% 关闭进度条
        end % HistoryK
    end  % methods (Static)
end % classdef

