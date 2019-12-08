classdef SimuTrade<handle
   properties
       Code % ����
       data    % ����Դ
       sDate % ����ʼ��
       sPrice % ����۸�
       bPrice % ����
       cPrice % �ɱ���
       amount % ������
       sl   % stoploss ֹ����
       tp   % takeprofit ֹӯ��
       add  % �Ӳ���
       tLog % ������־
       
   end
   methods
       function obj=SimuTrade(Code,data,sDate,sPrice,sl,tp,add)  % ���캯�� 
           %addpath('..\stock');
           obj.Code=Code;
           obj.data=data;
           obj.sDate=sDate;
           obj.sPrice=sPrice;
           obj.bPrice=sPrice;
           obj.cPrice=sPrice;
           obj.amount=0;
           obj.sl=sl;
           obj.tp=tp;
           obj.add=add;
           
       end

       function set.data(obj,value)
           if ismember('Data',fieldnames(value)) && ismember('Open',fieldnames(value)) && ismember('High',fieldnames(value))&& ismember('Low',fieldnames(value))&& ismember('Close',fieldnames(value)) && ismember('Volume',fieldnames(value))
              obj.data=value;
           else
              error('data����Ҫ���� Date\Open\High\Low\Close\Volume�ֶ�')
           end
       end
       
       function Start(obj)
           dL=obj.data(obj.data.Date>obj.sDate,:);
           obj.amount=1;
           for i=1:height(dL)
              if (obj.data.High(i)-obj.cPrice)/obj.cPrice>=obj.tp
              end
              if (obj.data.Low(i)-obj.cPrice)/obj.cPrice<=obj.sl
              end
              if (obj.data.Low(i)-obj.bPrice)/obj.bPrice<=obj.add
              end
           end
       end
   end
   methods (Access='private')
   end
   methods (Static) 
   end

end