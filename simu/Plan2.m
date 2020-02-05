classdef Plan2<BasePlan
   % 变动基价的网格交易
    properties
        gridProp
    end
    
    methods
        function obj = Plan2(code,data)
               obj=obj@BasePlan(code,data);
               obj.gridProp.base_day='2019-06-14';
               obj.gridProp.b_base_price=40.26;% 不变基础价
               obj.gridProp.base_price=obj.gridProp.b_base_price; % 变动基础价
               obj.gridProp.base_b_amount=1000; % 不变基础买入数量
               obj.gridProp.base_amount=obj.gridProp.base_b_amount;% 变动基础买入数量
               
               obj.gridProp.add_rate_list=[-0.05,-0.1,-0.2]; % 加仓点表
               obj.gridProp.add_amt_list=[1,1,1]; % 加仓倍数表
               
               obj.gridProp.sub_rate_list=[];  % 减仓点表
               obj.gridProp.sub_amt_list=[]; % 减仓倍数表
               
               obj.gridProp.tp_rate=0.2;   % 止盈点
               obj.gridProp.sl_rate=-0.9; % 止损点
        end
        
        function out=Before_Loop(obj)
            obj.tObj.init;
            obj.cDate=obj.gridProp.base_day;
            obj.gridProp.base_price=obj.gridProp.b_base_price;
            obj.gridProp.base_amount=obj.gridProp.base_b_amount;
            obj.gridProp.isdo_add=zeros(length(obj.gridProp.add_rate_list));
            obj.gridProp.isdo_sub=zeros(length(obj.gridProp.sub_rate_list));
            obj.gridProp.isdo_base=0;
            out=1;
        end
        
        function out=check(obj)
            out=1;
            % 基础价格购买
            if obj.gridProp.isdo_base==0
                if obj.cDate~=obj.gridProp.base_day
                    disp('     基价购买日期错误')
                    out=0;
                    return
                end
                price=obj.gridProp.base_price;
                amt=obj.gridProp.base_amount;
                if obj.tObj.buy(obj.cDate,price,amt)
                   obj.gridProp.isdo_base=1; 
                   disp(['     以基价格',num2str(price),'买入成功',num2str(amt),'份']) 
                else
                   disp('     以基价购买失败') 
                   out=0;
                   return
                end
            end
            
            % 以Open价格检测止损止盈
            if obj.idata.Open<=(1+obj.gridProp.sl_rate)*obj.gridProp.base_price % 以Open止损
                price=obj.idata.Open;
                amt=obj.tObj.amount;
                if obj.tObj.cell(obj.cDate,price,amt);
                    out=0;
                    disp(['    以Open价格',num2str(price),'止损成功',num2str(amt),'份'])
                    return
                end
            end
            if obj.idata.Open>=(1+obj.gridProp.tp_rate)*obj.gridProp.base_price % 以Open止盈
                price=obj.idata.Open;
                amt=obj.tObj.amount;
                if obj.tObj.cell(obj.cDate,price,amt);
                    out=0;
                    disp(['     以Open价格',num2str(price),'止盈成功',num2str(amt),'份'])
                    return
                end
            end
            % 加仓检测
            for i=1:length(obj.gridProp.add_rate_list)
                if obj.gridProp.isdo_add(i)==1
                    continue
                end
                if obj.idata.Low<=(1+obj.gridProp.add_rate_list(i))*obj.gridProp.base_price
                    price=(1+obj.gridProp.add_rate_list(i))*obj.gridProp.base_price;
                    amt= obj.gridProp.add_amt_list(i)*obj.gridProp.base_amount;
                    if obj.tObj.buy(obj.cDate,price,amt)
                        obj.gridProp.isdo_add(i)=1;
                        disp(['     以第',num2str(i),'加仓价格',num2str(price),'购买成功',num2str(amt),'份'])
                        obj.gridProp.base_price=(obj.tObj.s_funds-obj.tObj.funds)/obj.tObj.amount;% 调整基价
                        obj.gridProp.base_amount=obj.gridProp.base_amount+amt;% 调整基础持仓数
                    end
                end
            end
            % 减仓检测
            for i=1:length(obj.gridProp.sub_rate_list)
                if obj.gridProp.isdo_sub(i)==1
                    continue
                end 
                if obj.idata.High>=(1+obj.gridProp.sub_rate_list(i))*obj.gridProp.base_price
                    price=(1+obj.gridProp.sub_rate_list(i))*obj.gridProp.base_price;
                    amt= obj.gridProp.sub_amt_list(i)*obj.gridProp.base_amount;
                    if obj.tObj.cell(obj.cDate,price,amt)
                        obj.gridProp.isdo_sub(i)=1;
                        disp(['     以第',num2str(i),'减仓价格',num2str(price),'赎回成功',num2str(amt),'份'])
                        %obj.gridProp.base_price=(obj.tObj.s_funds-obj.tObj.funds)/obj.tObj.amount;% 调整基价
                        obj.gridProp.base_amount=obj.gridProp.base_amount-amt;% 调整基础持仓数
                    end
                end                
            end
            % 以Low价格检测止损止盈
            if obj.idata.Low<=(1+obj.gridProp.sl_rate)*obj.gridProp.base_price % 以Open止损
                price=(1+obj.gridProp.sl_rate)*obj.gridProp.base_price;
                amt=obj.tObj.amount;
                if obj.tObj.cell(obj.cDate,price,amt);
                    out=0;
                    disp(['     止损价',num2str(price),'止损',num2str(amt),'份'])
                    return
                end
            end
            if obj.idata.Low>=(1+obj.gridProp.tp_rate)*obj.gridProp.base_price % 以Open止盈
                price=(1+obj.gridProp.tp_rate)*obj.gridProp.base_price;
                amt=obj.tObj.amount;
                if obj.tObj.cell(obj.cDate,price,amt);
                    out=0;
                    disp(['     止盈价',num2str(price),'止盈',num2str(amt),'份'])
                    return
                end
            end            
            

        end
        
        function WriteLog(obj)
            dt=obj.cDate;
            base=[obj.gridProp.base_price,obj.gridProp.base_amount];
            o_h_c_l=[obj.idata.Open,obj.idata.High,obj.idata.Close,obj.idata.Low];
            tp_sl=(1+[obj.gridProp.tp_rate,obj.gridProp.sl_rate])*obj.gridProp.base_price;
            add=(1+obj.gridProp.add_rate_list)*obj.gridProp.base_price;
            sub=(1+obj.gridProp.sub_rate_list)*obj.gridProp.base_price;
            rate=[num2str((o_h_c_l-obj.gridProp.base_price)/obj.gridProp.base_price*100),'%'];
            obj.logfile=[obj.logfile;{dt,base,o_h_c_l,tp_sl,add,sub,rate}];
        end
        
        function out=getLog(obj)
            out=table2timetable(cell2table(obj.logfile));
            out.Properties.VariableNames ={'base','o_h_c_l','tp_sl','add','sub','rate'};
            out.Properties.DimensionNames{1}='Date';  
        end
        
        function plot(obj)
            logf=getLog(obj);
            candle(obj.data(logf.Date,:))
            hold on
            %plot(logf.Date,[logf.base(:,1)]);
            plot(logf.Date,logf.tp_sl(:,1));
            plot(logf.Date,logf.add);
            %plot(logf.Date,logf.sub);
            hold off
        end
    end
end

