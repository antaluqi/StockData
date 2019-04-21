classdef indicationBase<handle & matlab.mixin.Heterogeneous
    % ָ�����Ļ���
    properties
        type         % ��������
        parent       % ����������DataSource������
        axesName     % ��������
        hthis        % ͼ�ζ�����(��ֵ��indArrClass��ӵ�ͼ�ξ����UseData��)
        propertie    % �����������propNo�������ƣ���ֵ�󴥷�obj.calculation��
        Data         % ���ݣ������DataNo�������ƣ���ֵ�󴥷�obj.plot��
        show         % ��ʾ���أ�����plot��
        beSelected   % �Ƿ�ѡ��
        
    end
    properties (Access = 'protected')
        propNo       % ����Ĳ�������
        DataNo       % �������������
        listenerDC   % MainFigure�������ݸı����
        pField       % Stock.Indications���������������й涨����������ǰ׺����BOllMid,MA�ȣ����滹Ҫ�Ӳ�����str����BOllUp20_2��
    end  
    methods
        %-------------------------------------
        function obj=indicationBase(hMainFigure) % ���캯��
            if nargin ==0
                hMainFigure=[];
            end
            obj.listenerDC=[];
            obj.parent=hMainFigure;
            obj.show=1;
        end
        function calculation(obj)                % �������ݣ�һ���״������õ���
            if ~isempty(obj.parent) && ~isempty(obj.parent.DataSource)
                %--------------------------------------�����Candle���ȡ���ڷ�Χ���������ڲ���Ĭ�ϣ����Կ�������CANDLE���У�
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

                tableData=S.Indicators({obj.type},{obj.propertie},{startDay,endDay}); % ����
                obj.Data=[datenum(tableData.Date),tableData{:,7:end}];% ȡ����Ӧ�ֶ�����
            else
                error('MainFigureû������Դ')
            end
            
        end
        function update(obj,scr,data)            % DataSource�¼���Ӧ����
            obj.reload;
        end
        function reload(obj)                     %�������أ����ݼ��أ���MainFigure��Data��������ָ���йصļ��ص������Data��
            try
            reLoadData=obj.parent.Data;
            catch
                disp('֪ͨ���Ѿ���ɾ���Ķ���')
                obj
                return
            end
            if ~isempty(reLoadData) 
                pStr=strjoin(arrayfun(@(x) num2str(x),obj.propertie,'UniformOutput',0),'_'); % �����ַ�������[15,2]��Ϊ'15_2'
                if strcmp(obj.type,'CANDLE') % ���ָ����Candle����ȡ����Ӧ�ֶ�����
                    % obj.Data=extfield(reLoadData,{'Open','High','Close','Low','Volume'});
                    
                     d=[reLoadData.High,reLoadData.Low,reLoadData.Close,reLoadData.Open,reLoadData.Volume]; %---------------------------------------
                     obj.Data=[d.dates,fts2mat(d)];%---------------------------------------
                else                         % ���ָ���Ƿ�Candle����ȡ����Ӧ�ֶ�����
                    d=extfield(reLoadData,strcat(obj.pField,pStr)); % ȡ������BOll15_2��MA10���ֶ����ݣ����������ݶκϲ�
                    obj.Data=[d.dates,fts2mat(d)];           
                end
            else
                obj.calculation;
            end
        end
        function str=getValueStr(obj,x)          %�������أ�ȡ��ָ����ַ�����ʾ��xΪcoordPos��X���꣩
            str=[];
        end 
        function delete(obj)                     % ɾ��ָ�꣨����hthis��listenerDC��
            delete(obj.listenerDC)
            delete(obj.hthis)
            disp([obj.type,'��ɾ��'])
        end

        %-------------------------------------
        % set��get����ʵ�嶼��methods(Access= 'protected')�У���Ȼ�����޷�����
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
    methods(Access = 'protected') % ��set��get������ʵ�壬��������������أ����������������У�
        function set_parent(obj,value)             % ���ø��࣬���ؼ�������������뵽parent.indObjArr������
            if ~isempty(value)
                validateattributes(value, {'MainFigure'}, {'scalar'});
                if isempty(obj.listenerDC)
                    obj.listenerDC=value.addlistener('DataSourceChange',@obj.update);
                end
               value.indObjArr=[value.indObjArr,obj];%=============================
            end
        end
        function set_propertie(obj,value)          % ���ò���������Ҫ�������calculation�����Ϊ����ɾ����ǰhthis
            if ~isempty(value)
                if  ~ismember(length(value),obj.propNo)
                    error([obj.type,'�������propertie����'])
                end
                obj.calculation;
            else
                delete(obj.hthis)
            end
        end
        function set_Data(obj,value)               % �������ݣ�һ����calculation�������������plot
            obj.plot            
        end  
        function set_show(obj,value)               % ������ʾ����
            switch value
                case 0
                    delete(obj.hthis)
                case 1
                    obj.plot
                otherwise
                    error([obj.type,'��show����ֻ������0��1'])
            end      
        
        end
        function set_hthis(obj,value)              % ����ָ��ͼ���������õ���¼��ص�������һ�����ڼ��ѡ�����
            set(value,'ButtonDownFcn',{@obj.ButtonDownFcn});
        end
        function varaout=set_beSelected(obj,value) % ����ѡ��״̬
            if ~isempty(obj.hthis) && ~strcmp(obj.type,'CANDLE') && ~strcmp(obj.type,'MARK')
                if value==0
                    arrayfun(@(x) set(x,'Selected','off'),obj.hthis,'UniformOutput',0);
                elseif value==1
                    arrayfun(@(x) set(x,'Selected','on'),obj.hthis,'UniformOutput',0);
                else
                    error('beSelectedֻ��Ϊ0��1')
                end
              varaout=value;  
            else
               varaout=0;   
            end
                    
        end
        function value=get_beSelected(obj,value)   % ȡ��ѡ��״̬����hthis������
             if ~isempty(obj.hthis)
                beSelStr=arrayfun(@(x) x.Selected,obj.hthis,'UniformOutput',0);
                value=any(strcmp(beSelStr,'on'));
            else
                value=0;
            end           
        end
        %-------------------------------------
        function ButtonDownFcn(obj,hObject,event)  % �����Ӧ������һ��Ϊ��ɱ�ѡ��״̬������֮ǰѡ�еĶ���ȡ����
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
                        disp([obj.type,'û������˫���¼���'])
                    end
            end
        end
    end
    methods(Abstract)
        plot(obj) % plot �ӿ� ���������ʵ��
    end
end