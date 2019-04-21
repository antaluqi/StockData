classdef BOLL<indicationBase
    % BOLL指标类，继承于indicationBase类
    %-------------------------
    % BOLL(f,[20,2]) % 20日、2倍标准差布林带
    %-------------------------
    properties
    end
    methods 
        function obj=BOLL(hMainFigure,propertie) % 构造函数
            if nargin ==0
                hMainFigure=[];
            end
            obj=obj@indicationBase(hMainFigure);
            obj.type='BOLL';
            obj.axesName='CandleAxes';
            obj.propNo=2;     % 指标个数1个
            obj.DataNo=3;     % 数据列数1列
            obj.pField={'BOllMid','BOllUp','BOllDown'};% 数据列表头名前缀
            obj.propertie=propertie; % 输入参数
        end
        function plot(obj)                       %（接口实现）画图
            delete(obj.hthis) % 首先删除之前的句柄
            if obj.show==1    % 显示开关要开
                if isempty(obj.Data) % Data为空则清空hthis
                    obj.hthis=[];
                elseif size(obj.Data,2)==obj.DataNo+1 % 符合数据个数规则则开始画图
                    haxes=findobj(obj.parent.hfig,'tag',obj.axesName); % 作用画布的句柄 
                    obj.hthis=plot(obj.Data(:,2:end),'parent',haxes);  % 画图
                else
                    error('BOLL参数Data输入有误')
                end
            end
        end
        function str=getValueStr(obj,x)          %（重载）取得指标的字符串显示（x为coordPos的X坐标）
            if isempty(x)
                str=['BOLL:'];
                return
            end
            i=max(min(round(x),size(obj.Data,1)),1);% 取值在数据范围之内
            pStr=strjoin(arrayfun(@(x) num2str(x),obj.propertie,'UniformOutput',0),','); % 参数字符化，如[15,2]变为'15_2'
            
            Color=cellfun(@(x) num2str(x),get(obj.hthis,'Color'),'UniformOutput',0);
            colorStr=cellfun(@(x) regexp(x,'[ ]+', 'split'),Color,'UniformOutput',0);
            colorStr=cellfun(@(x) strjoin(x,','),colorStr,'UniformOutput',0);
            
            str=['BOLL[',pStr,'] ( \color[rgb]{',colorStr{2},'}Up:',sprintf('%8.2f',obj.Data(i,3)),',   \color[rgb]{',colorStr{1},'}Mid:',sprintf('%8.2f',obj.Data(i,2)),',   \color[rgb]{',colorStr{3},'}Down:',sprintf('%8.2f',obj.Data(i,4)),')   '];
        end
    end
    methods (Static)
        function propSet(parent,indObj)
            if nargin==1
                indProp(parent,mfilename,{'天数','标准差'});
            elseif nargin==2
                indProp(parent,mfilename,{'天数','标准差'},indObj);
            end
            disp(['运行',mfilename,'参数设定'])
        end
    end
end