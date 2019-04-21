classdef customizaBass<handle & matlab.mixin.Heterogeneous
    % �Զ��������
    properties
        type          % ��������
        parent        % ���࣬MainFigure����
        Data          % ���ݣ�Ĭ��containers.Map��ʽ��
        hthis         % ͼ�ξ��
        step          % ��ǰ��������
        motionSwitch  % ��������ƶ���Ӧ��������
        buttonSwitch  % �����������Ӧ��������
        beSelected    % �Ƿ�ѡ��
        beDestroied   % �Ƿ����٣���Ҫ������MainFigure��ע����
        textInfo      % ��ʾtext����
        coordTemp     % ��������洢������������ת������ػ棩
    end
    properties (Access = 'protected')
        listenerWBM   % ��������ƶ�����
        listenerWBD   % �������������
        listenerLC    % ��������ı����
        listenerDC    % MainFigure����Data�ı����
        pixelPos      % ��������
        coordPos      % ��������
        normPos       % ��һ������
        haxes         % ���õĻ���
        stepEnd       % �������������
        haxesFinal    % �������õĻ���
        
    end
    methods
        %--------------------------------------
        function obj=customizaBass(hMainFigure) % �������
            if nargin ==0
                hMainFigure=[];
            end
            obj.parent=hMainFigure;   % ��ֵ����
            obj.Data=containers.Map;  % ��ʼ������
            obj.motionSwitch=0;       % Ĭ�ϴ�������ƶ���Ӧ�ر�
            obj.buttonSwitch=0;       % Ĭ�ϴ����������Ӧ�ر�
            obj.beSelected=0;         % ѡ��״̬Ϊδѡ��
            obj.beDestroied=0;        % ������״̬Ϊδ����
        end
        function calculation(obj)               % ���㣨�����������أ�
           obj.Data=[];
        end
        function plot(obj)                      % ��ͼ�������������أ� 
            if  ~isempty(obj.pixelPos)
                disp(['pixelPos�� x=',num2str(obj.pixelPos(1)),',y=',num2str(obj.pixelPos(2))])
            end
            if  ~isempty(obj.coordPos)
                disp(['coordPos�� x=',datestr(obj.coordPos(1)),',y=',num2str(obj.coordPos(2))])
            end
            if  ~isempty(obj.normPos)
                disp(['normPos�� x=',num2str(obj.normPos(1)),',y=',num2str(obj.normPos(2))])
            end            
            if  ~isempty(obj.haxes)
                disp(['haxes��=',obj.haxes.Tag])
            end
        end
        function delete(obj)                    % ɾ��ָ�꣨���������������MainFigure�е�ע�ᣩ
            delete(obj.listenerWBM);
            delete(obj.listenerWBD);
            delete(obj.listenerLC);
            delete(obj.hthis);
            obj.beDestroied=1;
        end
        %------------------------------------set��get����protected��ʵ�֣��������أ�
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
        %------------------------------------set��get
        function set_parent(obj,value)       % ���ø��࣬ע�ᵽMainFigure��customizeObjArr�У���������¼��ļ���״̬��������������ļ���
                obj.motionSwitch=obj.motionSwitch;
                obj.buttonSwitch=obj.buttonSwitch;
                if ~isempty(value)
                    value.customizeObjArr=[value.customizeObjArr,obj];
                    obj.listenerLC=addlistener(value,'limChange',@obj.replot);
                    obj.listenerDC=addlistener(value,'DataSourceChange',@obj.reload);
                end
        end
        function set_Data(obj,value)         % �������ݣ�����plot
            if ~isempty(value)
                obj.plot;
            end
        end        
        function set_hthis(obj,value)        % ���þ�������ص����Ӧ��������Ҫ��Ӧ���ѡ�У�
            if ~isempty(value) && all(ishandle(value))
                set(value,'ButtonDownFcn',{@obj.ButtonDownFcn});
            end
        end
        function set_motionSwitch(obj,value) % ���ô�������ƶ���Ӧ���أ����ü�����
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
        function set_buttonSwitch(obj,value) % ���ô����������Ӧ���أ����ü�����
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
        function set_beSelected(obj,value)   % �����Ƿ�ѡ�� 
            if ~isempty(obj.hthis)  && ~strcmp(obj.type,'MARK')
                if value==0
                    set(obj.hthis,'Selected','off');
                elseif value==1
                    set(obj.hthis,'Selected','on')
                else
                    error('beSelectedֻ��Ϊ0��1')
                end
            end            
        end
        function set_step(obj,value)         % ���ò������裬���������Ӧ�¼������Ƽ���
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
        function set_beDestroied(obj,value)  % �����Ƿ����٣���Ҫ������MainFigure��ע����
            if value==1
                try
                    obj.parent.customizeObjArr([obj.parent.customizeObjArr.beDestroied]==1)=[];
                catch
                    disp('set_beDestroied��ɾ��customizeObjArr�еĶ���ʱ�д�����')
                end
            end
        end
        function value=get_pixelPos(obj)     % ȡ�õ�ǰ����������� 
            if isempty(obj.parent)
                value=[];
                return
            end
            value=get(obj.parent.hfig,'currentpoint');
        end
        function value=get_coordPos(obj)     % ȡ�õ�ǰ��껭������
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
        function value=get_normPos(obj)      % ȡ�õ�ǰ����һ������
            if isempty(obj.parent)
                value=[];
                return
            end   
            value=obj.parent.pixel2norm(obj.pixelPos);
        end
        function value=get_haxes(obj)        % ȡ�õ�ǰ����»���
            if isempty(obj.parent)
                value=[];
                return
            end
            value=obj.parent.pixel2axes(obj.pixelPos);
        end
        %------------------------------------
        function storeCoord(obj)             % �������أ�����ͼ�εĻ������꣨���ڻ�������ı����ػ棩
        end
        function replot(obj,scr,data)        % �������أ���������ı���ػ�
        end
        function reload(obj,scr,data)        %  MainFigure��Data���ݸı��Ĳ�����һ��Ϊɾ��
            delete(obj)
        end
        function Wmotion(obj,scr,data)       %  ��������ƶ���Ӧ���򣨼���calculation��
            %---------------------------
            obj.calculation;
            %---------------------------
        end
        function WDown(obj,scr,data)         %  �����������Ӧ����һ��Ϊ�ı�step+1��
            switch   get(gcbf,'SelectionType')
                case 'normal'
                    if  obj.step+1<=obj.stepEnd
                        obj.step=obj.step+1;
                    end             
            end
        end
        function ButtonDownFcn(obj,hObject,event)% �����Ӧ����������ı�ѡ��״̬���Ҽ�Ϊ�ı�step-1��
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