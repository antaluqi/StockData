classdef Plan3<BasePlan
    % ��ծƽ�⣨���뻯��
    properties
        gridProp
    end
    
    methods
        function obj = Plan3(code,data)
               obj=obj@BasePlan(code,data);
               obj.gridProp.base_day='2019-01-02';% ��ʼ��
               obj.gridProp.sValue=obj.tObj.funds*0.5; % ��Ʊ�ʽ����ʽ�
               obj.gridProp.bondR=0.036/365;% ծȯ������
               obj.gridProp.rfee=0.006; % ��������
               
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
                       str=[datestr(obj.cDate,'yyyy-mm-dd'),'��',num2str(price),'�ļ۸������Ʊ',num2str(amt),'��'];
                       fee=price*amt*obj.gridProp.rfee;
                   else
                       str='����ʧ��';
                   end
                   
               elseif obj.tObj.amount*obj.idata.Close>obj.gridProp.sValue
                   price=obj.idata.Close;
                   amt=obj.tObj.amount-obj.gridProp.sValue/obj.idata.Close;
                   if obj.tObj.cell(obj.cDate,price,amt)
                       str=[datestr(obj.cDate,'yyyy-mm-dd'),'��',num2str(price),'�ļ۸�������Ʊ',num2str(amt),'��'];
                       fee=price*amt*obj.gridProp.rfee;
                   else
                       str='���ʧ��';
                   end                  
               end
               obj.tObj.funds=(obj.tObj.funds-fee)*(1+obj.gridProp.bondR);
               s=obj.tObj.amount*obj.idata.Close;
               b=obj.tObj.funds;
               disp(['(�ɣ�',num2str(s),',ծ��',num2str(b),',�ܣ�',num2str(s+b),')',str])
            
        end
        
        function WriteLog(obj)

        end
        
        function out=getLog(obj)

        end
        
        function plot(obj)

        end
    end
end