classdef BasePlan<handle
     properties
         code    % ����
         data    % ����Դ
         tObj    % ���������
         
         needDataField  % ��Ҫ�������ֶ�,��ͬplan�ɸ�����Ҫ�޸� 
         cDate  % ��ǰ����
         idata  % ��ǰ����
         logfile=[]
     end
     properties(Access='private')
         startDay
     end
     methods
         function obj=BasePlan(code,data)
               obj.code=code;
               obj.data=data;
               obj.tObj=trade(code,data);
               obj.needDataField={'Open','Low','Close','High','Volume'};
               obj.cDate=data.Date(1);
         end
         
         function [out,info]=DataFieldCheck(obj) % �����ֶμ��
               if ~isa(obj.data,'timetable')
                   out=0;
                   info='data����Ϊtimetable����';
                   return;
               end
               if ~all(ismember(obj.needDataField,obj.data.Properties.VariableNames))
                    out=0;
                   info='data�����ֶ�ȱʧ';        
                   return;
               end
               out=1;
               info='';
         end
         
         function  set.cDate(obj,value)
              if ~any(value==obj.data.Date)     
                  error('��ʼ�ձ��������data�������ڷ�Χ��')
              end
              obj.cDate=datetime(value);
              obj.idata=obj.data(value,:);
         end
         
         function Loop(obj)         % ѭ��
             if isempty(obj.cDate)
                 error('��ȷ����ʼ��')
             end
             obj.Before_Loop;
             datelist=obj.data.Date;
             s=find(obj.cDate==datelist,1);
             for i=s:length(obj.data.Date)
                   obj.cDate=datelist(i);
                   disp(string(obj.cDate)+' ���׼��')
                   obj.WriteLog;
                   out=obj.check;
                   if out==0
                      break;
                   end
                   
             end
             obj.After_Loop;
         end
         
         function out=check(obj) % ѭ��ִ������
             
         end
         
         function out=Before_Loop(obj)  % ѭ��ǰ
             obj.tObj.init;
         end
         
         function out=After_Loop(obj)   % ѭ����
             
         end
         
         function WriteLog(obj)
         end
     end

end