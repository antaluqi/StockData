classdef Line<customizaBass
    %-----------------------
    % 直线（无限延伸）
    % Line(f)
    %-----------------------
    properties
    end
    properties (Access = 'protected')
        p % 线的一维回归系数
    end
    methods
        function obj=Line(hMainFigure)  % 构造函数
            obj.type='Line';            % 名称
            obj.parent=hMainFigure;     % 父类
            obj.stepEnd=2;              % 最大操作步骤2
            obj.step=0;                 % 开始步骤0
            obj.motionSwitch=1;         % 鼠标移动监听打开
            obj.buttonSwitch=1;         % 鼠标点击监听打开
        end
        function calculation(obj)       %（重载）计算
            if isempty(obj.haxes)     % 画布为空则不继续
                return
            end     
            if ~isempty(obj.normPos)  % 鼠标坐标不为空则继续
                switch obj.step       % 按步骤执行计算
                    case 0 % 首次点击前（只有text）     
                        delete(obj.hthis) % 删除之前可能存在的句柄
                        obj.hthis=[];
                        if isempty(obj.textInfo) % 如果texy对象为空则新建
                            obj.textInfo=[myText(obj.parent),myText(obj.parent)];
                        end    
                        % 移动分配text的坐标和文字（只移动显示第一个，第二个没显示）
                        obj.textInfo(1).str='lValue';
                        obj.textInfo(1).normPos=obj.normPos;
                        obj.textInfo(2).str='';                        
                    case 1 % 首次点击后（一根跨屏线和两个text）
                        obj.haxesFinal=obj.haxes;     % 确定作用画布
                        % 分配text的坐标和文字（只移动显示第二个，第一个保留点击前的最后值）
                        obj.textInfo(2).str='lValue';
                        obj.textInfo(2).normPos=obj.normPos;
                        %---------------------------------------
                        %通过两个text的坐标（x,y）一维回归产生的系数，来计算直线与画布边缘的接触点(X,Y)
                        x=[obj.textInfo(1).normPos(1),obj.textInfo(2).normPos(1)]; % 两个text的x坐标
                        y=[obj.textInfo(1).normPos(2),obj.textInfo(2).normPos(2)]; % 两个text的y坐标
                        % 画布的归一化坐标
                        XPosLim=[obj.haxesFinal.Position(1),obj.haxesFinal.Position(1)+obj.haxesFinal.Position(3)];
                        YPosLim=[obj.haxesFinal.Position(2),obj.haxesFinal.Position(2)+obj.haxesFinal.Position(4)];
                        if x(1)==x(2)    % 如果是垂直线则相应输出
                            X=x;
                            Y=YPosLim;
                        elseif y(1)==y(2)% 如果是水平线则直接输出
                            Y=y;
                            X=XPosLim;
                        else             % 否则就进行一维线性回归
                            obj.p=polyfit(x,y,1);        % 一维线性回归系数
                            Yval=polyval(obj.p,XPosLim); % 用回归系数和画布的X坐标方位来计算直线是否超出了画布的Y坐标方位
                            Y=min(max(Yval,YPosLim(1)),YPosLim(2)); % 直线的Y坐标选择在范围之内的计算值（如果超出则选择边缘值）
                            X=polyval(polyfit(y,x,1),Y);            % 通过Y值反向回归计算出X值
                        end
                        %---------------------------------------
                        
                        if isempty(obj.hthis) || ~ishandle(obj.hthis) % 如无则建立直线对象
                            obj.hthis=annotation(obj.parent.hfig,'line',X,Y,'tag','Line');
                        end
                        % 分配计算所得的直线的坐标
                        obj.hthis.X=X;
                        obj.hthis.Y=Y;                        
                        
                    otherwise
                end
            end
        end    
        function plot(obj)              %（重载）绘制（此处无用）
        end
    end
    methods(Access = 'protected')
        function storeCoord(obj)        %（重载）储存图形的画布坐标
            normPos=[obj.textInfo.normPos];
            obj.coordTemp=obj.parent.norm2coord(reshape(normPos,2,[])');
        end
        function replot(obj,scr,data)   %（重载）画布坐标改变后重绘
            % 主要思路是重定位各个text的坐标，并重复calculation的step-2过程
            if ~isempty(obj.hthis) && all(ishandle(obj.hthis)) && obj.step==obj.stepEnd && ~isempty(obj.coordTemp)
                 normPos=obj.parent.coord2norm(obj.coordTemp,obj.haxesFinal.Tag);
                for i=1:length(obj.textInfo)
                    obj.textInfo(i).normPos=normPos(i,:);
                end               
                x=[obj.textInfo(1).normPos(1),obj.textInfo(2).normPos(1)];
                y=[obj.textInfo(1).normPos(2),obj.textInfo(2).normPos(2)];
                XPosLim=[obj.haxesFinal.Position(1),obj.haxesFinal.Position(1)+obj.haxesFinal.Position(3)];
                YPosLim=[obj.haxesFinal.Position(2),obj.haxesFinal.Position(2)+obj.haxesFinal.Position(4)];                
                if x(1)==x(2)
                    obj.p=[inf,inf];
                    X=x;
                    Y=YPosLim;
                elseif y(1)==y(2)
                    obj.p=[0 0];
                    X=XPosLim;
                    Y=y;
                else
                    obj.p=polyfit(x,y,1);
                    Yval=polyval(obj.p,XPosLim);
                    Y=min(max(Yval,YPosLim(1)),YPosLim(2));
                    X=polyval(polyfit(y,x,1),Y);
                end
                    obj.hthis(1).X=X;
                    obj.hthis(1).Y=Y;
                
            end
        end
    end
    methods (Static)
        function propSet(parent)
            eval([mfilename,'(parent)']);
            disp(['运行',mfilename,'参数设定'])
        end
    end
end