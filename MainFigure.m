classdef MainFigure < handle
% ��������
    properties
        hfig            % ��ǰFigure������
        axesObj         % ����axes�Ķ���
        hResultTable    % �����
        hCodeList       % ���뾫��ҳ����
        hTagText        % ����
        Data;           % ����
        DataSource      % ����Դ
        indObjArr       % ָ���������
        customizeObjArr % �Զ����������
        CrossLineSwitch % ʮ�ֹ�꿪�أ�0 or 1��
    end
 
   
    events
        DataSourceChange   % �����桰Data�����Ա仯�¼�
        WindowButtonMotion % ����ƶ��¼�
        WindowButtonDown   % ������¼�
        limChange          % ������ı��¼�
    end
    methods
        function obj=MainFigure % ���캯��
            %--------------------------·������
            addpath([cd,'\indication']);
            addpath([cd,'\customiza']);
            addpath([cd,'\stock']);
            %--------------------------
            obj.Initialization     % �����ʼ��
            obj.loadData;          % �������ݣ���ʱ��
            %-------------------------���ػص�����
            obj.CrossLineSwitch=0;
            set(obj.hfig,'WindowButtonMotionFcn',{@obj.WindowButtonMotionFcn}) % ��������ƶ��ص�
            set(obj.hfig,'WindowButtonDownFcn',{@obj.WindowButtonDownFcn})     % ����������ص�
            set(obj.hfig,'WindowKeyPressFcn',{@obj.WindowKeyPressFcn});        % ���ڰ�����Ӧ����
            set(obj.hfig,'DeleteFcn',{@obj.WindowDeleteFcn});        % ���ڹر���Ӧ����
            %-------------------------
        end 
        function loadData(obj)  % �������ݣ�Ϊ�˷��㣩
              CANDLE(obj,[1000,100]);        %K��ͼ����
              obj.DataSource=Stock('sh000001'); % ��������Դ
              VOLUME(obj,1);                % �ɽ�������
              %--------------------------------------table���ݣ���������
%               Code=obj.DataSource.Code;
%               ftsData=obj.Data;
%               names=fieldnames(ftsData);
%               tD=[cellstr(datestr(ftsData.dates(end-13:end-3))),cellstr(datestr(ftsData.dates(end-10:end))),num2cell(fts2mat(ftsData(end-13:end-3)))];
%               tableData=cell2table([cellstr(repmat(Code,[size(tD,1),1])),tD],'VariableNames',{'Code','startDay','endDay',names{4:end}});
%               obj.hResultTable.Data=tableData;
              %--------------------------------------table���ݣ���������
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
                  disp('û��table���ݼ���')
              end
              %--------------------------------------
        end
        function update(obj)    % ���º�����������DataSource�ı�֮�󣬷��¼���Ӧ������
          % DataSource�ı�֮�����¼������ݲ���֮�洢��obj.Data��
           if ~isempty(obj.indObjArr) % obj.indObjArr���벻Ϊ��
               indName={obj.indObjArr.type}; % ָ�����������б�
               indCandle=obj.indObjArr(ismember(indName,'CANDLE')); % Ѱ�Ҵ洢Candle��indObjArr
               if ~isempty(indCandle) % ���֮ǰ��Candle�������ڲ�����֮ǰ����һ�£��������ڲ���ΪĬ��
                   startDay=today-indCandle.propertie(1);
                   endDay=today;
               else
                   startDay=today-720;
                   endDay=today;
               end
               indNoCandle=obj.indObjArr(~ismember(indName,{'CANDLE','VOLUME'})); % Ѱ�ҷ�Candle��indObjArr
               if ~isempty(indNoCandle) % ����з�Candle��ָ�꣬��ͨ��Stock���Indicators����ͬһ�������ָ�������
                   indNameNoCandle={indNoCandle.type}; 
                   indPropertie={indNoCandle.propertie};
                   obj.Data=Comm.table2fts(obj.DataSource.Indicators(indNameNoCandle,indPropertie,{startDay,endDay}));
               else                    % ���û�з�Candle��ָ�꣬��ֻ����Candle����
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
        %--------------------------------  set��get
        function set.hfig(obj,value)
            validateattributes(value, {'matlab.ui.Figure'}, {'scalar'}); % ֻ����figure����
            obj.hfig=value; 
        end
        function set.DataSource(obj,value)
            if ~isempty(value) % ֻ��Ϊ�ջ�Stock�������
                validateattributes(value, {'Stock'}, {'scalar'});
            end
            obj.hTagText.String=strcat(value.Code,'--',value.Name);
            obj.DataSource=value;
            obj.update;   % update�������¼����׼�����ݣ���֪ͨ��������
        end
        function set.Data(obj,value)
            obj.Data=value;
            obj.notify('DataSourceChange'); % ֪ͨ���������ݸ���
        end
        function set.CrossLineSwitch(obj,value)
            % ʮ���߹��߿���
           if value==1
               if isempty(obj.customizeObjArr) || ~any(strcmp({obj.customizeObjArr.type},'crossLine'))
                   crossLine(obj)
               end
           elseif value==0
               if ~isempty(obj.customizeObjArr)
                   delete(obj.customizeObjArr(strcmp({obj.customizeObjArr.type},'crossLine')))
               end
           else
               error('CrossLineSwitchֻ������0��1')
           end
           obj.CrossLineSwitch=value;
        end
        %--------------------------------���������ת��
        function normPos=pixel2norm(obj,pixelPos) % ��������ת��һ������
            if isempty(pixelPos)
                normPos=[];
                return
            end
            if size(pixelPos,2)~=2
                error('����pixelPos����Ϊ2��')
            end
            if ~isa(pixelPos,'double')
                error('pixelPos�������Ϊdouble')
            end
            fz=get(obj.hfig,'pos');
            x=pixelPos(:,1)./fz(3);
            y=pixelPos(:,2)./fz(4); 
            normPos=[x,y];
            
        end
        function coordinate=pixel2coord(obj,pixelPos) % ��������ת��������
              normPos=obj.pixel2norm(pixelPos);
              coordinate=norm2coord(obj,normPos);
        end
        function normPos=coord2norm(obj,coordinate,axesname) % ��������ת��һ������
            haxesNow=findobj(obj.hfig,'type','axes','tag',axesname);
            if isempty(coordinate) || isempty(haxesNow)
                normPos=[];
                return
            end
            if size(coordinate,2)~=2
                error('����pixelPos����Ϊ2��')
            end
            if ~isa(coordinate,'double')
                error('pixelPos�������Ϊdouble')
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
        function pixelPos=coord2pixel(obj,coordinate,axesname) % ��������ת��������
            normPos=coord2norm(obj,coordinate,axesname);
            pixelPos=norm2pixel(obj,normPos);
        end
        function pixelPos=norm2pixel(obj,normPos) % ��һ������ת��������
            if isempty(normPos)
                pixelPos=[];
                return
            end
            if size(normPos,2)~=2
                error('����pixelPos����Ϊ2��')
            end
            if ~isa(normPos,'double')
                error('pixelPos�������Ϊdouble')
            end        
            fz=get(obj.hfig,'pos');
            x=normPos(:,1)*fz(3);
            y=normPos(:,2)*fz(4); 
            pixelPos=[x,y];            
        end
        function coordinate=norm2coord(obj,normPos) % ��һ������ת��������
            if isempty(normPos)
                coordinate=[];
                return
            end
            if size(normPos,2)~=2
                error('����pixelPos����Ϊ2��')
            end
            if ~isa(normPos,'double')
                error('pixelPos�������Ϊdouble')
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
        function haxes=pixel2axes(obj,pixelPos)% ����������ָ��Ļ������
             normPos=obj.pixel2norm(pixelPos);
             haxes=norm2axes(obj,normPos);
        end
        function haxes=norm2axes(obj,normPos)% ��һ��������ָ��Ļ������
             if isempty(normPos)
                haxes=[];
                return
            end
            if size(normPos,2)~=2
                error('����pixelPos����Ϊ2��')
            end
            if ~isa(normPos,'double')
                error('pixelPos�������Ϊdouble')
            end
            axesList=findobj(obj.hfig,'type','axes');
            axesPos=cell2mat({axesList.Position}');
            x=normPos(1,1); %  Ҫ�޸�
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
        function Initialization(obj)  % �����ʼ������
            %-------------------------------------------------��������
            ScreenSize=get(0,'ScreenSize'); % ȡ����Ļ�ߴ�(����)
            FigureSize=[ScreenSize(3)/5,ScreenSize(4)/4,ScreenSize(3)/1.5,ScreenSize(4)/1.5];%������Ļ��С��������С
            obj.hfig=figure('Position',FigureSize); % �����հ�Figure����
            obj.axesObj=axesClass(obj); % ���������������Ĭ����CandleAxes������
            obj.axesObj.add; %����һ������
            obj.hResultTable=resultTable(obj); % ResultTable����б�
            obj.hCodeList=codeList(obj,0); % �����������
            obj.hTagText=annotation(obj.hfig,'textbox',[0.4,1,0,0],'String',{'��  ��'},'FitBoxToText','on','EdgeColor','none','FontSize',14,'VerticalAlignment','top');
        end
        function WindowKeyPressFcn(obj,hObject,event)    % ���ڰ�����Ӧ����
            axesObjend=obj.axesObj.axesList(end);
            XLim=axesObjend.XLim;
            dot=fix(diff(XLim)/100)+1; % ͼ����СԽ�࣬���Ʊ仯�ĳ߶�Խ��
            switch get(obj.hfig,'CurrentKey')
                case 'uparrow'    % �ϼ�ͷ���Ŵ�ͼ��
                    if XLim(1)+dot<XLim(2)-dot
                        axesObjend.XLim=[XLim(1)+dot,XLim(2)-dot];
                        obj.notify('limChange');
                    end
                case 'downarrow'  % �¼�ͷ����Сͼ��
                    axesObjend.XLim=[XLim(1)-dot,XLim(2)+dot];
                    obj.notify('limChange');
                case 'leftarrow'  % ����ͷ�������ƶ�ͼ�� 
                    axesObjend.XLim=[XLim(1)-dot,XLim(2)-dot];
                    obj.notify('limChange');
                case 'rightarrow' % �¼�ͷ�������ƶ�ͼ��
                    axesObjend.XLim=[XLim(1)+dot,XLim(2)+dot];
                    obj.notify('limChange');
                case 'delete'     % delete������ɾ��ѡ�еĶ���indObjArr��customizeObjArr�еģ�
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
        function WindowButtonMotionFcn(obj,hObject,event)% ��������ƶ���Ӧ����
            obj.notify('WindowButtonMotion');           
        end
        function WindowButtonDownFcn(obj,hObject,event)  % �����������Ӧ���� 
            obj.notify('WindowButtonDown');
        end
        function WindowDeleteFcn(obj,hObject,event)
            obj.delete;
        end
    end
end

