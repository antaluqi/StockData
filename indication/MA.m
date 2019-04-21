classdef MA<indicationBase
    % MA指标类，继承于indicationBase类
    %-------------------------
    % MA(f,20) % 20日均线
    %-------------------------
    properties
    end
    methods 
        function obj=MA(hMainFigure,propertie) % 构造函数
            if nargin ==0
                hMainFigure=[];
            end
            obj=obj@indicationBase(hMainFigure);
            obj.type='MA';
            obj.axesName='CandleAxes';
            obj.propNo=1;     % 指标个数1个
            obj.DataNo=1;     % 数据列数1列
            obj.pField={'MA'};% 数据列表头名前缀
            obj.propertie=propertie; % 加载参数
        end
        function plot(obj) %（接口实现）画图
            delete(obj.hthis) % 首先删除之前的句柄
            if obj.show==1    % 显示开关要开
                if isempty(obj.Data) % Data为空则清空hthis
                    obj.hthis=[];
                elseif size(obj.Data,2)==obj.DataNo+1  % 符合数据个数规则则开始画图
                    haxes=findobj(obj.parent.hfig,'tag',obj.axesName);  % 作用画布的句柄 
                    obj.hthis=plot(obj.Data(:,2),'parent',haxes);       % 画图
                else
                    error('MA参数Data输入有误')
                end
            end
        end
        function str=getValueStr(obj,x)        %（重载）取得指标的字符串显示（x为coordPos的X坐标）
            if isempty(x)
                str=['MA:'];
                return
            end
            i=max(min(round(x),size(obj.Data,1)),1); % 取值在数据范围之内
            pStr=strjoin(arrayfun(@(x) num2str(x),obj.propertie,'UniformOutput',0),'_'); % 参数字符化，如[15,2]变为'15_2'            
            str=['MA[',pStr,']:',sprintf('%8.2f',obj.Data(i,2)),32];
            rgbColor=obj.hthis.Color;
            rgbColorStr=strjoin(cellfun(@(x) num2str(x),num2cell(rgbColor),'UniformOutput',0),',');
            str=['\color[rgb]{',rgbColorStr,'}',str];
        end
    end
    methods(Access = 'protected')
    end
    methods (Static)
        function propSet(parent,indObj)
            if nargin==1
                indProp(parent,mfilename,{'天数'});
            elseif nargin==2
                indProp(parent,mfilename,{'天数'},indObj);
            end
            disp(['运行',mfilename,'参数设定'])
        end
    end
end