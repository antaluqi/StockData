classdef MainFigure < handle
% 主界面类
    properties
        hfig            % 当前Figure界面句柄
        axesObj         % 管理axes的对象
        hResultTable    % 表格句柄
        hCodeList       % 代码精灵页面句柄
        hTagText        % 标题
        Data;           % 数据
        DataSource      % 数据源
        indObjArr       % 指标对象数组
        customizeObjArr % 自定义对象数组
        CrossLineSwitch % 十字光标开关（0 or 1）
    end
 
   
    events
        DataSourceChange   % 主画面“Data”属性变化事件
        WindowButtonMotion % 鼠标移动事件
        WindowButtonDown   % 鼠标点击事件
        limChange          % 坐标轴改变事件
    end
    methods
        function obj=MainFigure % 构造函数
            %--------------------------路径设置
            addpath([cd,'\indication']);
            addpath([cd,'\customiza']);
            addpath([cd,'\stock']);
            %--------------------------
            obj.Initialization     % 界面初始化
            obj.loadData;          % 加载数据（临时）
            %-------------------------加载回调程序
            obj.CrossLineSwitch=0;
            set(obj.hfig,'WindowButtonMotionFcn',{@obj.WindowButtonMotionFcn}) % 窗口鼠标移动回调
            set(obj.hfig,'WindowButtonDownFcn',{@obj.WindowButtonDownFcn})     % 窗口鼠标点击回调
            set(obj.hfig,'WindowKeyPressFcn',{@obj.WindowKeyPressFcn});        % 窗口按键响应程序
            set(obj.hfig,'DeleteFcn',{@obj.WindowDeleteFcn});        % 窗口关闭响应程序
            %-------------------------
        end 
        function loadData(obj)  % 加载数据（为了方便）
              CANDLE(obj,[1000,100]);        %K线图对象
              obj.DataSource=Stock('sh000001'); % 加载数据源
              VOLUME(obj,1);                % 成交量对象
              %--------------------------------------table数据，两个日期
%               Code=obj.DataSource.Code;
%               ftsData=obj.Data;
%               names=fieldnames(ftsData);
%               tD=[cellstr(datestr(ftsData.dates(end-13:end-3))),cellstr(datestr(ftsData.dates(end-10:end))),num2cell(fts2mat(ftsData(end-13:end-3)))];
%               tableData=cell2table([cellstr(repmat(Code,[size(tD,1),1])),tD],'VariableNames',{'Code','startDay','endDay',names{4:end}});
%               obj.hResultTable.Data=tableData;
              %--------------------------------------table数据，单个日期
              Code=obj.DataSource.Code;
              ftsData=obj.Data;
              names=fieldnames(ftsData);
              tD=[cellstr(datestr(ftsData.dates(end-10:end))),num2cell(fts2mat(ftsData(end-13:end-3)))];
              %tableData=cell2table([cellstr(repmat(Code,[size(tD,1),1])),tD],'VariableNames',{'Code','Date',names{4:end}});
              try
                   tableData=readtable('C:\Users\17197\Desktop\Daniel\python\DataStorage\boll_test.xls');
                   tableData.Date=cellstr(datestr(tableData.Date,'yyyy-mm-dd'));
                  obj.hResultTable.Data=tableData;    
              catch
                  disp('没有table数据加载')
              end
              %--------------------------------------
        end
        function update(obj)    % 更新函数（作用于DataSource改变之后，非事件相应函数）
          % DataSource改变之后重新计算数据并将之存储于obj.Data中
           if ~isempty(obj.indObjArr) % obj.indObjArr必须不为空
               indName={obj.indObjArr.type}; % 指标对象的名称列表
               indCandle=obj.indObjArr(ismember(indName,'CANDLE')); % 寻找存储Candle的indObjArr
               if ~isempty(indCandle) % 如果之前有Candle，则日期参数和之前保持一致，否则日期参数为默认
                   startDay=today-indCandle.propertie(1);
                   endDay=today;
               else
                   startDay=today-720;
                   endDay=today;
               end
               indNoCandle=obj.indObjArr(~ismember(indName,{'CANDLE','VOLUME'})); % 寻找非Candle的indObjArr
               if ~isempty(indNoCandle) % 如果有非Candle的指标，则通过Stock类的Indicators方法同一计算各个指标的数据
                   indNameNoCandle={indNoCandle.type}; 
                   indPropertie={indNoCandle.propertie};
                   obj.Data=Comm.table2fts(obj.DataSource.Indicators(indNameNoCandle,indPropertie,{startDay,endDay}));
               else                    % 如果没有非Candle的指标，则只计算Candle数据
                   obj.Data=Comm.table2fts(obj.DataSource.HistoryDaily(startDay,endDay));
               end
           end
        end
        function delete(obj)
            delete(obj.axesObj)
            delete(obj.hResultTable)
            delete(obj.hCodeList.hfig)
            delete(obj.indObjArr)
            delete(obj.customizeObjArr)
        end
        %--------------------------------  set和get
        function set.hfig(obj,value)
            validateattributes(value, {'matlab.ui.Figure'}, {'scalar'}); % 只接受figure类型
            obj.hfig=value; 
        end
        function set.DataSource(obj,value)
            if ~isempty(value) % 只能为空或Stock类的数据
                validateattributes(value, {'Stock'}, {'scalar'});
            end
            obj.hTagText.String=strcat(value.Code,'--',value.Name);
            obj.DataSource=value;
            obj.update;   % update函数重新计算和准备数据，并通知各个对象
        end
        function set.Data(obj,value)
            obj.Data=value;
            obj.notify('DataSourceChange'); % 通知各对象数据更改
        end
        function set.CrossLineSwitch(obj,value)
            % 十字线工具开关
           if value==1
               if isempty(obj.customizeObjArr) || ~any(strcmp({obj.customizeObjArr.type},'crossLine'))
                   crossLine(obj)
               end
           elseif value==0
               if ~isempty(obj.customizeObjArr)
                   delete(obj.customizeObjArr(strcmp({obj.customizeObjArr.type},'crossLine')))
               end
           else
               error('CrossLineSwitch只能输入0或1')
           end
           obj.CrossLineSwitch=value;
        end
        %--------------------------------各种坐标的转换
        function normPos=pixel2norm(obj,pixelPos) % 像素坐标转归一化坐标
            if isempty(pixelPos)
                normPos=[];
                return
            end
            if size(pixelPos,2)~=2
                error('输入pixelPos必须为2个')
            end
            if ~isa(pixelPos,'double')
                error('pixelPos输入必须为double')
            end
            fz=get(obj.hfig,'pos');
            x=pixelPos(:,1)./fz(3);
            y=pixelPos(:,2)./fz(4); 
            normPos=[x,y];
            
        end
        function coordinate=pixel2coord(obj,pixelPos) % 像素坐标转画布坐标
              normPos=obj.pixel2norm(pixelPos);
              coordinate=norm2coord(obj,normPos);
        end
        function normPos=coord2norm(obj,coordinate,axesname) % 画布坐标转归一化坐标
            haxesNow=findobj(obj.hfig,'type','axes','tag',axesname);
            if isempty(coordinate) || isempty(haxesNow)
                normPos=[];
                return
            end
            if size(coordinate,2)~=2
                error('输入pixelPos必须为2个')
            end
            if ~isa(coordinate,'double')
                error('pixelPos输入必须为double')
            end  
            x=coordinate(:,1);
            y=coordinate(:,2);
             axesPos=haxesNow.Position;
             PosX=[axesPos(1),axesPos(1)+axesPos(3)];
             PosY=[axesPos(2),axesPos(2)+axesPos(4)];
             xlim=cell2mat({haxesNow.XLim}');
             ylim=cell2mat({haxesNow.YLim}'); 
             nX=(PosX(1)-PosX(2)).*(x-xlim(1))./(xlim(1)-xlim(2))+PosX(1);
             nY=(PosY(1)-PosY(2)).*(y-ylim(1))./(ylim(1)-ylim(2))+PosY(1);
             normPos=[nX,nY];
        end       
        function pixelPos=coord2pixel(obj,coordinate,axesname) % 画布坐标转像素坐标
            normPos=coord2norm(obj,coordinate,axesname);
            pixelPos=norm2pixel(obj,normPos);
        end
        function pixelPos=norm2pixel(obj,normPos) % 归一化坐标转像素坐标
            if isempty(normPos)
                pixelPos=[];
                return
            end
            if size(normPos,2)~=2
                error('输入pixelPos必须为2个')
            end
            if ~isa(normPos,'double')
                error('pixelPos输入必须为double')
            end        
            fz=get(obj.hfig,'pos');
            x=normPos(:,1)*fz(3);
            y=normPos(:,2)*fz(4); 
            pixelPos=[x,y];            
        end
        function coordinate=norm2coord(obj,normPos) % 归一化坐标转画布坐标
            if isempty(normPos)
                coordinate=[];
                return
            end
            if size(normPos,2)~=2
                error('输入pixelPos必须为2个')
            end
            if ~isa(normPos,'double')
                error('pixelPos输入必须为double')
            end
             x=normPos(:,1);
             y=normPos(:,2);  
             haxesNow=norm2axes(obj,normPos);
             if isempty(haxesNow)
                 coordinate=[];
                 return
             end
             axesPos=haxesNow.Position;
             PosX=[axesPos(1),axesPos(1)+axesPos(3)];
             PosY=[axesPos(2),axesPos(2)+axesPos(4)];
             xlim=cell2mat({haxesNow.XLim}');
             ylim=cell2mat({haxesNow.YLim}');   
             cX=(xlim(1)-xlim(2)).*(x-PosX(1))./(PosX(1)-PosX(2))+xlim(1);
             cY=(ylim(1)-ylim(2)).*(y-PosY(1))./(PosY(1)-PosY(2))+ylim(1);
             coordinate=[cX,cY];   
        end
        function haxes=pixel2axes(obj,pixelPos)% 像素坐标所指向的画布句柄
             normPos=obj.pixel2norm(pixelPos);
             haxes=norm2axes(obj,normPos);
        end
        function haxes=norm2axes(obj,normPos)% 归一化坐标所指向的画布句柄
             if isempty(normPos)
                haxes=[];
                return
            end
            if size(normPos,2)~=2
                error('输入pixelPos必须为2个')
            end
            if ~isa(normPos,'double')
                error('pixelPos输入必须为double')
            end
            axesList=findobj(obj.hfig,'type','axes');
            axesPos=cell2mat({axesList.Position}');
            x=normPos(1,1); %  要修改
            y=normPos(1,2);
            i = x>=axesPos(:,1) & x<=axesPos(:,1)+axesPos(:,3) & y>=axesPos(:,2) & y<=axesPos(:,2)+axesPos(:,4);
             if ~any(i)
                 haxes=[];
             else
                 haxes=axesList(i);
             end   
        end
        
    end
    methods (Access = 'private')
        function Initialization(obj)  % 界面初始化函数
            %-------------------------------------------------基本布局
            ScreenSize=get(0,'ScreenSize'); % 取得屏幕尺寸(像素)
            FigureSize=[ScreenSize(3)/5,ScreenSize(4)/4,ScreenSize(3)/1.5,ScreenSize(4)/1.5];%根据屏幕大小定义界面大小
            obj.hfig=figure('Position',FigureSize); % 建立空白Figure界面
            obj.axesObj=axesClass(obj); % 建立画布管理对象（默认有CandleAxes画布）
            obj.axesObj.add; %增加一个画布
            obj.hResultTable=resultTable(obj); % ResultTable结果列表
            obj.hCodeList=codeList(obj,0); % 按键精灵对象
            obj.hTagText=annotation(obj.hfig,'textbox',[0.4,1,0,0],'String',{'标  题'},'FitBoxToText','on','EdgeColor','none','FontSize',14,'VerticalAlignment','top');
        end
        function WindowKeyPressFcn(obj,hObject,event)    % 窗口按键相应程序
            axesObjend=obj.axesObj.axesList(end);
            XLim=axesObjend.XLim;
            dot=fix(diff(XLim)/100)+1; % 图像缩小越多，控制变化的尺度越大
            switch get(obj.hfig,'CurrentKey')
                case 'uparrow'    % 上箭头，放大图像
                    if XLim(1)+dot<XLim(2)-dot
                        axesObjend.XLim=[XLim(1)+dot,XLim(2)-dot];
                        obj.notify('limChange');
                    end
                case 'downarrow'  % 下箭头，缩小图像
                    axesObjend.XLim=[XLim(1)-dot,XLim(2)+dot];
                    obj.notify('limChange');
                case 'leftarrow'  % 做箭头，向左移动图像 
                    axesObjend.XLim=[XLim(1)-dot,XLim(2)-dot];
                    obj.notify('limChange');
                case 'rightarrow' % 下箭头，向右移动图像
                    axesObjend.XLim=[XLim(1)+dot,XLim(2)+dot];
                    obj.notify('limChange');
                case 'delete'     % delete按键，删除选中的对象（indObjArr和customizeObjArr中的）
                    if ~isempty(obj.indObjArr) 
                        isSelected=logical([obj.indObjArr.beSelected]);
                        delete(obj.indObjArr(isSelected));
                        obj.indObjArr(isSelected)=[];
                    end
                    if ~isempty(obj.customizeObjArr)
                        isSelected=logical([obj.customizeObjArr.beSelected]);
                        delete(obj.customizeObjArr(isSelected));
                    end
                otherwise                 
                    obj.hCodeList.show=1;
                    obj.hCodeList.inputStr=[obj.hCodeList.inputStr,get(obj.hfig,'currentcharacter')];                   
            end
        end
        function WindowButtonMotionFcn(obj,hObject,event)% 窗口鼠标移动响应程序
            obj.notify('WindowButtonMotion');           
        end
        function WindowButtonDownFcn(obj,hObject,event)  % 窗口鼠标点击响应程序 
            obj.notify('WindowButtonDown');
        end
        function WindowDeleteFcn(obj,hObject,event)
            obj.delete;
        end
    end
end

