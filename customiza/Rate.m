classdef Rate<customizaBass
    %-----------------------
    % 收益测量线
    % Rate(f)
    %-----------------------
    properties
    end
    methods
        function obj=Rate(hMainFigure) % 构造函数
            obj.type='Rate';           % 名称
            obj.parent=hMainFigure;    % 父类
            obj.stepEnd=2;             % 最大操作步骤2
            obj.step=0;                % 开始步骤0
            obj.motionSwitch=1;        % 鼠标移动监听打开
            obj.buttonSwitch=1;        % 鼠标点击监听打开
        end
        function calculation(obj)      %（重载）计算
            if isempty(obj.haxes)      % 画布为空则不继续
                return
            end            
            if ~isempty(obj.normPos)   % 鼠标坐标不为空则继续
                area=obj.parent.axesObj.area;
                [left,right]=deal(area(1,1),area(1,2));
                 x=obj.normPos(1);
                 y=obj.normPos(2);                
                switch obj.step % 按步骤执行计算
                    case 0 % 首次点击前
                        firstLineX=[left,right];        % 开始线坐标X（画布宽度）
                        firstLineY=[y,y];               % 开始线坐标Y（鼠标的归一化坐标）
                        firstLineTextPos=[right-0.1,y]; % 开始线text对象坐标
                        firstLineTextStr='0%:lValue';   % 开始线text对象文字
                        % 赋值给Data的containers.Map容器
                        obj.Data=containers.Map({'firstLineX','firstLineY','firstLineTextPos','firstLineTextStr'},{firstLineX,firstLineY,firstLineTextPos,firstLineTextStr});
                    case 1 % 首次点击后
                        firstLineX=obj.Data('firstLineX'); % 开始线坐标X（取出用于计算）
                        firstLineY=obj.Data('firstLineY'); % 开始线坐标Y（取出用于计算）
                        endLineX=[left,right];             % 结束线坐标X（画布宽度）
                        endLineY=[y,y];                    % 结束线坐标Y（鼠标的归一化坐标）
                        firstLineTextPos=obj.Data('firstLineTextPos'); % 开始线text对象坐标 
                        endLineTextPos=[right-0.1,endLineY(1)];        % 结束线text对象坐标
                        firstLineTextStr=obj.Data('firstLineTextStr'); % 开始线text对象文字
                                                                       % 计算区间收益
                        End=roundn(obj.parent.norm2coord([0.5,y]),-2); 
                        Start=roundn(obj.parent.norm2coord([0.5,firstLineY(1)]),-2);
                        str=[num2str(roundn(100*(End(2)-Start(2))/Start(2),-2)),'%:lValue'];
                        endLineTextStr=str;                            % 结束线text对象文字
                        % 赋值给Data的containers.Map容器
                        Key={'firstLineX','firstLineY','endLineX','endLineY'...
                            ,'firstLineTextPos','endLineTextPos','firstLineTextStr','endLineTextStr'};
                        Value={firstLineX,firstLineY,endLineX,endLineY...
                            ,firstLineTextPos,endLineTextPos,firstLineTextStr,endLineTextStr};
                        obj.Data=containers.Map(Key,Value);
                    otherwise
                end
            end
        end     
        function plot(obj)             %（重载）绘制
            switch obj.step % 按步骤绘制
                case 0  % 首次点击前
                    % 如无则建立开始线对象
                    if length(obj.hthis)>1 || isempty(obj.hthis) ||(length(obj.hthis)==1 && ~ishandle(obj.hthis))
                        delete(obj.hthis)
                        obj.hthis=annotation(obj.parent.hfig,'line',obj.Data('firstLineX'),obj.Data('firstLineY'),'tag','crossLine_level');    %水平线
                        delete(obj.textInfo)
                        obj.textInfo=[myText(obj.parent),myText(obj.parent)];
                    end
                    % 分配开始线的坐标和文字
                    obj.hthis.X=obj.Data('firstLineX');
                    obj.hthis.Y=obj.Data('firstLineY');
                    obj.textInfo(1).str=obj.Data('firstLineTextStr') ; 
                    obj.textInfo(1).normPos=obj.Data('firstLineTextPos') ;
                case 1 % 首次点击后
                    if length(obj.hthis)~=2 % 建立结束线、0.618线、0.382线的对象
                        delete(obj.hthis);
                        firstLine=annotation(obj.parent.hfig,'line',obj.Data('firstLineX'),obj.Data('firstLineY'),'tag','crossLine_level');
                        endLine=annotation(obj.parent.hfig,'line',obj.Data('endLineX'),obj.Data('endLineY'),'tag','crossLine_level');
                        obj.hthis=[firstLine,endLine];
                    end
                    % 分配结束线、0.618线、0.382线的对象的坐标和文字
                    obj.hthis(2).X=obj.Data('endLineX');
                    obj.hthis(2).Y=obj.Data('endLineY');
                    obj.textInfo(2).str=obj.Data('endLineTextStr');
                    obj.textInfo(2).normPos=obj.Data('endLineTextPos');
                otherwise
            end
        end        
    end
    methods(Access = 'protected')
        function storeCoord(obj)       %（重载）储存图形的画布坐标（用于画布坐标改变后的重绘）
            normX=cell2mat({obj.hthis.X}');
            normY=cell2mat({obj.hthis.Y}');
            pointStart=[normX(:,1),normY(:,1)];
            pointEnd=[normX(:,2),normY(:,2)];
            coordStart=obj.parent.norm2coord(pointStart);
            coordEnd=obj.parent.norm2coord(pointEnd);
            obj.coordTemp=[coordStart;coordEnd];
        end
        function replot(obj,scr,data)  %（重载）画布坐标改变后重绘
            if ~isempty(obj.hthis) && all(ishandle(obj.hthis)) && obj.step==obj.stepEnd && ~isempty(obj.coordTemp)
                normPos=obj.parent.coord2norm(obj.coordTemp,obj.haxesFinal.Tag);
                normPosStart=normPos(1:4,:);
                y=normPosStart(:,2);
                [obj.hthis.Y]=deal([y(1),y(1)],[y(2),y(2)]);
                textBox=[obj.textInfo.hthis];
                for i=1:length(textBox)
                    textBox(i).Position(2)=y(i);
                end
                obj.Data('firstLineY')=[y(1),y(1)];
                obj.Data('endLineY')=[y(2),y(2)];
                firstLineTextPos=obj.Data('firstLineTextPos');
                firstLineTextPos(2)=y(1);
                obj.Data('firstLineTextPos')=firstLineTextPos;
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