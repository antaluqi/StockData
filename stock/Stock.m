classdef Stock<handle

    
    properties
        %------------------------------基本信息
        Code        % 股票代码
        Name       % 股票名称
        State        % 股票状态
        LastTime % 最后数据更新时间
        %------------------------------价格信息
        RealPrice %实时价格
        YClosePrice % 昨收
        OpenPrice   %今开
        High % 最高
        Low  % 最低
        HardenPrice % 涨停价
        LimitPrice % 跌停价
        %------------------------------涨跌幅度
        Rise          %涨跌金额
        Yield         %涨跌幅度%
        Amplitude %振幅 
        %-------------------------------成交情况
        Volume    %成交手
        Amount    %成交金额
        %-------------------------------市值
        CirculationMarketValue%流通市值
        TotalMarketValue   %总市值
        %-------------------------------一些简单指标
        PE %  市盈率
        PB %  市净率
        HSL% 换手率 
        %-------------------------------资金面
        MInflow              % 主力流入
        MOutflow           % 主力流出
        MNetInflow        % 主力净流入
        MNetInflow_Total % 主力净流入/流入流出总资金
        RInflow              % 散户流入
        ROutflow           % 散户流出
        RNetInflow        % 散户净流入
        RNetInflow_Total % 散户净流入/流入流出总资金
        TotalFund          % 流入流出总金额
        %--------------------------------大小单
        BuyLargeQuantity % 大单买入占比
        BuySmallQuantity % 小单买入占比
        SellLargeQuantity % 卖出大单占比
        SellSmallQuantity % 卖出小单占比
    end % properties
    
    %properties(Access='private')
    properties(Hidden)
        stold
        edold
        st
        ed
    end  % properties(Access='private')
    
    properties(Dependent)
    end  % properties(Dependent)
    
    methods
        %---------------------------------------------------------------------------------------------------------------------------------------
         function obj=Stock(Code,varargin)  % 构造函数 
             addpath([cd,'\pytdx']);
             % e.g.  S=Stock('sh600123')
             % e.g.  S=Stock('600123')
             % e.g.  S=Stock('lhkc')
             % e.g.  S=Stock('sh600123','Flash')
             %---------------------------------------------------------------------
              obj.Code=Code;
             if nargin == 2                 % 'Flash'：在建立对象的时候获取基本交易信息
                 if strcmp(varargin{1},'Flash')
                     obj.Flash;
                 else
                     error('输入只能为Flash')
                 end
             end
         end % Stock
         function set.Code(obj,value)
             try      % 两个Code转换接口测试(可以以拼音输入，但速度会减慢)
                 S=Stock.Py2Code(value);
                 Code=S(1);
             catch
                 Code=Stock.CodeCheck(value);    % 代码标准化
             end
             %        Code=Stock.CodeCheck(Code);    % 代码标准化（单独留出代码以备加速使用）
             obj.Code=cell2mat(Code);       % 代码
             info=Stock.QuickInfo(obj.Code);% 获取基本信息
             obj.Name=info{1,2};            % 名字
         end
        %--------------------------------------------------------------------------------------------------------------------------------------- 
         function Val=Block(obj) % 股票所属板块(包括地域，行业，概念)
             %-----------------------------------读取接口信息
             url=['http://ifzq.gtimg.cn/stock/relate/data/plate?code=',obj.Code,'&_var=_IFLOAD_2']; % 股票所属板块 后面的&_var=_IFLOAD_2 似乎用不到
             [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
             if ~status
                 error('读取错误\n')
             end
             %-----------------------------------分析重组接口信息
             expr1='"code":"(.*?)","name":"(.*?)"'; % json 的正则表达式
             [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
             BlockCode=[[date_tokens{:}]']';
             BlockCode=BlockCode(1:2:end)';
             %-------------------------------------将读取的版块代码用Stock.BlockInfo函数获取基本信息
             Val=Stock.BlockInfo(BlockCode);
         end % Block
         function Val=RelatedStock(obj) % 关联股票
             %-----------------------------读取接口数据
             url=['http://ifzq.gtimg.cn/stock/relate/data/relate?code=',obj.Code,'&_var=_IFLOAD_1']
             [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
             if ~status
                 error('读取错误\n')
             end
             %-----------------------------分析重组接口数据
             expr1='([shz]{2}\d{6})';
             [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
             Code=[date_tokens{:}]';
             %------------------------------读取列表股票的基本盘口信息
             Val=Stock.QuickInfo(Code);
         end % RelatedStock
         %---------------------------------------------------------------------------------------------------------------------------------------
         function Flash(obj) % 更新盘口数据
             info=Stock.Handicap(obj.Code);
                  %---------------------------------------基本盘口数据刷新
                  obj.RealPrice=str2double(info{1,{'RealPrice'}}); % 最新价格
                  obj.Rise=str2double(info{1,{'Rise'}});           % 涨跌额 
                  obj.Yield=str2double(info{1,{'Yield'}});         % 涨跌幅
                  obj.Volume=str2double(info{1,{'Volume'}});       % 成交手 
                  obj.Amount=str2double(info{1,{'Amount'}});       % 成交额
                  obj. TotalMarketValue=str2double(info{1,{'TotalMarketValue'}}); % 总市值
                  obj.State=info{1,{'State'}};% 状态
                  t=info.LastTime{:};
                  obj.LastTime=[t(1:4),'-',t(5:6),'-',t(7:8),' ',t(9:10),':',t(11:12),':',t(13:end)];
                  
                  
                  obj.YClosePrice=str2double(info{1,{'YClosePrice'}}); % 昨收
                  obj.OpenPrice=str2double(info{1,{'OpenPrice'}});     % 今开
                  obj.High=str2double(info{1,{'High'}});               % 最高
                  obj.Low=str2double(info{1,{'Low'}});                 % 最低
                  obj.HardenPrice=str2double(info{1,{'HardenPrice'}}); % 涨停价
                  obj.LimitPrice=str2double(info{1,{'LimitPrice'}});   % 跌停价
                  
                  obj.Amplitude=str2double(info{1,{'Amplitude'}});     % 振幅
                  obj.CirculationMarketValue=str2double(info{1,{'CirculationMarketValue'}}); % 流通市值
                  obj.PE=str2double(info{1,{'PE'}});  % 市盈率
                  obj.PB=str2double(info{1,{'PB'}});  % 市净率
                  obj.HSL=str2double(info{1,{'HSL'}});% 换手率
                  
                  
         info=Stock.Fund(obj.Code);
                  %-------------------------------资金面数据刷新
             if ~isempty(info)    % 有些如大盘指数等的没有资金面数据
                  obj.MInflow=str2double(info{1,{'MInflow'}});                  % 主力资金流入
                  obj.MOutflow=str2double(info{1,{'MOutflow'}});                % 主力资金流出
                  obj. MNetInflow=str2double(info{1,{'MNetInflow'}});           % 主力资金净流入
                  obj.MNetInflow_Total=str2double(info{1,{'MNetInflow_Total'}});% 主力资金净流入/总进出资金
                  obj.RInflow=str2double(info{1,{'RInflow'}});                  % 散户资金流入
                  obj.ROutflow=str2double(info{1,{'ROutflow'}});                % 散户资金流出
                  obj. RNetInflow=str2double(info{1,{'RNetInflow'}});           % 散户资金净流入
                  obj.RNetInflow_Total=str2double(info{1,{'RNetInflow_Total'}});% 散户资金净流入/总资金进出
                  obj.TotalFund=str2double(info{1,{'TotalFund'}});              % 总进出资金
             end
         info=Stock.HandicapAnalysis(obj.Code);
                  %--------------------------------大小单数据刷新
                  obj.BuyLargeQuantity=str2double(info{1,{'BuyLargeQuantity'}});  % 大单买入占比
                  obj.BuySmallQuantity=str2double(info{1,{'BuySmallQuantity'}});  % 大单卖出占比
                  obj.SellLargeQuantity=str2double(info{1,{'SellLargeQuantity'}});% 小单买入占比
                  obj.SellSmallQuantity=str2double(info{1,{'SellSmallQuantity'}});% 小单卖出占比

         end % Flash   
         function Val=RealTick(obj) % 当天逐笔交易数据？？
             %-----------------------------------------------读取接口数据
             url=['http://vip.stock.finance.sina.com.cn/quotes_service/view/CN_TransListV2.php?num=90000&symbol=',obj.Code];
             [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
             if ~status
                 error('读取错误\n')
             end
             %-----------------------------------------------分析重组接口数据
             expr1='(?<='')([\d:A-Z\.]+)(?='')';
             [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
             Val=[date_tokens{:}];
             Val=reshape(Val,4,length(Val)/4)';
             Val=[Val(:,1),num2cell(str2double(Val(:,2:3))),Val(:,4)];
             %-----------------------------------------------转换成Table数据
             Name={'Time','Volume','Price','Direction'};
             Val=cell2table(Val(end:-1:1,:),'VariableNames',Name)
         end % RealTick
         function Val=HistoryTick2(obj,Date) %历史逐笔交易
             %-----------------------------------------读取接口数据
             url=['http://stock.gtimg.cn/data/index.php?appn=detail&action=download&c=',obj.Code,'&d=',datestr(Date,'yyyymmdd')];           
             % 读取网页信息
             [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
             if ~status
                 error('读取错误\n')
             end
             Val=regexp(sourcefile, '[\n\t]', 'split');
             Val=reshape(Val(7:end),6,length(Val(7:end))/6)';
             Name={'Time','Price','P_Change','Volume','Amount','Direction'};
             Val=cell2table([Val(:,1),num2cell(str2double(Val(:,2:5))),Val(:,6)],'VariableNames',Name);

         end % 腾讯
         function Val=HistoryTick(obj,Date)
             if obj.Code(1:2)=='sh'
                 market=1;
             else
                 market=0;
             end
             code=obj.Code(3:end);
             date=str2num(datestr(Date,'yyyymmdd'));
             value=get_history_minute_time_data(market,code,date);
             Name={'Price','Volume'};
             Val=cell2table(num2cell(value),'VariableNames',Name);
             
         end
         
         function Val=Real1m(obj) % 实时1分钟数据
             %---------------------------------------读取接口数据
             url=['http://data.gtimg.cn/flashdata/hushen/minute/',obj.Code,'.js?maxage=10&0.9551210514741698'] % 腾讯当日1分钟数据接口
             [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
             if ~status
                 error('读取错误\n')
             end
             %---------------------------------------分析重组接口数据
             expr1='([\.\d]+)'
             [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
             Val=[date_tokens{:}]';
             Val=[Val(2:3:end),num2cell(str2double(Val(3:3:end))),num2cell(str2double(Val(4:3:end)))];
             %---------------------------------------组合成Table数据
             Name={'Time','Price','Volume'};
             Val=cell2table(Val,'VariableNames',Name);
              Val.Volume=[Val.Volume(1);diff(Val.Volume)];
             end % Real1m
         function Val=NewlyData(obj, Scale) % 最近 5 15 30 60 分钟h和周线、月线数据
             % e.g.:  Stock.NewlyData(5) 
             % e.g.:  Stock.NewlyData('w') 
             %------------------------------------------参数输入限定
             if Scale~=5 & Scale~=15 & Scale~=30 & Scale~=60 & Scale~='w' & Scale~='m'
                 error('必须为数字5、15、30、60或者字符w和m')
             end
             
             if ~isstr(Scale) % 5 15 30 60 分钟数据接口
                 %------------------------------------------读取接口信息（5 15 30 60 分钟）
                 Scale=num2str(Scale);
                 url=['http://money.finance.sina.com.cn/quotes_service/api/json_v2.php/CN_MarketData.getKLineData?symbol=',obj.Code,'&scale=', Scale,'&ma=no&datalen=1023'];
                 % 读取网页信息
                 [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                 if ~status
                     error('读取错误\n')
                 end
                 %------------------------------------------分析重组接口信息（5 15 30 60 分钟）
                 expr1='(?<=[ynhwe]):"(.*?)"';
                 [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
                 Val=[date_tokens{:}];
                 Val=reshape(Val,6,length(Val)/6)';
                 %------------------------------------------转换成Table数据（5 15 30 60 分钟）
                 Name={'Time','Open','High','Low','Close','Volume'};
                 Val=cell2table([Val(:,1),num2cell(str2double(Val(:,2:end)))],'VariableNames',Name);
             else % week month 数据接口
                 %------------------------------------------读取接口信息（week month）
                 if Scale=='w'
                     Scale='weekly';
                 else
                     Scale='monthly';
                 end
                 url=['http://data.gtimg.cn/flashdata/hushen/',Scale,'/',obj.Code,'.js?']; %  腾讯周线 月线数据接口
                 % 读取网页信息
                 [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                 if ~status
                     error('读取错误\n')
                 end
                 %------------------------------------------分析重组接口信息（week month）
                 Val=regexp(sourcefile, '[\n\s\\]', 'split');
                 Val=reshape(Val(4:end-1),8,length(Val(4:end-1))/8)';
                 Val(:,1)=cellfun(@(x) strcat(x(5:6),'/',x(3:4),'/',x(1:2)),Val(:,1),'UniformOutput',0);% 时间结构转换
                 %------------------------------------------转换成Table数据（week month）
                 Name={'Time','Open','High','Low','Close','Volume'};
                 Val=cell2table([Val(:,1),num2cell(str2double(Val(:,2:end-2)))],'VariableNames',Name);
             end
             
             
         end % NewlyData
         function Val=PriceList(obj,BeginDate,EndDate) % 阶段分价表
             % e.g.: Stock.PriceList('2015-09-01','2015-09-10')
             %------------------------------------------读取接口数据
             url=['http://market.finance.sina.com.cn/pricehis.php?symbol=',obj.Code,'&startdate=',BeginDate,'&enddate=',EndDate];
             % 读取网页信息
             [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
             if ~status
                 error('读取错误\n')
             end
             %------------------------------------------分析重组接口数据
             expr1='(?<=<tbody>)(.*?)(?=</tbody>)';
             [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
             
             if ~isempty(date_tokens) % 判断是否读取空
                 sourcefile=date_tokens{:}{:};
                 expr1='(?<=<td>)(.*?)(?=</td>)';
                 [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
                 Val=[date_tokens{1:3:end};date_tokens{2:3:end};date_tokens{3:3:end}]';
                 Val=[num2cell(str2double(Val(:,1:2))),num2cell(str2double(strrep(Val(:,3),'%','')))];
                 %------------------------------------------转换为Table数据类型
                 Name={'Price','Volume','Percent'};
                 Val=cell2table(Val,'VariableNames',Name); 
             else
                 Val=[];
             end
             
             
             
         end % PriceList
         
         function Val=HistoryDaily2(obj,BeginDate,EndDate)% 历史日线交易
             %----------------------------------------日期格式输入转换
             BeginDateF=datestr(BeginDate,'yyyy-mm-dd');
             EndDateF=datestr(EndDate,'yyyy-mm-dd');
              connection=database('testDB','postgres','123456','org.postgresql.Driver','jdbc:postgresql://localhost:5432/testDB');
              query = ['select date,open,high,close,low,volume from aa where code=''',obj.Code,''' and date>=''',BeginDateF,''' and date<=''',EndDateF,''''];
              curs = exec(connection, query);
              row = fetch(curs);
              Val=row.Data(:,1:end);
              Val=[datenum(Val(:,1)),cell2mat(Val(:,2:end))];
              close(connection)
             %-------------------------------------加入当日变动数据
             if datenum(EndDate)>=today && datenum(Val(end,1))<today && ~strcmp(obj.State,'S')
                 obj.Flash;
                 if datenum(obj.LastTime)>=today && datenum(obj.LastTime)>datenum(Val(end,1))
                     TodayK=[today,obj.OpenPrice,obj.High,obj.RealPrice,obj.Low,obj.Volume];
                     Val=[Val;TodayK];
                 end
             end
             name={'Date','Open','High','Close','Low','Volume'};
             Val=cell2table([cellstr(datestr(Val(:,1),'yyyy-mm-dd')),num2cell(Val(:,2:end))],'VariableNames',name);
         end %Postsql
         function Val=HistoryDaily3(obj,BeginDate,EndDate)% 历史日线交易
             BeginDateF=datestr(BeginDate,'yyyy-mm-dd');
             EndDateF=datestr(EndDate,'yyyy-mm-dd');
             date_len=datenum(EndDateF,'yyyy-mm-dd')-datenum(BeginDateF,'yyyy-mm-dd');
             url=['http://web.ifzq.gtimg.cn/appstock/app/fqkline/get?_var=kline_dayqfq&param=',obj.Code,',day,',BeginDateF,',',EndDateF,',',num2str(date_len),',qfq&r=',num2str(rand)]
             [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
             if ~status
                 error('读取错误\n')
             end
             jsonStruct=jsondecode(sourcefile(14:end));
             fn=eval(['fieldnames(jsonStruct.data.',obj.Code,');']);
             celldata=eval(['jsonStruct.data.',obj.Code,'.',fn{1},';']);
             dateArr=cellfun(@(x) datenum(x{1},'yyyy-mm-dd'),celldata);
             d=cell2mat(cellfun(@(x) [str2num(x{2}),str2num(x{4}),str2num(x{3}),str2num(x{5}),str2num(x{6})],celldata,'UniformOutput', false));
             Val=[dateArr,d];
             %-------------------------------------加入当日变动数据
             if datenum(EndDate)>=today && datenum(Val(end,1))<today && ~strcmp(obj.State,'S')
                 obj.Flash;
                 if datenum(obj.LastTime)>=today && datenum(obj.LastTime)>datenum(Val(end,1))
                     TodayK=[today,obj.OpenPrice,obj.High,obj.RealPrice,obj.Low,obj.Volume];
                     Val=[Val;TodayK];
                 end
             end
             name={'Date','Open','High','Close','Low','Volume'};
             Val=cell2table([cellstr(datestr(Val(:,1),'yyyy-mm-dd')),num2cell(Val(:,2:end))],'VariableNames',name);
         end %ifeng数据
         function Val=HistoryDaily(obj,BeginDate,EndDate)% 历史日线交易
             BeginDateF=datestr(BeginDate,'yyyy-mm-dd');
             EndDateF=datestr(EndDate,'yyyy-mm-dd');
             date_len=min(datenum(EndDateF,'yyyy-mm-dd')-datenum(BeginDateF,'yyyy-mm-dd'),800);
             ed=min(datenum(BeginDateF,'yyyy-mm-dd')+800,datenum(EndDateF,'yyyy-mm-dd'));
             celldata=[];
             while 1
                  url=['http://web.ifzq.gtimg.cn/appstock/app/fqkline/get?_var=kline_dayfq&param=',obj.Code,',day,',BeginDateF,',',datestr(ed,'yyyy-mm-dd'),',',num2str(date_len),',fq&r=',num2str(rand)];
                 [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                 if ~status
                     error('读取错误\n')
                 end
                 jsonStruct=jsondecode(sourcefile(13:end));
                 fn=eval(['fieldnames(jsonStruct.data.',obj.Code,');']);
                 celldata=[celldata;eval(['jsonStruct.data.',obj.Code,'.',fn{1},';'])];
                 if ed>=datenum(EndDateF,'yyyy-mm-dd')
                     break
                 else
                     BeginDateF=datestr(ed+1,'yyyy-mm-dd');
                     ed=min(ed+800,datenum(EndDateF,'yyyy-mm-dd'));
                 end
             end
             dateArr=cellfun(@(x) datenum(x{1},'yyyy-mm-dd'),celldata);
             d=cell2mat(cellfun(@(x) [str2num(x{2}),str2num(x{4}),str2num(x{3}),str2num(x{5}),str2num(x{6})],celldata,'UniformOutput', false));
             Val=[dateArr,d];
             %-------------------------------------加入当日变动数据
             if datenum(EndDate)>=today && datenum(Val(end,1))<today && ~strcmp(obj.State,'S')
                 obj.Flash;
                 if datenum(obj.LastTime)>=today && datenum(obj.LastTime)>datenum(Val(end,1))
                     TodayK=[today,obj.OpenPrice,obj.High,obj.RealPrice,obj.Low,obj.Volume];
                     Val=[Val;TodayK];
                 end
             end
             Val=obj.fuquan(Val,'L');
             
             name={'Date','Open','High','Close','Low','Volume'};
             Val=cell2table([cellstr(datestr(Val(:,1),'yyyy-mm-dd')),num2cell(Val(:,2:end))],'VariableNames',name);
             Val.Date=datetime(Val.Date);
             Val=table2timetable(Val,'RowTimes','Date');
         end %ifeng数据
         %---------------------------------------------------------------------------------------------------------------------------------------
         function Val=Indicators(obj, type ,ParameterList,DateRange,varargin) %计算各种指标
             % e.g. Val=Stock.Indicators({'Lowest','Highest','MA','STD','BOLL'},{6,6,2,5,[20,2]},{'2015-07-10'})
             % e.g. Val=Stock.Indicators({'Lowest','Highest','MA','STD','BOLL'},{6,6,2,5,[20,2]},{'2015-01-01','2015-07-10'})
             %--------------------------------------------
             if isempty(DateRange)
                 stold=datestr(today,'yyyy-mm-dd');
                 edold=datestr(today,'yyyy-mm-dd');
             elseif length(DateRange)==1
                  stold=datestr(DateRange{1},'yyyy-mm-dd');
                  edold=datestr(DateRange{1},'yyyy-mm-dd');
             elseif length(DateRange)==2
                  stold=datestr(DateRange{1},'yyyy-mm-dd');
                  edold=datestr(DateRange{2},'yyyy-mm-dd');
             else
                 error('日期输入错误')
             end
              L=max(cell2mat(cellfun(@(x) x(1),ParameterList,'UniformOutput', false)));
              st=datestr(datenum(stold)-L-60,'yyyy-mm-dd');
              ed=edold;
              
              obj.stold=stold;
              obj.edold=edold;
              obj.st=st;
              obj.ed=ed;
              
              KData=obj.HistoryDaily(st,ed); % K线数据选择前复权
              L=length(KData.Date);
              for i=1:length(type)
                    switch type{i}
                        case 'Y' % 收益率
                            Len=ParameterList{i};
                            out=obj.Y(KData,Len);
                            eval(['KData.Y',num2str(Len),'=out;'])
                        case 'Highest'  %阶段最大值
                            Len=ParameterList{i};
                            out=obj.Highest(KData,Len);
                            eval(['KData.High',num2str(Len),'=out;'])                           
                        case 'Lowest' %阶段最小值
                            Len=ParameterList{i};
                            out=obj.Lowest(KData,Len);
                            eval(['KData.Low',num2str(Len),'=out;'])            
                        case 'MA' % 移动平均
                            Len=ParameterList{i};
                             out=obj.MA(KData,Len);
                            eval(['KData.MA',num2str(Len),'=out;'])                                       
                        case 'EMA'
                            Len=ParameterList{i};
                              out=obj.EMA(KData,Len);
                            eval(['KData.EMA',num2str(Len),'=out;'])                                        
                        case 'STD' % 阶段标准差
                            Len=ParameterList{i};
                              out=obj.STD(KData,Len);
                            eval(['KData.STD',num2str(Len),'=out;'])                                            
                        case 'BOLL' % 布林带指标
                            Len=ParameterList{i}(1);
                            Width=ParameterList{i}(2); 
                            out=obj.BOLL(KData,Len,Width);
                            eval(['KData.BOllMid',num2str(Len),'_',num2str(Width),'=out(:,1);'])
                            eval(['KData.BOllUp',num2str(Len),'_',num2str(Width),'=out(:,2);'])
                            eval(['KData.BOllDown',num2str(Len),'_',num2str(Width),'=out(:,3);'])
                        case 'MACD' % MACD 指标计算
                            if length(ParameterList{i})~=3
                                error('MACD 参数输入有误')
                            end
                            LeadLen=ParameterList{i}(1);
                            LagLen=ParameterList{i}(2);
                            DIFFLen=ParameterList{i}(3);
                            out=obj.MACD(KData,LeadLen,LagLen,DIFFLen);
                            eval(['KData.DIFF',num2str(LeadLen),'_',num2str(LagLen),'_',num2str(DIFFLen),'=out(:,1);'])
                            eval(['KData.DEA',num2str(LeadLen),'_',num2str(LagLen),'_',num2str(DIFFLen),'=out(:,2);'])
                            eval(['KData.MACD',num2str(LeadLen),'_',num2str(LagLen),'_',num2str(DIFFLen),'=out(:,3);'])
                        case 'BIAS' % 乖离率
                            if length(ParameterList{i})==1
                                LenLead=1;
                                LenLag=ParameterList{i}(1);
                            elseif length(ParameterList{i})==2
                                LenLead=ParameterList{i}(1);
                                LenLag=ParameterList{i}(2);
                            else
                                error('BIAS 参数输入有误')
                            end
                            out=obj.BIAS(KData,LenLead,LenLag);
                            eval(['KData.BIAS',num2str(LenLead),'_',num2str(LenLag),'=out;']);
                        case 'KDJ'
                            if length(ParameterList{i})~=3
                                error('KDJ 参数输入有误')
                            end
                            Len= ParameterList{i}(1);
                            M1=ParameterList{i}(2);
                            M2=ParameterList{i}(3);
                            out=obj.KDJ(KData,Len,M1,M2);
                           eval(['KData.K',num2str(Len),'_',num2str(M1),'_',num2str(M2),'=out(:,1);']);
                           eval(['KData.D',num2str(Len),'_',num2str(M1),'_',num2str(M2),'=out(:,2);']);
                           eval(['KData.J',num2str(Len),'_',num2str(M1),'_',num2str(M2),'=out(:,3);']);
                        case 'RSI' % 相对强弱指标
                            Len= ParameterList{i};
                            out=obj.RSI(KData,Len);
                            eval(['KData.RSI',num2str(Len),'=out;'])
                        case 'LB'% 量比
                            out=obj.Lb2(KData,5);
                            KData.Lb5=out;
                        case 'OBV' % 净成交量
                            out=obj.OBV(KData);
                            KData.OBV=out;
                        case 'SAR' % 抛物线转账指标
                            Len= ParameterList{i};
                            out=obj.SAR(KData,Len);
                            eval(['KData.SAR',num2str(Len),'=out;'])
                        case 'DMI' % 趋势指标(标准)
                            if length(ParameterList{i})~=2
                                error('DMI 参数输入有误')
                            end
                            N= ParameterList{i}(1);
                            M= ParameterList{i}(2);
                            out=obj.DMI(KData,N,M);
                            eval(['KData.PDI',num2str(N),'_',num2str(M),'=out(:,1);']);
                            eval(['KData.MDI',num2str(N),'_',num2str(M),'=out(:,2);']);
                            eval(['KData.ADX',num2str(N),'_',num2str(M),'=out(:,3);']);
                            eval(['KData.ADXR',num2str(N),'_',num2str(M),'=out(:,4);']);
                        case 'CCI' % 顺势指标
                            N= ParameterList{i};
                            out=obj.CCI(KData,N);
                            eval(['KData.CCI',num2str(N),'=out;'])
                        case 'PSY' % 心理线
                            N= ParameterList{i};
                            out=obj.PSY(KData,N);
                            eval(['KData.PSY',num2str(N),'=out;'])
                        otherwise 
                            error('没有相应指标')
                    end
                    
              end    
              % 如果检测到 AllOut 参数为 1 就将所有前置数据一并输出
              if ~isempty(varargin) & mod(length(varargin),2)==0 & varargin{find(strcmp(varargin,'AllOut'))+1}
                  Val=KData;
              elseif ~isempty(varargin) & mod(length(varargin),2)~=0
                  error('参数输入有误')
              else
                  Val=KData(datenum(KData.Date)>=datenum(stold),:);
              end
              
         end % Indicators
         function Val=Lb(obj,varargin) % 量比（实时和历史）
             %-------------------------------------------------------------
             % e.g. Val=Stock.Lb                  %当天每分钟量比数据
             % e.g. Val=Stock.Lb('2015-03-02')    %历史某日每分钟量比数据
             % e.g. Val=Stock.Lb('2015-03-02','2015-04-30') % 量比daily数据
             %-------------------------------------------------------------
             if nargin==1 | (nargin==2 & datenum(varargin)==today) % 当日每分钟量比数据
                 if strcmp(obj.State,'')
                     r1m=obj.Real1m; % 当日实时1分钟数据
                     r1m.Mint=[1:length(r1m.Time)]'; % 列表中行数据的已过分钟数
                     r1m.TVolume=cumsum(r1m.Volume); % 每分钟的累计成交量
                     K=obj.HistoryDaily(datenum(obj.LastTime)-60,datenum(obj.LastTime)); % K线数据
                     v5m=sum(K.Volume(end-5:end-1))/1200; % 前5日每分钟成交量
                     r1m.Lb=r1m.TVolume./(v5m*r1m.Mint); % 当日每分钟的量比数据
                     Val= r1m(:,{'Time','Lb'});
                 else
                     Val=NaN;
                 end
                 
             elseif nargin==2 & datenum(varargin)<today % 历史每日每分钟量比数据
                 day=varargin{1};
                 ht=obj.HistoryTick(day);
                 if isempty(ht)
                     Val=NaN;
                 else
                     ht.Time=datestr(ht.Time,'HH:MM');
                     ht=ht(:,{'Time','Volume'});
                     r1m=grpstats(ht,'Time',{'sum'});
                     r1m.TVolume=cumsum(r1m.sum_Volume);
                     r1m.Mint=[1:length(r1m.Time)]'; % 列表中行数据的已过分钟数
                     K=obj.HistoryDaily(datenum(day)-60,datenum(day)); % K线数据
                     v5m=sum(K.Volume(end-5:end-1))/1200; % 前5日每分钟成交量
                     r1m.Lb=r1m.TVolume./(v5m*r1m.Mint); % 当日每分钟的量比数据
                     Val= r1m(:,{'Time','Lb'});
                 end
             elseif nargin==3
                 stold=varargin{1};
                 edold=varargin{2};
                 st=datenum(stold)-60;
                 ed=edold;
                 K=obj.HistoryDaily(st,ed); % K线数据
                 L=length(K.Volume);
                 for j=1:5
                     DataVolume(:,j)=K.Volume(5-j+1:L-j+1);
                 end
                 Volume5=NaN(L,1);
                 Volume5(6:end)=sum(DataVolume(1:end-1,:),2);
                 K.Volume5=Volume5;
                 K.Lb=5*K.Volume./Volume5;
                 Val=K(:,{'Date','Lb'});
                 Val=Val(datenum(Val.Date)>=datenum(stold),:);
             else
                 error('参数输入个数有误')
                 
             end
             
         end %Lb
         %---------------------------------------------------------------------------------------------------------------------------------------
         
    end % methods 
    
    
    methods (Access='private')
        function Val=fuquan(obj,KData,type) % 复权(腾讯复权数据)
            %-----------------------------------------------------------下载复权数据
            url=['http://data.gtimg.cn/flashdata/hushen/fuquan/',obj.Code,'.js?maxage=6000000']
            [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
            if ~status
                % error('读取错误\n')
                Val=KData;
            else
                expr1='(?<=["~^])([\d.]+)(?=["~])';
                [~, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
                fqData=[date_tokens{:}]';
                t=cell2mat(cellfun(@(x) datenum([x(:,1:4),'/',x(5:6),'/',x(7:8)]),fqData(1:3:end),'UniformOutput' ,false));
                fqData=[t,str2double([fqData(2:3:end),fqData(3:3:end)])];
                fqData(:,3)=cumprod(fqData(:,3));
                %------------------------------------------------------------加载复权数据
                switch type
                    case 'L'
                        for i=1:size(fqData,1)
                            if i==1
                                dayi=KData(:,1)<fqData(i);
                            else
                                dayi=KData(:,1)<fqData(i) & KData(:,1)>=fqData(i-1);
                            end
                            KData(dayi,2:end-1)=KData(dayi,2:end-1)*fqData(i,2);
                        end
                        Val=KData;
                        
                    case 'R'
                        %--------------------------------
                        
                        for i=1:size(fqData,1)
                            if i==size(fqData,1)
                                dayi=KData(:,1)>=fqData(i);
                            else
                                dayi=KData(:,1)>=fqData(i) & KData(:,1)<fqData(i+1);
                            end
                            KData(dayi,2:end-1)=KData(dayi,2:end-1)*fqData(i,3);
                        end
                        Val=KData;
                        %--------------------------------
                    otherwise
                end
            end
        end% fuquan
        function Val=EMA(obj,KData,Len,field,coef) %EMA
            
            error(nargchk(2, 5, nargin))
            len=Len;
            if nargin < 5
                coef = [];
            end
            if nargin < 4
                field ='Close';
            end            
            if nargin< 3
                len = 2;
            end
            % 指定EMA系数
            if isempty(coef)
                k = 2/(len + 1);
            else
                k = coef;
            end
            Price=eval(['KData.',field,';']);
            Price(isnan(Price))=0;
            % 计算EMAvalue
            EMAvalue = zeros(length(Price), 1);
            EMAvalue(1:len-1) = Price(1:len-1);
            
            for i = len:length(Price)
                
                EMAvalue(i) = k*( Price(i)-EMAvalue(i-1) ) + EMAvalue(i-1);
                
            end
           Val=EMAvalue;
        end%EMA
        function Val=SMA(obj,KData,Len,field,coef) %EMA
            error(nargchk(2, 5, nargin))
            len=Len;
            if nargin < 5
                coef = [];
            end
            if nargin < 4
                field ='Close';
            end            
            if nargin< 3
                len = 2;
            end
            % 指定SMA系数
            if isempty(coef)
               % k = 2/(len + 1);
               k = 1/len;
            else
                k = coef;
            end
            Price=eval(['KData.',field,';']);
            Price(isnan(Price))=0;
            % 计算SMAvalue
            SMAvalue = zeros(length(Price), 1);
            SMAvalue(1:len-1) = Price(1:len-1);
            
            for i = len:length(Price)
                
                SMAvalue(i) = k*( Price(i)-SMAvalue(i-1) ) + SMAvalue(i-1);
                
            end
           Val=SMAvalue;
        end%SMA
        function Val=Y(obj,KData,Len) % Y
            L=length(KData.Date);
            Y=NaN(1,L)';
            Y(Len+1:end)=(KData.Close(Len+1:end)-KData.Close(1:end-Len))./KData.Close(1:end-Len);
            Val=Y;
        end % Y
        function Val=Highest(obj,KData,Len) % Highest
            L=length(KData.Date);
            DataHigh=[];
            for j=0:Len-1
                DataHigh(:,j+1)=KData.High(Len-j:L-j);
            end
            Hightest=NaN(L,1);
            Hightest(Len:end)=max(DataHigh,[],2);
            Val= Hightest;
        end % Highest
        function Val=Lowest(obj,KData,Len) % Lowest
            L=length(KData.Date);
            DataLow=[];
            for j=0:Len-1
                DataLow(:,j+1)=KData.Low(Len-j:L-j);
            end
            Lowest=NaN(L,1);
            Lowest(Len:end)=min(DataLow,[],2);
            Val=Lowest;
        end % Lowest       
        function Val=MA(obj,KData,Len,field) % MA
            if nargin < 4
              field='Close';  
            end
            L=length(KData.Date);
            DataClose=[];
            for j=0:Len-1
                DataClose(:,j+1)=eval(['KData.',field,'(Len-j:L-j);']);
            end
            Avg=NaN(L,1);
            Avg(Len:end)=mean(DataClose,2);
           Val=Avg;
        end % MA
        function Val=STD(obj,KData,Len,field) % STD
            if nargin < 4
                field='Close';
            end
            L=length(KData.Date);
            DataClose=[];
            for j=0:Len-1
                DataClose(:,j+1)=eval(['KData.',field,'(Len-j:L-j);']);
            end
            Std=NaN(L,1);
            Std(Len:end)=std(DataClose,0,2);
           Val=Std;
        end % STD
        function Val=BOLL(obj,KData,Len,Width) % BOLL
            L=length(KData.Date);
            BollMid=obj.MA(KData,Len);
            STD=obj.STD(KData,Len);
            BollUp=BollMid+Width*STD;
            BollDown=BollMid-Width*STD;
            Val=[BollMid,BollUp,BollDown];
        end % BOLL
        function Val=MACD(obj,KData,LeadLen,LagLen,DIFFLen) % MACD2
            L=length(KData.Date);
                LeadMA=obj.EMA(KData,LeadLen);
                LagMA=obj.EMA(KData,LagLen);
                DIFF=LeadMA-LagMA;
                KData.DIFF=DIFF
                DEA=obj.EMA(KData,DIFFLen,'DIFF');
                MACD=2*(DIFF-DEA);
                Val=[DIFF,DEA,MACD];
        end % MACD
        function Val=BIAS(obj,KData,LeadLen,LagLen) % BIAS
                 L=length(KData.Date);
                 LeadMA=obj.EMA(KData,LeadLen);
                LagMA=obj.EMA(KData,LagLen);       
                BIAS=100*(LeadMA-LagMA)./LagMA;
             Val=BIAS;
        end % BIAS
        function Val=KDJ(obj,KData,Len,M1,M2)% KDJ
            L=length(KData.Date);
           HH=obj.Highest(KData,Len);
           LL=obj.Lowest(KData,Len);
           Close=KData.Close;
           KData.RSV=100*(Close-LL)./(HH-LL);
           K=obj.SMA(KData,M1,'RSV');
           KData.K=K;
           D=obj.SMA(KData,M2,'K');
           J=3*K-2*D;
           Val=[K,D,J];

        end % KDJ
        function Val=RSI(obj,KData,Len) % RSI
            L=length(KData.Date);
            Close=KData.Close;
            CloseDiff=zeros(L,1);
            CloseDiff(2:end)=Close(2:end)-Close(1:end-1);
            KData.Rise=max(CloseDiff,0);
            KData.All=abs(CloseDiff);
            RSI=100*obj.SMA(KData,Len,'Rise')./obj.SMA(KData,Len,'All');
            Val=RSI;
        end % RSI
        function Val=OBV(obj,KData) % OBV
            L=length(KData.Date);
            OBV=zeros(L,1);
            Volume=KData.Volume;
            Close=KData.Close;
            CloseDiffSign=sign([0;Close(2:end)-Close(1:end-1)]);
            OBV=cumsum(Volume.*CloseDiffSign);
            Val=OBV;
            
        end % OBV
        function Val=Lb2(obj,KData,Len) % Lb2按日计算的量比
            L=length(KData.Date);
            for j=1:5
                DataVolume(:,j)=KData.Volume(5-j+1:L-j+1);
            end
            Volume5=NaN(L,1);
            Volume5(6:end)=sum(DataVolume(1:end-1,:),2);
           Val=5*KData.Volume./Volume5;
        end %Lb2
        function Val=SAR(obj,KData,Len)% SAR
            L=length(KData.Date);
            %-----------------选择开始点
            Close=KData.Close;
            High=KData.High;
            Low=KData.Low;
            HH=obj.Highest(KData,Len);
            LL=obj.Lowest(KData,Len);
            [~,mini]=min(Low(Len:Len+20));
            [~,maxi]=max(High(Len:Len+20));
            if abs(mini-10)<abs(maxi-10)
                starti=mini+Len;
            else
                starti=maxi+Len;
            end
            AF=0.02;
            SAR=NaN(L,1);
            AFALL=NaN(L,1);%-------------- 测试语句
            
            if starti==mini % 首个SAR计算
                SAR(starti)=LL(starti);
                SAR(starti+1)=SAR(starti)+AF*(HH(starti)-SAR(starti));
                type='up';
            else
                SAR(starti)=HH(starti);
                SAR(starti+1)=SAR(starti)+AF*(LL(starti)-SAR(starti));
                type='down';
            end

            for i=starti+1:L-1
                switch type
                    case 'up' % 上升通道
                        
                      if Low(i)<SAR(i) % 翻转为空判断
                          SAR(i+1)=HH(i);
                          AF=0.02; 
                          AFALL(i)=AF;% -------------- 测试语句
                          type='down';
                      else % 正常上升通道计算
                          if HH(i+1)>HH(i) % 判断AF是否增加
                              AF=min(AF+0.02,0.2);
                          end
                          AFALL(i)=AF;% --------------
                          SAR(i+1)=SAR(i)+AF*(HH(i)-SAR(i)); 
                      end
                      
                    case 'down'
                      if High(i)>SAR(i) % 翻转为多判断
                          SAR(i+1)=LL(i);
                          AF=0.02; 
                          AFALL(i+1)=AF;% -------------- 测试语句
                          type='up';
                      else % 正常下降通道计算
                          if LL(i+1)<LL(i) % 判断AF是否增加
                              AF=min(AF+0.02,0.2);
                          end
                           AFALL(i+1)=AF;% -------------- 测试语句
                          SAR(i+1)=SAR(i)+AF*(LL(i)-SAR(i)); 
                      end                       
                        
                end
            end
            [KData.Date,num2cell([SAR,HH,LL,Close,AFALL])];%------------- 测试语句
            Val=SAR;
        end % SAR
        function Val=DMI(obj,KData,N,M) % DMI
            L=length(KData.Date);
            High=KData.High;
            Low=KData.Low;
            Close=KData.Close;
            TR1=High-Low;%当日的最高价减去当日的最低价的价差
            TR2=abs(High-[NaN;Close(1:end-1)]);% 当日的最高价减去前一日的收盘价的价差
            TR3=abs(Low-[NaN;Close(1:end-1)]);% 当日的最低价减去前一日的收盘价的价差
            KData.Temp=max([TR1,TR2,TR3],[],2);% TR 取三者最大值
            TR=obj.MA(KData,N,'Temp')*N ;
            HD=High-[NaN;High(1:end-1)];
            LD=[NaN;Low(1:end-1)]-Low;
            KData.Temp=(HD>0 & HD>LD).*HD;
            DMP=obj.MA(KData,N,'Temp')*N;
            KData.Temp=(LD>0 & LD>HD).*LD;
            DMM=obj.MA(KData,N,'Temp')*N;
            PDI=DMP*100./TR;
            MDI=DMM*100./TR;
            KData.Temp=abs(MDI-PDI)./(MDI+PDI)*100;
            ADX=obj.MA(KData,M,'Temp');
            ADXR=(ADX+[NaN(M,1);ADX(1:end-M)])/2;
            Val=[PDI,MDI,ADX,ADXR];
        end % DMI
        function Val=CCI(obj,KData,N) % CCI
            L=length(KData.Date);
            High=KData.High;
            Low=KData.Low;
            Close=KData.Close;
            TYP=(High+Low+Close)/3;
            KData.TYP=TYP;
            MATYP=obj.MA(KData,N,'TYP');
             DataTYP=[];
            for j=0:N-1
                DataTYP(:,j+1)=TYP(N-j:L-j);
            end
            MD=NaN(L,1);
            MD(N:end)=mad(DataTYP')';
            CCI=(TYP-MATYP)./(0.015*MD);
             Val=CCI;
        end % CCI
        function Val=PSY(obj,KData,N) % PSY
            L=length(KData.Date);
            Close=KData.Close;       
            RC=[NaN;Close(2:end)>Close(1:end-1)];
            DataRC=[];
            for j=0:N-1
                DataRC(:,j+1)=RC(N-j:L-j);
            end
            CountRCN=NaN(L,1);
            CountRCN(N:end)=sum(DataRC,2);
            PSY=CountRCN/N*100;
            Val=PSY;
        end % PSY

    end % methods (Access='private')
    
    methods (Static) 
        %-------------------------------------------------------------------------------------------------------------------
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
        function out=CodeNameChange(in)  % 代码名字互相转换
            
            List=Stock.StockList;
            if in(1:2)=='sh' | in(1:2)=='sz'
                in=in(3:end);
                out=List(strmatch(in,List),2);
            else
                out=List(strmatch(in,List)-length(List),1);
            end
            if size(out,1)>1 | size(out,1)==0
                out
                error('有多个匹配项或无匹配项')
            end
            out=out{:};
        end % CodeNameChange
        function out=CodeCheck(in) % 标准化输入代码
            if ~iscell(in) % 转换成为cell数组输入 '600001'转变为{'600001'}输入
                in={in};
            end
            out=[];
                  for i=1:length(in) % 对cell数组中的每一个成员进行遍历操作
                      C=in{i};
                      if ~isstr(C)
                          error('输入必须为字符串')
                      end
                      if  length(C)==6 & (strcmp(C(1),'6') | strcmp(C,'000001')) % 沪市代码
                          out{i}= ['sh',C];
                      elseif length(C)==6 & (strcmp(C(1),'0') | strcmp(C(1),'3')) & ~strcmp(C,'000001') % 深市代码
                          out{i}= ['sz',C];
                      else % 其余按原样输出
                          out{i}=[C];
                      end
                  end
            
        end % CodeCheck
        function out=Py2Code(in,outtype) % 拼音代码转换
            if  iscell(in) 
                in=in{:};
            end
            url=['http://smartbox.gtimg.cn/s3/?q=',in,'&t=gp']; % 拼音代码转换接口
            [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
            if ~status
                error('读取错误\n')
            end
            sourcefile2= regexp(sourcefile, '[~"^]', 'split')';
            Code=strcat(sourcefile2(2:5:end-1),sourcefile2(3:5:end));
            Py=sourcefile2(5:5:end-1);
            if ~isempty(Py)
                info=Stock.QuickInfo(Code);
                Name=info.Name;
                out=[Code,Py,Name];
            else
                error('没有信息')
            end

        end
        %-------------------------------------------------------------------------------------------------------------------
        function info=QuickInfo(Code) % 对Code列表股票快速获取即时价格信息
            % e.g.:  info=QuickInfo('600123')
            % e.g.:  info=QuickInfo({'600123','000523'})
            Code=Stock.CodeCheck(Code); % 输入代码标准化

            % 腾讯数据接口地址开头
            urlHead='http://qt.gtimg.cn/q=';
            %-----------------------------------------------------
            sourcefileall=[];
            b=1; % 
            e=60;% 一次最多读入的代码个数（由于url限制）
            len=length(Code); % 代码个数
            while b<=len 
                % 将代码转换成地址组成部分
                C=strcat('s_',Code(b:min(e,len)),',');
                urlAddress=strcat(urlHead,[C{:}]);
                % 读取网页信息
                [sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
                if isempty(sourcefile)
                    error('没有此股票数据')
                end
                if ~status
                    error('读取错误\n')
                end
                sourcefileall=[sourcefileall,sourcefile];
                b=b+60;
                e=e+60;% 新增要读取的代码
            end
            %-------------------------------------------------------
            % 正则表达式(将股票信息列表化方便逐个操作)
            expr1='(?<=v_)(.*?)(?=";)';
            [datefile, date_tokens]= regexp(sourcefileall, expr1, 'match', 'tokens');
            sourcefile=[date_tokens{:}]';
            if isempty(sourcefile)
                error(['没有股票',Code{:},'的数据'])
            end
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
            S(:,[4:8,10])=num2cell(str2double(S(:,[4:8,10])));
            S(:,3)=strcat(strrep(strrep(S(:,1),'51','sz'),'1','sh'),S(:,3));
            Explain={'市场代码','名字','代码','当前价格','涨跌','涨跌%','成交量(手)','成交量(万)','状态','总市值','unknow'};
            Name={'Market','Name','Code','RealPrice','Rise','Yield','Volume','Amount','State','TotalMarketValue','unknow'};
            info=cell2table(S,'VariableNames',Name');  
        end % QuickInfo
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
        function info=Handicap(Code)%盘口信息
            Code=Stock.CodeCheck(Code);
            % 腾讯数据接口地址开头
            urlHead='http://qt.gtimg.cn/q=';
            %--------------------------------------------------------------
            sourcefileall=[];
            b=1;
            e=60;% 限制一次读取的代码数量（URL限制）
            len=length(Code); % 代码个数
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
            end
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
            Name={'Market','Name','Code','RealPrice','YClosePrice','OpenPrice','Volume','B','S','Buy1Price','Buy1Volume','Buy2Price','Buy2Volume','Buy3Price','Buy3Volume','Buy4Price','Buy4Volume','Buy5Price','Buy5Volume','Sell1Price','Sell1Volume','Sell2Price','Sell2Volume','Sell3Price','Sell3Volume','Sell4Price','Sell4Volume','Sell5Price','Sell5Volume','LastTransaction','LastTime','Rise','Yield','HighPrice','LowPrice','Price_Volume_Amount','Volume2','Amount','HSL','PE','State','High','Low','Amplitude','CirculationMarketValue','TotalMarketValue','PB','HardenPrice','LimitPrice','blank2','blank3','blank4','blank5','blank6','blank7','blank8','blank9','blank10','blank11','blank12','blank13','blank14'};
            % 将标题与信息组合
              info=cell2table(S(:,1:size(Name,2)),'VariableNames',Name');
            
            %--------------------------------------------------------------
        end% Handicap
        function info=Fund(Code) %资金流向
            Code=Stock.CodeCheck(Code);
            % 腾讯数据接口地址开头
            urlHead='http://qt.gtimg.cn/q=';
            %-----------------------------------------------------
            sourcefileall=[];
            b=1;
            e=60;
            len=length(Code);
            while b<=len
                  % 将代码转换成地址组成部分
                C=strcat('ff_',Code(b:min(e,len)),',');
                urlAddress=strcat(urlHead,[C{:}]);
                [sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
                if ~status
                    error('读取错误\n')
                end
                sourcefileall=[sourcefileall,sourcefile];
                b=b+60;
                e=e+60;
            end
            %-------------------------------------------------------
                        expr1='(?<=v_)(.*?)(?=";)';
            [datefile, date_tokens]= regexp(sourcefileall, expr1, 'match', 'tokens');
            sourcefile=[date_tokens{:}]';
            S={};
            for i=1:length(sourcefile)
                expr1='(?<=="s[hz])(.*)';
                [datefile, date_tokens]= regexp(sourcefile{i}, expr1, 'match', 'tokens');
                if isempty(date_tokens)
                    info=[];
                    return
                end
                sourcefile2=date_tokens{:};
                % 分割信息
                ss=regexp(sourcefile2, '~', 'split');
                % 组合提取的信息
                S(i,:)=ss{:};
            end
            Explain={'代码','主力流入','主力流出','主力净流入','主力净流入/资金流入流出总和','散户流入','散户流出','散户净流入','散户净流入/资金流入流出总和',...
                '资金流入流出总和1+2+5+6','未知','未知','名字','日期','未知','未知','未知','未知','未知','未知','未知'};
             Name={'Code','MInflow','MOutflow','MNetInflow','MNetInflow_Total','RInflow','ROutflow','RNetInflow','RNetInflow_Total','TotalFund','unknow1','unknow2','Name','LastTime','unknow3','unknow4','unknow5','unknow6','unknow7','unknow8','unknow9'};
             if ~isempty(S)
                 info=cell2table(S,'VariableNames',Name(1:size(S,2)));
             else
                 info=[];
             end
        end% Fund
        function info=HandicapAnalysis(Code)%盘口大小单分析
            Code=Stock.CodeCheck(Code);
            % 腾讯数据接口地址开头
            urlHead='http://qt.gtimg.cn/q=';    
            %-----------------------------------------------------
            sourcefileall=[];
            b=1;
            e=60;
            len=length(Code);
            while b<=len
                % 将代码转换成地址组成部分
                C=strcat('s_pk',Code(b:min(e,len)),',');
                urlAddress=strcat(urlHead,[C{:}]);
                % 读取网页信息
                [sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
                if ~status
                    error('读取错误\n')
                end
                sourcefileall=[sourcefileall,sourcefile];
                b=b+60;
                e=e+60;
            end
                        % 正则表达式(将股票信息列表化方便逐个操作)
            expr1='(?<=v_)(.*?)(?=";)';
            [datefile, date_tokens]= regexp(sourcefileall, expr1, 'match', 'tokens');
            sourcefile=[date_tokens{:}]';
            % 逐行提取信息
            for i=1:length(sourcefile)
                expr1='(?<=s[hz])(.*?)(?==")';
                [datefile, date_tokens]= regexp(sourcefile{i}, expr1, 'match', 'tokens');
                Shead=[date_tokens{:}];
                expr1='(?<==")(.*)';
                [datefile, date_tokens]= regexp(sourcefile{i}, expr1, 'match', 'tokens');
                ss=date_tokens{:};
                ss = regexp(ss, '~', 'split');
                S(i,:)=[Shead,ss{:}];
            end
            Explain={'代码','买盘大单','买盘小单','卖盘大单','卖盘小单'};
            Name={'Code','BuyLargeQuantity','BuySmallQuantity','SellLargeQuantity','SellSmallQuantity'};
            % info=cell2table([title',S']','VariableNames',Title','RowNames',{'Title',Code{:}}');
            info=cell2table(S,'VariableNames',Name);
        end % HandicapAnalysis
        %--------------------------------------------------------------------------------------------------------------------
        function Val=BlockInfo(BlockCode) % 板块代码查询板块基本信息及行情
            %----------------------------------------------
            sourcefileall=[];
            b=1;
            e=60; % 每次读入60条数据（URL限制）
            len=length(BlockCode); % 代码个数
            while b<=len % 对代码进行遍历
                %------------------------------------------------------------------URL拼接及接口数据读取
                urltail=strcat('bkhz',BlockCode(b:min(e,len)),',');
                urltail=strcat(urltail{:});
                url=['http://push3.gtimg.cn/q=',urltail(1:end-1)]; % 腾讯板块名字行情信息接口
                [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                if ~status
                    error('读取错误\n')
                end
                sourcefileall=[sourcefileall,sourcefile];
                b=b+60;
                e=e+60; % 继续便利下一组代码
            end
            %------------------------------------------------------分析及重组接口数据
            expr1='(?<=\=")(.*?)(?=";)';
            [datefile, date_tokens]= regexp(sourcefileall, expr1, 'match', 'tokens');
            sourcefile2=[date_tokens{:}]';
            Val=regexp(sourcefile2, '~', 'split');
            Val=[Val{:}];
            Val=reshape(Val,18,length(Val)/18)';
            %--------------------------------------------------------组合成Table数据
            Explain={'板块代码','板块名字','上涨家数','停牌家数','下跌家数','总股票数',...
                '平均价格','涨跌额','涨跌幅','总成交手','总成交额','领涨股票','领跌股票',...
                '主力资金流入','主力资金流出','主力资金净流入','未知','占版块成交比'};
            Name={'Code','Name','RiseNum','FlatNum','FullNum','TotleNum',...
                'AveragePrice','Rise','Yield','Volume','Amount','Top1','Last1'...
                ,'MainInflow','MainOutflow','Main9NetInflow','unknow1','TurnoverRatio'};
            Val=cell2table([Val(:,1:2),num2cell(str2double(Val(:,3:11))),Val(:,12:13),num2cell(str2double(Val(:,14:end)))],'VariableNames',Name);
        end %BlockInfo
        function StockList=BlockStock(BlockCode) % 板块代码查询查询版块所属股票
            %------------------------------------------------------------------读取接口信息
            url=['http://stock.gtimg.cn/data/index.php?appn=rank&t=',['pt',BlockCode],'/chr&p=1&o=0&l=800&v=list_data']
             [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
             if ~status
                 error('读取错误\n')
             end
            %------------------------------------------------------------------分析及重组接口信息 
             expr1='([shz]{2}\d{6})';
             [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
             Code=[date_tokens{:}]';
             %------------------------------------------------------------------将读取的代码用Stock.QuickInfo获取股票基本信息
             StockList=Stock.QuickInfo(Code);
        end%BlockStock
        function List=BlockList(in) % 地域 行业 概念 版块列表
           switch in
               case 1  % 腾讯行业版块
                   about='01'; 
               case 2  % 概念版块
                   about='02';
               case 3  % 地域板块
                   about='03';
               case 4  % 证监会行业板块
                   about='04';
               otherwise
                   error('请核实输入')
           end
           %--------------------------------------------------------------------------------读取接口数据
           url=['http://stock.gtimg.cn/data/view/bdrank.php?&t=',about,'/averatio&p=1&o=0&l=800&v=list_data'];
           [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
           if ~status
               error('读取错误\n')
           end
           %--------------------------------------------------------------------------------分析组合接口数据
          expr1='bkqt(\w+)[,'']';
         [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
         BlockCode=[date_tokens{:}]';
         %--------------------------------------------------------------------------------将提取的版块代码用Stock.BlockInfo读取版块基本信息
         List=Stock.BlockInfo(BlockCode) ;
        end % BlockList
        %--------------------------------------------------------------------------------------------------------------------
        function List=TechnologyChoice(Type,Para) % 腾讯技术选股
            % e.g. Stock.TechnologyChoice('ljzf',10)
            %----------------------------------------------------------------------------------------------------------------
            %     1             2         3         4              5             6           7           8         9
            %   ljzf           lxsz      lxxd      hsltj         bigsell      bigbuy       cjltz       ylcb       lzjz
            % 累计涨幅       连续上涨   连续下跌    换手率统计      大卖单       大买单      成交量突增  远离成本    量增价涨
            % {5 10 20 30 }  {3 5 7}   {3 5 7} {5 10 20 60 120} {1 2 3 4 5} {1 2 3 4 5}      {1}        {1}        {1}
            % {'累计涨幅'}  {'连续天数'}{'连续天数'}{'累计换手率'}{'大单换手率'}{'大单换手率'}{'换手涨跌率'}{'远离度'}{'量比'}
            T={'ljzf','lxsz','lxxd','hsltj','bigsell','bigbuy','cjltz','ylcb','lzjz'}; 
            if isstr(Type)                % 将方法限制在以上名称范围以内
               Type=find(ismember(T,Type));
               if isempty(Type)
                   Type=10;
               end
            end
            if ~isnumeric(Para)     
                error('参数输入必须为数字')
            end
            switch Type % 选择技术方法
                case 1
                    % 累计涨幅 P={5 10 20 30} OutPara={'累计涨幅'}
                    P=[5 10 20 30];
                    if ~sum(Para==P) % 限定参数输入
                        error(['"累计涨幅"的输入天数限制为：',num2str(P)])
                    end
                    Name={'FullCode',['ljzf',num2str(Para)]};
                    Explain={'代码',[num2str(Para),'日累计涨幅']};
                case 2
                    % 连续上涨 P={3 5 7} OutPara={'连续天数'}
                    P=[3 5 7];
                    if ~sum(Para==P)
                        error(['"连续上涨"的输入天数限制为：',num2str(P)])
                    end    
                    Name={'FullCode',['lxts',num2str(Para)]};
                    Explain={'代码','连续上涨天数'};
                case 3
                    % 连续下跌 P={3 5 7} OutPara={'连续天数'}
                    P=[3 5 7];
                    if ~sum(Para==P)
                        error(['"连续下跌"的输入天数限制为：',num2str(P)])
                    end
                    Name={'FullCode',['lxts',num2str(Para)]};
                    Explain={'代码','连续下跌天数'};                    
                case 4
                   % 换手率统计 P={5 10 20 60 120} OutPara={'累计换手率'}
                    P=[5 10 20 60 120];
                    if ~sum(Para==P)
                        error(['"换手率统计"的输入天数限制为：',num2str(P)])
                    end   
                    Name={'FullCode',['ljhsl',num2str(Para)]};
                    Explain={'代码',[num2str(Para),'日累计换手率']};                    
                case 5
                   % 大卖单 P={1 2 3 4 5} OutPara={'大单换手率'}
                    P=[1 2 3 4 5];
                    if ~sum(Para==P)
                        error(['"大卖单"的输入天数限制为：',num2str(P)])
                    end  
                    Name={'FullCode',['ddhsl',num2str(Para)]};
                    Explain={'代码',[num2str(Para),'日大单(卖)换手率']};                         
                case 6
                   % 大买单 P={1 2 3 4 5} OutPara={'大单换手率'}
                    P=[1 2 3 4 5];
                    if ~sum(Para==P)
                        error(['"大买单"的输入天数限制为：',num2str(P)])
                    end     
                    Name={'FullCode',['ddhsl',num2str(Para)]};
                    Explain={'代码',[num2str(Para),'日大单（买）换手率']};                           
                case 7
                   % 成交量突增 P={1} OutPara={'换手涨跌率'}
                    P=[1];
                    if ~sum(Para==P)
                        error(['"成交量突增"的输入天数限制为：',num2str(P)])
                    end 
                    Name={'FullCode',['hszdl',num2str(Para)]};
                    Explain={'代码','换手涨跌率'};                           
                case 8
                   % 远离成本 P={1} OutPara={'远离度'}
                    P=[1];
                    if ~sum(Para==P)
                        error(['"远离成本"的输入天数限制为：',num2str(P)])
                    end   
                    Name={'FullCode',['yld',num2str(Para)]};
                    Explain={'代码','远离度'};                     
                case 9
                   % 量增价涨 P={1} OutPara={'量比'}
                    P=[1];
                    if ~sum(Para==P)
                        error(['"量增价涨"的输入天数限制为：',num2str(P)])
                    end   
                    Name={'FullCode',['lb',num2str(Para)]};
                    Explain={'代码','量比'};                     
                otherwise
                    error('输入的选股方法名称有误')
            end
            % ------------------------------------------------------------------------读取接口数据
            url=['http://stock.gtimg.cn/data/view/dataPro.php?t=',num2str(Type),'&p=',num2str(Para)]
            [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
            if ~status
                error('读取错误\n')
            end
            % -----------------------------------------分析及重组接口数据
            expr1='([-szh\d\.]+)';
            [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
            a=[date_tokens{:}]';
            List=cell2table([a(4:2:end),a(5:2:end)],'VariableNames',Name);
            %----------------------------------------将得到的代码用Stock.QuickInfo获取股票基本信息
            Info=Stock.QuickInfo(List{:,1});
            %---------------------------------------组合统计数据和股票基本信息
            List=[List,Info];
        end % TechnologyChoice
        function List=FundChoice(Type,varagin) % 腾讯资金面选股
            %      1                                2                   3                        4                     5                        6                         7
            % 资金流向全览 行业资金流向 概念资金流向 主力增减仓排名 价跌主力增仓 价涨主力减仓股 主力资金放量
            T={'overview','industry','concept','mainforce','jdzlzc','jzzljc','zlzjfl'};
            if isstr(Type)        % 将选择方法限定在以上列表当中
                Type=find(ismember(T,Type));
                if isempty(Type)
                    Type=10;
                end
            end
            
            switch Type  % 各个统计方法
                case 1
                    % 资金全天流向全览
                    info=Stock.Handicap({'sh000001'});
                    time=info.LastTime{1};
                    time=time(1:8);
                    url=['http://stock.gtimg.cn/data/view/flow.php?t=',num2str(Type),'&dt=',time,'&r=0.6092258914799902']
                    % 读取网页信息
                    [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                    if ~status
                        error('读取错误\n')
                    end
                    expr1='([-\d\.:]+)'
                    [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
                    a=[date_tokens{:}]';
                    List=reshape(a,8,length(a)/8)';
                    Name={'MInflow','MOutflow','MNetInflow','RInflow','ROutflow','RNetInflow','Date','Time'};
                    Explain={'主力资金流入','主力资金流出','主力资金净流入','散户资金流入','散户资金流出','散户资金净流入','日期','时间'};
                     List=cell2table([Explain;flipud(List)],'VariableNames',Name);
                     
                    %if ~ isempty(flipud(List)) % 无说明行输出
                    %    List=cell2table(flipud(List),'VariableNames',Name);
                   % end
                case 2
                    % 行业板块资金进出情况
                    url=['http://stock.gtimg.cn/data/view/flow.php?t=',num2str(Type)]
                    % 读取网页信息
                    [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                    if ~status
                        error('读取错误\n')
                    end
                    sourcefile2= regexp(sourcefile, ';', 'split')';
                    expr1='(?<=[\^''~])(.*?)(?=[~''\^])'
                    [datefile, date_tokens]= regexp(sourcefile2(1), expr1, 'match', 'tokens');
                    a=[date_tokens{:}{:}]';
                    List=reshape(a,7,length(a)/7)';
                    Name={'Code','Name','MInflow','MOutflow','MNetInflow','unknow','TurnoverRatio'};
                    Explain={'代码','名称','主力资金流入','主力资金流出','主力资金净流入','未知','占板块成交比'}
                    List=cell2table([Explain;List],'VariableNames',Name);
                    %if ~ isempty(flipud(List)) % 无说明行输出
                    %    List=cell2table(flipud(List),'VariableNames',Name);
                    % end
                case 3
                    % 概念板块资金进出情况
                    url=['http://stock.gtimg.cn/data/view/flow.php?t=5']
                    % 读取网页信息
                    [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                    if ~status
                        error('读取错误\n')
                    end
                    sourcefile2= regexp(sourcefile, ';', 'split')';
                    expr1='(?<=[\^''~])(.*?)(?=[~''\^])';
                    [datefile, date_tokens]= regexp(sourcefile2(1), expr1, 'match', 'tokens');
                    a=[date_tokens{:}{:}]'
                    List=reshape(a,7,length(a)/7)';
                    Name={'Code','Name','MInflow','MOutflow','MNetInflow','unknow','TurnoverRatio'};
                    Explain={'代码','名称','主力资金流入','主力资金流出','主力资金净流入','未知','占板块成交比'}
                    List=cell2table([Explain;List],'VariableNames',Name);        
                    %if ~ isempty(flipud(List)) % 无说明行输出
                    %    List=cell2table(flipud(List),'VariableNames',Name);
                   % end                   
                case 4
                    % 主力增减仓排名
                    if nargin==1
                        Para=1;
                    elseif nargin==2 & isnumeric(varagin(1)) & varagin(1)==1
                        Para=1;
                    elseif nargin==2 & isnumeric(varagin(1)) & varagin(1)==5
                        Para=2;
                    else
                        error('只有一个参数，1：1日主力增仓量、5：5日主力增仓量')
                    end
                    url=['http://stock.gtimg.cn/data/view/zldx.php?t=',num2str(Para)]
                    % 读取网页信息
                    [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                    if ~status
                        error('读取错误\n')
                    end
                    if Para==1
                        col=11;
                    elseif Para==2
                        col=3;
                    end
                    sourcefile2= regexp(sourcefile, ';', 'split')';
                    expr1='(?<=[''~\^])(.*?)(?=[~''\^])';
                    [datefile, date_tokens]= regexp(sourcefile2(1), expr1, 'match', 'tokens');
                    a=[date_tokens{:}{:}]';
                    try
                         zlzc=reshape(a,col,length(a)/col)';
                    catch
                        zlzc=[];
                    end
                    [datefile, date_tokens]= regexp(sourcefile2(2), expr1, 'match', 'tokens');
                    a=[date_tokens{:}{:}]';
                    try
                        zljc=reshape(a,col,length(a)/col)';
                    catch
                        zljc=[];
                    end
                    List.zlzc=zlzc;
                    List.zljc=zljc;
                case 5
                case 6
                case 7                  
                otherwise
            end
        end  % FundChoice
        function List=FundHistory(Code,Day) % 个股资金进出历史明细 ,Day天数据
            % e.g. Stock.FundHistory('600123',10) 
            %----------------------------------------------------------------------------------
            Code=Stock.CodeCheck(Code);
            C=strcat(Code,',');
            C=strcat(C{:});
            url=['http://stock.gtimg.cn/data/view/ggdx.php?t=3&d=',num2str(Day),'&q=',C(1:end-1)]
            % 读取网页信息
            [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
            if ~status
                error('读取错误\n')
            end
            sourcefile2= regexp(sourcefile, ';', 'split')';
            expr1='(?<=[''~\^])(.*?)(?=[~''\^])';     
            for i=1:length(Code)
                [datefile, date_tokens]= regexp(sourcefile2(i), expr1, 'match', 'tokens');
                a=[date_tokens{:}{:}]';
                listdata=flipud(reshape(a,4,length(a)/4)');
                listdata=[num2cell(str2double(listdata(:,1:end-1))),listdata(:,end)];
                if length(Code)==1
                  List=listdata;
                else
                    eval(['List.',Code{i},'=listdata;']);
                end
            end
            
            Explain={'总增减仓','主力增减仓','散户增减仓'};
            Name={'TPosition','MPosition','RPosition','Date'};
             List=cell2table(List,'VariableNames',Name);
        end % FundHistory
        %---------------------------------------------------------------------------------------------------------------------
        function List=CYData(SortNameList)  % 超赢数据(只有沪市数据)
            % SortNameList 排序的字段 字段详见Explain
            % e.g. List=Stock.CYData('VBUpIn10Day')
            %-------------------------------------------------------------------------------
            url=['http://chagu.dingniugu.com/chaoying/cy.php?id=5'] % 详细数据解释看 http://chagu.dingniugu.com/chaoying/index.asp
            % 读取网页信息
            [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
            if ~status
                error('读取错误\n')
            end
            expr1='\[(\d{6}),\[(\d),(\d),(\d),(\d)\],\[(\d),(\d),(\d),(\d)\],\[([\d\.-]+),([\d\.-]+),([\d\.-]+),([\d\.-]+),([\d\.-]+)\],\[([\d\.-]+),([\d\.-]+),([\d\.-]+),([\d\.-]+),([\d\.-]+)\],\[([\d\.-]+),([\d\.-]+),([\d\.-]+),([\d\.-]+),([\d\.-]+)\],\[([\d\.-]+),([\d\.-]+),([\d\.-]+),([\d\.-]+),([\d\.-]+)\],\[([\d\.-]+),([\d\.-]+),([\d\.-]+),([\d\.-]+)\],([\d\.-]+),([\d\.-]+),([\d\.-]+)';
            [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
            a=[date_tokens{:}]';
            List=reshape(a,36,length(a)/36)';
            Explain={'代码',...
                '连续主力增(日)','连续超户增(日)','连续大户增(日)','连续散户减(日)',...
                '10日主力增(日)','10日超户增(日)','10日大户增(日)','10日散户减(日)',...
                '主力1日增减仓%','主力3日增减仓%','主力5日增减仓%','主力10日增减仓%','主力当日持仓',...
                '超大户1日增减仓%','超大户3日增减仓%','超大户5日增减仓%','超大户10日增减仓%','超大户当日持仓',...
                '大户1日增减仓%','大户3日增减仓%','大户5日增减仓%','大户10日增减仓%','大户当日持仓',...
                '散户1日增减仓%','散户3日增减仓%','散户5日增减仓%','散户10日增减仓%','散户当日持仓',...
                '超赢资金1日','超赢资金3日','超赢资金5日','超赢资金10日',...
                '当前价格','涨跌幅%','主力资金'};
            Name={'Code','Name',...
                'LMUpDay','LVBUpDay','LBUDay','LRDownDay',...
                'MUpIn10Day','VBUpIn10Day','BUpIn10Day','RDownIn10Day'...
                'MFund1Day','MFund3Day','MFund5Day','MFund10Day','MUpFund'...
                'VBFund1Day','VBFund3Day','VBFund5Day','VBFund10Day','VBUpFund'...
                'BFund1Day','BFund3Day','BFund5Day','BFund10Day','BUpFund'...
                'RFund1Day','RFund3Day','RFund5Day','RFund10Day','RUpFund'...
                'CYFund1Day','CYFund3Day','CYFund5Day','CYFund10Day',...
                'Price','Yield','MFund'};
            info=Stock.QuickInfo(List(:,1));
            List=cell2table([List(:,1),info{:,2},num2cell(str2double(List(:,2:end)))],'VariableNames',Name);
            List=sortrows(List,SortNameList,'descend');
           
            
        end % CYData
        %---------------------------------------------------------------------------------------------------------------------
        function Val=SLOPE(KData,N,field) %计算指标的斜率
             %-----------------------------------------------------------输入参数的正确性检验
                if (istable(KData) &  nargin<3) ||  (isnumeric(KData) & nargin>2) || (nargin<2) || (nargin>3) 
                    error('输入参数个数不对')
                elseif ~istable(KData) && ~isnumeric(KData)
                    error('输入的数据格式必须为table或者double')
                elseif  nargin==3 & ~isstr(field)
                    error('field 参数必须为字符串')
                elseif (istable(KData) &  nargin==3 )
                    Data=eval(['KData.',field,';']);
                elseif  (isnumeric(KData) & nargin==2)
                    Data=KData;
                end
              %-----------------------------------------------------------计算
              L=length(Data);
              DiffData=nan(length(Data),1);
              DiffData(2:end)=diff(Data);
             
                  MDiffData=nan(L,1);
             if L>=N
                  for j=0:N-1
                      TempData(:,j+1)=DiffData(N-j:L-j);
                  end
                 MDiffData(N:end)=mean(TempData,2); 
              end
              %-----------------------------------------------------------输出
              if istable(KData)
                  eval(['KData.S_',field,'=MDiffData;'])
                  Val=KData;
              else
                  Val=MDiffData;
              end
              
        end % SLOPE
    end  % methods (Static) 
    
end

