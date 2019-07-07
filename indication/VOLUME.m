classdef VOLUME<indicationBase
    % VOLUME指标类，继承于indicationBase类
    %-------------------------
    % VOLUME(f,1)
    %-------------------------
    properties      
    end
    methods
        function obj=VOLUME(hMainFigure,propertie) % 构造函数
            if nargin ==0
                hMainFigure=[];
            end
            obj=obj@indicationBase(hMainFigure);
            obj.type='VOLUME';
            obj.axesName='IndicatorsAxes1';
            obj.propNo=1;            % 指标个数1个
            obj.DataNo=2;            % 数据列数1列
            obj.pField={'Volume'};   % 数据列表头名前缀
            obj.propertie=propertie; % 输入参数
        end
        function calculation(obj)                  %（重载）计算数据（一般首次运行用到，Volume有别于通用calculation函数）
            if ~isempty(obj.parent) && ~isempty(obj.parent.DataSource) % 需要MainFigure中的DataSource存在
                % 找出Candle指标对象句柄
                if ~isempty(obj.parent) && isa(obj.parent,'MainFigure') && ~isempty(obj.parent.indObjArr)
                   candleObj=obj.parent.indObjArr(strcmp({obj.parent.indObjArr.type},'CANDLE')); 
                else
                    candleObj=[];
                end
                % 计算的到原始Volume数据，并通过Candle指标对象确定涨跌信息
                if ~isempty(candleObj) && ~isempty(candleObj.Data)
                    iUp=candleObj.Data(:,5)<=candleObj.Data(:,4);
                    iDown=~iUp;
                    VolumeData=candleObj.Data(:,[1,6]);
                else
                    S=obj.parent.DataSource;
                    tableData=S.HistoryDaily(today-720,today); % 计算
                    iUp=tableData.Open<=tableData.Close;
                    iDown=~iUp;                   
                    VolumeData=[datenum(tableData.Date),tableData.Volume];% 取出相应字段数据
                end
                % 处理后的Volume数据，分为时间、涨、跌三列信息
                obj.Data=[VolumeData(:,1),VolumeData(:,2).*iUp,VolumeData(:,2).*iDown];
            else
                error('MainFigure没有数据源')
            end
        end
        function plot(obj)                         %（接口实现）画图
            delete(obj.hthis) % 首先删除之前的句柄
            if obj.show==1      % 显示开关要开
                if isempty(obj.Data) % Data为空则清空hthis
                    obj.hthis=[];
                elseif size(obj.Data,2)==obj.DataNo+1 % 符合数据个数规则则开始画图
                    haxes=findobj(obj.parent.hfig,'tag',obj.axesName);      %作用画布的句柄 
                    up=bar(obj.Data(:,2),'parent',haxes,'facecolor','r');   % 画红柱
                    down=bar(obj.Data(:,3),'parent',haxes,'facecolor','g'); % 画绿柱
                    obj.hthis=[up,down];
                else
                    error('BOLL参数Data输入有误')
                end
            end
        end
        function reload(obj)                       % MainFigur的Data改变响应程序 
            reLoadData=obj.parent.Data; % 取得MainFigur的Data数据(fts格式)
            if ~isempty(reLoadData)     % 如果MainFigur的Data数据不为空则取出本指标字段并赋值obj.Data触发重绘
                iUp=fts2mat(reLoadData.Open)<=fts2mat(reLoadData.Close);
                iDown=~iUp;
                VolumeData=fts2mat(extfield(reLoadData,strcat(obj.pField))); % 取得类似BOll15_2、MA10等字段数据，和日期数据段合并
                obj.Data=[reLoadData.dates,VolumeData.*iUp,VolumeData.*iDown];
            else                        % 如果MainFigur的Data数据为空则调用自身计算 
                obj.calculation;
            end

        end
        function str=getValueStr(obj,x)            %（重载）取得指标的字符串显示（x为coordPos的X坐标）
            if isempty(x)
                str='Volume:';
                return
            end
            i=max(min(round(x),size(obj.Data,1)),1);% 取值在数据范围之内
            str=['Volume: ',sprintf('%8.0f',obj.Data(i,2)+obj.Data(i,3)),'   '];
        end
    end
    methods(Access = 'protected')
    end
    methods (Static)
        function propSet(parent)
            eval([mfilename,'(parent)']);
            disp(['运行',mfilename,'参数设定'])
        end
    end    
end