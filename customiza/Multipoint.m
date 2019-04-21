classdef Multipoint<customizaBass
    properties
        propertie % 参数
        thisAxes
    end
    methods
        function obj=Multipoint(hMainFigure,propertie,thisAxes) % 构造函数
            if nargin ==0
                hMainFigure=[];
            end
            obj=obj@customizaBass(hMainFigure); % 调用父类构造函数
            obj.type='Multipoint';               % 名称   
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
        function calculation(obj)            %（重载）计算
            if isempty(obj.thisAxes)
               error('Multipoint的haxes为空')
            end
            if size(obj.propertie,2)~=2
               error('Multipoint的propertie必须有两列')
            end
            if isempty(obj.parent.Data)
                error('MainFigure的Data为空')
            end
            obj.Data=obj.propertie;
         end   
        function plot(obj)
            delete(obj.hthis)     % 删除之前可能存在的句柄
            obj.hthis=[];
            if isempty(obj.Data) || isempty(obj.thisAxes)  % 数据不能为空
                return;
            end
                x=obj.Data(:,1);
                y=obj.Data(:,2);
                obj.hthis=plot(x,y,'o','parent',obj.thisAxes);
            
        end
        function set.propertie(obj,value)    %  参数（相对于父类增加的参数）
            obj.propertie=value;
            set_propertie(obj,value);
        end
    end
    methods(Access = 'protected')
        function set_hthis(obj,value)             %（重载）设置句柄（句柄上不用绑定点击响应函数） 
        end       
        function set_propertie(obj,value)         % 设置参数，激活calculation计算
            obj.calculation;
        end 
        function value=get_beSelected(obj)        % (重载) 不能被选中
            value=0;
        end     
        function set_beDestroied(obj,value)       %（重载）设置是否被销毁（增加了在resultTable中注销hmark）
            if value==1
                try
                    obj.parent.customizeObjArr([obj.parent.customizeObjArr.beDestroied]==1)=[];
                catch
                    disp('set_beDestroied在删除customizeObjArr中的对象时有错误发生')
                end
                try
                    obj.parent.hResultTable.hmark=[];
                catch
                    disp('set_beDestroied在删除customizeObjArr中的对象时有错误发生')
                end                
            end
        end  
    end
    methods (Static)
        function propSet(parent)
            disp(['运行',mfilename,'参数设定'])
        end        
    end
end