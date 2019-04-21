classdef customizaBass<handle & matlab.mixin.Heterogeneous
    % 自定义对象父类
    properties
        type          % 对象名称
        parent        % 父类，MainFigure类型
        Data          % 数据（默认containers.Map格式）
        hthis         % 图形句柄
        step          % 当前操作步骤
        motionSwitch  % 窗口鼠标移动响应监听开关
        buttonSwitch  % 窗口鼠标点击响应监听开关
        beSelected    % 是否被选中
        beDestroied   % 是否被销毁（主要用于在MainFigure中注销）
        textInfo      % 显示text对象
        coordTemp     % 画布坐标存储（用于坐标轴转换后的重绘）
    end
    properties (Access = 'protected')
        listenerWBM   % 窗口鼠标移动监听
        listenerWBD   % 窗口鼠标点击监听
        listenerLC    % 画布坐标改变监听
        listenerDC    % MainFigure数据Data改变监听
        pixelPos      % 像素坐标
        coordPos      % 画布坐标
        normPos       % 归一化坐标
        haxes         % 作用的画布
        stepEnd       % 操作的最大步骤数
        haxesFinal    % 最终作用的画布
        
    end
    methods
        %--------------------------------------
        function obj=customizaBass(hMainFigure) % 构造程序
            if nargin ==0
                hMainFigure=[];
            end
            obj.parent=hMainFigure;   % 赋值父类
            obj.Data=containers.Map;  % 初始化数据
            obj.motionSwitch=0;       % 默认窗口鼠标移动响应关闭
            obj.buttonSwitch=0;       % 默认窗口鼠标点击相应关闭
            obj.beSelected=0;         % 选中状态为未选中
            obj.beDestroied=0;        % 被销毁状态为未销毁
        end
        function calculation(obj)               % 计算（用来子类重载）
           obj.Data=[];
        end
        function plot(obj)                      % 画图（用来子类重载） 
            if  ~isempty(obj.pixelPos)
                disp(['pixelPos： x=',num2str(obj.pixelPos(1)),',y=',num2str(obj.pixelPos(2))])
            end
            if  ~isempty(obj.coordPos)
                disp(['coordPos： x=',datestr(obj.coordPos(1)),',y=',num2str(obj.coordPos(2))])
            end
            if  ~isempty(obj.normPos)
                disp(['normPos： x=',num2str(obj.normPos(1)),',y=',num2str(obj.normPos(2))])
            end            
            if  ~isempty(obj.haxes)
                disp(['haxes：=',obj.haxes.Tag])
            end
        end
        function delete(obj)                    % 删除指标（包括句柄、监听、MainFigure中的注册）
            delete(obj.listenerWBM);
            delete(obj.listenerWBD);
            delete(obj.listenerLC);
            delete(obj.hthis);
            obj.beDestroied=1;
        end
        %------------------------------------set和get（在protected中实现，便于重载）
        function set.parent(obj,value)
            if ~isempty(value)
                validateattributes(value, {'MainFigure'}, {'scalar'});
                obj.parent=value;
            end
            set_parent(obj,value);
        end
        function set.Data(obj,value)
            obj.Data=value;
            set_Data(obj,value);
        end
        function set.hthis(obj,value)
             obj.hthis=value;
             set_hthis(obj,value);
        end
        function set.motionSwitch(obj,value)
            set_motionSwitch(obj,value);
            obj.motionSwitch=value;
        end
        function set.buttonSwitch(obj,value)
             set_buttonSwitch(obj,value);
             obj.buttonSwitch=value;           
        end
        function set.beSelected(obj,value)
            obj.beSelected=value;
            set_beSelected(obj,value);
        end
        function set.step(obj,value)
            set_step(obj,value);
            obj.step=value;
        end
        function set.beDestroied(obj,value)
             obj.beDestroied=value; 
            set_beDestroied(obj,value);
                     
        end  
        function value=get.pixelPos(obj)
            value=get_pixelPos(obj);
        end
        function value=get.coordPos(obj)
            value=get_coordPos(obj);
        end
        function value=get.normPos(obj)
            value=get_normPos(obj);
        end
        function value=get.haxes(obj)
            value=get_haxes(obj);
        end 
        %--------------------------------------
    end
    methods(Access = 'protected') 
        %------------------------------------set和get
        function set_parent(obj,value)       % 设置父类，注册到MainFigure的customizeObjArr中，加载鼠标事件的监听状态、加载另几个父类的监听
                obj.motionSwitch=obj.motionSwitch;
                obj.buttonSwitch=obj.buttonSwitch;
                if ~isempty(value)
                    value.customizeObjArr=[value.customizeObjArr,obj];
                    obj.listenerLC=addlistener(value,'limChange',@obj.replot);
                    obj.listenerDC=addlistener(value,'DataSourceChange',@obj.reload);
                end
        end
        function set_Data(obj,value)         % 设置数据，激活plot
            if ~isempty(value)
                obj.plot;
            end
        end        
        function set_hthis(obj,value)        % 设置句柄，加载点击相应函数（主要响应点击选中）
            if ~isempty(value) && all(ishandle(value))
                set(value,'ButtonDownFcn',{@obj.ButtonDownFcn});
            end
        end
        function set_motionSwitch(obj,value) % 设置窗口鼠标移动响应开关（设置监听）
            if isempty(obj.parent) || ishandle(obj.parent)
               return
            end
            delete(obj.listenerWBM)
            if value==0
                obj.listenerWBM=[];
            else
                obj.listenerWBM=addlistener(obj.parent,'WindowButtonMotion',@obj.Wmotion);
            end
        end
        function set_buttonSwitch(obj,value) % 设置窗口鼠标点击响应开关（设置监听）
            if isempty(obj.parent) || ishandle(obj.parent)
               return
            end
            delete(obj.listenerWBD)
            if value==0
                obj.listenerWBD=[];
            else
                obj.listenerWBD=addlistener(obj.parent,'WindowButtonDown',@obj.WDown);
            end            
        end
        function set_beSelected(obj,value)   % 设置是否被选中 
            if ~isempty(obj.hthis)  && ~strcmp(obj.type,'MARK')
                if value==0
                    set(obj.hthis,'Selected','off');
                elseif value==1
                    set(obj.hthis,'Selected','on')
                else
                    error('beSelected只能为0或1')
                end
            end            
        end
        function set_step(obj,value)         % 设置操作步骤，处理相关响应事件及控制监听
            if value==obj.stepEnd
                obj.motionSwitch=0;
                obj.buttonSwitch=0;
                %-----------------------
                obj.haxesFinal=obj.haxes;
                obj.storeCoord
                %-----------------------
            end
            if value<obj.stepEnd && obj.motionSwitch==0
                obj.motionSwitch=1;                
            end
            if value<obj.stepEnd && obj.buttonSwitch==0
                obj.buttonSwitch=1;
            end
        end
        function set_beDestroied(obj,value)  % 设置是否被销毁（主要用于在MainFigure中注销）
            if value==1
                try
                    obj.parent.customizeObjArr([obj.parent.customizeObjArr.beDestroied]==1)=[];
                catch
                    disp('set_beDestroied在删除customizeObjArr中的对象时有错误发生')
                end
            end
        end
        function value=get_pixelPos(obj)     % 取得当前鼠标像素坐标 
            if isempty(obj.parent)
                value=[];
                return
            end
            value=get(obj.parent.hfig,'currentpoint');
        end
        function value=get_coordPos(obj)     % 取得当前鼠标画布坐标
             if isempty(obj.parent)
                value=[];
                return
             end   
            co=obj.parent.pixel2coord(obj.pixelPos);
            try
                value=co(1,1:2);
            catch
                value=[];
            end            
        end
        function value=get_normPos(obj)      % 取得当前鼠标归一化坐标
            if isempty(obj.parent)
                value=[];
                return
            end   
            value=obj.parent.pixel2norm(obj.pixelPos);
        end
        function value=get_haxes(obj)        % 取得当前鼠标下画布
            if isempty(obj.parent)
                value=[];
                return
            end
            value=obj.parent.pixel2axes(obj.pixelPos);
        end
        %------------------------------------
        function storeCoord(obj)             % （需重载）储存图形的画布坐标（用于画布坐标改变后的重绘）
        end
        function replot(obj,scr,data)        % （需重载）画布坐标改变后重绘
        end
        function reload(obj,scr,data)        %  MainFigure的Data数据改变后的操作，一般为删除
            delete(obj)
        end
        function Wmotion(obj,scr,data)       %  窗口鼠标移动响应程序（激活calculation）
            %---------------------------
            obj.calculation;
            %---------------------------
        end
        function WDown(obj,scr,data)         %  窗口鼠标点击响应程序（一般为改变step+1）
            switch   get(gcbf,'SelectionType')
                case 'normal'
                    if  obj.step+1<=obj.stepEnd
                        obj.step=obj.step+1;
                    end             
            end
        end
        function ButtonDownFcn(obj,hObject,event)% 点击相应函数（左键改变选中状态，右键为改变step-1）
            switch   get(gcf,'SelectionType')
                case 'normal'
                    if ~isempty(obj.parent) && ~isempty(obj.parent.customizeObjArr)
                        if obj.beSelected==1
                            obj.beSelected=0;
                        else
                            [obj.parent.customizeObjArr.beSelected]=deal(0);
                            obj.beSelected=1;
                        end
                    end
                case 'alt'
                    if ~isempty(obj.hthis) && all(ishandle(obj.hthis)) && obj.step-1>=0
                        obj.step=obj.step-1;
                    end                          
            end
        end
    end
end