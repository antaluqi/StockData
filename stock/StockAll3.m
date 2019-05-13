classdef StockAll3<handle
    properties
        CodeList
        KDataAll
        IndDataAll
        
    end %  properties
    
    properties(Access='private')

    end  % properties(Access='private')
    
    properties(Dependent)
        
    end  % properties(Dependent) 
    
    methods
        function obj=StockAll3 % 构造函数
            
        end % StockAll
        
        function Download(obj)
            DataPath='..\Data\';
            DatafileName='Data';
            %-------------------------------------------删除已存在的mat数据文件
            delete([DataPath,DatafileName,'.mat'])
            %-------------------------------------------从Postgresql下载
            connection=database('testDB','postgres','123456','org.postgresql.Driver','jdbc:postgresql://localhost:5432/testDB');
            curs = exec(connection, 'select code from stock_code;');
            row = fetch(curs);
            CodeList = row.Data;

            query = 'select * from information_schema.columns where table_schema=''public'' and table_name=''golang''; ';
            curs = exec(connection, query);
            row = fetch(curs);
            colume_name=row.Data(:,4);

            tic
            for i=1:length(CodeList)
                 code = CodeList{i};
                 query=['select * from golang where code=''', code,''';'];
                 curs = exec(connection, query);
                 row = fetch(curs);
                 data=row.Data;
                 %cell2table([cellstr(datestr(data(:,1),'yyyy-mm-dd')),num2cell(data(:,2:end))],'VariableNames',colume_name);

                 store_data=[datenum(data(:,1),'yyyy-mm-dd'),cell2mat(data(:,[2:6,8:end]))];
                 stroe_code=['k',data{1,7}];
                 eval([stroe_code,'=store_data;'])
                 DatafileName='Data';
                 if i==1
                        save([DataPath,DatafileName,'.mat'],stroe_code,'-v6')
                    else
                        save([DataPath,DatafileName,'.mat'],stroe_code,'-append','-v6')
                 end
                 i
            end
            colume_name={'date', 'open', 'close', 'high', 'low', 'volume'}; 
            save([DataPath,DatafileName,'.mat'],'colume_name','-append','-v6')

            toc
            close(curs)
            close(connection)
        end

        function importData(obj,typeList)
            if ismember('k',typeList)
                 if ~exist('../Data/Data.mat')
                     obj.Download
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
                if Code(1)~='k'
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
                            case 'RATE'
                                ParaLen=1;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end
                                Len=ParameterList{j}(1);
                                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                                d=RATEi(FieldData,Len,shift);
                                outData=[outData,d];
                                NAMEi={['RATE',num2str(shift),'_',num2str(Len)]};
                                name=[name,NAMEi];                                
                            case 'MA'  
                                ParaLen=1;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end
                                Len=ParameterList{j}(1);
                                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                                d=MAi(FieldData,Len,shift);
                                outData=[outData,d];
                                NAMEi={['MA',num2str(shift),'_',num2str(Len)]};
                                name=[name,NAMEi];
                            case 'STD'             
                                ParaLen=1;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end                              
                                Len=ParameterList{j}(1);
                                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                                d=STDi(FieldData,Len,shift);
                                outData=[outData,d];
                                NAMEi={['STD',num2str(shift),'_',num2str(Len)]};
                                name=[name,NAMEi];                             
                            case 'HHigh'
                                ParaLen=1;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end                                    
                                Len=ParameterList{j}(1);
                                FieldData=KData(:,4); % 最高价
                                d=HHighi(FieldData,Len,shift);
                                outData=[outData,d];
                                NAMEi={['HHigh',num2str(shift),'_',num2str(Len)]};
                                name=[name,NAMEi];                               
                            case 'LLow'
                                ParaLen=1;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end  
                                Len=ParameterList{j}(1);
                                FieldData=KData(:,5); % 最低价
                                d=LLowi(FieldData,Len,shift);
                                outData=[outData,d];
                                NAMEi={['LLow',num2str(shift),'_',num2str(Len)]};
                                name=[name,NAMEi];  
                                
                            case 'EMA'
                                ParaLen=1;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end  
                                Len=ParameterList{j}(1);
                                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                                d=EMAi(FieldData,Len,shift);
                                outData=[outData,d];
                                NAMEi={['EMA',num2str(shift),'_',num2str(Len)]};
                                name=[name,NAMEi];  
                                
                            case 'SMA'
                                ParaLen=1;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end  
                                Len=ParameterList{j}(1);
                                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                                d=SMAi(FieldData,Len,shift);
                                outData=[outData,d];
                                NAMEi={['SMA',num2str(shift),'_',num2str(Len)]};
                                name=[name,NAMEi];  
                                
                            case 'MACD'
                                ParaLen=3;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end  
                                LeadLen=ParameterList{j}(1);
                                LagLen=ParameterList{j}(2);
                                DIFFLen=ParameterList{j}(3);
                                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                                d=MACDi(FieldData,LeadLen,LagLen,DIFFLen,shift);
                                outData=[outData,d];
                                NAMEi={['DIFF',num2str(shift),'_',num2str(LeadLen),'_',num2str(LagLen),'_',num2str(DIFFLen)],...
                                ['DEA',num2str(shift),'_',num2str(LeadLen),'_',num2str(LagLen),'_',num2str(DIFFLen)],...
                                ['MACD',num2str(shift),'_',num2str(LeadLen),'_',num2str(LagLen),'_',num2str(DIFFLen)]};
                                name=[name,NAMEi];  
                            case 'BOLL'
                                ParaLen=2;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end  
                                Len=ParameterList{j}(1);
                                Width=ParameterList{j}(2);
                                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                                d=BOLLi(FieldData,Len,Width,shift);
                                outData=[outData,d];
                                NAMEi={['MID',num2str(shift),'_',num2str(Len),'_',num2str(Width)],...
                                      ['UP',num2str(shift),'_',num2str(Len),'_',num2str(Width)],...
                                      ['DOWN',num2str(shift),'_',num2str(Len),'_',num2str(Width)]};
                                name=[name,NAMEi];  
                            case 'BIAS'
                                ParaLen=2;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end                                 
                                LeadLen=ParameterList{j}(1);
                                LagLen=ParameterList{j}(2);
                                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                                d=BIASi(FieldData,LeadLen,LagLen,shift);
                                outData=[outData,d];
                                NAMEi={['BIAS',num2str(shift),'_',num2str(LeadLen),'_',num2str(LagLen)]};
                                name=[name,NAMEi]; 
                                
                            case 'KDJ'
                                ParaLen=3;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end  
                                Len= ParameterList{j}(1);
                                M1=ParameterList{j}(2);
                                M2=ParameterList{j}(3);
                                d=KDJi(KData,Len,M1,M2,shift);
                                outData=[outData,d];
                                NAMEi={['K',num2str(shift),'_',num2str(Len),'_',num2str(M1),'_',num2str(M2)],...
                                       ['D',num2str(shift),'_',num2str(Len),'_',num2str(M1),'_',num2str(M2)],...
                                       ['J',num2str(shift),'_',num2str(Len),'_',num2str(M1),'_',num2str(M2)]};
                                name=[name,NAMEi]; 
                                
                            case 'RSI'
                                ParaLen=1;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end 
                                Len= ParameterList{j}(1);
                                FieldData=KData(:,3); % 收盘价
                                d=RSIi(FieldData,Len,shift);
                                outData=[outData,d];
                                NAMEi={['RSI',num2str(shift),'_',num2str(Len)]};
                                name=[name,NAMEi]; 
                                
                            case 'OBV'
                                
                            case 'LB'
                                ParaLen=1;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end                                 
                                if isempty( ParameterList{j})
                                    Len=5;
                                else
                                    Len= ParameterList{j}(1);
                                end
                                FieldData=KData(:,6); % 成交量
                                d=LBi(FieldData,Len,shift);
                                outData=[outData,d];
                                NAMEi={['LB',num2str(shift),'_',num2str(Len)]};
                                name=[name,NAMEi];
                                
                            case'SAR'
                                ParaLen=1;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end  
                                Len= ParameterList{j};
                                d=SARi(KData,Len,shift);
                                outData=[outData,d];
                                NAMEi={['SAR',num2str(shift),'_',num2str(Len)]};
                                name=[name,NAMEi];
                                
                            case 'DMI'
                                ParaLen=2;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end  
                                N= ParameterList{j}(1);
                                M= ParameterList{j}(2);
                                d=DMIi(KData,N,M,shift);
                                outData=[outData,d];
                                NAMEi={['pdi',num2str(shift),'_',num2str(N),'_',num2str(M)],...
                                       ['mdi',num2str(shift),'_',num2str(N),'_',num2str(M)],...
                                       ['adx',num2str(shift),'_',num2str(N),'_',num2str(M)],...
                                       ['adxr',num2str(shift),'_',num2str(N),'_',num2str(M)]};
                                name=[name,NAMEi];
                                
                            case 'CCI'
                                ParaLen=1;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end  
                                Len= ParameterList{j}(1);
                                d=CCIi(KData,Len,shift);
                                outData=[outData,d];
                                NAMEi={['CCI',num2str(shift),'_',num2str(Len)]};
                                name=[name,NAMEi];
                                
                            case 'PSY'
                                ParaLen=1;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end  
                                Len= ParameterList{j}(1);
                                FieldData=KData(:,3); % 收盘价
                                d=PSYi(FieldData,Len,shift);
                                outData=[outData,d];
                                NAMEi={['PSY',num2str(shift),'_',num2str(Len)]};
                                name=[name,NAMEi];
                                
                             case 'CBOLL'  
                                ParaLen=2;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end  
                                Len=ParameterList{j}(1);
                                Width=ParameterList{j}(2);

                                FieldData=KData(:,3); % 收盘价
                                d=CBOLLi(FieldData,Len,Width,shift);
                                outData=[outData,d];
                                NAMEi={['CUP',num2str(shift),'_',num2str(Len),'_',num2str(Width)],...
                                       ['CDOWN',num2str(shift),'_',num2str(Len),'_',num2str(Width)]};
                                name=[name,NAMEi];
                             case 'CMA'
                                ParaLen=1;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end  
                                 Len= ParameterList{j}(1);
                                 FieldData=KData(:,3); % 收盘价
                                 d=CMAi(FieldData,Len,shift);
                                 outData=[outData,d];
                                 NAMEi={['CMA',num2str(shift),'_',num2str(Len)]};
                                 name=[name,NAMEi];
                                 
                             case 'MAMA'
                                ParaLen=2;
                                shift=0;
                                if length(ParameterList{j})>ParaLen
                                   shift=ParameterList{j}(ParaLen+1);
                                end  
                                 
                                 Len1= ParameterList{j}(1);
                                 Len2= ParameterList{j}(2);
                                 FieldData=KData(:,3); % 收盘价
                                 d=MAMAi(FieldData,Len1,Len2,shift);
                                 outData=[outData,d];
                                 NAMEi={['MAMA',num2str(shift),'_',num2str(Len1),'_',num2str(Len2)]};
                                 name=[name,NAMEi];
                                 
                             case 'FUTURE'
                                Len= ParameterList{j};
                                c=KData(:,3);% 收盘价
                                h=KData(:,4);
                                l=KData(:,5);
                                futurei=FUTUREi(c,h,l,Len);
                                outData=[outData,futurei];
                                name{end+1}=['fhh_',num2str(Len)];
                                name{end+1}=['fhhi_',num2str(Len)];
                                name{end+1}=['fll_',num2str(Len)];
                                name{end+1}=['flli_',num2str(Len)];
                                name{end+1}=['fc_',num2str(Len)];
                            otherwise
                    end % switch
                    if length(ParameterList{j})>ParaLen+1
                        rLen=ParameterList{j}(ParaLen+2);
                        rdata=RATEi(d,rLen);
                        outData=[outData,rdata];
                        rNAMEi=strcat(['r',num2str(rLen),'_'],NAMEi);
                        name=[name,rNAMEi];
                    end
                end
                eval(['Val.',Code,'=outData;']) %合并到Struct变量中
                Val.name=name;
               % waitbar(i/fnL,hwait,[num2str(i/fnL*100),'%',':',Code,',',num2str(i),'/',num2str(fnL)]);% 进度条
                waitbar(i/fnL,hwait);% 进度条
            end
            close(hwait);% 关闭进度条
            toc
        end
        
        function Val=Find(obj)
            addpath([cd,'\FindFun']);
            if isempty(obj.KDataAll)
                obj.importData('k');   
            end
            obj.IndDataAll=obj.Indicators({'CBOLL','BOLL'},{[20,2,1],[20,2,1,3]});
            fn=fieldnames(obj.IndDataAll); % 代码列表
            fnL=length(fn);      % 代码个数
            hwait=waitbar(0,'查找符合条件的tick>>>>>>>>'); % 时间统计开始
            tic
            codeArr=[];
            outAll=[];
            for i=1:fnL % 每个股票循环
                Code=fn{i};
                if Code(1)~='k'
                     continue
                end
                %----------------------------------------------------------
                KData=eval(['obj.KDataAll.',Code]);
                IndData=eval(['obj.IndDataAll.',Code]);
                if isempty(KData) || isempty(IndData)
                   continue
                end
                Data=[KData,IndData(:,2:end)];
                [out,title]=c_down(Data);
                if isempty(out)
                   continue
                end
                outAll=[outAll;out];
                codeArr=[codeArr;repmat({Code(2:end)},[size(out,1),1])];
                %---------------------------------------------------------- 
                waitbar(i/fnL,hwait);% 进度条
            end % for 
            close(hwait);% 关闭进度条
            toc
            Val=sortrows([codeArr,cellstr(datestr(outAll(:,1),'yyyy-mm-dd')),num2cell(outAll(:,2:end))],2);
            xlswrite('..\Data\find.xlsx',[['Code',title];Val]);
        end % find
        
         function Val=Verify(obj)
             connection=database('testDB','postgres','123456','org.postgresql.Driver','jdbc:postgresql://localhost:5432/testDB');
            curs = exec(connection, 'select * from findall where rdown20>0;');
            row = fetch(curs);
            fdata=row.Data;
            codelist=fdata(:,1);
            datelist=fdata(:,2);
            %for i=1:length(codelist)
            for i=1:5
                code=codelist{i};
                date=datelist{i};
                kdataAll=eval(['obj.KDataAll.k',code,';']);
                sid=find(kdataAll(:,1)==datenum(date,'yyyy-mm-dd'))+1;
                eid=min(size(kdataAll,1),sid+9);
                kdataAll(sid:eid,:)
            end
        end
    end %  methods
    
    methods (Access='private')
        
    end % methods (Access='private')
    
    methods (Static)
        function info=QuickInfo(Code) % 对Code列表股票快速获取即时价格信息
%             profile on
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
            Explain={'市场代码','名字','代码','当前价格','涨跌','涨跌%','成交量(手)','成交量(万)','状态','总市值'};
            Name={'Market','Name','code','RealPrice','Rise','Yield','Volume','Amount','State','TotalMarketValue'};
            info=cell2table(S,'VariableNames',Name');  
%             profile viewer
        end % QuickInfo
    
        function info=QuickInfo2(Code)
%             profile on
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
            ss=regexp(sourcefile, '~', 'split');
            S=[ss{:}];
            S=reshape(S,[10,length(S)/10])';
            S(:,1)=arrayfun(@(x) x{:}(3:10),S(:,1),'UniformOutput',0);
            S(:,3:10)=num2cell(str2double(S(:,3:10)));
            Explain={'市场代码','名字','代码','当前价格','涨跌','涨跌%','成交量(手)','成交量(万)','状态','总市值'};
            Name={'Market','Name','code','RealPrice','Rise','Yield','Volume','Amount','State','TotalMarketValue'};
            info=cell2table(S,'VariableNames',Name'); 
%             profile viewer
        end
        
        function info=RealData(obj)
            url='http://file.tushare.org/tsdata/h/hq.csv';
            [sourcefile, status] =urlread(sprintf(url),'Charset','utf-8');
             if ~status
                 error('读取错误\n')
             end
             strArr=regexp(sourcefile, '\n', 'split');
             strArr=regexp(strArr, ',', 'split');
             val=[strArr{2:end-1}];
             L=length(val);
             S=reshape(val,[30,L/30])';
%              S(:,[3:18,21:28])=num2cell(str2double(S(:,[3:18,21:28])));
%              title=strArr{1};
             S=[S(:,1),num2cell(str2double(S(:,4)))];
             title={'code','price'};
             info=cell2table(S,'VariableNames',title'); 
        end
    end  % methods (Static)
end % classdef