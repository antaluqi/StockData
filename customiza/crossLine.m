classdef crossLine<customizaBass
    % 十字线类
    properties
        midRange % 交叉点空洞大小
    end
    methods
        function obj=crossLine(hMainFigure) % 构造函数
            obj.type='crossLine';    % 名称
            obj.parent=hMainFigure;  % 父类
            obj.midRange=0.01;       % 交叉点空洞大小
            obj.motionSwitch=1;      % 鼠标移动监听打开 
            obj.buttonSwitch=0;      % 鼠标点击监听关闭
        end
        function calculation(obj)           %（重载）计算（此处包括绘图）
            if isempty(obj.parent) || isempty(obj.haxes) % 如果载体为空则删除所有组件
                delete(obj.hthis)
                try
                    delete([obj.textInfo.hthis])
                end
                return
            end
            %----------------------------------------------------------计算
            if ~isempty(obj.normPos)  % 在坐标点不为空的情况下运行
                area=obj.parent.axesObj.area;
                [left,right,bottom,top]=deal(area(1,1),area(1,2),area(2,1),area(2,2)); %所有axes的范围
                x=obj.normPos(1); % 鼠标归一化坐标X
                y=obj.normPos(2); % 鼠标归一化坐标Y
                leftlX=[left,x-obj.midRange];     % 左边线的X坐标
                leftlY=[y,y];                     % 左边线的Y坐标
                rightlX=[x+obj.midRange,right];   % 右边线的X坐标
                rightlY=[y,y];                    % 右边线的Y坐标
                bottomvX=[x,x];                   % 下边线的X坐标
                bottomvY=[bottom,y-obj.midRange]; % 下边线的Y坐标
                topvX=[x,x];                      % 上边线的X坐标
                topvY=[y+obj.midRange,top];       % 上边线的Y坐标
                ltextPos=[right,y];               % 横线右边text的坐标
                vtextPos=[x,top];                 % 纵线上边text的坐标
                ltextStr='lValue';                % 横线右边text的文字（实际的Y值）
                vtextStr='vDate';                 % 纵线上边text的文字（日期值）
                %------------------------------------------------------绘图
                if isempty(obj.hthis) || all(~ishandle(obj.hthis)) % 首次建立图形对象
                    leftl=annotation(obj.parent.hfig,'line',leftlX,leftlY,'tag','left_level');            %左边线
                    rightl=annotation(obj.parent.hfig,'line',rightlX,rightlY,'tag','right_level');        %右边线
                    bottomv=annotation(obj.parent.hfig,'line',bottomvX,bottomvY,'tag','bottom_vertical'); %下边线
                    topv=annotation(obj.parent.hfig,'line',topvX,topvY,'tag','top_vertical');             %上边线
                    obj.hthis=[leftl,rightl,bottomv,topv]; % 组合图形句柄
                end
                % 之后每次只对图形对象分配坐标
                leftl=obj.hthis(1);
                rightl=obj.hthis(2);
                bottomv=obj.hthis(3);
                topv=obj.hthis(4);
                leftl.X=leftlX;
                leftl.Y=leftlY;
                rightl.X=rightlX;
                rightl.Y=rightlY;
                bottomv.X=bottomvX;
                bottomv.Y=bottomvY;
                topv.X=topvX;
                topv.Y=topvY;
                
                if isempty(obj.textInfo)  || all(~ishandle([obj.textInfo.hthis])) % 首次建立text对象
                    obj.textInfo=[myText(obj.parent),myText(obj.parent)];
                end
                % 之后每次只对text对象分配坐标和文字
                htext=[obj.textInfo.hthis];
                %[htext.Visible]=deal('on');
                obj.textInfo(1).str=ltextStr;
                obj.textInfo(2).str=vtextStr;
                obj.textInfo(1).normPos=ltextPos;
                obj.textInfo(2).normPos=vtextPos;
                %---------------------------------------------------------
            end
            
        end
        function plot(obj)                  %（重载）绘图（此处无用）    
        end
        function delete(obj)                %（重载）删除指标（多了一个CrossLineSwitch=0）
            obj.parent.CrossLineSwitch=0;
            delete(obj.listenerWBM);
            delete(obj.listenerWBD);
            delete(obj.listenerLC);
            delete(obj.hthis);
            obj.beDestroied=1;
        end
    end
    methods(Access = 'protected')
        function set_motionSwitch(obj,value)% 鼠标移动监听开关
            set_motionSwitch@customizaBass(obj,value);
            if value==0
                delete(obj.hthis)
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