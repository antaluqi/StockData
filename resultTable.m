classdef resultTable<handle
    % �б���
    properties
        parent  % ������ֻ����MainFigure�����ڸ�ֵʱ��ע��MainFigure��DataSourceChange�¼�����Ӧ����Ϊobj.update
        hthis   % �����
        hmark   % �����Ԫ��ʱ������ͼ����
        Data    % ������ݣ�ֻ����table����
    end
    properties (Access = 'protected')
        listenerDC   % MainFigure�������ݸı����
    end
    methods
        function obj=resultTable(MainFigObj) % ���캯��
            obj.parent=MainFigObj; 
            obj.hthis=uitable('parent',obj.parent.hfig,'Units','normalized','Position',[0.04 0.01 0.92 0.19],'ColumnName',{'����','����','����'});
            obj.hmark=[];
        end
        function update(obj,scr,data)        % MainFigure��DataSourceChange�¼�����Ӧ�����������������ʱɾ��ͼ�꣨��MARK���reLoad���������ظ���
            delete(obj.hmark); 
            obj.hmark=[];
        end
        %-------------------------------- set��get
        function set.parent(obj,value)       % ������ֻ����MainFigure�����ڸ�ֵʱ��ע��MainFigure��DataSourceChange�¼�����Ӧ����Ϊobj.update 
          
            validateattributes(value, {'MainFigure'}, {'scalar'});
            if ~ishandle(value.hfig)
                error('��������hfig�ѱ�ɾ��')
            end
            obj.parent=value;
            obj.listenerDC=value.addlistener('DataSourceChange',@obj.update);
        end
        function set.Data(obj,value)         % �������
            
            if ~isa(value,'table') % ֻ����table����
                error('resultTable��Data�����ʽֻ��Ϊtable')
            end
            names=value.Properties.VariableNames; % ȡ��table���ݵı�ͷ��
            if ~ismember({'Code'},names) % ��ͷ���б������Code��
                error('resultTable��Data�����б������Code�ֶ�')
            end

            obj.Data=value;
            if ismember({'Date'},names)                                        % ���ʱ����ΪDate(��һʱ����)
                tableData=value(:,['Code','Date',names(~ismember(names,{'Code','Date'}))]); % ��������
                set(obj.hthis,'CellSelectionCallback',{@obj.CellSelectionCallback1});       % ������Ӧ����
            elseif ismember({'startDay','endDay'},names)                       % ���ʱ����Ϊ{'startDay','endDay'}������ʼ�ͽ���ʱ�䣩
                tableData=value(:,['Code','startDay','endDay',names(~ismember(names,{'Code','startDay','endDay'}))]); % ��������
                set(obj.hthis,'CellSelectionCallback',{@obj.CellSelectionCallback2});                                 % ������Ӧ����
            elseif ismember({'point1','point2','price1','price2'},names)
                tableData=value(:,['Code','point1','point2',names(~ismember(names,{'Code','point1','point2','price1','price2'}))]); % ��������
                set(obj.hthis,'CellSelectionCallback',{@obj.CellSelectionCallback4});                        
            else
                tableData=value;
                set(obj.hthis,'CellSelectionCallback',{@obj.CellSelectionCallback3});   
            end
                tableNames=tableData.Properties.VariableNames; % ȡ�����ź�ı���
                obj.hthis.Data=table2cell(tableData);          % ��table��������
                obj.hthis.ColumnName=tableNames;               % ��table���ر�ͷ
            
        end
    end
    methods (Access = 'private')
        function CellSelectionCallback1(obj,hObject,event) % ��Ӧ�����룬���ڣ�����1������2��...������ʽ
            
            tableData=obj.Data; % ����
            pos=event.Indices;  % ����ĵ�Ԫ������
            if isempty(pos)     % ���Ϊ�վ��޷�Ӧ
                return;
            end
            Code=tableData.Code(pos(1));  % ȡ�õ���е�Code����
            Dates=tableData.Date(pos(1)); % ȡ�õ���е�Dates����
            if isempty(obj.parent.DataSource) || ~strcmp(obj.parent.DataSource.Code,Code) % ��������Code��DateSource��Code��һ���Ļ������DataSource
                obj.parent.DataSource=Stock(Code);
            end
            if isempty(obj.hmark) % �����Ƕ���hmarkΪ�վ��½�һ���������Ϊ�վ͸������������
              obj.hmark=MARKpoint(obj.parent);
              obj.hmark.propertie={'CandleAxes',Dates};
            else
                obj.hmark.propertie={'CandleAxes',Dates};
            end
            
            midPoint=find(obj.parent.Data.dates==datenum(Dates));
            obj.parent.axesObj.axesList(2).XLim=[midPoint-50.5,midPoint+50.5];
            
            
        end
        function CellSelectionCallback2(obj,hObject,event) % ��Ӧ�����룬��ʼ���ڣ��������ڣ�����1������2��...������ʽ
            
            tableData=obj.Data; % ����
            pos=event.Indices;  % ����ĵ�Ԫ������
            if isempty(pos)     % ���Ϊ�վ��޷�Ӧ
                return;
            end
            Code=tableData.Code(pos(1));  % ȡ�õ���е�Code����
            startDay=tableData.startDay(pos(1)); % ȡ�õ���е�startDay����
            endDay=tableData.endDay(pos(1)); % ȡ�õ���е�endDay����
            if isempty(obj.parent.DataSource) || ~strcmp(obj.parent.DataSource.Code,Code) % ��������Code��DateSource��Code��һ���Ļ������DataSource
                obj.parent.DataSource=Stock(Code);
            end
            if isempty(obj.hmark) % �����Ƕ���hmarkΪ�վ��½�һ���������Ϊ�վ͸������������
              obj.hmark=MARKcircle(obj.parent);
              obj.hmark.propertie={'CandleAxes',startDay,endDay};            
            else
                obj.hmark.propertie={'CandleAxes',startDay,endDay};
            end    
        end
        function CellSelectionCallback3(obj,hObject,event) % ��Ӧֻ��Code����ʽ
            tableData=obj.Data; % ����
            pos=event.Indices;  % ����ĵ�Ԫ������
            if isempty(pos)     % ���Ϊ�վ��޷�Ӧ
                return;
            end
            Code=tableData.Code(pos(1));  % ȡ�õ���е�Code����            
            if isempty(obj.parent.DataSource) || ~strcmp(obj.parent.DataSource.Code,Code) % ��������Code��DateSource��Code��һ���Ļ������DataSource
                obj.parent.DataSource=Stock(Code);
            end      
        end
        function CellSelectionCallback4(obj,hObject,event) % ��Ӧ2�������ʽ
            tableData=obj.Data; % ����
            pos=event.Indices;  % ����ĵ�Ԫ������
            if isempty(pos)     % ���Ϊ�վ��޷�Ӧ
                return;
            end
            Code=tableData.Code(pos(1));  % ȡ�õ���е�Code���� 
            point1X=tableData.point1(pos(1));
            point2X=tableData.point2(pos(1));
            price1Price=tableData.price1(pos(1));
            price2Price=tableData.price2(pos(1));
            if isempty(obj.parent.DataSource) || ~strcmp(obj.parent.DataSource.Code,Code) % ��������Code��DateSource��Code��һ���Ļ������DataSource
                obj.parent.DataSource=Stock(Code);
            end    
            propertie=[point1X,price1Price;point2X,price2Price];
            if isempty(obj.hmark) % �����Ƕ���hmarkΪ�վ��½�һ���������Ϊ�վ͸������������
              obj.hmark=Multipoint(obj.parent,propertie);             
            else
                obj.hmark.propertie=propertie;
            end
        end
    end
end