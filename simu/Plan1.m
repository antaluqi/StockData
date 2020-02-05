classdef Plan1<BasePlan
    % 固定基价的网格交易
    properties
        gridProp
    end
    
    methods
        function obj = Plan1(code,data)
               obj=obj@BasePlan(code,data);
               obj.gridProp.base_day='2019-11-05';
               obj.gridProp.base_price=3.8; % 基础价
               obj.gridProp.base_amount=1000;% 基础买入数量
               
               obj.gridProp.add_rate_list=[-0.05,-0.1]; % 加仓点表
               obj.gridProp.add_amt_list=[1,2]; % 加仓倍数表
               
               obj.gridProp.sub_rate_list=[0.05,0.1];  % 减仓点表
               obj.gridProp.sub_amt_list=[0.4,0.4]; % 减仓倍数表
               
               obj.gridProp.tp_rate=0.15;   % 止盈点
               obj.gridProp.sl_rate=-0.2; % 止损点
        end
        
        function out=Before_Loop(obj)
            obj.tObj.init; % 交易模块重置
            obj.cDate=obj.gridProp.base_day; % 交易日重置
            obj.gridProp.isdo_add=zeros(length(obj.gridProp.add_rate_list)); % 加仓标记重置
            obj.gridProp.isdo_sub=zeros(length(obj.gridProp.sub_rate_list)); % 减仓标记重置
            obj.gridProp.isdo_base=0; % 基价购买标志重置
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
                obj.tObj.cell(obj.cDate,price,amt);
                out=0;
                disp(['    以Open价格',num2str(price),'止损成功',num2str(amt),'份'])
                return
            end
            if obj.idata.Open>=(1+obj.gridProp.tp_rate)*obj.gridProp.base_price % 以Open止盈
                price=obj.idata.Open;
                amt=obj.tObj.amount;
                obj.tObj.cell(obj.cDate,price,amt);
                out=0;
                disp(['     以Open价格',num2str(price),'止盈成功',num2str(amt),'份'])
                return
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
                    end
                end                
            end
            % 以Low价格检测止损止盈
            if obj.idata.Low<=(1+obj.gridProp.sl_rate)*obj.gridProp.base_price % 以Open止损
                price=(1+obj.gridProp.sl_rate)*obj.gridProp.base_price;
                amt=obj.tObj.amount;
                obj.tObj.cell(obj.cDate,price,amt);
                out=0;
                disp(['     止损价',num2str(price),'止损',num2str(amt),'份'])
                return
            end
            if obj.idata.Low>=(1+obj.gridProp.tp_rate)*obj.gridProp.base_price % 以Open止盈
                price=(1+obj.gridProp.tp_rate)*obj.gridProp.base_price;
                amt=obj.tObj.amount;
                obj.tObj.cell(obj.cDate,price,amt);
                out=0;
                disp(['     止盈价',num2str(price),'止盈',num2str(amt),'份'])
                return
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
            obj.logfile=[obj.logfile;dt,base,o_h_c_l,tp_sl,add,sub,rate];
        end
        
        function out=getLog(obj)
            out=table2timetable(cell2table(obj.logfile));
            out.Properties.VariableNames ={'base','o_h_c_l','tp_sl','add','sub','rate'};
            out.Properties.DimensionNames{1}='Date';  
        end
        
        function plot(obj)
            logf=getLog(obj);
            candle(obj.data(logf.Data))
            hold on
            plot(logf.base(:,1));
            hold off
        end
    end
end

