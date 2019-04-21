classdef Multipoint<customizaBass
    properties
        propertie % ����
        thisAxes
    end
    methods
        function obj=Multipoint(hMainFigure,propertie,thisAxes) % ���캯��
            if nargin ==0
                hMainFigure=[];
            end
            obj=obj@customizaBass(hMainFigure); % ���ø��๹�캯��
            obj.type='Multipoint';               % ����   
            if nargin < 2   
                propertie=[];
            end   
            if nargin < 3
                axesName='CandleAxes';
            end
            if nargin == 3
                axesName=thisAxes;
            end  
            if ishandle(axesName)
                obj.thisAxes=axesName;
            elseif ischar(axesName)
                obj.thisAxes=findobj(obj.parent.hfig,'tag',axesName);
            else
                obj.thisAxes=[];
            end            
            
            obj.propertie=propertie;

        end
        function calculation(obj)            %�����أ�����
            if isempty(obj.thisAxes)
               error('Multipoint��haxesΪ��')
            end
            if size(obj.propertie,2)~=2
               error('Multipoint��propertie����������')
            end
            if isempty(obj.parent.Data)
                error('MainFigure��DataΪ��')
            end
            obj.Data=obj.propertie;
         end   
        function plot(obj)
            delete(obj.hthis)     % ɾ��֮ǰ���ܴ��ڵľ��
            obj.hthis=[];
            if isempty(obj.Data) || isempty(obj.thisAxes)  % ���ݲ���Ϊ��
                return;
            end
                x=obj.Data(:,1);
                y=obj.Data(:,2);
                obj.hthis=plot(x,y,'o','parent',obj.thisAxes);
            
        end
        function set.propertie(obj,value)    %  ����������ڸ������ӵĲ�����
            obj.propertie=value;
            set_propertie(obj,value);
        end
    end
    methods(Access = 'protected')
        function set_hthis(obj,value)             %�����أ����þ��������ϲ��ð󶨵����Ӧ������ 
        end       
        function set_propertie(obj,value)         % ���ò���������calculation����
            obj.calculation;
        end 
        function value=get_beSelected(obj)        % (����) ���ܱ�ѡ��
            value=0;
        end     
        function set_beDestroied(obj,value)       %�����أ������Ƿ����٣���������resultTable��ע��hmark��
            if value==1
                try
                    obj.parent.customizeObjArr([obj.parent.customizeObjArr.beDestroied]==1)=[];
                catch
                    disp('set_beDestroied��ɾ��customizeObjArr�еĶ���ʱ�д�����')
                end
                try
                    obj.parent.hResultTable.hmark=[];
                catch
                    disp('set_beDestroied��ɾ��customizeObjArr�еĶ���ʱ�д�����')
                end                
            end
        end  
    end
    methods (Static)
        function propSet(parent)
            disp(['����',mfilename,'�����趨'])
        end        
    end
end