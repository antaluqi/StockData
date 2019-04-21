classdef StockDataCatch < handle
 %% ����  ========================================================
    properties
       databaseName
       connA
    end % properties 
    properties(Access='private')
    end % properties(Access='private') 
 %% ���� =========================================================   
     methods
         function obj=StockDataCatch(obj) % ���캯�� 
             obj.databaseName='StockDataStore';
             %obj.connA = database.ODBCConnection('ttt','','')
             obj.connA=database(obj.databaseName,'','')    
         end % StockDataCatch
       
         function curs=CreatTable(obj,TableName) % ������Ӧ��Access��
             switch TableName
                 case 'StockList'
                     SQLQUERY='Create TABLE [StockList]([StockCode] varchar(50),[StockName] varchar(50),[Mark] varchar(50))'
                     curs = exec(obj.connA,SQLQUERY);
                 case 'RealTimeData'
                     SQLQUERY='Create TABLE [RealTimeData]([unknow1] varchar(50),[StockName] varchar(50),[StockCode] varchar(50),[RealPrice] varchar(50),[YClosePrice] varchar(50),[OpenPrice] varchar(50),[Volume] varchar(50),[Buy] varchar(50),[Sell] varchar(50),[Buy1Price] varchar(50),[Buy1Volume] varchar(50),[Buy2Price] varchar(50),[Buy2Volume] varchar(50),[Buy3Price] varchar(50),[Buy3Volume] varchar(50),[Buy4Price] varchar(50),[Buy4Volume] varchar(50),[Buy5Price] varchar(50),[Buy5Volume] varchar(50),[Sell1Price] varchar(50),[Sell1Volume] varchar(50),[Sell2Price] varchar(50),[Sell2Volume] varchar(50),[Sell3Price] varchar(50),[Sell3Volume] varchar(50),[Sell4Price] varchar(50),[Sell4Volume] varchar(50),[Sell5Price] varchar(50),[Sell5Volume] varchar(50),[LastTransaction] varchar(200),[LastTime] varchar(50),[Rise] varchar(50),[Yield] varchar(50),[HighPrice] varchar(50),[LowPrice] varchar(50),[Price_Volume_Amount] varchar(50),[Volume2] varchar(50),[Amount] varchar(50),[TurnoverRate] varchar(50),[PE] varchar(50),[blank1] varchar(50),[High] varchar(50),[Low] varchar(50),[Amplitude] varchar(50),[CirculationMarketValue] varchar(50),[TotalMarketValue] varchar(50),[PB] varchar(50),[HardenPrice] varchar(50),[LimitPrice] varchar(50),[blank2] varchar(50))'
                    curs = exec(obj.connA,SQLQUERY);
                 case 'Fund'
                    SQLQUERY='Create TABLE [Fund]([StockCode] varchar(50),[MainInflow] varchar(50),[MainOutflow] varchar(50),[MainNetInflow] varchar(50),[MainNetInflow_D_MainTotal] varchar(50),[RetailInflow] varchar(50),[RetailOutflow] varchar(50),[RetailNetInflow] varchar(50),[RetailNetInflow_D_RetailTotal] varchar(50),[TotalFund] varchar(50),[unknow1] varchar(50),[unknow2] varchar(50),[StockName] varchar(50),[LastTime] varchar(50),[unknow3] varchar(50),[unknow4] varchar(50),[unknow5] varchar(50),[unknow6] varchar(50))'
                    curs = exec(obj.connA,SQLQUERY);
                 case 'TapeReading' 
                    SQLQUERY='Create TABLE [TapeReading]([StockCode] varchar(50),[BuyLargeQuantity] varchar(50),[BuySmallQuantity] varchar(50),[SellLargeQuantity] varchar(50),[SellSmallQuantity] varchar(50))';
                    curs = exec(obj.connA,SQLQUERY);                   
                 case 'SimpleInfo'
                     SQLQUERY='Create TABLE [SimpleInfo]([unknow1] varchar(50),[StockName] varchar(50),[StockCode] varchar(50),[RealPrice] varchar(50),[Rise] varchar(50),[Yield] varchar(50),[Volume] varchar(50),[Amount] varchar(50),[TradingSuspension] varchar(50),[TotalMarketValue] varchar(50))';
                     curs = exec(obj.connA,SQLQUERY);                   
                 otherwise
                     error('�����Խ����˱�')
             end
             
         end % CreatTable
         function exdata=StockList(obj)      % �����
            url='http://quote.eastmoney.com/stocklist.html';
            tablename = 'StockList';
            [sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
            if ~status
                error('��ȡ����\n')
            end
            expr1='<li><a target="_blank" href="http://quote.eastmoney.com/.*?">(.*?)\((\d+)\)</a></li>';
            [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
            a=[date_tokens{:}];
            b=[a(2:2:end);a(1:2:end)]';
            colnames={'StockCode','StockName'};
            exdata=cell2table(b,'VariableNames',colnames);
            
            curs = exec(obj.connA,['DELETE FROM ',tablename]);
            insert(obj.connA,tablename,colnames,exdata);
            
         end % StockList
         function exdata=RealTimeData(obj,CodeList)   % �����̿����ݱ�
             urlHead='http://qt.gtimg.cn/q=' % ������ת���ɵ�ַ��ɲ���
             C=strcat(CodeList,','); % ������ת���ɵ�ַ��ɲ���
             urlAddress=strcat(urlHead,[C{:}]);
             % ��ȡ��ҳ��Ϣ
             [sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
             if ~status
                 error('��ȡ����\n')
             end
             % ������ʽ(����Ʊ��Ϣ�б������������)
             expr1='(?<=v_)(.*?)(?=";)';
             [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
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
             colnames={'unknow1','StockName','StockCode','RealPrice','YClosePrice','OpenPrice','Volume','Buy','Sell','Buy1Price','Buy1Volume','Buy2Price','Buy2Volume','Buy3Price','Buy3Volume','Buy4Price','Buy4Volume','Buy5Price','Buy5Volume','Sell1Price','Sell1Volume','Sell2Price','Sell2Volume','Sell3Price','Sell3Volume','Sell4Price','Sell4Volume','Sell5Price','Sell5Volume','LastTransaction','LastTime','Rise','Yield','HighPrice','LowPrice','Price_Volume_Amount','Volume2','Amount','TurnoverRate','PE','blank1','High','Low','Amplitude','CirculationMarketValue','TotalMarketValue','PB','HardenPrice','LimitPrice','blank2'};
             exdata=cell2table(S,'VariableNames',colnames);
             tablename = 'RealTimeData';
             curs = exec(obj.connA,['DELETE FROM ',tablename]);
             insert(obj.connA,tablename,colnames,exdata);            
         end % RealTimeData
         function exdata=Fund(obj,CodeList) % �ʽ����������
             % ��Ѷ���ݽӿڵ�ַ��ͷ
             urlHead='http://qt.gtimg.cn/q='
             % ������ת���ɵ�ַ��ɲ���
             C=strcat('ff_',CodeList,',');
             urlAddress=strcat(urlHead,[C{:}]);
             % ��ȡ��ҳ��Ϣ
             [sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
             if ~status
                 error('��ȡ����\n')
             end
             % ������ʽ(����Ʊ��Ϣ�б������������)
             expr1='(?<=v_)(.*?)(?=";)';
             [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
             sourcefile=[date_tokens{:}]';
             for i=1:length(sourcefile)
                 expr1='(?<=="s[hz])(.*)';
                 [datefile, date_tokens]= regexp(sourcefile{i}, expr1, 'match', 'tokens');
                 sourcefile2=date_tokens{:};
                 % �ָ���Ϣ
                 ss=regexp(sourcefile2, '~', 'split');
                 % �����ȡ����Ϣ
                 S(i,:)=ss{:};
             end
             colnames={'StockCode','MainInflow','MainOutflow','MainNetInflow','MainNetInflow_D_MainTotal','RetailInflow','RetailOutflow','RetailNetInflow','RetailNetInflow_D_RetailTotal','TotalFund','unknow1','unknow2','StockName','LastTime','unknow3','unknow4','unknow5','unknow6'};
             exdata=cell2table(S,'VariableNames',colnames);
             tablename = 'Fund';
             curs = exec(obj.connA,['DELETE FROM ',tablename]);
             insert(obj.connA,tablename,colnames,exdata);   
         end % Fund
         function exdata=TapeReading(obj,CodeList) % �̿ڷ�����
             % ��Ѷ���ݽӿڵ�ַ��ͷ
             urlHead='http://qt.gtimg.cn/q='
             % ������ת���ɵ�ַ��ɲ���
             C=strcat('s_pk',CodeList,',');
             urlAddress=strcat(urlHead,[C{:}]);
             % ��ȡ��ҳ��Ϣ
             [sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
             if ~status
                 error('��ȡ����\n')
             end
             % ������ʽ(����Ʊ��Ϣ�б������������)
             expr1='(?<=v_)(.*?)(?=";)';
             [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
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
             colnames={'StockCode','BuyLargeQuantity','BuySmallQuantity','SellLargeQuantity','SellSmallQuantity'};
             exdata=cell2table(S,'VariableNames',colnames);
             tablename = 'TapeReading';
             curs = exec(obj.connA,['DELETE FROM ',tablename]);
             insert(obj.connA,tablename,colnames,exdata);   
         end
         function exdata=SimpleInfo(obj,CodeList) % ��ȡ��Ҫ��Ϣ��
             % ��Ѷ���ݽӿڵ�ַ��ͷ
             urlHead='http://qt.gtimg.cn/q='
             % ������ת���ɵ�ַ��ɲ���
             C=strcat('s_',CodeList,',');
             urlAddress=strcat(urlHead,[C{:}]);
             % ��ȡ��ҳ��Ϣ
             [sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
             if ~status
                 error('��ȡ����\n')
             end
             % ������ʽ(����Ʊ��Ϣ�б������������)
             expr1='(?<=v_)(.*?)(?=";)';
             [datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
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
             colnames={'unknow1','StockName','StockCode','RealPrice','Rise','Yield','Volume','Amount','TradingSuspension','TotalMarketValue'};
             exdata=cell2table(S,'VariableNames',colnames);
             tablename = 'SimpleInfo';
             curs = exec(obj.connA,['DELETE FROM ',tablename]);  
             insert(obj.connA,tablename,colnames,exdata);   
         end
         
         function delete(obj) % ��������
             close(obj.connA)
         end % delete
     end % methods
    
    
    
    
    
    
end
