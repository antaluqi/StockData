classdef SimuTrade<handle
   properties
       Code % ����
       data    % ����Դ
       sDate  % ��ʼ������
       sPrice % ��ʼ���򵥼�
       cPrice % ��ǰ����
       cDate  % ��ǰ����
       nDate % �¸�����
       sAmount % ��ʼ��������
       cAmount % ��ǰ����
       tLog % ������־
       
   end
   methods
       function obj=SimuTrade(Code,data,sDate,sPrice,sAmount)  % ���캯�� 
           %addpath('..\stock');
           obj.Code=Code;
           obj.data=data;
           obj.sDate=sDate;
           obj.sPrice=sPrice;
           obj.cPrice=sPrice;
           obj.cDate=sDate;
           obj.sAmount=sAmount;
           obj.cAmount=sAmount;
       end

       function set.data(obj,value)
           if ismember('Date',fieldnames(value)) && ismember('Open',fieldnames(value)) && ismember('High',fieldnames(value))&& ismember('Low',fieldnames(value))&& ismember('Close',fieldnames(value)) && ismember('Volume',fieldnames(value))
              obj.data=value;
           else
              error('data����Ҫ���� Date\Open\High\Low\Close\Volume�ֶ�')
           end
       end
       
       function set.sDate(obj,value)
           if any(obj.data.Date==value)
               obj.sDate=value;
           else
               error('��ʼ����sPrice��������Դdata�����ڷ�Χ֮��')
           end
       end
       
       function set.cDate(obj,value)
           if any(obj.data.Date==value)
               obj.cDate=value;
               obj.nDate=obj.NextDate(value);
           else
               error('��ǰ����cPrice��������Դdata�����ڷ�Χ֮��')
           end           
       end
       
       function set.sPrice(obj,value)
           i=find(obj.data.Date==obj.sDate);
           if value<=obj.data.High(i) && value>=obj.data.Low(i)
               obj.sPrice=value;
           else
              error([obj.Code,'��sPrice����',num2str(value),'��',num2str(obj.sDate),'�ճ����������ݷ�Χ[',num2str(obj.data.Low(i)),',',num2str(obj.data.High(i)),']']);
           end
       end
       
       function value=NextDate(obj,cdate)
           if find(obj.data.Date==cdate)>=height(obj.data)
               value='';
           else
               value=obj.data(find(obj.data.Date==cdate)+1,:).Date;
           end
       end
       
       function out=StepNext(obj)
           if isempty(obj.nDate)
               obj.EndFun
               out=0;
           else
               SL_Check(obj);
               TP_Check(obj)
               Add_Check(obj)
               Sub_Check(obj)
               obj.cDate=obj.nDate;
               out=1;
           end
       end
       
       function SL_Check(obj) % ֹ����
           disp('ֹ����')
       end
       
       function TP_Check(obj) % ֹӯ���
           disp('ֹӯ���')
       end
       
       function Add_Check(obj) % �Ӳּ��
           disp('�Ӳּ��')
       end
       
       function Sub_Check(obj) % ���ּ��
           disp('���ּ��')
       end
       
       function EndFun(obj) % ����������
           disp('����')
       end
   end     
   methods (Access='private')
   end
   methods (Static) 
   end

end