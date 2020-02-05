classdef Plan3<BasePlan
    % 股债平衡（理想化）
    properties
        gridProp
    end
    
    methods
        function obj = Plan3(code,data)
               obj=obj@BasePlan(code,data);
               obj.gridProp.base_day='2019-01-02';% 开始日
               obj.gridProp.sValue=obj.tObj.funds*0.5; % 股票资金总资金
               obj.gridProp.bondR=0.036/365;% 债券日利率
               obj.gridProp.rfee=0.006; % 手续费率
               
        end
        
        function out=Before_Loop(obj)
             obj.tObj.init;
             obj.cDate=obj.gridProp.base_day;
             obj.tObj.tdate=obj.cDate;
        end
        
        function out=check(obj)
            out=1;
               obj.tObj.tdate=obj.cDate;
               str='';
               fee=0;
               if obj.tObj.amount*obj.idata.Close<obj.gridProp.sValue
                   price=obj.idata.Close;
                   amt=obj.gridProp.sValue/obj.idata.Close-obj.tObj.amount;
                   if obj.tObj.buy(obj.cDate,price,amt)
                       str=[datestr(obj.cDate,'yyyy-mm-dd'),'以',num2str(price),'的价格买入股票',num2str(amt),'股'];
                       fee=price*amt*obj.gridProp.rfee;
                   else
                       str='购买失败';
                   end
                   
               elseif obj.tObj.amount*obj.idata.Close>obj.gridProp.sValue
                   price=obj.idata.Close;
                   amt=obj.tObj.amount-obj.gridProp.sValue/obj.idata.Close;
                   if obj.tObj.cell(obj.cDate,price,amt)
                       str=[datestr(obj.cDate,'yyyy-mm-dd'),'以',num2str(price),'的价格卖出股票',num2str(amt),'股'];
                       fee=price*amt*obj.gridProp.rfee;
                   else
                       str='赎回失败';
                   end                  
               end
               obj.tObj.funds=(obj.tObj.funds-fee)*(1+obj.gridProp.bondR);
               s=obj.tObj.amount*obj.idata.Close;
               b=obj.tObj.funds;
               disp(['(股：',num2str(s),',债：',num2str(b),',总：',num2str(s+b),')',str])
            
        end
        
        function WriteLog(obj)

        end
        
        function out=getLog(obj)

        end
        
        function plot(obj)

        end
    end
end