classdef indicationBase<handle & matlab.mixin.Heterogeneous
    % 指标对象的基类
    properties
        type         % 种类名称
        parent       % 父级（加载DataSource监听）
        axesName     % 画布名称
        hthis        % 图形对象句柄(赋值后将indArrClass添加到图形句柄的UseData中)
        propertie    % 参数（需符合propNo个数限制，赋值后触发obj.calculation）
        Data         % 数据（需符合DataNo个数限制，赋值后触发obj.plot）
        show         % 显示开关（调用plot）
        beSelected   % 是否被选中
        
    end
    properties (Access = 'protected')
        propNo       % 允许的参数个数
        DataNo       % 允许的数据列数
        listenerDC   % MainFigure对象数据改变监听
        pField       % Stock.Indications方法产生的数据中规定的数据名称前缀（如BOllMid,MA等，后面还要加参数的str，如BOllUp20_2）
    end  
    methods
        %-------------------------------------
        function obj=indicationBase(hMainFigure) % 构造函数
            if nargin ==0
                hMainFigure=[];
            end
            obj.listenerDC=[];
            obj.parent=hMainFigure;
            obj.show=1;
        end
        function calculation(obj)                % 计算数据（一般首次运行用到）
            if ~isempty(obj.parent) && ~isempty(obj.parent.DataSource)
                %--------------------------------------如果有Candle则获取日期范围，否则日期参数默认（可以考虑做在CANDLE类中）
                S=obj.parent.DataSource;
                if ~strcmp('type','CANDLE') && ~isempty(obj.parent) && isa(obj.parent,'MainFigure') && ~isempty(obj.parent.indObjArr)
                   candleObj=obj.parent.indObjArr(strcmp({obj.parent.indObjArr.type},'CANDLE'));
                else
                    candleObj=[];
                end
                if ~isempty(candleObj) && ~isempty(candleObj.Data)
                    startDay=candleObj.Data(1,1);
                    endDay=candleObj.Data(end,1);                   
                else
                    startDay=today-720;
                    endDay=today;
                end
                %--------------------------------------

                tableData=S.Indicators({obj.type},{obj.propertie},{startDay,endDay}); % 计算
                obj.Data=[datenum(tableData.Date),tableData{:,7:end}];% 取出相应字段数据
            else
                error('MainFigure没有数据源')
            end
            
        end
        function update(obj,scr,data)            % DataSource事件相应函数
            obj.reload;
        end
        function reload(obj)                     %（可重载）数据加载，将MainFigure的Data数据中与指标有关的加载到本类的Data中
            try
            reLoadData=obj.parent.Data;
            catch
                disp('通知了已经被删除的对象')
                obj
                return
            end
            if ~isempty(reLoadData) 
                pStr=strjoin(arrayfun(@(x) num2str(x),obj.propertie,'UniformOutput',0),'_'); % 参数字符化，如[15,2]变为'15_2'
                if strcmp(obj.type,'CANDLE') % 如果指标是Candle，则取得相应字段数据
                    % obj.Data=extfield(reLoadData,{'Open','High','Close','Low','Volume'});
                    
                     d=[reLoadData.High,reLoadData.Low,reLoadData.Close,reLoadData.Open,reLoadData.Volume]; %---------------------------------------
                     obj.Data=[d.dates,fts2mat(d)];%---------------------------------------
                else                         % 如果指标是非Candle，则取得相应字段数据
                    d=extfield(reLoadData,strcat(obj.pField,pStr)); % 取得类似BOll15_2、MA10等字段数据，和日期数据段合并
                    obj.Data=[d.dates,fts2mat(d)];           
                end
            else
                obj.calculation;
            end
        end
        function str=getValueStr(obj,x)          %（可重载）取得指标的字符串显示（x为coordPos的X坐标）
            str=[];
        end 
        function delete(obj)                     % 删除指标（包括hthis和listenerDC）
            delete(obj.listenerDC)
            delete(obj.hthis)
            disp([obj.type,'被删除'])
        end

        %-------------------------------------
        % set和get函数实体都在methods(Access= 'protected')中，不然子类无法重载
        function set.parent(obj,value)
            set_parent(obj,value);
            obj.parent=value;
        end 
        function set.propertie(obj,value)
            obj.propertie=value;
            set_propertie(obj,value);
        end
        function set.Data(obj,value)
             obj.Data=value;
             set_Data(obj,value);
        end
        function set.show(obj,value)
             obj.show=value;
             set_show(obj,value);
        end
        function set.hthis(obj,value)
            set_hthis(obj,value);
            obj.hthis=value;
        end
        function set.beSelected(obj,value)
            varaout=set_beSelected(obj,value);
            if ~isempty(varaout)
                obj.beSelected=varaout;
            end
        end
        function value=get.beSelected(obj)
            value=get_beSelected(obj);
        end
        %-------------------------------------
    end
    methods(Access = 'protected') % 各set或get方法的实体，便于子类对其重载（简介在上面参数表中）
        function set_parent(obj,value)             % 设置父类，加载监听、将自身加入到parent.indObjArr数组中
            if ~isempty(value)
                validateattributes(value, {'MainFigure'}, {'scalar'});
                if isempty(obj.listenerDC)
                    obj.listenerDC=value.addlistener('DataSourceChange',@obj.update);
                end
               value.indObjArr=[value.indObjArr,obj];%=============================
            end
        end
        function set_propertie(obj,value)          % 设置参数，符合要求就运行calculation，如果为空则删除当前hthis
            if ~isempty(value)
                if  ~ismember(length(value),obj.propNo)
                    error([obj.type,'输入参数propertie有误'])
                end
                obj.calculation;
            else
                delete(obj.hthis)
            end
        end
        function set_Data(obj,value)               % 设置数据，一般由calculation计算而来，运行plot
            obj.plot            
        end  
        function set_show(obj,value)               % 设置显示开关
            switch value
                case 0
                    delete(obj.hthis)
                case 1
                    obj.plot
                otherwise
                    error([obj.type,'的show参数只能输入0或1'])
            end      
        
        end
        function set_hthis(obj,value)              % 设置指标图像句柄，设置点击事件回调函数（一般用于检测选定与否）
            set(value,'ButtonDownFcn',{@obj.ButtonDownFcn});
        end
        function varaout=set_beSelected(obj,value) % 设置选定状态
            if ~isempty(obj.hthis) && ~strcmp(obj.type,'CANDLE') && ~strcmp(obj.type,'MARK')
                if value==0
                    arrayfun(@(x) set(x,'Selected','off'),obj.hthis,'UniformOutput',0);
                elseif value==1
                    arrayfun(@(x) set(x,'Selected','on'),obj.hthis,'UniformOutput',0);
                else
                    error('beSelected只能为0或1')
                end
              varaout=value;  
            else
               varaout=0;   
            end
                    
        end
        function value=get_beSelected(obj,value)   % 取得选定状态（由hthis而来）
             if ~isempty(obj.hthis)
                beSelStr=arrayfun(@(x) x.Selected,obj.hthis,'UniformOutput',0);
                value=any(strcmp(beSelStr,'on'));
            else
                value=0;
            end           
        end
        %-------------------------------------
        function ButtonDownFcn(obj,hObject,event)  % 点击相应函数（一般为变成被选中状态，并将之前选中的对象取消）
            switch get(gcf,'SelectionType')
                case 'normal'
                    if ~isempty(obj.parent) && ~isempty(obj.parent.indObjArr)
                        if obj.beSelected==1
                            obj.beSelected=0;
                        else
                            [obj.parent.indObjArr.beSelected]=deal(0);
                            obj.beSelected=1;
                        end
                        
                    end
                case 'open'
                    try
                        eval([obj.type,'.propSet(obj.parent,obj);'])
                    catch
                        disp([obj.type,'没有运行双击事件。'])
                    end
            end
        end
    end
    methods(Abstract)
        plot(obj) % plot 接口 ，子类必须实现
    end
end