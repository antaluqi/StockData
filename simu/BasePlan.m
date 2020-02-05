classdef BasePlan<handle
     properties
         code    % 代码
         data    % 数据源
         tObj    % 交易类对象
         
         needDataField  % 需要的数据字段,不同plan可根据需要修改 
         cDate  % 当前日期
         idata  % 当前数据
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
         
         function [out,info]=DataFieldCheck(obj) % 数据字段检测
               if ~isa(obj.data,'timetable')
                   out=0;
                   info='data必须为timetable类型';
                   return;
               end
               if ~all(ismember(obj.needDataField,obj.data.Properties.VariableNames))
                    out=0;
                   info='data数据字段缺失';        
                   return;
               end
               out=1;
               info='';
         end
         
         function  set.cDate(obj,value)
              if ~any(value==obj.data.Date)     
                  error('起始日必须包含于data数据日期范围中')
              end
              obj.cDate=datetime(value);
              obj.idata=obj.data(value,:);
         end
         
         function Loop(obj)         % 循环
             if isempty(obj.cDate)
                 error('请确定起始日')
             end
             obj.Before_Loop;
             datelist=obj.data.Date;
             s=find(obj.cDate==datelist,1);
             for i=s:length(obj.data.Date)
                   obj.cDate=datelist(i);
                   disp(string(obj.cDate)+' 交易检测')
                   obj.WriteLog;
                   out=obj.check;
                   if out==0
                      break;
                   end
                   
             end
             obj.After_Loop;
         end
         
         function out=check(obj) % 循环执行内容
             
         end
         
         function out=Before_Loop(obj)  % 循环前
             obj.tObj.init;
         end
         
         function out=After_Loop(obj)   % 循环后
             
         end
         
         function WriteLog(obj)
         end
     end

end