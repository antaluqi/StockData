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
        function obj=StockAll % ���캯��
             tic
             StockList=StockAll.StockList; % ���ش����б�
             toc
             SLCode=StockAll.CodeCheck(StockList(:,1))'; % �����׼��
             obj.CodeList=SLCode(strmatch('s',SLCode));    % ѡ����������sh,sz��ͷ�Ĺ�Ʊ����
%              simpleCode=cellfun(@(x) x(3:end),obj.CodeList,'UniformOutput',0);
%              obj.NameList=StockList(ismember(StockList,simpleCode),2);
        end % StockStatistics
        function type=DownloadData(obj,DataNameList) % ��������
            DataNameList=cellstr(DataNameList);
            StandardName={'K','FQ','Flash'};
            L=length(DataNameList);
            if sum(ismember(DataNameList,StandardName))~=L
               error('δ����Ӧ���ݿ�����,������������')
            end
            for i=1:L
               DataName = DataNameList{i};
               tic
               switch DataName
                   case 'K' % K ������
                       %Year=datestr(today,'yy');
                       info=StockAll.DownloadKData(obj.CodeList,1);
                   case 'FQ' % ��Ȩ����
                       info=StockAll.DownloadFQData(obj.CodeList);         
                   case 'Flash' % ��ʱ�̿�����
                       info=StockAll.Handicap(obj.CodeList);
                   otherwise
                       error(['δ��',type,'���ݿ�����,������������'])
               end
               toc
            end
            type=info;
        end % DownloadData
        function ImportData(obj,DatafileList) % ��������
            DatafileList=cellstr(DatafileList);
            StandardName={'K','KL','KR','Flash'};
            L=length(DatafileList);
            if sum(ismember(DatafileList,StandardName))~=L
                error('δ����Ӧ���ݿ�����,������������')
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
                        error(['û��',DatafileName,'�����ݿ��Ե���'])
                end
                toc
            end
            
        end % ImportData
        function Val=Indicators(obj,type,ParameterList) % ��������ָ��
            if isempty(obj.KDataAll)
                obj.ImportData('KL');   
            end
            Data=obj.KDataAll;
            fn=fieldnames(Data); % �����б�
            fnL=length(fn);      % �������
            hwait=waitbar(0,'����ָ��>>>>>>>>'); % ʱ��ͳ�ƿ�ʼ
            tic
            for i=1:fnL % ÿ����Ʊѭ��
                Code=fn{i}                        % ��ȡ����
                KData=eval(['Data.',Code]);  % ��ȡ��ǰ��ƱK������
                if  isempty(KData)  % ���K�����ݲ�Ϊ�գ�������ĵ�һ��Ϊ����
                    outData=[];
                else
                    outData=KData(:,1);
                    
                    for j=1:length(type) % ѭ������ָ��
                        switch type{j}
                            case 'MA'
                                Len=ParameterList{j};
                                FieldData=KData(:,3); % ���ڼ�������� ��������ʱĬ��Ϊ���̼�
                                mai=MAi(FieldData,Len);
                                outData=[outData,mai];
                            case 'STD'
                                Len=ParameterList{j};
                                FieldData=KData(:,3); % ���ڼ�������� ��������ʱĬ��Ϊ���̼�
                                stdi=STDi(FieldData,Len);
                                outData=[outData,stdi];
                            case 'HHigh'
                                Len=ParameterList{j};
                                FieldData=KData(:,4); % ��߼�
                                hhighi=HHighi(FieldData,Len);
                                outData=[outData,hhighi];
                            case 'LLow'
                                Len=ParameterList{j};
                                FieldData=KData(:,5); % ��ͼ�
                                llowi=LLow(FieldData,Len);
                                outData=[outData,llowi];
                            case 'EMA'
                                Len=ParameterList{j};
                                FieldData=KData(:,3); % ���ڼ�������� ��������ʱĬ��Ϊ���̼�
                                emai=EMAi(FieldData,Len);
                                outData=[outData,emai];
                            case 'SMA'
                                Len=ParameterList{j};
                                FieldData=KData(:,3); % ���ڼ�������� ��������ʱĬ��Ϊ���̼�
                                emai=SMAi(FieldData,Len);
                                outData=[outData,emai];
                            case 'MACD'
                                if length(ParameterList{j})~=3
                                    error('MACD ������������')
                                end
                                LeadLen=ParameterList{j}(1);
                                LagLen=ParameterList{j}(2);
                                DIFFLen=ParameterList{j}(3);
                                FieldData=KData(:,3); % ���ڼ�������� ��������ʱĬ��Ϊ���̼�
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
                                    error('BOLL ������������')
                                end
                                
                                FieldData=KData(:,3); % ���ڼ�������� ��������ʱĬ��Ϊ���̼�
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
                                    error('BIAS ������������')
                                end
                                FieldData=KData(:,3); % ���ڼ�������� ��������ʱĬ��Ϊ���̼�
                                biasi=BIASi(FieldData,LeadLen,LagLen);
                                outData=[outData,biasi];
                            case 'KDJ'
                                if length(ParameterList{j})~=3
                                    error('KDJ ������������')
                                end
                                Len= ParameterList{j}(1);
                                M1=ParameterList{j}(2);
                                M2=ParameterList{j}(3);
                                kdji=KDJi(KData,Len,M1,M2);
                                outData=[outData,kdji];
                            case 'RSI'
                                Len= ParameterList{j};
                                FieldData=KData(:,3); % ���̼�
                                rsii=RSIi(FieldData,Len);
                                outData=[outData,rsii];
                            case 'OBV'
                                
                            case 'LB'
                                if isempty( ParameterList{j})
                                    Len=5;
                                else
                                    Len= ParameterList{j};
                                end
                                FieldData=KData(:,6); % �ɽ���
                                lbi=LBi(FieldData,Len);
                                outData=[outData,lbi];
                            case'SAR'
                                Len= ParameterList{j};
                                sari=SARi(KData,Len);
                                outData=[outData,sari];
                            case 'DMI'
                                if length(ParameterList{j})~=2
                                    error('DMI ������������')
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
                                FieldData=KData(:,3); % �ɽ���
                                psyi=PSYi(FieldData,Len);
                                outData=[outData,psyi];
                            otherwise
                        end % switch
                    end
                end
                eval(['Val.',Code,'=outData;']) %�ϲ���Struct������
               % waitbar(i/fnL,hwait,[num2str(i/fnL*100),'%',':',Code,',',num2str(i),'/',num2str(fnL)]);% ������
                waitbar(i/fnL,hwait);% ������
            end
            close(hwait);% �رս�����
            toc
        end % Indicators
        function flashTodayK(obj) % ���뵱�����ݽ�KDataAll
            if isempty(obj.KDataAll)
                warning('KDataAll����Ϊ�ա�')
                return
            end
            szzs=StockAll.Handicap('sh000001');
            lastDay=szzs.LastTime{:};
            if datenum([lastDay(1:4),'-',lastDay(5:6),'-',lastDay(7:8)])~=today
                warning('���ڽ����գ�������flashTodayK')
                return
            end
            obj.ImportData('Flash');  % ���������̿�����
         
         
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
            hwait=waitbar(0,'�ϲ���������>>>>>>>>');
            tic
            for i=1:L
                 Code=fn{i};
                 Data=DataAll(Code);
                 if Data(1)<=today && StateAll(Code)==1 && eval(['obj.KDataAll.',Code,'(end,1)<Data(1)'])
                      DataToday=Data;
                     eval(['obj.KDataAll.',Code,'(end+1,:)=DataToday;'])
                 end
                  waitbar(i/L,hwait)
%                waitbar(i/L,hwait,[num2str(i/L*100),'%; ',num2str(i),'/',num2str(L)]);% ������(��ʱ��)
            end
            toc
            close(hwait)
        end
        function Val=gtyx(obj) % Ѱ�ҹ�ͷ����
            obj.ImportData('Flash');  % ���������̿�����
            FlashData=obj.FlashData; % ���������̿�����
            RealPrice=str2double(FlashData.RealPrice); % ���¼۸�
            High=str2double(FlashData.High);           % ��߼۸�
            Yield=str2double(FlashData.Yield);         % ����������
            HardenPrice=str2double(FlashData.HardenPrice); % ������ͣ��
            Val= sortrows(FlashData((RealPrice==High & RealPrice~=0 & Yield>0 & RealPrice<HardenPrice),{'Code','Name','RealPrice','High','Yield'}),'Yield');
        end %gtyx
        function Val=Find(obj,funName,propertie,option) % ͨ�ò��Һ���
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
                    error('K�����ݲ�ȫ�����Ȳ�������');
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
            hwait=waitbar(0,'Ѱ�ҹ�Ʊ>>>>>>>>'); % ʱ��ͳ�ƿ�ʼ            
            for i=1:L
                Code=fn{i};
                obj.FindTemp=Code;
                indData=eval(['indDataAll.',Code,';']);
                eval(['obj.',funName,'(indData,option);'])
                if eval(['obj.',funName,'(indData,option);'])==1
                    out=[out;Code];
                end;
                waitbar(i/L,hwait);% ������
            end
            close(hwait)
            toc
             % ȥ��ͣ�ƵĹ�Ʊ
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
                error('option�������ʽ����')
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
                error('option�������ʽ����')
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
        function out=CodeCheck(in) % ��׼���������
            if ~iscell(in) % ת����Ϊcell�������� '600001'ת��Ϊ{'600001'}����
                in={in};
            end
            out=[];
                  for i=1:length(in) % ��cell�����е�ÿһ����Ա���б�������
                      C=in{i};
                      if ~ischar(C)
                          error('�������Ϊ�ַ���')
                      end
                      if  length(C)==6 && (strcmp(C(1),'6') || strcmp(C,'000001')) % ���д���
                          out{i}= ['sh',C];
                      elseif length(C)==6 && (strcmp(C(1),'0') || strcmp(C(1),'3')) && ~strcmp(C,'000001') % ���д���
                          out{i}= ['sz',C];
                      else % ���ఴԭ�����
                          out{i}=[C];
                      end
                  end
            
        end % CodeCheck
        function info=DownloadKData(CodeList,Y,thisYear)% ��������K������
            %-------------------------------------
            CodeList=Stock.CodeCheck(CodeList); % ���������׼��
            hwait=waitbar(0,'��ȴ�>>>>>>>>');
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
            for i=1:L % ��ÿһ�������������
                
                Code=CodeList{i};
                ValAll=[];
                for j=Y-1:-1:0 %ÿһ�����
                    %---------------------------------------��ȡ�ӿ���Ϣ
                    Year=num2str(thisYear-j);
                    url=['http://data.gtimg.cn/flashdata/hushen/daily/',Year,'/',Code,'.js?maxage=43201'] % ��Ѷ��K������
                    % ��ȡ��ҳ��Ϣ
                    [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
                    if ~status
                        continue;
                    end
                    %---------------------------------------��������ӿ���Ϣ
                    Val=regexp(sourcefile, '[\s\n\\]', 'split')';
                    Val=[Val(4:8:end-3),Val(5:8:end-3),Val(6:8:end-3),Val(7:8:end-3),Val(8:8:end-3),Val(9:8:end-3)];
                    ValAll=[ValAll;Val];
                end
                if ~isempty(ValAll)
                    ValAll(:,1)=cellfun(@(x) [x(3:4),'/',x(5:6),'/',x(1:2)],ValAll(:,1),'UniformOutput',false);
                    % ValAll=[ValAll(:,1),num2cell(str2double(ValAll(:,2:6)))]; % cell�������
                       ValAll=[datenum(ValAll(:,1)),str2double(ValAll(:,2:6))];  %ȫ�����������                     
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
                
                %------------------------------����Ϣ�洢����Struct�����У�����Ϊ�ֶ���
                % eval(['info.',Code,'.K=Val;']);

                waitbar(i/length(CodeList),hwait,[num2str(i/length(CodeList)*100),'%',':',num2str(CodeList{i}),',',num2str(i),'/',num2str(length(CodeList))]);% ������

                info=blankdata;
            end
                close(hwait);% �رս�����
        end %DownloadKData
        function info=DownloadFQData(CodeList) % �������ظ�Ȩ����
            %-------------------------------------
            CodeList=Stock.CodeCheck(CodeList); % ���������׼��
            hwait=waitbar(0,'��ȴ�>>>>>>>>');
            L=length(CodeList);
            for i=1:L % ��ÿһ�������������
                %---------------------------------------��ȡ�ӿ���Ϣ
                Code=CodeList{i};
                Val=[];
                url=['http://data.gtimg.cn/flashdata/hushen/fuquan/',Code,'.js?maxage=6000000']
                % ��ȡ��ҳ��Ϣ
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
                waitbar(i/length(CodeList),hwait,[num2str(i/length(CodeList)*100),'%',':',num2str(CodeList{i}),',',num2str(i),'/',num2str(length(CodeList))]);% ������
            end
            info=1;
            close(hwait);% �رս�����
        end %DownlodeFQDate
        function info=Handicap(Code)%�̿���Ϣ
            Code=Stock.CodeCheck(Code);
            % ��Ѷ���ݽӿڵ�ַ��ͷ
            urlHead='http://qt.gtimg.cn/q=';
            %--------------------------------------------------------------
            sourcefileall=[];
            b=1;
            e=60;% ����һ�ζ�ȡ�Ĵ���������URL���ƣ�
            len=length(Code); % �������
            hwait=waitbar(0,'��ȴ�>>>>>>>>');
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
                waitbar(b/len,hwait,[num2str(b/len*100),'%',':',num2str(b),'/',num2str(len)]);% ������
            end
            close(hwait);% �رս�����
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
            Name={'Market','Name','Code','RealPrice','YClosePrice','OpenPrice','Volume','B','S','Buy1Price','Buy1Volume','Buy2Price','Buy2Volume','Buy3Price','Buy3Volume','Buy4Price','Buy4Volume','Buy5Price','Buy5Volume','Sell1Price','Sell1Volume','Sell2Price','Sell2Volume','Sell3Price','Sell3Volume','Sell4Price','Sell4Volume','Sell5Price','Sell5Volume','LastTransaction','LastTime','Rise','Yield','HighPrice','LowPrice','Price_Volume_Amount','Volume2','Amount','HSL','PE','State','High','Low','Amplitude','CirculationMarketValue','TotalMarketValue','PB','HardenPrice','LimitPrice','blank2','blank3','blank4','blank5','blank6'};
             
            % ����������Ϣ���
              info=cell2table(S,'VariableNames',Name');
              info.Code=StockAll.CodeCheck(info.Code)';
             
            %--------------------------------------------------------------
        end% Handicap
        function info=fq(type) % ������Ȩ
            % tic;KDataAll=open('Data.mat');toc
            DataBefore=open('DataBefore.mat');
            DataNew=open('Data.mat');
            KDataAll=StockAll.unionData(DataNew,DataBefore);
            tic;fqDataAll=open('fq.mat');toc
            
            fieldK=fieldnames(KDataAll);
            fieldFQ=fieldnames(fqDataAll);
            LfieldK=size(fieldK,1);
            hwait=waitbar(0,'��Ȩ>>>>>>>>');
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
                % waitbar(i/LfieldK,hwait,[num2str(i/LfieldK*100),'%',':',num2str(fieldK{i}),',',num2str(i),'/',num2str(LfieldK)]);% ������
                 waitbar(i/LfieldK,hwait);% ������
            end
            
            close(hwait);% �رս�����
        end % fq
        function info=unionData(DataNew,DataBefore) % �����ϲ�����
            fn=fieldnames(DataNew);
            L=length(fn);
            %hwait=waitbar(0,'��ȴ�>>>>>>>>');
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
            %close(hwait);% �رս�����
            info=Data;
        end % unionData
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
    end  % methods (Static)
end % classdef

