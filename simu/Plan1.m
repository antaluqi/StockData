classdef Plan1<BasePlan
    % �̶����۵�������
    properties
        gridProp
    end
    
    methods
        function obj = Plan1(code,data)
               obj=obj@BasePlan(code,data);
               obj.gridProp.base_day='2019-11-05';
               obj.gridProp.base_price=3.8; % ������
               obj.gridProp.base_amount=1000;% ������������
               
               obj.gridProp.add_rate_list=[-0.05,-0.1]; % �Ӳֵ��
               obj.gridProp.add_amt_list=[1,2]; % �Ӳֱ�����
               
               obj.gridProp.sub_rate_list=[0.05,0.1];  % ���ֵ��
               obj.gridProp.sub_amt_list=[0.4,0.4]; % ���ֱ�����
               
               obj.gridProp.tp_rate=0.15;   % ֹӯ��
               obj.gridProp.sl_rate=-0.2; % ֹ���
        end
        
        function out=Before_Loop(obj)
            obj.tObj.init; % ����ģ������
            obj.cDate=obj.gridProp.base_day; % ����������
            obj.gridProp.isdo_add=zeros(length(obj.gridProp.add_rate_list)); % �Ӳֱ������
            obj.gridProp.isdo_sub=zeros(length(obj.gridProp.sub_rate_list)); % ���ֱ������
            obj.gridProp.isdo_base=0; % ���۹����־����
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
                obj.tObj.cell(obj.cDate,price,amt);
                out=0;
                disp(['    ��Open�۸�',num2str(price),'ֹ��ɹ�',num2str(amt),'��'])
                return
            end
            if obj.idata.Open>=(1+obj.gridProp.tp_rate)*obj.gridProp.base_price % ��Openֹӯ
                price=obj.idata.Open;
                amt=obj.tObj.amount;
                obj.tObj.cell(obj.cDate,price,amt);
                out=0;
                disp(['     ��Open�۸�',num2str(price),'ֹӯ�ɹ�',num2str(amt),'��'])
                return
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
                    end
                end                
            end
            % ��Low�۸���ֹ��ֹӯ
            if obj.idata.Low<=(1+obj.gridProp.sl_rate)*obj.gridProp.base_price % ��Openֹ��
                price=(1+obj.gridProp.sl_rate)*obj.gridProp.base_price;
                amt=obj.tObj.amount;
                obj.tObj.cell(obj.cDate,price,amt);
                out=0;
                disp(['     ֹ���',num2str(price),'ֹ��',num2str(amt),'��'])
                return
            end
            if obj.idata.Low>=(1+obj.gridProp.tp_rate)*obj.gridProp.base_price % ��Openֹӯ
                price=(1+obj.gridProp.tp_rate)*obj.gridProp.base_price;
                amt=obj.tObj.amount;
                obj.tObj.cell(obj.cDate,price,amt);
                out=0;
                disp(['     ֹӯ��',num2str(price),'ֹӯ',num2str(amt),'��'])
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

