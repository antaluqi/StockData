classdef SimuTrade<handle
   properties
       Code % ����
       data    % ����Դ
       sDate  % ��ʼ������
       sPrice % ��ʼ���򵥼�
       cPrice % ��ǰ����
       cDate  % ��ǰ����
       nDate % �¸�����
       cdata % ��ǰ����
       ndata % �¸�����
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
               obj.cdata=obj.data(value,:);
               obj.nDate=obj.NextDate(value);
           else
               error('��ǰ����cPrice��������Դdata�����ڷ�Χ֮��')
           end           
       end
       
       function set.nDate(obj,value)
          if ~isempty(value)
             obj.nDate=value;
             obj.ndata=obj.data(value,:);
          else
             obj.nDate=[];
             obj.ndata=[];              
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
               value=[];
           else
               value=obj.data(find(obj.data.Date==cdate)+1,:).Date;
           end
       end
       
       function loop(obj)
           while obj.StepNext==1
               obj.nDate
           end
           obj.EndFun
       end
       
       function out=StepNext(obj)
           if isempty(obj.nDate)
               out=0;
           else
               if SL_Check(obj) || TP_Check(obj)
                   out=0;
                   return 
               end
               Add_Check(obj);
               Sub_Check(obj);
               obj.cDate=obj.nDate;
               out=1;
           end
       end
       
       function out=SL_Check(obj) % ֹ����
           disp(['ֹ����:Low=',num2str(obj.ndata.Low),',cPrice=',num2str(obj.cPrice),',r=',num2str((obj.ndata.Low-obj.cPrice)/obj.cPrice*100),'%(Ŀ��:-10%)'])
           if obj.ndata.Low<obj.cPrice*0.9
               out=1;
               disp('��ֹ��')
           else
               out=0;
           end
       end
       
       function out=TP_Check(obj) % ֹӯ���
           disp(['ֹӯ���:High=',num2str(obj.ndata.High),',cPrice=',num2str(obj.cPrice),',r=',num2str((obj.ndata.High-obj.cPrice)/obj.cPrice*100),'%(Ŀ��:5%)'])
           if obj.ndata.High>obj.cPrice*1.05
               out=1;
               disp('��ֹӯ')
           else
               out=0;
           end
       end
       
       function out=Add_Check(obj) % �Ӳּ��
           disp('�Ӳּ��')
       end
       
       function out=Sub_Check(obj) % ���ּ��
           disp('���ּ��')
       end
       
       function out=EndFun(obj) % ����������
           disp('����')
       end
   end     
   methods (Access='private')
   end
   methods (Static) 
   end

end