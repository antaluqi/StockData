classdef LineSegment<customizaBass
    %-----------------------
    % 线段
    % LineSegment(f)
    %-----------------------
    properties
    end
    methods
        function obj=LineSegment(hMainFigure) % 构造函数
            obj.type='LineSegment';
            obj.parent=hMainFigure;
            hMainFigure.customizeObjArr=[hMainFigure.customizeObjArr,obj];% 可以放入父类中 
            obj.stepEnd=2;
            obj.step=0;
            obj.motionSwitch=1;
            obj.buttonSwitch=1;                 
        end
        function calculation(obj)             %（重载）计算
            if isempty(obj.haxes)    % 画布为空则不继续      
                return
            end
            if ~isempty(obj.normPos) % 鼠标坐标不为空则继续
                switch obj.step % 按步骤执行计算
                    case 0 % 首次点击前（只有text）
                        delete(obj.hthis) % 删除之前可能存在的句柄
                        obj.hthis=[];
                        if isempty(obj.textInfo) % 如果texy对象为空则新建
                            obj.textInfo=[myText(obj.parent),myText(obj.parent)];
                        end
                        % 移动分配text的坐标和文字（只移动显示第一个，第二个没显示）
                        obj.textInfo(1).str=num2str(roundn(obj.coordPos(2),-2));
                        obj.textInfo(1).haxes=obj.haxes;
                        obj.textInfo(1).coordPos=obj.coordPos;
                        obj.textInfo(2).str='';
                    case 1 % 首次点击后（一根线两个text）
                        obj.haxesFinal=obj.haxes; % 确定作用画布
                        % 分配text的坐标和文字（只移动显示第二个，第一个保留点击前的最后值）
                        obj.textInfo(2).str=num2str(roundn(obj.coordPos(2),-2));
                        obj.textInfo(2).haxes=obj.haxes;
                        obj.textInfo(2).coordPos=obj.coordPos;
                        if isempty(obj.hthis) || ~ishandle(obj.hthis) % 如无则建立线的句柄（使用coordPos坐标）
                            obj.hthis=line([obj.textInfo(1).coordPos(1),obj.textInfo(2).coordPos(1)],[obj.textInfo(1).coordPos(2),obj.textInfo(2).coordPos(2)],'parent',obj.haxesFinal);
                        end
                        % 移动分配线的坐标
                        obj.hthis.XData=[obj.textInfo(1).coordPos(1),obj.textInfo(2).coordPos(1)];
                        obj.hthis.YData=[obj.textInfo(1).coordPos(2),obj.textInfo(2).coordPos(2)];
                    otherwise
                end
            end
        end
        function plot(obj)                    %（重载）绘制（此处无用）
        end
    end
    methods(Access = 'protected')
        function storeCoord(obj)              %（重载）储存图形的画布坐标（此处使用了coordPos绘制，所以重载为无操作）
        end
        function replot(obj,scr,data)         %（重载）画布坐标改变后重绘（此处使用了coordPos绘制，所以重载为无操作）
        end      
    end
    methods (Static)
        function propSet(parent)
            eval([mfilename,'(parent)']);
            disp(['运行',mfilename,'参数设定'])
        end
    end
end