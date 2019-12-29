classdef Stock<handle

    
    properties
        %------------------------------������Ϣ
        Code        % ��Ʊ����
        Name       % ��Ʊ����
        State        % ��Ʊ״̬
        LastTime % ������ݸ���ʱ��
        %------------------------------�۸���Ϣ
        RealPrice %ʵʱ�۸�
        YClosePrice % ����
        OpenPrice   %��
        High % ���
        Low  % ���
        HardenPrice % ��ͣ��
        LimitPrice % ��ͣ��
        %------------------------------�ǵ�����
        Rise          %�ǵ����
        Yield         %�ǵ�����%
        Amplitude %��� 
        %-------------------------------�ɽ����
        Volume    %�ɽ���
        Amount    %�ɽ����
        %-------------------------------��ֵ
        CirculationMarketValue%��ͨ��ֵ
        TotalMarketValue   %����ֵ
        %-------------------------------һЩ��ָ��
        PE %  ��ӯ��
        PB %  �о���
        HSL% ������ 
        %-------------------------------�ʽ���
        MInflow              % ��������
        MOutflow           % ��������
        MNetInflow        % ����������
        MNetInflow_Total % ����������/�����������ʽ�
        RInflow              % ɢ������
        ROutflow           % ɢ������
        RNetInflow        % ɢ��������
        RNetInflow_Total % ɢ��������/�����������ʽ�
        TotalFund          % ���������ܽ��
        %--------------------------------��С��
        BuyLargeQuantity % ������ռ��
        BuySmallQuantity % С������ռ��
        SellLargeQuantity % ������ռ��
        SellSmallQuantity % ����С��ռ��
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
         function obj=Stock(Code,varargin)  % ���캯�� 
             addpath([cd,'\pytdx']);
             % e.g.  S=Stock('sh600123')
             % e.g.  S=Stock('600123')
             % e.g.  S=Stock('lhkc')
             % e.g.  S=Stock('sh600123','Flash')
             %---------------------------------------------------------------------
              obj.Code=Code;
             if nargin == 2                 % 'Flash'���ڽ��������ʱ���ȡ����������Ϣ
                 if strcmp(varargin{1},'Flash')
                     obj.Flash;
                 else
                     error('����ֻ��ΪFlash')
                 end
             end
         end % Stock
         function set.Code(obj,value)
             try      % ����Codeת���ӿڲ���(������ƴ�����룬���ٶȻ����)
                 S=Stock.Py2Code(value);
                 Code=S(1);
             catch
                 Code=Stock.CodeCheck(value);    % �����׼��
             end
             %        Code=Stock.CodeCheck(Code);    % �����׼�����������������Ա�����ʹ�ã�
             obj.Code=cell2mat(Code);       % ����
             info=Stock.QuickInfo(obj.Code);% ��ȡ������Ϣ
             obj.Name=info{1,2};            % ����
         end
        %--------------------------------------------------------------------------------------------------------------------------------------- 
         function Val=Block(obj) % ��Ʊ�������(����������ҵ������)
             %-----------------------------------��ȡ�ӿ���Ϣ
             url=['http://ifzq.gtimg.cn/stock/relate/data/plate?code=',obj.Code,'&_var=_IFLOAD_2']; % ��Ʊ������� �����&_var=_IFLOAD_2 �ƺ��ò���
             [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
             if ~status
                 error('��ȡ����\n')
             end
             %-----------------------------------��������ӿ���Ϣ
             expr1='"code":"(.*?)","name":"(.*?)"'; % json ��������ʽ
             [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
             BlockCode=[[date_tokens{:}]']';
             BlockCode=BlockCode(1:2:end)';
             %-------------------------------------����ȡ�İ�������Stock.BlockInfo������ȡ������Ϣ
             Val=Stock.BlockInfo(BlockCode);
         end % Block
         function Val=RelatedStock(obj) % ������Ʊ
             %-----------------------------��ȡ�ӿ�����
             url=['http://ifzq.gtimg.cn/stock/relate/data/relate?code=',obj.Code,'&_var=_IFLOAD_1']
             [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
             if ~status
                 error('��ȡ����\n')
             end
             %-----------------------------��������ӿ�����
             expr1='([shz]{2}\d{6})';
             [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
             Code=[date_tokens{:}]';
             %------------------------------��ȡ�б��Ʊ�Ļ����̿���Ϣ
             Val=Stock.QuickInfo(Code);
         end % RelatedStock
         %---------------------------------------------------------------------------------------------------------------------------------------
         function Flash(obj) % �����̿�����
             info=Stock.Handicap(obj.Code);
                  %---------------------------------------�����̿�����ˢ��
                  obj.RealPrice=str2double(info{1,{'RealPrice'}}); % ���¼۸�
                  obj.Rise=str2double(info{1,{'Rise'}});           % �ǵ��� 
                  obj.Yield=str2double(info{1,{'Yield'}});         % �ǵ���
                  obj.Volume=str2double(info{1,{'Volume'}});       % �ɽ��� 
                  obj.Amount=str2double(info{1,{'Amount'}});       % �ɽ���
                  obj. TotalMarketValue=str2double(info{1,{'TotalMarketValue'}}); % ����ֵ
                  obj.State=info{1,{'State'}};% ״̬
                  t=info.LastTime{:};
                  obj.LastTime=[t(1:4),'-',t(5:6),'-',t(7:8),' ',t(9:10),':',t(11:12),':',t(13:end)];
                  
                  
                  obj.YClosePrice=str2double(info{1,{'YClosePrice'}}); % ����
                  obj.OpenPrice=str2double(info{1,{'OpenPrice'}});     % ��
                  obj.High=str2double(info{1,{'High'}});               % ���
                  obj.Low=str2double(info{1,{'Low'}});                 % ���
                  obj.HardenPrice=str2double(info{1,{'HardenPrice'}}); % ��ͣ��
                  obj.LimitPrice=str2double(info{1,{'LimitPrice'}});   % ��ͣ��
                  
                  obj.Amplitude=str2double(info{1,{'Amplitude'}});     % ���
                  obj.CirculationMarketValue=str2double(info{1,{'CirculationMarketValue'}}); % ��ͨ��ֵ
                  obj.PE=str2double(info{1,{'PE'}});  % ��ӯ��
                  obj.PB=str2double(info{1,{'PB'}});  % �о���
                  obj.HSL=str2double(info{1,{'HSL'}});% ������
                  
                  
         info=Stock.Fund(obj.Code);
                  %-------------------------------�ʽ�������ˢ��
             if ~isempty(info)    % ��Щ�����ָ���ȵ�û���ʽ�������
                  obj.MInflow=str2double(info{1,{'MInflow'}});                  % �����ʽ�����
                  obj.MOutflow=str2double(info{1,{'MOutflow'}});                % �����ʽ�����
                  obj. MNetInflow=str2double(info{1,{'MNetInflow'}});           % �����ʽ�����
                  obj.MNetInflow_Total=str2double(info{1,{'MNetInflow_Total'}});% �����ʽ�����/�ܽ����ʽ�
                  obj.RInflow=str2double(info{1,{'RInflow'}});                  % ɢ���ʽ�����
                  obj.ROutflow=str2double(info{1,{'ROutflow'}});                % ɢ���ʽ�����
                  obj. RNetInflow=str2double(info{1,{'RNetInflow'}});           % ɢ���ʽ�����
                  obj.RNetInflow_Total=str2double(info{1,{'RNetInflow_Total'}});% ɢ���ʽ�����/���ʽ����
                  obj.TotalFund=str2double(info{1,{'TotalFund'}});              % �ܽ����ʽ�
             end
         info=Stock.HandicapAnalysis(obj.Code);
                  %--------------------------------��С������ˢ��
                  obj.BuyLargeQuantity=str2double(info{1,{'BuyLargeQuantity'}});  % ������ռ��
                  obj.BuySmallQuantity=str2double(info{1,{'BuySmallQuantity'}});  % ������ռ��
                  obj.SellLargeQuantity=str2double(info{1,{'SellLargeQuantity'}});% С������ռ��
                  obj.SellSmallQuantity=str2double(info{1,{'SellSmallQuantity'}});% С������ռ��

         end % Flash   
         function Val=RealTick(obj) % ������ʽ������ݣ���
             %-----------------------------------------------��ȡ�ӿ�����
             url=['http://vip.stock.finance.sina.com.cn/quotes_service/view/CN_TransListV2.php?num=90000&symbol=',obj.Code];
             [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
             if ~status
                 error('��ȡ����\n')
             end
             %-----------------------------------------------��������ӿ�����
             expr1='(?<='')([\d:A-Z\.]+)(?='')';
             [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
             Val=[date_tokens{:}];
             Val=reshape(Val,4,length(Val)/4)';
             Val=[Val(:,1),num2cell(str2double(Val(:,2:3))),Val(:,4)];
             %-----------------------------------------------ת����Table����
             Name={'Time','Volume','Price','Direction'};
             Val=cell2table(Val(end:-1:1,:),'VariableNames',Name)
         end % RealTick
         function Val=HistoryTick2(obj,Date) %��ʷ��ʽ���
             %-----------------------------------------��ȡ�ӿ�����
             url=['http://stock.gtimg.cn/data/index.php?appn=detail&action=download&c=',obj.Code,'&d=',datestr(Date,'yyyymmdd')];           
             % ��ȡ��ҳ��Ϣ
             [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
             if ~status
                 error('��ȡ����\n')
             end
             Val=regexp(sourcefile, '[\n\t]', 'split');
             Val=reshape(Val(7:end),6,length(Val(7:end))/6)';
             Name={'Time','Price','P_Change','Volume','Amount','Direction'};
             Val=cell2table([Val(:,1),num2cell(str2double(Val(:,2:5))),Val(:,6)],'VariableNames',Name);

         end % ��Ѷ
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
         
         function Val=Real1m(obj) % ʵʱ1��������
             %---------------------------------------��ȡ�ӿ�����
             url=['http://data.gtimg.cn/flashdata/hushen/minute/',obj.Code,'.js?maxage=10&0.9551210514741698'] % ��Ѷ����1�������ݽӿ�
             [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
             if ~status
                 error('��ȡ����\n')
             end
             %---------------------------------------��������ӿ�����
             expr1='([\.\d]+)'
             [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
             Val=[date_tokens{:}]';
             Val=[Val(2:3:end),num2cell(str2double(Val(3:3:end))),num2cell(str2double(Val(4:3:end)))];
             %---------------------------------------��ϳ�Table����
             Name={'Time','Price','Volume'};
             Val=cell2table(Val,'VariableNames',Name);
              Val.Volume=[Val.Volume(1);diff(Val.Volume)];
             end % Real1m
         function Val=NewlyData(obj, Scale) % ��� 5 15 30 60 ����h�����ߡ���������
             % e.g.:  Stock.NewlyData(5) 
             % e.g.:  Stock.NewlyData('w') 
             %------------------------------------------���������޶�
             if Scale~=5 & Scale~=15 & Scale~=30 & Scale~=60 & Scale~='w' & Scale~='m'
                 error('����Ϊ����5��15��30��60�����ַ�w��m')
             end
             
             if ~isstr(Scale) % 5 15 30 60 �������ݽӿ�
                 %------------------------------------------��ȡ�ӿ���Ϣ��5 15 30 60 ���ӣ�
                 Scale=num2str(Scale);
                 url=['http://money.finance.sina.com.cn/quotes_service/api/json_v2.php/CN_MarketData.getKLineData?symbol=',obj.Code,'&scale=', Scale,'&ma=no&datalen=1023'];
                 % ��ȡ��ҳ��Ϣ
                 [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                 if ~status
                     error('��ȡ����\n')
                 end
                 %------------------------------------------��������ӿ���Ϣ��5 15 30 60 ���ӣ�
                 expr1='(?<=[ynhwe]):"(.*?)"';
                 [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
                 Val=[date_tokens{:}];
                 Val=reshape(Val,6,length(Val)/6)';
                 %------------------------------------------ת����Table���ݣ�5 15 30 60 ���ӣ�
                 Name={'Time','Open','High','Low','Close','Volume'};
                 Val=cell2table([Val(:,1),num2cell(str2double(Val(:,2:end)))],'VariableNames',Name);
             else % week month ���ݽӿ�
                 %------------------------------------------��ȡ�ӿ���Ϣ��week month��
                 if Scale=='w'
                     Scale='weekly';
                 else
                     Scale='monthly';
                 end
                 url=['http://data.gtimg.cn/flashdata/hushen/',Scale,'/',obj.Code,'.js?']; %  ��Ѷ���� �������ݽӿ�
                 % ��ȡ��ҳ��Ϣ
                 [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                 if ~status
                     error('��ȡ����\n')
                 end
                 %------------------------------------------��������ӿ���Ϣ��week month��
                 Val=regexp(sourcefile, '[\n\s\\]', 'split');
                 Val=reshape(Val(4:end-1),8,length(Val(4:end-1))/8)';
                 Val(:,1)=cellfun(@(x) strcat(x(5:6),'/',x(3:4),'/',x(1:2)),Val(:,1),'UniformOutput',0);% ʱ��ṹת��
                 %------------------------------------------ת����Table���ݣ�week month��
                 Name={'Time','Open','High','Low','Close','Volume'};
                 Val=cell2table([Val(:,1),num2cell(str2double(Val(:,2:end-2)))],'VariableNames',Name);
             end
             
             
         end % NewlyData
         function Val=PriceList(obj,BeginDate,EndDate) % �׶ηּ۱�
             % e.g.: Stock.PriceList('2015-09-01','2015-09-10')
             %------------------------------------------��ȡ�ӿ�����
             url=['http://market.finance.sina.com.cn/pricehis.php?symbol=',obj.Code,'&startdate=',BeginDate,'&enddate=',EndDate];
             % ��ȡ��ҳ��Ϣ
             [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
             if ~status
                 error('��ȡ����\n')
             end
             %------------------------------------------��������ӿ�����
             expr1='(?<=<tbody>)(.*?)(?=</tbody>)';
             [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
             
             if ~isempty(date_tokens) % �ж��Ƿ��ȡ��
                 sourcefile=date_tokens{:}{:};
                 expr1='(?<=<td>)(.*?)(?=</td>)';
                 [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
                 Val=[date_tokens{1:3:end};date_tokens{2:3:end};date_tokens{3:3:end}]';
                 Val=[num2cell(str2double(Val(:,1:2))),num2cell(str2double(strrep(Val(:,3),'%','')))];
                 %------------------------------------------ת��ΪTable��������
                 Name={'Price','Volume','Percent'};
                 Val=cell2table(Val,'VariableNames',Name); 
             else
                 Val=[];
             end
             
             
             
         end % PriceList
         
         function Val=HistoryDaily2(obj,BeginDate,EndDate)% ��ʷ���߽���
             %----------------------------------------���ڸ�ʽ����ת��
             BeginDateF=datestr(BeginDate,'yyyy-mm-dd');
             EndDateF=datestr(EndDate,'yyyy-mm-dd');
              connection=database('testDB','postgres','123456','org.postgresql.Driver','jdbc:postgresql://localhost:5432/testDB');
              query = ['select date,open,high,close,low,volume from aa where code=''',obj.Code,''' and date>=''',BeginDateF,''' and date<=''',EndDateF,''''];
              curs = exec(connection, query);
              row = fetch(curs);
              Val=row.Data(:,1:end);
              Val=[datenum(Val(:,1)),cell2mat(Val(:,2:end))];
              close(connection)
             %-------------------------------------���뵱�ձ䶯����
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
         function Val=HistoryDaily3(obj,BeginDate,EndDate)% ��ʷ���߽���
             BeginDateF=datestr(BeginDate,'yyyy-mm-dd');
             EndDateF=datestr(EndDate,'yyyy-mm-dd');
             date_len=datenum(EndDateF,'yyyy-mm-dd')-datenum(BeginDateF,'yyyy-mm-dd');
             url=['http://web.ifzq.gtimg.cn/appstock/app/fqkline/get?_var=kline_dayqfq&param=',obj.Code,',day,',BeginDateF,',',EndDateF,',',num2str(date_len),',qfq&r=',num2str(rand)]
             [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
             if ~status
                 error('��ȡ����\n')
             end
             jsonStruct=jsondecode(sourcefile(14:end));
             fn=eval(['fieldnames(jsonStruct.data.',obj.Code,');']);
             celldata=eval(['jsonStruct.data.',obj.Code,'.',fn{1},';']);
             dateArr=cellfun(@(x) datenum(x{1},'yyyy-mm-dd'),celldata);
             d=cell2mat(cellfun(@(x) [str2num(x{2}),str2num(x{4}),str2num(x{3}),str2num(x{5}),str2num(x{6})],celldata,'UniformOutput', false));
             Val=[dateArr,d];
             %-------------------------------------���뵱�ձ䶯����
             if datenum(EndDate)>=today && datenum(Val(end,1))<today && ~strcmp(obj.State,'S')
                 obj.Flash;
                 if datenum(obj.LastTime)>=today && datenum(obj.LastTime)>datenum(Val(end,1))
                     TodayK=[today,obj.OpenPrice,obj.High,obj.RealPrice,obj.Low,obj.Volume];
                     Val=[Val;TodayK];
                 end
             end
             name={'Date','Open','High','Close','Low','Volume'};
             Val=cell2table([cellstr(datestr(Val(:,1),'yyyy-mm-dd')),num2cell(Val(:,2:end))],'VariableNames',name);
         end %ifeng����
         function Val=HistoryDaily(obj,BeginDate,EndDate)% ��ʷ���߽���
             BeginDateF=datestr(BeginDate,'yyyy-mm-dd');
             EndDateF=datestr(EndDate,'yyyy-mm-dd');
             date_len=min(datenum(EndDateF,'yyyy-mm-dd')-datenum(BeginDateF,'yyyy-mm-dd'),800);
             ed=min(datenum(BeginDateF,'yyyy-mm-dd')+800,datenum(EndDateF,'yyyy-mm-dd'));
             celldata=[];
             while 1
                  url=['http://web.ifzq.gtimg.cn/appstock/app/fqkline/get?_var=kline_dayfq&param=',obj.Code,',day,',BeginDateF,',',datestr(ed,'yyyy-mm-dd'),',',num2str(date_len),',fq&r=',num2str(rand)];
                 [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                 if ~status
                     error('��ȡ����\n')
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
             %-------------------------------------���뵱�ձ䶯����
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
         end %ifeng����
         %---------------------------------------------------------------------------------------------------------------------------------------
         function Val=Indicators(obj, type ,ParameterList,DateRange,varargin) %�������ָ��
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
                 error('�����������')
             end
              L=max(cell2mat(cellfun(@(x) x(1),ParameterList,'UniformOutput', false)));
              st=datestr(datenum(stold)-L-60,'yyyy-mm-dd');
              ed=edold;
              
              obj.stold=stold;
              obj.edold=edold;
              obj.st=st;
              obj.ed=ed;
              
              KData=obj.HistoryDaily(st,ed); % K������ѡ��ǰ��Ȩ
              L=length(KData.Date);
              for i=1:length(type)
                    switch type{i}
                        case 'Y' % ������
                            Len=ParameterList{i};
                            out=obj.Y(KData,Len);
                            eval(['KData.Y',num2str(Len),'=out;'])
                        case 'Highest'  %�׶����ֵ
                            Len=ParameterList{i};
                            out=obj.Highest(KData,Len);
                            eval(['KData.High',num2str(Len),'=out;'])                           
                        case 'Lowest' %�׶���Сֵ
                            Len=ParameterList{i};
                            out=obj.Lowest(KData,Len);
                            eval(['KData.Low',num2str(Len),'=out;'])            
                        case 'MA' % �ƶ�ƽ��
                            Len=ParameterList{i};
                             out=obj.MA(KData,Len);
                            eval(['KData.MA',num2str(Len),'=out;'])                                       
                        case 'EMA'
                            Len=ParameterList{i};
                              out=obj.EMA(KData,Len);
                            eval(['KData.EMA',num2str(Len),'=out;'])                                        
                        case 'STD' % �׶α�׼��
                            Len=ParameterList{i};
                              out=obj.STD(KData,Len);
                            eval(['KData.STD',num2str(Len),'=out;'])                                            
                        case 'BOLL' % ���ִ�ָ��
                            Len=ParameterList{i}(1);
                            Width=ParameterList{i}(2); 
                            out=obj.BOLL(KData,Len,Width);
                            eval(['KData.BOllMid',num2str(Len),'_',num2str(Width),'=out(:,1);'])
                            eval(['KData.BOllUp',num2str(Len),'_',num2str(Width),'=out(:,2);'])
                            eval(['KData.BOllDown',num2str(Len),'_',num2str(Width),'=out(:,3);'])
                        case 'MACD' % MACD ָ�����
                            if length(ParameterList{i})~=3
                                error('MACD ������������')
                            end
                            LeadLen=ParameterList{i}(1);
                            LagLen=ParameterList{i}(2);
                            DIFFLen=ParameterList{i}(3);
                            out=obj.MACD(KData,LeadLen,LagLen,DIFFLen);
                            eval(['KData.DIFF',num2str(LeadLen),'_',num2str(LagLen),'_',num2str(DIFFLen),'=out(:,1);'])
                            eval(['KData.DEA',num2str(LeadLen),'_',num2str(LagLen),'_',num2str(DIFFLen),'=out(:,2);'])
                            eval(['KData.MACD',num2str(LeadLen),'_',num2str(LagLen),'_',num2str(DIFFLen),'=out(:,3);'])
                        case 'BIAS' % ������
                            if length(ParameterList{i})==1
                                LenLead=1;
                                LenLag=ParameterList{i}(1);
                            elseif length(ParameterList{i})==2
                                LenLead=ParameterList{i}(1);
                                LenLag=ParameterList{i}(2);
                            else
                                error('BIAS ������������')
                            end
                            out=obj.BIAS(KData,LenLead,LenLag);
                            eval(['KData.BIAS',num2str(LenLead),'_',num2str(LenLag),'=out;']);
                        case 'KDJ'
                            if length(ParameterList{i})~=3
                                error('KDJ ������������')
                            end
                            Len= ParameterList{i}(1);
                            M1=ParameterList{i}(2);
                            M2=ParameterList{i}(3);
                            out=obj.KDJ(KData,Len,M1,M2);
                           eval(['KData.K',num2str(Len),'_',num2str(M1),'_',num2str(M2),'=out(:,1);']);
                           eval(['KData.D',num2str(Len),'_',num2str(M1),'_',num2str(M2),'=out(:,2);']);
                           eval(['KData.J',num2str(Len),'_',num2str(M1),'_',num2str(M2),'=out(:,3);']);
                        case 'RSI' % ���ǿ��ָ��
                            Len= ParameterList{i};
                            out=obj.RSI(KData,Len);
                            eval(['KData.RSI',num2str(Len),'=out;'])
                        case 'LB'% ����
                            out=obj.Lb2(KData,5);
                            KData.Lb5=out;
                        case 'OBV' % ���ɽ���
                            out=obj.OBV(KData);
                            KData.OBV=out;
                        case 'SAR' % ������ת��ָ��
                            Len= ParameterList{i};
                            out=obj.SAR(KData,Len);
                            eval(['KData.SAR',num2str(Len),'=out;'])
                        case 'DMI' % ����ָ��(��׼)
                            if length(ParameterList{i})~=2
                                error('DMI ������������')
                            end
                            N= ParameterList{i}(1);
                            M= ParameterList{i}(2);
                            out=obj.DMI(KData,N,M);
                            eval(['KData.PDI',num2str(N),'_',num2str(M),'=out(:,1);']);
                            eval(['KData.MDI',num2str(N),'_',num2str(M),'=out(:,2);']);
                            eval(['KData.ADX',num2str(N),'_',num2str(M),'=out(:,3);']);
                            eval(['KData.ADXR',num2str(N),'_',num2str(M),'=out(:,4);']);
                        case 'CCI' % ˳��ָ��
                            N= ParameterList{i};
                            out=obj.CCI(KData,N);
                            eval(['KData.CCI',num2str(N),'=out;'])
                        case 'PSY' % ������
                            N= ParameterList{i};
                            out=obj.PSY(KData,N);
                            eval(['KData.PSY',num2str(N),'=out;'])
                        otherwise 
                            error('û����Ӧָ��')
                    end
                    
              end    
              % �����⵽ AllOut ����Ϊ 1 �ͽ�����ǰ������һ�����
              if ~isempty(varargin) & mod(length(varargin),2)==0 & varargin{find(strcmp(varargin,'AllOut'))+1}
                  Val=KData;
              elseif ~isempty(varargin) & mod(length(varargin),2)~=0
                  error('������������')
              else
                  Val=KData(datenum(KData.Date)>=datenum(stold),:);
              end
              
         end % Indicators
         function Val=Lb(obj,varargin) % ���ȣ�ʵʱ����ʷ��
             %-------------------------------------------------------------
             % e.g. Val=Stock.Lb                  %����ÿ������������
             % e.g. Val=Stock.Lb('2015-03-02')    %��ʷĳ��ÿ������������
             % e.g. Val=Stock.Lb('2015-03-02','2015-04-30') % ����daily����
             %-------------------------------------------------------------
             if nargin==1 | (nargin==2 & datenum(varargin)==today) % ����ÿ������������
                 if strcmp(obj.State,'')
                     r1m=obj.Real1m; % ����ʵʱ1��������
                     r1m.Mint=[1:length(r1m.Time)]'; % �б��������ݵ��ѹ�������
                     r1m.TVolume=cumsum(r1m.Volume); % ÿ���ӵ��ۼƳɽ���
                     K=obj.HistoryDaily(datenum(obj.LastTime)-60,datenum(obj.LastTime)); % K������
                     v5m=sum(K.Volume(end-5:end-1))/1200; % ǰ5��ÿ���ӳɽ���
                     r1m.Lb=r1m.TVolume./(v5m*r1m.Mint); % ����ÿ���ӵ���������
                     Val= r1m(:,{'Time','Lb'});
                 else
                     Val=NaN;
                 end
                 
             elseif nargin==2 & datenum(varargin)<today % ��ʷÿ��ÿ������������
                 day=varargin{1};
                 ht=obj.HistoryTick(day);
                 if isempty(ht)
                     Val=NaN;
                 else
                     ht.Time=datestr(ht.Time,'HH:MM');
                     ht=ht(:,{'Time','Volume'});
                     r1m=grpstats(ht,'Time',{'sum'});
                     r1m.TVolume=cumsum(r1m.sum_Volume);
                     r1m.Mint=[1:length(r1m.Time)]'; % �б��������ݵ��ѹ�������
                     K=obj.HistoryDaily(datenum(day)-60,datenum(day)); % K������
                     v5m=sum(K.Volume(end-5:end-1))/1200; % ǰ5��ÿ���ӳɽ���
                     r1m.Lb=r1m.TVolume./(v5m*r1m.Mint); % ����ÿ���ӵ���������
                     Val= r1m(:,{'Time','Lb'});
                 end
             elseif nargin==3
                 stold=varargin{1};
                 edold=varargin{2};
                 st=datenum(stold)-60;
                 ed=edold;
                 K=obj.HistoryDaily(st,ed); % K������
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
                 error('���������������')
                 
             end
             
         end %Lb
         %---------------------------------------------------------------------------------------------------------------------------------------
         
    end % methods 
    
    
    methods (Access='private')
        function Val=fuquan(obj,KData,type) % ��Ȩ(��Ѷ��Ȩ����)
            %-----------------------------------------------------------���ظ�Ȩ����
            url=['http://data.gtimg.cn/flashdata/hushen/fuquan/',obj.Code,'.js?maxage=6000000']
            [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
            if ~status
                % error('��ȡ����\n')
                Val=KData;
            else
                expr1='(?<=["~^])([\d.]+)(?=["~])';
                [~, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
                fqData=[date_tokens{:}]';
                t=cell2mat(cellfun(@(x) datenum([x(:,1:4),'/',x(5:6),'/',x(7:8)]),fqData(1:3:end),'UniformOutput' ,false));
                fqData=[t,str2double([fqData(2:3:end),fqData(3:3:end)])];
                fqData(:,3)=cumprod(fqData(:,3));
                %------------------------------------------------------------���ظ�Ȩ����
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
            % ָ��EMAϵ��
            if isempty(coef)
                k = 2/(len + 1);
            else
                k = coef;
            end
            Price=eval(['KData.',field,';']);
            Price(isnan(Price))=0;
            % ����EMAvalue
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
            % ָ��SMAϵ��
            if isempty(coef)
               % k = 2/(len + 1);
               k = 1/len;
            else
                k = coef;
            end
            Price=eval(['KData.',field,';']);
            Price(isnan(Price))=0;
            % ����SMAvalue
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
        function Val=Lb2(obj,KData,Len) % Lb2���ռ��������
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
            %-----------------ѡ��ʼ��
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
            AFALL=NaN(L,1);%-------------- �������
            
            if starti==mini % �׸�SAR����
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
                    case 'up' % ����ͨ��
                        
                      if Low(i)<SAR(i) % ��תΪ���ж�
                          SAR(i+1)=HH(i);
                          AF=0.02; 
                          AFALL(i)=AF;% -------------- �������
                          type='down';
                      else % ��������ͨ������
                          if HH(i+1)>HH(i) % �ж�AF�Ƿ�����
                              AF=min(AF+0.02,0.2);
                          end
                          AFALL(i)=AF;% --------------
                          SAR(i+1)=SAR(i)+AF*(HH(i)-SAR(i)); 
                      end
                      
                    case 'down'
                      if High(i)>SAR(i) % ��תΪ���ж�
                          SAR(i+1)=LL(i);
                          AF=0.02; 
                          AFALL(i+1)=AF;% -------------- �������
                          type='up';
                      else % �����½�ͨ������
                          if LL(i+1)<LL(i) % �ж�AF�Ƿ�����
                              AF=min(AF+0.02,0.2);
                          end
                           AFALL(i+1)=AF;% -------------- �������
                          SAR(i+1)=SAR(i)+AF*(LL(i)-SAR(i)); 
                      end                       
                        
                end
            end
            [KData.Date,num2cell([SAR,HH,LL,Close,AFALL])];%------------- �������
            Val=SAR;
        end % SAR
        function Val=DMI(obj,KData,N,M) % DMI
            L=length(KData.Date);
            High=KData.High;
            Low=KData.Low;
            Close=KData.Close;
            TR1=High-Low;%���յ���߼ۼ�ȥ���յ���ͼ۵ļ۲�
            TR2=abs(High-[NaN;Close(1:end-1)]);% ���յ���߼ۼ�ȥǰһ�յ����̼۵ļ۲�
            TR3=abs(Low-[NaN;Close(1:end-1)]);% ���յ���ͼۼ�ȥǰһ�յ����̼۵ļ۲�
            KData.Temp=max([TR1,TR2,TR3],[],2);% TR ȡ�������ֵ
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
        function List=StockList % ���ع�Ʊ�������ƶ��ձ�
            % e.g.: List=Stock.StockList
            %----------------------------------------------��ȡ�ӿ�����
            [sourcefile, status] =urlread(sprintf('http://quote.eastmoney.com/stocklist.html'),'Charset','GBK');
            if ~status
                error('��ȡ����\n')
            end
            %----------------------------------------------������������
            expr1='<li><a target="_blank" href="http://quote.eastmoney.com/.*?">(.*?)\((\d+)\)</a></li>';
            [~, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
            a=[date_tokens{:}];
            %----------------------------------------------�������
            List=[a(2:2:end);a(1:2:end)]';
        end % StockList
        function out=CodeNameChange(in)  % �������ֻ���ת��
            
            List=Stock.StockList;
            if in(1:2)=='sh' | in(1:2)=='sz'
                in=in(3:end);
                out=List(strmatch(in,List),2);
            else
                out=List(strmatch(in,List)-length(List),1);
            end
            if size(out,1)>1 | size(out,1)==0
                out
                error('�ж��ƥ�������ƥ����')
            end
            out=out{:};
        end % CodeNameChange
        function out=CodeCheck(in) % ��׼���������
            if ~iscell(in) % ת����Ϊcell�������� '600001'ת��Ϊ{'600001'}����
                in={in};
            end
            out=[];
                  for i=1:length(in) % ��cell�����е�ÿһ����Ա���б�������
                      C=in{i};
                      if ~isstr(C)
                          error('�������Ϊ�ַ���')
                      end
                      if  length(C)==6 & (strcmp(C(1),'6') | strcmp(C,'000001')) % ���д���
                          out{i}= ['sh',C];
                      elseif length(C)==6 & (strcmp(C(1),'0') | strcmp(C(1),'3')) & ~strcmp(C,'000001') % ���д���
                          out{i}= ['sz',C];
                      else % ���ఴԭ�����
                          out{i}=[C];
                      end
                  end
            
        end % CodeCheck
        function out=Py2Code(in,outtype) % ƴ������ת��
            if  iscell(in) 
                in=in{:};
            end
            url=['http://smartbox.gtimg.cn/s3/?q=',in,'&t=gp']; % ƴ������ת���ӿ�
            [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
            if ~status
                error('��ȡ����\n')
            end
            sourcefile2= regexp(sourcefile, '[~"^]', 'split')';
            Code=strcat(sourcefile2(2:5:end-1),sourcefile2(3:5:end));
            Py=sourcefile2(5:5:end-1);
            if ~isempty(Py)
                info=Stock.QuickInfo(Code);
                Name=info.Name;
                out=[Code,Py,Name];
            else
                error('û����Ϣ')
            end

        end
        %-------------------------------------------------------------------------------------------------------------------
        function info=QuickInfo(Code) % ��Code�б��Ʊ���ٻ�ȡ��ʱ�۸���Ϣ
            % e.g.:  info=QuickInfo('600123')
            % e.g.:  info=QuickInfo({'600123','000523'})
            Code=Stock.CodeCheck(Code); % ��������׼��

            % ��Ѷ���ݽӿڵ�ַ��ͷ
            urlHead='http://qt.gtimg.cn/q=';
            %-----------------------------------------------------
            sourcefileall=[];
            b=1; % 
            e=60;% һ��������Ĵ������������url���ƣ�
            len=length(Code); % �������
            while b<=len 
                % ������ת���ɵ�ַ��ɲ���
                C=strcat('s_',Code(b:min(e,len)),',');
                urlAddress=strcat(urlHead,[C{:}]);
                % ��ȡ��ҳ��Ϣ
                [sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
                if isempty(sourcefile)
                    error('û�д˹�Ʊ����')
                end
                if ~status
                    error('��ȡ����\n')
                end
                sourcefileall=[sourcefileall,sourcefile];
                b=b+60;
                e=e+60;% ����Ҫ��ȡ�Ĵ���
            end
            %-------------------------------------------------------
            % ������ʽ(����Ʊ��Ϣ�б������������)
            expr1='(?<=v_)(.*?)(?=";)';
            [datefile, date_tokens]= regexp(sourcefileall, expr1, 'match', 'tokens');
            sourcefile=[date_tokens{:}]';
            if isempty(sourcefile)
                error(['û�й�Ʊ',Code{:},'������'])
            end
            % ������ȡ��Ϣ
            for i=1:length(sourcefile)
                % ������ʽ(��ȡ�ؼ�����)
                expr1='(?<==")(.*)';
                [datefile, date_tokens]= regexp(sourcefile{i}, expr1, 'match', 'tokens');
                sourcefile2=date_tokens{:};
                % �ָ���Ϣ
                ss=regexp(sourcefile2, '~', 'split');
                % �����ȡ����Ϣ
                S(i,:)=ss{:};
            end
            S(:,[4:8,10])=num2cell(str2double(S(:,[4:8,10])));
            S(:,3)=strcat(strrep(strrep(S(:,1),'51','sz'),'1','sh'),S(:,3));
            Explain={'�г�����','����','����','��ǰ�۸�','�ǵ�','�ǵ�%','�ɽ���(��)','�ɽ���(��)','״̬','����ֵ','unknow'};
            Name={'Market','Name','Code','RealPrice','Rise','Yield','Volume','Amount','State','TotalMarketValue','unknow'};
            info=cell2table(S,'VariableNames',Name');  
        end % QuickInfo
        function info=HistoryK(CodeList,BeginDate,EndDate) % ���ƱK���������
            %e.g. Stock.HistoryK('600123','2015-01-01','2015-01-31')
            %e.g. Stock.HistoryK({'600123','000523'},'2015-01-01','2015-01-31')
            % ���ΪStruct�������ֶ���Ϊ���룬����ΪCell��ʽ
            
            %-------------------------------------
            CodeList=Stock.CodeCheck(CodeList); % ���������׼��
            % ------------------------------------���������׼��
            BeginDate=datestr(BeginDate,'yyyymmdd');
            EndDate=datestr(EndDate,'yyyymmdd');
            hwait=waitbar(0,'��ȴ�>>>>>>>>');
            L=length(CodeList);
            for i=1:L % ��ÿһ�������������
                tic
                Code=CodeList{i};
                %---------------------------------------��ȡ�ӿ���Ϣ
                url=['http://biz.finance.sina.com.cn/stock/flash_hq/kline_data.php?symbol=',Code,'&end_date=',EndDate,'&begin_date=',BeginDate] % ����K������
                % ��ȡ��ҳ��Ϣ
                [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                if ~status
                    error('��ȡ����\n')
                end
                toc
                %---------------------------------------��������ӿ���Ϣ
                tic
                expr1='(?<=[dohclv])="(.*?)" ';
                [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
                Val=[date_tokens{:}];
                toc
                %---------------------------------------��������ӿ���Ϣ
                tic
                Name={'Date','Open','High','Close','Low','Volume'};
                if ~isempty(Val)
                    Val=reshape(Val,7,length(Val)/7)';
                    %Val=[Val(:,1),num2cell(str2double(Val(:,2:6)))];
                    Val=cell2table([Val(:,1),num2cell(str2double(Val(:,2:6)))],'VariableNames',Name);
                end
                %------------------------------����Ϣ�洢����Struct�����У�����Ϊ�ֶ���
                eval(['info.',Code,'=Val;']);
                toc
                waitbar(i/length(CodeList),hwait,[num2str(i/length(CodeList)*100),'%',':',num2str(CodeList{i}),',',num2str(i),'/',num2str(length(CodeList))]);% ������

            end
                close(hwait);% �رս�����
        end % HistoryK
        function info=Handicap(Code)%�̿���Ϣ
            Code=Stock.CodeCheck(Code);
            % ��Ѷ���ݽӿڵ�ַ��ͷ
            urlHead='http://qt.gtimg.cn/q=';
            %--------------------------------------------------------------
            sourcefileall=[];
            b=1;
            e=60;% ����һ�ζ�ȡ�Ĵ���������URL���ƣ�
            len=length(Code); % �������
            while b<=len 
                C=strcat(Code(b:min(e,len)),',');
                urlAddress=strcat(urlHead,[C{:}]);
                % ��ȡ��ҳ��Ϣ
                [sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
                if ~status
                    error('��ȡ����\n')
                end
                sourcefileall=[sourcefileall,sourcefile];
                b=b+60;
                e=e+60;                
            end
            expr1='(?<=v_)(.*?)(?=";)';
            [datefile, date_tokens]= regexp(sourcefileall, expr1, 'match', 'tokens');
            sourcefile=[date_tokens{:}]';
            % ������ȡ��Ϣ
            for i=1:length(sourcefile)
                % ������ʽ(��ȡ�ؼ�����)
                expr1='(?<==")(.*)';
                [datefile, date_tokens]= regexp(sourcefile{i}, expr1, 'match', 'tokens');
                sourcefile2=date_tokens{:};
                % �ָ���Ϣ
                ss=regexp(sourcefile2, '~', 'split');
                % �����ȡ����Ϣ
                S(i,:)=ss{:};
            end
            % ����
            Explain={'�г�','����','����','��ǰ�۸�','����','��','�ɽ������֣�','����','����','��һ','��һ�����֣�','���','��������֣�','����'...
                ,'���������֣�','����','���������֣�','����','���������֣�','��һ','��һ�����֣�','����','���������֣�','����','���������֣�'...
                ,'����','���������֣�','����','���������֣�','�����ʳɽ�','ʱ��','�ǵ�','�ǵ�%','���','���','�۸�/�ɽ������֣�/�ɽ���','�ɽ������֣�'...
                ,'�ɽ����','������','��ӯ��','[blank]','���','���','���','��ͨ��ֵ','����ֵ','�о���','��ͣ��','��ͣ��','[blank]'};
            Name={'Market','Name','Code','RealPrice','YClosePrice','OpenPrice','Volume','B','S','Buy1Price','Buy1Volume','Buy2Price','Buy2Volume','Buy3Price','Buy3Volume','Buy4Price','Buy4Volume','Buy5Price','Buy5Volume','Sell1Price','Sell1Volume','Sell2Price','Sell2Volume','Sell3Price','Sell3Volume','Sell4Price','Sell4Volume','Sell5Price','Sell5Volume','LastTransaction','LastTime','Rise','Yield','HighPrice','LowPrice','Price_Volume_Amount','Volume2','Amount','HSL','PE','State','High','Low','Amplitude','CirculationMarketValue','TotalMarketValue','PB','HardenPrice','LimitPrice','blank2','blank3','blank4','blank5','blank6','blank7','blank8','blank9','blank10','blank11','blank12','blank13','blank14'};
            % ����������Ϣ���
              info=cell2table(S(:,1:size(Name,2)),'VariableNames',Name');
            
            %--------------------------------------------------------------
        end% Handicap
        function info=Fund(Code) %�ʽ�����
            Code=Stock.CodeCheck(Code);
            % ��Ѷ���ݽӿڵ�ַ��ͷ
            urlHead='http://qt.gtimg.cn/q=';
            %-----------------------------------------------------
            sourcefileall=[];
            b=1;
            e=60;
            len=length(Code);
            while b<=len
                  % ������ת���ɵ�ַ��ɲ���
                C=strcat('ff_',Code(b:min(e,len)),',');
                urlAddress=strcat(urlHead,[C{:}]);
                [sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
                if ~status
                    error('��ȡ����\n')
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
                % �ָ���Ϣ
                ss=regexp(sourcefile2, '~', 'split');
                % �����ȡ����Ϣ
                S(i,:)=ss{:};
            end
            Explain={'����','��������','��������','����������','����������/�ʽ����������ܺ�','ɢ������','ɢ������','ɢ��������','ɢ��������/�ʽ����������ܺ�',...
                '�ʽ����������ܺ�1+2+5+6','δ֪','δ֪','����','����','δ֪','δ֪','δ֪','δ֪','δ֪','δ֪','δ֪'};
             Name={'Code','MInflow','MOutflow','MNetInflow','MNetInflow_Total','RInflow','ROutflow','RNetInflow','RNetInflow_Total','TotalFund','unknow1','unknow2','Name','LastTime','unknow3','unknow4','unknow5','unknow6','unknow7','unknow8','unknow9'};
             if ~isempty(S)
                 info=cell2table(S,'VariableNames',Name(1:size(S,2)));
             else
                 info=[];
             end
        end% Fund
        function info=HandicapAnalysis(Code)%�̿ڴ�С������
            Code=Stock.CodeCheck(Code);
            % ��Ѷ���ݽӿڵ�ַ��ͷ
            urlHead='http://qt.gtimg.cn/q=';    
            %-----------------------------------------------------
            sourcefileall=[];
            b=1;
            e=60;
            len=length(Code);
            while b<=len
                % ������ת���ɵ�ַ��ɲ���
                C=strcat('s_pk',Code(b:min(e,len)),',');
                urlAddress=strcat(urlHead,[C{:}]);
                % ��ȡ��ҳ��Ϣ
                [sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
                if ~status
                    error('��ȡ����\n')
                end
                sourcefileall=[sourcefileall,sourcefile];
                b=b+60;
                e=e+60;
            end
                        % ������ʽ(����Ʊ��Ϣ�б������������)
            expr1='(?<=v_)(.*?)(?=";)';
            [datefile, date_tokens]= regexp(sourcefileall, expr1, 'match', 'tokens');
            sourcefile=[date_tokens{:}]';
            % ������ȡ��Ϣ
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
            Explain={'����','���̴�','����С��','���̴�','����С��'};
            Name={'Code','BuyLargeQuantity','BuySmallQuantity','SellLargeQuantity','SellSmallQuantity'};
            % info=cell2table([title',S']','VariableNames',Title','RowNames',{'Title',Code{:}}');
            info=cell2table(S,'VariableNames',Name);
        end % HandicapAnalysis
        %--------------------------------------------------------------------------------------------------------------------
        function Val=BlockInfo(BlockCode) % �������ѯ��������Ϣ������
            %----------------------------------------------
            sourcefileall=[];
            b=1;
            e=60; % ÿ�ζ���60�����ݣ�URL���ƣ�
            len=length(BlockCode); % �������
            while b<=len % �Դ�����б���
                %------------------------------------------------------------------URLƴ�Ӽ��ӿ����ݶ�ȡ
                urltail=strcat('bkhz',BlockCode(b:min(e,len)),',');
                urltail=strcat(urltail{:});
                url=['http://push3.gtimg.cn/q=',urltail(1:end-1)]; % ��Ѷ�������������Ϣ�ӿ�
                [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                if ~status
                    error('��ȡ����\n')
                end
                sourcefileall=[sourcefileall,sourcefile];
                b=b+60;
                e=e+60; % ����������һ�����
            end
            %------------------------------------------------------����������ӿ�����
            expr1='(?<=\=")(.*?)(?=";)';
            [datefile, date_tokens]= regexp(sourcefileall, expr1, 'match', 'tokens');
            sourcefile2=[date_tokens{:}]';
            Val=regexp(sourcefile2, '~', 'split');
            Val=[Val{:}];
            Val=reshape(Val,18,length(Val)/18)';
            %--------------------------------------------------------��ϳ�Table����
            Explain={'������','�������','���Ǽ���','ͣ�Ƽ���','�µ�����','�ܹ�Ʊ��',...
                'ƽ���۸�','�ǵ���','�ǵ���','�ܳɽ���','�ܳɽ���','���ǹ�Ʊ','�����Ʊ',...
                '�����ʽ�����','�����ʽ�����','�����ʽ�����','δ֪','ռ���ɽ���'};
            Name={'Code','Name','RiseNum','FlatNum','FullNum','TotleNum',...
                'AveragePrice','Rise','Yield','Volume','Amount','Top1','Last1'...
                ,'MainInflow','MainOutflow','Main9NetInflow','unknow1','TurnoverRatio'};
            Val=cell2table([Val(:,1:2),num2cell(str2double(Val(:,3:11))),Val(:,12:13),num2cell(str2double(Val(:,14:end)))],'VariableNames',Name);
        end %BlockInfo
        function StockList=BlockStock(BlockCode) % �������ѯ��ѯ���������Ʊ
            %------------------------------------------------------------------��ȡ�ӿ���Ϣ
            url=['http://stock.gtimg.cn/data/index.php?appn=rank&t=',['pt',BlockCode],'/chr&p=1&o=0&l=800&v=list_data']
             [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
             if ~status
                 error('��ȡ����\n')
             end
            %------------------------------------------------------------------����������ӿ���Ϣ 
             expr1='([shz]{2}\d{6})';
             [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
             Code=[date_tokens{:}]';
             %------------------------------------------------------------------����ȡ�Ĵ�����Stock.QuickInfo��ȡ��Ʊ������Ϣ
             StockList=Stock.QuickInfo(Code);
        end%BlockStock
        function List=BlockList(in) % ���� ��ҵ ���� ����б�
           switch in
               case 1  % ��Ѷ��ҵ���
                   about='01'; 
               case 2  % ������
                   about='02';
               case 3  % ������
                   about='03';
               case 4  % ֤�����ҵ���
                   about='04';
               otherwise
                   error('���ʵ����')
           end
           %--------------------------------------------------------------------------------��ȡ�ӿ�����
           url=['http://stock.gtimg.cn/data/view/bdrank.php?&t=',about,'/averatio&p=1&o=0&l=800&v=list_data'];
           [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
           if ~status
               error('��ȡ����\n')
           end
           %--------------------------------------------------------------------------------������Ͻӿ�����
          expr1='bkqt(\w+)[,'']';
         [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
         BlockCode=[date_tokens{:}]';
         %--------------------------------------------------------------------------------����ȡ�İ�������Stock.BlockInfo��ȡ��������Ϣ
         List=Stock.BlockInfo(BlockCode) ;
        end % BlockList
        %--------------------------------------------------------------------------------------------------------------------
        function List=TechnologyChoice(Type,Para) % ��Ѷ����ѡ��
            % e.g. Stock.TechnologyChoice('ljzf',10)
            %----------------------------------------------------------------------------------------------------------------
            %     1             2         3         4              5             6           7           8         9
            %   ljzf           lxsz      lxxd      hsltj         bigsell      bigbuy       cjltz       ylcb       lzjz
            % �ۼ��Ƿ�       ��������   �����µ�    ������ͳ��      ������       ����      �ɽ���ͻ��  Զ��ɱ�    ��������
            % {5 10 20 30 }  {3 5 7}   {3 5 7} {5 10 20 60 120} {1 2 3 4 5} {1 2 3 4 5}      {1}        {1}        {1}
            % {'�ۼ��Ƿ�'}  {'��������'}{'��������'}{'�ۼƻ�����'}{'�󵥻�����'}{'�󵥻�����'}{'�����ǵ���'}{'Զ���'}{'����'}
            T={'ljzf','lxsz','lxxd','hsltj','bigsell','bigbuy','cjltz','ylcb','lzjz'}; 
            if isstr(Type)                % �������������������Ʒ�Χ����
               Type=find(ismember(T,Type));
               if isempty(Type)
                   Type=10;
               end
            end
            if ~isnumeric(Para)     
                error('�����������Ϊ����')
            end
            switch Type % ѡ��������
                case 1
                    % �ۼ��Ƿ� P={5 10 20 30} OutPara={'�ۼ��Ƿ�'}
                    P=[5 10 20 30];
                    if ~sum(Para==P) % �޶���������
                        error(['"�ۼ��Ƿ�"��������������Ϊ��',num2str(P)])
                    end
                    Name={'FullCode',['ljzf',num2str(Para)]};
                    Explain={'����',[num2str(Para),'���ۼ��Ƿ�']};
                case 2
                    % �������� P={3 5 7} OutPara={'��������'}
                    P=[3 5 7];
                    if ~sum(Para==P)
                        error(['"��������"��������������Ϊ��',num2str(P)])
                    end    
                    Name={'FullCode',['lxts',num2str(Para)]};
                    Explain={'����','������������'};
                case 3
                    % �����µ� P={3 5 7} OutPara={'��������'}
                    P=[3 5 7];
                    if ~sum(Para==P)
                        error(['"�����µ�"��������������Ϊ��',num2str(P)])
                    end
                    Name={'FullCode',['lxts',num2str(Para)]};
                    Explain={'����','�����µ�����'};                    
                case 4
                   % ������ͳ�� P={5 10 20 60 120} OutPara={'�ۼƻ�����'}
                    P=[5 10 20 60 120];
                    if ~sum(Para==P)
                        error(['"������ͳ��"��������������Ϊ��',num2str(P)])
                    end   
                    Name={'FullCode',['ljhsl',num2str(Para)]};
                    Explain={'����',[num2str(Para),'���ۼƻ�����']};                    
                case 5
                   % ������ P={1 2 3 4 5} OutPara={'�󵥻�����'}
                    P=[1 2 3 4 5];
                    if ~sum(Para==P)
                        error(['"������"��������������Ϊ��',num2str(P)])
                    end  
                    Name={'FullCode',['ddhsl',num2str(Para)]};
                    Explain={'����',[num2str(Para),'�մ�(��)������']};                         
                case 6
                   % ���� P={1 2 3 4 5} OutPara={'�󵥻�����'}
                    P=[1 2 3 4 5];
                    if ~sum(Para==P)
                        error(['"����"��������������Ϊ��',num2str(P)])
                    end     
                    Name={'FullCode',['ddhsl',num2str(Para)]};
                    Explain={'����',[num2str(Para),'�մ󵥣��򣩻�����']};                           
                case 7
                   % �ɽ���ͻ�� P={1} OutPara={'�����ǵ���'}
                    P=[1];
                    if ~sum(Para==P)
                        error(['"�ɽ���ͻ��"��������������Ϊ��',num2str(P)])
                    end 
                    Name={'FullCode',['hszdl',num2str(Para)]};
                    Explain={'����','�����ǵ���'};                           
                case 8
                   % Զ��ɱ� P={1} OutPara={'Զ���'}
                    P=[1];
                    if ~sum(Para==P)
                        error(['"Զ��ɱ�"��������������Ϊ��',num2str(P)])
                    end   
                    Name={'FullCode',['yld',num2str(Para)]};
                    Explain={'����','Զ���'};                     
                case 9
                   % �������� P={1} OutPara={'����'}
                    P=[1];
                    if ~sum(Para==P)
                        error(['"��������"��������������Ϊ��',num2str(P)])
                    end   
                    Name={'FullCode',['lb',num2str(Para)]};
                    Explain={'����','����'};                     
                otherwise
                    error('�����ѡ�ɷ�����������')
            end
            % ------------------------------------------------------------------------��ȡ�ӿ�����
            url=['http://stock.gtimg.cn/data/view/dataPro.php?t=',num2str(Type),'&p=',num2str(Para)]
            [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
            if ~status
                error('��ȡ����\n')
            end
            % -----------------------------------------����������ӿ�����
            expr1='([-szh\d\.]+)';
            [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
            a=[date_tokens{:}]';
            List=cell2table([a(4:2:end),a(5:2:end)],'VariableNames',Name);
            %----------------------------------------���õ��Ĵ�����Stock.QuickInfo��ȡ��Ʊ������Ϣ
            Info=Stock.QuickInfo(List{:,1});
            %---------------------------------------���ͳ�����ݺ͹�Ʊ������Ϣ
            List=[List,Info];
        end % TechnologyChoice
        function List=FundChoice(Type,varagin) % ��Ѷ�ʽ���ѡ��
            %      1                                2                   3                        4                     5                        6                         7
            % �ʽ�����ȫ�� ��ҵ�ʽ����� �����ʽ����� �������������� �۵��������� �����������ֹ� �����ʽ����
            T={'overview','industry','concept','mainforce','jdzlzc','jzzljc','zlzjfl'};
            if isstr(Type)        % ��ѡ�񷽷��޶��������б���
                Type=find(ismember(T,Type));
                if isempty(Type)
                    Type=10;
                end
            end
            
            switch Type  % ����ͳ�Ʒ���
                case 1
                    % �ʽ�ȫ������ȫ��
                    info=Stock.Handicap({'sh000001'});
                    time=info.LastTime{1};
                    time=time(1:8);
                    url=['http://stock.gtimg.cn/data/view/flow.php?t=',num2str(Type),'&dt=',time,'&r=0.6092258914799902']
                    % ��ȡ��ҳ��Ϣ
                    [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                    if ~status
                        error('��ȡ����\n')
                    end
                    expr1='([-\d\.:]+)'
                    [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
                    a=[date_tokens{:}]';
                    List=reshape(a,8,length(a)/8)';
                    Name={'MInflow','MOutflow','MNetInflow','RInflow','ROutflow','RNetInflow','Date','Time'};
                    Explain={'�����ʽ�����','�����ʽ�����','�����ʽ�����','ɢ���ʽ�����','ɢ���ʽ�����','ɢ���ʽ�����','����','ʱ��'};
                     List=cell2table([Explain;flipud(List)],'VariableNames',Name);
                     
                    %if ~ isempty(flipud(List)) % ��˵�������
                    %    List=cell2table(flipud(List),'VariableNames',Name);
                   % end
                case 2
                    % ��ҵ����ʽ�������
                    url=['http://stock.gtimg.cn/data/view/flow.php?t=',num2str(Type)]
                    % ��ȡ��ҳ��Ϣ
                    [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                    if ~status
                        error('��ȡ����\n')
                    end
                    sourcefile2= regexp(sourcefile, ';', 'split')';
                    expr1='(?<=[\^''~])(.*?)(?=[~''\^])'
                    [datefile, date_tokens]= regexp(sourcefile2(1), expr1, 'match', 'tokens');
                    a=[date_tokens{:}{:}]';
                    List=reshape(a,7,length(a)/7)';
                    Name={'Code','Name','MInflow','MOutflow','MNetInflow','unknow','TurnoverRatio'};
                    Explain={'����','����','�����ʽ�����','�����ʽ�����','�����ʽ�����','δ֪','ռ���ɽ���'}
                    List=cell2table([Explain;List],'VariableNames',Name);
                    %if ~ isempty(flipud(List)) % ��˵�������
                    %    List=cell2table(flipud(List),'VariableNames',Name);
                    % end
                case 3
                    % �������ʽ�������
                    url=['http://stock.gtimg.cn/data/view/flow.php?t=5']
                    % ��ȡ��ҳ��Ϣ
                    [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                    if ~status
                        error('��ȡ����\n')
                    end
                    sourcefile2= regexp(sourcefile, ';', 'split')';
                    expr1='(?<=[\^''~])(.*?)(?=[~''\^])';
                    [datefile, date_tokens]= regexp(sourcefile2(1), expr1, 'match', 'tokens');
                    a=[date_tokens{:}{:}]'
                    List=reshape(a,7,length(a)/7)';
                    Name={'Code','Name','MInflow','MOutflow','MNetInflow','unknow','TurnoverRatio'};
                    Explain={'����','����','�����ʽ�����','�����ʽ�����','�����ʽ�����','δ֪','ռ���ɽ���'}
                    List=cell2table([Explain;List],'VariableNames',Name);        
                    %if ~ isempty(flipud(List)) % ��˵�������
                    %    List=cell2table(flipud(List),'VariableNames',Name);
                   % end                   
                case 4
                    % ��������������
                    if nargin==1
                        Para=1;
                    elseif nargin==2 & isnumeric(varagin(1)) & varagin(1)==1
                        Para=1;
                    elseif nargin==2 & isnumeric(varagin(1)) & varagin(1)==5
                        Para=2;
                    else
                        error('ֻ��һ��������1��1��������������5��5������������')
                    end
                    url=['http://stock.gtimg.cn/data/view/zldx.php?t=',num2str(Para)]
                    % ��ȡ��ҳ��Ϣ
                    [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                    if ~status
                        error('��ȡ����\n')
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
        function List=FundHistory(Code,Day) % �����ʽ������ʷ��ϸ ,Day������
            % e.g. Stock.FundHistory('600123',10) 
            %----------------------------------------------------------------------------------
            Code=Stock.CodeCheck(Code);
            C=strcat(Code,',');
            C=strcat(C{:});
            url=['http://stock.gtimg.cn/data/view/ggdx.php?t=3&d=',num2str(Day),'&q=',C(1:end-1)]
            % ��ȡ��ҳ��Ϣ
            [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
            if ~status
                error('��ȡ����\n')
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
            
            Explain={'��������','����������','ɢ��������'};
            Name={'TPosition','MPosition','RPosition','Date'};
             List=cell2table(List,'VariableNames',Name);
        end % FundHistory
        %---------------------------------------------------------------------------------------------------------------------
        function List=CYData(SortNameList)  % ��Ӯ����(ֻ�л�������)
            % SortNameList ������ֶ� �ֶ����Explain
            % e.g. List=Stock.CYData('VBUpIn10Day')
            %-------------------------------------------------------------------------------
            url=['http://chagu.dingniugu.com/chaoying/cy.php?id=5'] % ��ϸ���ݽ��Ϳ� http://chagu.dingniugu.com/chaoying/index.asp
            % ��ȡ��ҳ��Ϣ
            [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
            if ~status
                error('��ȡ����\n')
            end
            expr1='\[(\d{6}),\[(\d),(\d),(\d),(\d)\],\[(\d),(\d),(\d),(\d)\],\[([\d\.-]+),([\d\.-]+),([\d\.-]+),([\d\.-]+),([\d\.-]+)\],\[([\d\.-]+),([\d\.-]+),([\d\.-]+),([\d\.-]+),([\d\.-]+)\],\[([\d\.-]+),([\d\.-]+),([\d\.-]+),([\d\.-]+),([\d\.-]+)\],\[([\d\.-]+),([\d\.-]+),([\d\.-]+),([\d\.-]+),([\d\.-]+)\],\[([\d\.-]+),([\d\.-]+),([\d\.-]+),([\d\.-]+)\],([\d\.-]+),([\d\.-]+),([\d\.-]+)';
            [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
            a=[date_tokens{:}]';
            List=reshape(a,36,length(a)/36)';
            Explain={'����',...
                '����������(��)','����������(��)','��������(��)','����ɢ����(��)',...
                '10��������(��)','10�ճ�����(��)','10�մ���(��)','10��ɢ����(��)',...
                '����1��������%','����3��������%','����5��������%','����10��������%','�������ճֲ�',...
                '����1��������%','����3��������%','����5��������%','����10��������%','���󻧵��ճֲ�',...
                '��1��������%','��3��������%','��5��������%','��10��������%','�󻧵��ճֲ�',...
                'ɢ��1��������%','ɢ��3��������%','ɢ��5��������%','ɢ��10��������%','ɢ�����ճֲ�',...
                '��Ӯ�ʽ�1��','��Ӯ�ʽ�3��','��Ӯ�ʽ�5��','��Ӯ�ʽ�10��',...
                '��ǰ�۸�','�ǵ���%','�����ʽ�'};
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
        function Val=SLOPE(KData,N,field) %����ָ���б��
             %-----------------------------------------------------------�����������ȷ�Լ���
                if (istable(KData) &  nargin<3) ||  (isnumeric(KData) & nargin>2) || (nargin<2) || (nargin>3) 
                    error('���������������')
                elseif ~istable(KData) && ~isnumeric(KData)
                    error('��������ݸ�ʽ����Ϊtable����double')
                elseif  nargin==3 & ~isstr(field)
                    error('field ��������Ϊ�ַ���')
                elseif (istable(KData) &  nargin==3 )
                    Data=eval(['KData.',field,';']);
                elseif  (isnumeric(KData) & nargin==2)
                    Data=KData;
                end
              %-----------------------------------------------------------����
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
              %-----------------------------------------------------------���
              if istable(KData)
                  eval(['KData.S_',field,'=MDiffData;'])
                  Val=KData;
              else
                  Val=MDiffData;
              end
              
        end % SLOPE
    end  % methods (Static) 
    
end

