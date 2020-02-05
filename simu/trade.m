classdef trade<handle
    %TRADE 此处显示有关此类的摘要
    %   此处显示详细说明
    
    properties
        code                % 代码
        data;               % 数据
        s_funds;            % 初始资金
        s_can_use_funds;    % 初始可用资金
        s_amount;           % 初始证券数额
        s_can_use_amount;   % 初始可用证券数额
        
        tdate;              % 当前交易日
        funds;              % 资金
        can_use_funds;      % 可用资金
        amount;             % 证券数额
        can_use_amount;     % 可用证券数额
        dealLog             % 成交记录
        entrustsLog         % 委托记录
    end
    
    methods
        function obj = trade(code,data)
            obj.code=code;
            obj.data=data;
            obj.s_funds=100000;
            obj.s_can_use_funds=100000;
            obj.s_amount=0;
            obj.s_can_use_amount=0;
            obj.init;
        end
        
        function init(obj)
            obj.funds=obj.s_funds;
            obj.can_use_funds=obj.s_can_use_funds;
            obj.amount=obj.s_amount;
            obj.can_use_amount=obj.s_can_use_amount; 
            obj.tdate=obj.data.Date(1);
            obj.dealLog=[];
            obj.entrustsLog=[];
        end
        
        function set.tdate(obj,value)
                
               if isempty(obj.tdate) || value>obj.tdate
                 obj.can_use_funds=obj.funds;
                 obj.can_use_amount=obj.amount;
               end
                obj.tdate=datetime(value);
        end
        
        function out=buy(obj,dt,money,amt)
            if dt<obj.tdate       % 交易日不能小于现在交易日
                disp('交易日不能小于现在交易日')
                obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'买入',money,amt,'失败',['交易日',dt,'不能小于现在交易日',obj.tdate]}];
                out=0;
                return;
            end

            if ~((dt==obj.tdate && money*amt<=obj.can_use_funds) || (dt>obj.tdate && money*amt<obj.funds)) % 资金必须够
                disp('资金必须够')
                obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'买入',money,amt,'失败',['资金必须够funds:',num2str(obj.funds),'/can_use_fund:',num2str(obj.can_use_funds),'<money:',num2str(money),'×amt:',num2str(amt)]}];
                out=0;
                return;
            end
            if ~any(dt==obj.data.Date) % 交易日期必须在数据里面
                disp('交易日期必须在数据里面')
                obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'买入',money,amt,'失败','交易日期必须在数据里面'}];
               out=0;
               return;
            end
            
            
            if money>obj.data.High(dt)|| money<obj.data.Low(dt) % 交易价格必须在当日数据范围内
              disp('交易价格必须在当日数据范围内')  
              obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'买入',money,amt,'失败',['交易价格',num2str(money),'必须在当日数据范围内(Low:',num2str(obj.data.Low(dt)),',High:',num2str(obj.data.High(dt)),')']}];
               out=0;
               return;                
            end
            
            obj.tdate=dt;
            
            obj.funds=obj.funds-money*amt;
            obj.can_use_funds=obj.can_use_funds-money*amt;
            obj.amount=obj.amount+amt;
            obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'买入',money,amt,'成功','null'}];
            obj.dealLog=[obj.dealLog;{obj.tdate,'买入',money,amt}];
            out=1;
        end
        
        function out=cell(obj,dt,money,amt)
            if dt<obj.tdate       % 交易日不能小于现在交易日
                 disp('交易日不能小于现在交易日')
                 obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'卖出',money,-amt,'失败',['交易日',dt,'不能小于现在交易日',obj.tdate]}];
                out=0;
                return;
            end
            
            if ~any(dt==obj.data.Date) % 交易日期必须在数据里面
                 disp('交易日期必须在数据里面')
                 obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'卖出',money,-amt,'失败','交易日期必须在数据里面'}];
               out=0;
               return;
            end     
            

            if ~((dt==obj.tdate && amt<=obj.can_use_amount) || (dt>obj.tdate && amt<=obj.amount))  % 可卖证券数量必须够
                 disp('可卖证券数量必须够')
                 obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'卖出',money,-amt,'失败',['可卖证券数量amount:',num2str(obj.amount),'/can_use_funds:',num2str(obj.can_use_amount),'<amt:',num2str(amt)]}];
                out=0;
                return;
            end
            
            if money>obj.data.High(dt)|| money<obj.data.Low(dt) % 交易价格必须在当日数据范围内
                disp('交易价格必须在当日数据范围内') 
                obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'卖出',money,-amt,'失败',['交易价格',num2str(money),'必须在当日数据范围内(Low:',num2str(obj.data.Low(dt)),',High:',num2str(obj.data.High(dt)),')']}];
               
               out=0;
               return;                
            end            
            
            obj.tdate=dt;
            obj.amount=obj.amount-amt;
            obj.can_use_amount=obj.can_use_amount-amt;
            obj.funds=obj.funds+money*amt;
            obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'卖出',money,-amt,'成功','null'}];
            obj.dealLog=[obj.dealLog;{obj.tdate,'卖出',money,-amt}];
            out=1;
            
        end
        
        function out=getDealHis(obj)
            out=table2timetable(cell2table(obj.dealLog));
            out.Properties.VariableNames ={'Opt','Price','iAmt'};
            out.Properties.DimensionNames{1}='Date';
            out.Amt=cumsum(out.iAmt);
            out.iMoney=-out.Price.*out.iAmt;
            out.Money=cumsum(out.iMoney)+obj.s_funds;
        end
        
        function out=getEntrustsHis(obj)
            out=table2timetable(cell2table(obj.entrustsLog));
            out.Properties.VariableNames ={'Opt','Price','Amt','Succ','Info'};
            out.Properties.DimensionNames{1}='Date';            
        end
        
        function out=getDayHis(obj)
            out=[];
            dh=obj.getDealHis;
             for i=1:height(dh)
                 if i==1
                     iOut=obj.data(obj.data.Date<dh.Date(i),{'Close'});
                     iOut.Amt=zeros(height(iOut),1);
                     iOut.Money=obj.s_funds*ones(height(iOut),1);
                     out=[out;iOut];
                 else
                     iOut=obj.data(obj.data.Date>=dh.Date(i-1) & obj.data.Date<dh.Date(i),{'Close'});
                     iOut.Amt=ones(height(iOut),1)*dh.Amt(i-1);
                     iOut.Money=dh.Money(i-1)*ones(height(iOut),1);
                     out=[out;iOut];
                 end
             end
             iOut=obj.data(obj.data.Date>=dh.Date(end),{'Close'});
             iOut.Amt=ones(height(iOut),1)*dh.Amt(end);
             iOut.Money=dh.Money(end)*ones(height(iOut),1);
             out=[out;iOut];
             out.Value=out.Money+out.Amt.*out.Close;
             if obj.amount==0
               out=out(obj.entrustsLog{1,1}:obj.tdate,:);
             else
               out=out(obj.entrustsLog{1,1}:obj.data.Date(end),:);  
             end
        end
    end
end

