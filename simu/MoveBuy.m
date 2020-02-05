classdef MoveBuy<handle
    % 移动购买测试
    
    properties
       code       % 代码
       S          % 数据源
       Date       % 日期
       data       % 数据
       BASE_P     % 基础价格
       BUY_P      % 静态购买价格
       buy_P      % 动态购买价格
       SPACE      % 静态减价缓冲空间
       RESET      % 放弃交易的偏离度阈值
       space      % 动态减价缓冲空间
       down       % 是否向下穿越
       WAIT_T       % 静态犹豫时间
       wait_T       % 动态犹豫时间
       buyP_list  % 动态购买价格表
       buy_point  % 卖出点
    end
    
    methods
        function obj = MoveBuy(code)
            obj.code=code;
        end
        
        % 基础参数设定
        function init(obj)
            obj.BASE_P=obj.data.Price(1);     % 测试用 基础比较价格，可以是上一天的收盘价等  
            obj.BUY_P=obj.BASE_P*(1-0.00);    % 基础购买价格,这里设定为基础价格下浮多少比例
            obj.SPACE=0.001;                  % 减价缓冲空间（比率）
            obj.RESET=0.001;
            obj.WAIT_T=2;                     % 等待时间
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
            obj.buy_P=obj.BUY_P;
            obj.space=obj.SPACE;
            obj.down=0;
            obj.buyP_list=[];
            obj.buy_point={};
            price=obj.data.Price;
            t=timeofday(datetime([datestr(obj.Date,'yyyy-mm-dd'),' 09:30'])+minutes(1:240));
            obj.buy_point={t(end),price(end)};
            obj.wait_T=obj.WAIT_T;
            for i=1:length(price)
                
                if obj.down==-1
                    % 已经购买（跳过）
                    obj.buyP_list=[obj.buyP_list,obj.buy_P];
                    continue;
                end
                
                if price(i)>=obj.buy_P && obj.down==0
                      % 价格高于购买点 & 非从下穿越而上(不做任何动作)
                    obj.wait_T=obj.WAIT_T;
                elseif  price(i)>=obj.buy_P && obj.down==1 && obj.wait_T>0
                    % 价格高于或等于购买点 & 为从下穿越而上 & 犹豫时间未到（维持穿越标记，犹豫时间减少）   
                    obj.down=1;
                    obj.wait_T=obj.wait_T-1;
                    fprintf('第%d步%s，犹豫，价格%.3f（较BUY_P调整%.3f）,较BASE_P比例%.3f%%(较BUY_P调整%.3f%%)\n',i,t(i),price(i),price(i)-obj.BUY_P,(price(i)-obj.BASE_P)/obj.BASE_P*100,(price(i)-obj.BUY_P)/obj.BASE_P*100);

                elseif  price(i)>=obj.buy_P && obj.down==1 && obj.wait_T==0 && (price(i)-obj.BUY_P)/obj.BASE_P<obj.RESET
                    % 价格高于或等于购买点 & 为从下穿越而上 & 犹豫时间已过 & 价格偏离度小于阈值（购买，更改穿越标记）
                    obj.down=-1;
                    obj.buy_point={t(i),price(i)};
                    fprintf('第%d步%s，购买，价格%.3f（较BUY_P调整%.3f）,较BASE_P比例%.3f%%(较BUY_P调整%.3f%%)\n',i,t(i),price(i),price(i)-obj.BUY_P,(price(i)-obj.BASE_P)/obj.BASE_P*100,(price(i)-obj.BUY_P)/obj.BASE_P*100);
                elseif  price(i)>=obj.buy_P && obj.down==1 && obj.wait_T==0 && (price(i)-obj.BUY_P)/obj.BASE_P>=obj.RESET
                    % 价格高于或等于购买点 & 为从下穿越而上 & 犹豫时间已过 & 价格偏离度大于等于阈值（放弃购买，还原）
                    obj.down=0;
                    obj.buy_P=obj.BUY_P;
                    obj.wait_T=obj.WAIT_T;
                    fprintf('第%d步%s，价格偏离过大，复原，价格%.3f（较BUY_P调整%.3f）,较BASE_P比例%.3f%%(较BUY_P调整%.3f%%)\n',i,t(i),price(i),price(i)-obj.BUY_P,(price(i)-obj.BASE_P)/obj.BASE_P*100,(price(i)-obj.BUY_P)/obj.BASE_P*100);
                elseif price(i)<obj.buy_P && price(i)>=obj.buy_P-obj.BASE_P*obj.space
                    % 价格低于购买价，但未低于缓冲区间（更改或维持穿越标记，犹豫时间复原）
                    obj.down=1;
                    obj.wait_T=obj.WAIT_T;
                elseif price(i)<obj.buy_P-obj.BASE_P*obj.space
                    % 价格低于购买价+缓冲区（更改或维持穿越标记，犹豫时间复原，购买价调整）
                    obj.down=1;
                    obj.wait_T=obj.WAIT_T;
                    obj.buy_P=price(i)+obj.BASE_P*obj.space;
                    fprintf('第%d步%s，购买价格调整，价格%.3f（较BUY_P调整%.3f）,较BASE_P比例%.3f%%(较BUY_P调整%.3f%%)\n',i,t(i),price(i),price(i)-obj.BUY_P,(price(i)-obj.BASE_P)/obj.BASE_P*100,(price(i)-obj.BUY_P)/obj.BASE_P*100);

                else
                    fprintf('第%d步%s,其他情况\n',i,t(i))
                end
                obj.buyP_list=[obj.buyP_list,obj.buy_P];
                
            end
            obj.plot
        end
        
        function plot(obj)
           d=datetime([datestr(obj.Date,'yyyy-mm-dd'),' 09:30']);
           t=timeofday(d+minutes(1:240));
           p=plot(t,obj.data.Price,'-o',t,obj.buyP_list');
           hold on
           plot(obj.buy_point{1},obj.buy_point{2},'r*')
           hold off
           title([obj.code,' ----  ',datestr(obj.Date,'yyyy-mm-dd')]);
        end
    end
end

