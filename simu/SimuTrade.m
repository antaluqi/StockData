classdef SimuTrade<handle
   properties
       Code % 代码
       data    % 数据源
       sDate  % 初始购买日
       sPrice % 初始购买单价
       cPrice % 当前单价
       cDate  % 当前日期
       nDate % 下个日期
       sAmount % 初始购买数量
       cAmount % 当前数量
       tLog % 交易日志
       
   end
   methods
       function obj=SimuTrade(Code,data,sDate,sPrice,sAmount)  % 构造函数 
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
              error('data必须要包含 Date\Open\High\Low\Close\Volume字段')
           end
       end
       
       function set.sDate(obj,value)
           if any(obj.data.Date==value)
               obj.sDate=value;
           else
               error('开始日期sPrice超出数据源data的日期范围之外')
           end
       end
       
       function set.cDate(obj,value)
           if any(obj.data.Date==value)
               obj.cDate=value;
               obj.nDate=obj.NextDate(value);
           else
               error('当前日期cPrice超出数据源data的日期范围之外')
           end           
       end
       
       function set.sPrice(obj,value)
           i=find(obj.data.Date==obj.sDate);
           if value<=obj.data.High(i) && value>=obj.data.Low(i)
               obj.sPrice=value;
           else
              error([obj.Code,'的sPrice数据',num2str(value),'在',num2str(obj.sDate),'日超出当日数据范围[',num2str(obj.data.Low(i)),',',num2str(obj.data.High(i)),']']);
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
       
       function SL_Check(obj) % 止损检测
           disp('止损检测')
       end
       
       function TP_Check(obj) % 止盈检测
           disp('止盈检测')
       end
       
       function Add_Check(obj) % 加仓检测
           disp('加仓检测')
       end
       
       function Sub_Check(obj) % 减仓检测
           disp('减仓检测')
       end
       
       function EndFun(obj) % 结束处理函数
           disp('结束')
       end
   end     
   methods (Access='private')
   end
   methods (Static) 
   end

end