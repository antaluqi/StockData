classdef CANDLE<indicationBase
    % CANDLE指标类，继承于indicationBase类
    %-------------------------
    % CANDLE(f,[720,100]) % 数据范围720天，显示最后100天
    %-------------------------
    properties
    end
    methods 
        function obj=CANDLE(hMainFigure,propertie)% 构造函数
            if nargin ==0
                hMainFigure=[];
            end
            obj=obj@indicationBase(hMainFigure);
            obj.type='CANDLE';
            obj.axesName='CandleAxes';
            obj.propNo=2;            % 参数个数2个（数据长度和显示长度）
            obj.DataNo=4;            % 数据列数（应该有5列，继承的弊端，可以考虑做相应修改）
            obj.propertie=propertie; % 设置参数
        end
        function calculation(obj)                 %（重载）计算数据（一般首次运行用到，Candle有别于通用calculation函数）
            if ~isempty(obj.parent) && ~isempty(obj.parent.DataSource)
                S=obj.parent.DataSource;
                h=S.HistoryDaily(today-obj.propertie(1),today,'L');
                obj.Data=[datenum(h.Date),h.High,h.Low,h.Close,h.Open,h.Volume];
            end
        end        
        function plot(obj)                        %（接口实现）画图

            delete(obj.hthis)
            if obj.show==1
                if isempty(obj.Data)
                    obj.hthis=[];
                elseif size(obj.Data,2)==obj.DataNo+2%？？？？？有问题，需要修改
                    %---------------------------
                    % Candle与其他Line图形共同绘制于一个图层时，更新Candle会发生错误
                    % 所以在Candle绘制的时候临时建立一个图层（位置与CandleAxes相同，并且一定要将两个图层的X轴相连）
                    hCandleAxes=findobj(obj.parent.hfig,'tag',obj.axesName);
                    haxesTemp=axes('parent',obj.parent.hfig,'position',hCandleAxes.Position);
                    linkaxes([hCandleAxes,haxesTemp],'x')
                    %---------------------------
                    axes(haxesTemp);
                    %---------------------------
                    %用普通candle绘制，可以避免时间序列绘制产生的空挡，不过句柄要靠额外取得
                    %设置颜色和显示区域
                    candle(obj.Data(:,5),obj.Data(:,2),obj.Data(:,3),obj.Data(:,4));
                    hcdl_vl = findobj(gca, 'Type', 'line');
                    hcdl_bx = findobj(gca, 'Type', 'patch');
                    obj.hthis=[hcdl_vl(:); hcdl_bx(:)];
                    ch = get(gca,'children');
                    set(ch(1),'FaceColor','g');
                    set(ch(2),'FaceColor','r');
                    showTime=[size(obj.Data,1)-obj.propertie(2),size(obj.Data,1)];
                    haxesTemp.XLim=[showTime(1)-0.5,showTime(2)+0.5];
                    
                    %---------------------------
                    % 将临时图层上绘制的Candle的Parent参数转移至CandleAxes图层并删除临时图层
                    [obj.hthis.Parent]=deal(hCandleAxes);
                    delete(haxesTemp)
                    %---------------------------
                else
                    error('CANDLE参数Data输入有误')
                end
            end
        end
        function str=getValueStr(obj,x)           %（重载）取得指标的字符串显示（x为coordPos的X坐标）
            if isempty(x)
                str=['日期： '];
                return
            end
            i=max(min(round(x),size(obj.Data,1)),1); % 取值在数据范围之内
            d=obj.Data(i,:);
            str=['日期:',datestr(d(1),'yyyy-mm-dd'),'  开:',sprintf('%8.2f',d(5)),' 高:',sprintf('%8.2f',d(2)),'  低:',sprintf('%8.2f',d(3)),'  收:',sprintf('%8.2f',d(4)),10];
        end
        function delete(obj) %？？？？？
            if ~isempty(obj.parent)
               obj.parent=[];
            end
            delete(obj.hthis)
        end
    end
    methods(Access = 'protected')

    end
    methods (Static)
        function propSet(parent)
            eval([mfilename,'(parent)']);
            disp(['运行',mfilename,'参数设定'])
        end
    end
end