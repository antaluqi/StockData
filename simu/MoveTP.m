classdef MoveTP<handle
   % 移动止盈测试
    
    properties
       code       % 代码
       S          % 数据源
       Date       % 日期
       data       % 数据
       BASE_P     % 基础价格
       SELL_P      % 静态卖出价格
       sell_P      % 动态卖出价格
       SPACE      % 静态加价缓冲空间
       space      % 动态加价缓冲空间
       up         % 是否向上穿越
       WAIT_T       % 静态犹豫时间
       wait_T       % 动态犹豫时间
       sellP_list  % 动态卖出价格表
       sell_point  % 卖出点
    end
    
    methods
        function obj = MoveTP(code)
             obj.code=code;
        end
        
        % 基础参数设定
        function init(obj)
            obj.BASE_P=obj.data.Price(1);     % 测试用 基础比较价格，可以是上一天的收盘价等  
            obj.SELL_P=obj.BASE_P*(1+0.01);    % 基础卖出价格,这里设定为基础价格上浮多少比例
            obj.SPACE=0.001;                  % 减价缓冲空间（比率）
            obj.WAIT_T=2;                    % 等待时间
        end
        
        function set.code(obj,value)
            obj.S=Stock(value);
            obj.code=value;
        end
        
        function set.Date(obj,value)
            try
               obj.data=obj.S.HistoryTick(value);
               obj.Date=datetime(value);
            catch
               obj.data=[];
               obj.Date=[];
            end
        end
 
        function Loop(obj,dt)
            obj.Date=dt;
            obj.init;
            obj.sell_P=obj.SELL_P;
            obj.space=obj.SPACE;
            obj.up=0;
            obj.sellP_list=[];
            price=obj.data.Price;
            t=timeofday(datetime([datestr(obj.Date,'yyyy-mm-dd'),' 09:30'])+minutes(1:240));
            obj.sell_point={t(end),price(end)};
            obj.wait_T=obj.WAIT_T;        
            for i=1:length(price)
                if obj.up==-1
                    % 已经卖出（跳过）
                    obj.sellP_list=[obj.sellP_list,obj.sell_P];
                    continue;
                end 
                
                if price(i)<=obj.sell_P && obj.up==0
                    % 价格低于卖出点 & 非从上穿越而下(不做任何动作)
                    obj.wait_T=obj.WAIT_T;
                elseif price(i)<=obj.sell_P && obj.up==1 && obj.wait_T>0
                    % 价格低于或等于卖出点 & 为从上穿越而下 & 犹豫时间未到（维持穿越标记，犹豫时间减少）
                    obj.up=1;
                    obj.wait_T=obj.wait_T-1;
                    fprintf('第%d步%s，犹豫，价格%.3f（较SELL_P调整%.3f）,较BASE_P比例%.3f%%(较SELL_P调整%.3f%%)\n',i,t(i),price(i),price(i)-obj.SELL_P,(price(i)-obj.BASE_P)/obj.BASE_P*100,(price(i)-obj.SELL_P)/obj.BASE_P*100);

                elseif price(i)<=obj.sell_P && obj.up==1 && obj.wait_T==0
                     % 价格低于或等于卖出点 & 为从上穿越而下 & 犹豫时间已过（购买，更改穿越标记）
                    obj.up=-1;
                    obj.sell_point={t(i),price(i)};
                    fprintf('第%d步%s，卖出，价格%.3f（较SELL_P调整%.3f）,较BASE_P比例%.3f%%(较SELL_P调整%.3f%%)\n',i,t(i),price(i),price(i)-obj.SELL_P,(price(i)-obj.BASE_P)/obj.BASE_P*100,(price(i)-obj.SELL_P)/obj.BASE_P*100);
   
                elseif price(i)>obj.sell_P && price(i)<=obj.sell_P+obj.BASE_P*obj.space
                   % 价格高于购买价，但未高于缓冲区间（更改或维持穿越标记，犹豫时间复原）
                    obj.up=1;
                    obj.wait_T=obj.WAIT_T;
                elseif price(i)>obj.sell_P+obj.BASE_P*obj.space
                    % 价格高于购买价+缓冲区（更改或维持穿越标记，犹豫时间复原，购买价调整）
                    obj.up=1;
                    obj.wait_T=obj.WAIT_T;
                    obj.sell_P=price(i)-obj.BASE_P*obj.space;
                    fprintf('第%d步%s，卖出价格调整，价格%.3f（较SELL_P调整%.3f）,较BASE_P比例%.3f%%(较SELL_P调整%.3f%%)\n',i,t(i),price(i),price(i)-obj.SELL_P,(price(i)-obj.BASE_P)/obj.BASE_P*100,(price(i)-obj.SELL_P)/obj.BASE_P*100);

                else
                    disp('其他情况')
                end
                obj.sellP_list=[obj.sellP_list,obj.sell_P];
            end
            obj.plot
        end
        
        function plot(obj)
           d=datetime([datestr(obj.Date,'yyyy-mm-dd'),' 09:30']);
           t=timeofday(d+minutes(1:240));
           p=plot(t,obj.data.Price,'-o',t,obj.sellP_list');
           hold on
           plot(obj.sell_point{1},obj.sell_point{2},'r*')
           hold off
           title([obj.code,' ----  ',datestr(obj.Date,'yyyy-mm-dd')]);
        end
    end
end

