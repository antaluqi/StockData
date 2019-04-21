classdef indProp<handle
    properties
        indName
        propName
        hfig
        indObj
        parent
        hPropTitle
        hEdit
        hBottomOK
        hBottomCancle
    end
    events
    end
    methods
        function obj=indProp(hMainFigure,indName,propName,hindObj)
            
            obj.parent=hMainFigure;
            indNameList=Comm.indFileName;
            if ischar(indName) && ismember(indName,indNameList)
                obj.indName=indName;
            else
                error('indName��������û�����ָ��')
            end
            if isempty(propName)
                obj.propName=[];
            elseif ~isempty(propName) && all(cellfun(@(x) ischar(x),propName))
                obj.propName=propName;
            else
                error('propName�������')
            end
            obj.Initialization     % �����ʼ��
            set(obj.hBottomOK,'Callback',{@obj.OKButtonDownFcn})
            set(obj.hBottomCancle,'Callback',{@obj.CancleButtonDownFcn})
            set(obj.hfig,'WindowKeyPressFcn',{@obj.WindowKeyPressFcn})
            if nargin==4
                obj.indObj=hindObj;
            end
            uicontrol(obj.hEdit(1));
        end
        function set.indObj(obj,value)
            if ~isempty(value) && ~isa(value,obj.indName)
                error([obj.indName,'���indProp��indObj���������Ϊ',obj.indName,'�Ķ���'])
            end
            obj.indObj=value;
            if ~isempty(value.propertie)
                for i=1:length(value.propertie)
                    hEditObj=handle(obj.hEdit(i));
                    hEditObj.String=value.propertie(i);
                end
            end
        end
        function delete(obj)
            delete(obj.hfig)
            disp('indProp��ɾ��')
        end
    end
    methods (Access = 'private')
        function Initialization(obj)
            if ~isempty(obj.propName)
                MFPos=obj.parent.hfig.Position; % ������λ��
                wight=MFPos(3)*0.4;
                high=MFPos(4)*0.4;
                X=MFPos(1)+MFPos(3)*0.3;
                Y=MFPos(2)+MFPos(4)*0.3;
                FigureSize=[X,Y,wight,high];
                obj.hfig=figure('Position',FigureSize,'MenuBar','none','ToolBar','none'); % �����հ�Figure����
                Title= uicontrol('Style','text','parent',obj.hfig,'Units','normal','position',[0.3,0.85,0.4,0.1],'string',['������',obj.indName,'ָ�����'],'fontsize',12,'FontWeight','bold');% ����
                obj.hBottomOK=uicontrol('Style','pushbutton','parent',obj.hfig,'Units','normal','position',[0.2,0.15,0.2,0.1],'String','ȷ��');
                obj.hBottomCancle=uicontrol('Style','pushbutton','parent',obj.hfig,'Units','normal','position',[0.6,0.15,0.2,0.1],'String','ȡ��');
                
                startY=Title.Position(2);
                dotY=(Title.Position(2)-obj.hBottomOK.Position(2)-obj.hBottomOK.Position(4))/(length(obj.propName)*2+1);
                for i=1:length(obj.propName)
                    Y=startY-dotY*(i*2);
                    obj.hPropTitle(i)=uicontrol('Style','text','parent',obj.hfig,'Units','normal','position',[0.1,Y,0.2,min(dotY,0.1)],'string',[obj.propName{i},':'],'fontsize',12,'FontWeight','bold');
                    obj.hEdit(i)=uicontrol('Style','edit','parent',obj.hfig,'Units','normal','position',[0.4,Y,0.4,min(dotY,0.1)]);
                end
            end
        end
        function OKButtonDownFcn(obj,hObject,event)
            hEditObj=handle(obj.hEdit); 
            propValue=str2double({hEditObj.String});
            if ~isempty(propValue) && length(propValue)==length(obj.propName) && all(~isnan(propValue))
                set(obj.hPropTitle,'ForegroundColor','black');  
                if isempty(obj.indObj)
                    obj.indObj=eval([obj.indName,'(obj.parent,[',strjoin(arrayfun(@(x) num2str(x),propValue,'UniformOutput',0),','),'])']);
                else
                    obj.indObj.propertie=propValue;
                end
                disp(['����',obj.indName])
                delete(obj)
            else
                set(obj.hPropTitle(~isnan(propValue)),'ForegroundColor','black');
                set(obj.hPropTitle(isnan(propValue)),'ForegroundColor','r');
            end            
        end
        function CancleButtonDownFcn(obj,hObject,event)
            delete(obj)
        end
        function WindowKeyPressFcn(obj,hObject,event)
            switch get(obj.hfig,'CurrentKey')
                case 'return'
                    uicontrol(obj.hBottomOK)
                    obj.OKButtonDownFcn
            end
        end
    end
end