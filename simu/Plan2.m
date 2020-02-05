classdef Plan2<BasePlan
   % �䶯���۵�������
    properties
        gridProp
    end
    
    methods
        function obj = Plan2(code,data)
               obj=obj@BasePlan(code,data);
               obj.gridProp.base_day='2019-06-14';
               obj.gridProp.b_base_price=40.26;% ���������
               obj.gridProp.base_price=obj.gridProp.b_base_price; % �䶯������
               obj.gridProp.base_b_amount=1000; % ���������������
               obj.gridProp.base_amount=obj.gridProp.base_b_amount;% �䶯������������
               
               obj.gridProp.add_rate_list=[-0.05,-0.1,-0.2]; % �Ӳֵ��
               obj.gridProp.add_amt_list=[1,1,1]; % �Ӳֱ�����
               
               obj.gridProp.sub_rate_list=[];  % ���ֵ��
               obj.gridProp.sub_amt_list=[]; % ���ֱ�����
               
               obj.gridProp.tp_rate=0.2;   % ֹӯ��
               obj.gridProp.sl_rate=-0.9; % ֹ���
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
            % �����۸���
            if obj.gridProp.isdo_base==0
                if obj.cDate~=obj.gridProp.base_day
                    disp('     ���۹������ڴ���')
                    out=0;
                    return
                end
                price=obj.gridProp.base_price;
                amt=obj.gridProp.base_amount;
                if obj.tObj.buy(obj.cDate,price,amt)
                   obj.gridProp.isdo_base=1; 
                   disp(['     �Ի��۸�',num2str(price),'����ɹ�',num2str(amt),'��']) 
                else
                   disp('     �Ի��۹���ʧ��') 
                   out=0;
                   return
                end
            end
            
            % ��Open�۸���ֹ��ֹӯ
            if obj.idata.Open<=(1+obj.gridProp.sl_rate)*obj.gridProp.base_price % ��Openֹ��
                price=obj.idata.Open;
                amt=obj.tObj.amount;
                if obj.tObj.cell(obj.cDate,price,amt);
                    out=0;
                    disp(['    ��Open�۸�',num2str(price),'ֹ��ɹ�',num2str(amt),'��'])
                    return
                end
            end
            if obj.idata.Open>=(1+obj.gridProp.tp_rate)*obj.gridProp.base_price % ��Openֹӯ
                price=obj.idata.Open;
                amt=obj.tObj.amount;
                if obj.tObj.cell(obj.cDate,price,amt);
                    out=0;
                    disp(['     ��Open�۸�',num2str(price),'ֹӯ�ɹ�',num2str(amt),'��'])
                    return
                end
            end
            % �Ӳּ��
            for i=1:length(obj.gridProp.add_rate_list)
                if obj.gridProp.isdo_add(i)==1
                    continue
                end
                if obj.idata.Low<=(1+obj.gridProp.add_rate_list(i))*obj.gridProp.base_price
                    price=(1+obj.gridProp.add_rate_list(i))*obj.gridProp.base_price;
                    amt= obj.gridProp.add_amt_list(i)*obj.gridProp.base_amount;
                    if obj.tObj.buy(obj.cDate,price,amt)
                        obj.gridProp.isdo_add(i)=1;
                        disp(['     �Ե�',num2str(i),'�Ӳּ۸�',num2str(price),'����ɹ�',num2str(amt),'��'])
                        obj.gridProp.base_price=(obj.tObj.s_funds-obj.tObj.funds)/obj.tObj.amount;% ��������
                        obj.gridProp.base_amount=obj.gridProp.base_amount+amt;% ���������ֲ���
                    end
                end
            end
            % ���ּ��
            for i=1:length(obj.gridProp.sub_rate_list)
                if obj.gridProp.isdo_sub(i)==1
                    continue
                end 
                if obj.idata.High>=(1+obj.gridProp.sub_rate_list(i))*obj.gridProp.base_price
                    price=(1+obj.gridProp.sub_rate_list(i))*obj.gridProp.base_price;
                    amt= obj.gridProp.sub_amt_list(i)*obj.gridProp.base_amount;
                    if obj.tObj.cell(obj.cDate,price,amt)
                        obj.gridProp.isdo_sub(i)=1;
                        disp(['     �Ե�',num2str(i),'���ּ۸�',num2str(price),'��سɹ�',num2str(amt),'��'])
                        %obj.gridProp.base_price=(obj.tObj.s_funds-obj.tObj.funds)/obj.tObj.amount;% ��������
                        obj.gridProp.base_amount=obj.gridProp.base_amount-amt;% ���������ֲ���
                    end
                end                
            end
            % ��Low�۸���ֹ��ֹӯ
            if obj.idata.Low<=(1+obj.gridProp.sl_rate)*obj.gridProp.base_price % ��Openֹ��
                price=(1+obj.gridProp.sl_rate)*obj.gridProp.base_price;
                amt=obj.tObj.amount;
                if obj.tObj.cell(obj.cDate,price,amt);
                    out=0;
                    disp(['     ֹ���',num2str(price),'ֹ��',num2str(amt),'��'])
                    return
                end
            end
            if obj.idata.Low>=(1+obj.gridProp.tp_rate)*obj.gridProp.base_price % ��Openֹӯ
                price=(1+obj.gridProp.tp_rate)*obj.gridProp.base_price;
                amt=obj.tObj.amount;
                if obj.tObj.cell(obj.cDate,price,amt);
                    out=0;
                    disp(['     ֹӯ��',num2str(price),'ֹӯ',num2str(amt),'��'])
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

