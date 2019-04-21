classdef resultTable<handle
    % 列表类
    properties
        parent  % 父级，只接受MainFigure，并在赋值时候注册MainFigure的DataSourceChange事件，相应函数为obj.update
        hthis   % 表格句柄
        hmark   % 点击单元格时产生的图标句柄
        Data    % 表格数据，只接受table类型
    end
    properties (Access = 'protected')
        listenerDC   % MainFigure对象数据改变监听
    end
    methods
        function obj=resultTable(MainFigObj) % 构造函数
            obj.parent=MainFigObj; 
            obj.hthis=uitable('parent',obj.parent.hfig,'Units','normalized','Position',[0.04 0.01 0.92 0.19],'ColumnName',{'代码','日期','参数'});
            obj.hmark=[];
        end
        function update(obj,scr,data)        % MainFigure类DataSourceChange事件的相应函数，在主界面更新时删除图标（在MARK类的reLoad方法中有重复）
            delete(obj.hmark); 
            obj.hmark=[];
        end
        %-------------------------------- set和get
        function set.parent(obj,value)       % 父级，只接受MainFigure，并在赋值时候注册MainFigure的DataSourceChange事件，相应函数为obj.update 
          
            validateattributes(value, {'MainFigure'}, {'scalar'});
            if ~ishandle(value.hfig)
                error('主画面句柄hfig已被删除')
            end
            obj.parent=value;
            obj.listenerDC=value.addlistener('DataSourceChange',@obj.update);
        end
        function set.Data(obj,value)         % 表格数据
            
            if ~isa(value,'table') % 只接受table类型
                error('resultTable的Data输入格式只能为table')
            end
            names=value.Properties.VariableNames; % 取得table数据的表头名
            if ~ismember({'Code'},names) % 表头名中必须包含Code列
                error('resultTable的Data数据中必须包含Code字段')
            end

            obj.Data=value;
            if ismember({'Date'},names)                                        % 如果时间列为Date(单一时间列)
                tableData=value(:,['Code','Date',names(~ismember(names,{'Code','Date'}))]); % 数据重排
                set(obj.hthis,'CellSelectionCallback',{@obj.CellSelectionCallback1});       % 设置响应函数
            elseif ismember({'startDay','endDay'},names)                       % 如果时间列为{'startDay','endDay'}（有起始和结束时间）
                tableData=value(:,['Code','startDay','endDay',names(~ismember(names,{'Code','startDay','endDay'}))]); % 数据重排
                set(obj.hthis,'CellSelectionCallback',{@obj.CellSelectionCallback2});                                 % 设置响应函数
            elseif ismember({'point1','point2','price1','price2'},names)
                tableData=value(:,['Code','point1','point2',names(~ismember(names,{'Code','point1','point2','price1','price2'}))]); % 数据重排
                set(obj.hthis,'CellSelectionCallback',{@obj.CellSelectionCallback4});                        
            else
                tableData=value;
                set(obj.hthis,'CellSelectionCallback',{@obj.CellSelectionCallback3});   
            end
                tableNames=tableData.Properties.VariableNames; % 取得重排后的表名
                obj.hthis.Data=table2cell(tableData);          % 给table加载数据
                obj.hthis.ColumnName=tableNames;               % 给table加载表头
            
        end
    end
    methods (Access = 'private')
        function CellSelectionCallback1(obj,hObject,event) % 对应【代码，日期，参数1，参数2，...】的形式
            
            tableData=obj.Data; % 数据
            pos=event.Indices;  % 点击的单元格坐标
            if isempty(pos)     % 如果为空就无反应
                return;
            end
            Code=tableData.Code(pos(1));  % 取得点击行的Code数据
            Dates=tableData.Date(pos(1)); % 取得点击行的Dates数据
            if isempty(obj.parent.DataSource) || ~strcmp(obj.parent.DataSource.Code,Code) % 如果点击的Code和DateSource的Code不一样的话则更换DataSource
                obj.parent.DataSource=Stock(Code);
            end
            if isempty(obj.hmark) % 如果标记对象hmark为空就新建一个，如果不为空就更改其坐标参数
              obj.hmark=MARKpoint(obj.parent);
              obj.hmark.propertie={'CandleAxes',Dates};
            else
                obj.hmark.propertie={'CandleAxes',Dates};
            end
            
            midPoint=find(obj.parent.Data.dates==datenum(Dates));
            obj.parent.axesObj.axesList(2).XLim=[midPoint-50.5,midPoint+50.5];
            
            
        end
        function CellSelectionCallback2(obj,hObject,event) % 对应【代码，开始日期，结束日期，参数1，参数2，...】的形式
            
            tableData=obj.Data; % 数据
            pos=event.Indices;  % 点击的单元格坐标
            if isempty(pos)     % 如果为空就无反应
                return;
            end
            Code=tableData.Code(pos(1));  % 取得点击行的Code数据
            startDay=tableData.startDay(pos(1)); % 取得点击行的startDay数据
            endDay=tableData.endDay(pos(1)); % 取得点击行的endDay数据
            if isempty(obj.parent.DataSource) || ~strcmp(obj.parent.DataSource.Code,Code) % 如果点击的Code和DateSource的Code不一样的话则更换DataSource
                obj.parent.DataSource=Stock(Code);
            end
            if isempty(obj.hmark) % 如果标记对象hmark为空就新建一个，如果不为空就更改其坐标参数
              obj.hmark=MARKcircle(obj.parent);
              obj.hmark.propertie={'CandleAxes',startDay,endDay};            
            else
                obj.hmark.propertie={'CandleAxes',startDay,endDay};
            end    
        end
        function CellSelectionCallback3(obj,hObject,event) % 对应只有Code的形式
            tableData=obj.Data; % 数据
            pos=event.Indices;  % 点击的单元格坐标
            if isempty(pos)     % 如果为空就无反应
                return;
            end
            Code=tableData.Code(pos(1));  % 取得点击行的Code数据            
            if isempty(obj.parent.DataSource) || ~strcmp(obj.parent.DataSource.Code,Code) % 如果点击的Code和DateSource的Code不一样的话则更换DataSource
                obj.parent.DataSource=Stock(Code);
            end      
        end
        function CellSelectionCallback4(obj,hObject,event) % 对应2个点的形式
            tableData=obj.Data; % 数据
            pos=event.Indices;  % 点击的单元格坐标
            if isempty(pos)     % 如果为空就无反应
                return;
            end
            Code=tableData.Code(pos(1));  % 取得点击行的Code数据 
            point1X=tableData.point1(pos(1));
            point2X=tableData.point2(pos(1));
            price1Price=tableData.price1(pos(1));
            price2Price=tableData.price2(pos(1));
            if isempty(obj.parent.DataSource) || ~strcmp(obj.parent.DataSource.Code,Code) % 如果点击的Code和DateSource的Code不一样的话则更换DataSource
                obj.parent.DataSource=Stock(Code);
            end    
            propertie=[point1X,price1Price;point2X,price2Price];
            if isempty(obj.hmark) % 如果标记对象hmark为空就新建一个，如果不为空就更改其坐标参数
              obj.hmark=Multipoint(obj.parent,propertie);             
            else
                obj.hmark.propertie=propertie;
            end
        end
    end
end