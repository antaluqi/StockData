classdef codeList<handle
    properties
        hfig
        parent
        Data
        hTable
        hEdit
        inputStr
        indicia
        show
        indName
    end
    events
    end
    methods
        function obj=codeList(hMainFigure,show)
            obj.parent=hMainFigure;
            obj.Initialization     % 界面初始化
            set(obj.hfig,'WindowKeyPressFcn',{@obj.WindowKeyPressFcn});
            obj.indicia=0;
            if nargin == 2   
                obj.show=show;
            end
        end
        function set.inputStr(obj,value)
            %-------------------------------------
            MFPos=obj.parent.hfig.Position; % 主画面位置
            wight=MFPos(3)*0.31;
            high=wight*0.8;
            X=MFPos(1)+MFPos(3)-wight;
            Y=MFPos(2);
            FigureSize=[X,Y,wight,high];
            obj.hfig.Position=FigureSize;
            %-------------------------------------
            indList=[];
            if ~isempty(value)
                indNameFind=obj.indName(strncmpi(obj.indName,value,length(value)));
                if ~isempty(indNameFind)
                    indList=cell(length(indNameFind),3);
                    indList(:,2)=indNameFind;
                else
                    indList=[];
                end
                try
                    stockList=Stock.Py2Code(value);
                catch
                    stockList=[];
                end
            else
                stockList=[];
            end
            obj.Data=[indList;stockList];
            obj.inputStr=value;
            obj.hEdit.String=value;
        end
        function set.Data(obj,value)
             obj.hTable.Data=value;
             obj.Data=value;
        end
        function set.show(obj,value)
            if value==0
                obj.hfig.Visible='off';
            elseif value==1
                obj.hfig.Visible='on';
            else
                error('codeList的show只能输入0或1')
            end
            obj.show=value;
        end
        function value=get.indName(obj)
            value=Comm.indFileName;
        end
        function delete(obj)
            disp('codeList被删除')
        end
    end
    methods (Access = 'private')
        function Initialization(obj) % 界面初始化函数
           MFPos=obj.parent.hfig.Position; % 主画面位置
           wight=MFPos(3)*0.31;
           high=wight*0.8;
           X=MFPos(1)+MFPos(3)-wight;
           Y=MFPos(2);
           FigureSize=[X,Y,wight,high];
           obj.hfig=figure('Position',FigureSize,'MenuBar','none','ToolBar','none'); % 建立空白Figure界面
           obj.hTable=uitable('parent',obj.hfig,'Units','normalized','Position',[0 0 1 0.9],'ColumnName',{'代码','拼音','名称'});
           uicontrol('Style','text','parent',obj.hfig,'Units','normal','position',[0,0.9,0.2,0.1],'string','输入:','fontsize',10,'FontWeight','bold');
           obj.hEdit=uicontrol('Style','edit','parent',obj.hfig,'Units','normal','position',[0.2,0.9,0.8,0.1]);
        end
        function WindowKeyPressFcn(obj,hObject,event)    % 窗口按键相应程序
            absKey=abs(get(obj.hfig,'currentcharacter'));
            if (absKey>=48 && absKey<=57) || (absKey>=97 && absKey<=122)|| (absKey>=65 && absKey<=90)
                obj.inputStr=[obj.inputStr,char(absKey)];
                obj.indicia=0;
            elseif absKey==13
              %  disp('Enter')
                if ~isempty(obj.Data)
                    Code=obj.Data{max(obj.indicia,1),1};
                    if ~isempty(Code)
                        obj.parent.DataSource=Stock(Code);
                    else
                        Code=obj.Data{max(obj.indicia,1),2};
                        eval([Code,'.propSet(obj.parent)'])
                    end
                end
                obj.inputStr=[];
                obj.indicia=0;
                obj.show=0;
            elseif absKey==8
              %  disp('Backspace')
                try
                    obj.inputStr=obj.inputStr(1:end-1);
                end
                if isempty(obj.inputStr)
                    obj.show=0;
                end
                obj.indicia=0;
            elseif absKey==27
             %   disp('Esc')
                obj.inputStr=[];
                obj.indicia=0;
            elseif absKey==30
             %   disp('up')
                if ~isempty(obj.Data) && obj.indicia-1>=1
                    obj.indicia=obj.indicia-1;
                    indiciaData=obj.Data;
                    indiciaData(obj.indicia,:)=strcat('<html><BODY bgcolor="green">',obj.Data(obj.indicia,:),'</BODY></html>');
                    obj.hTable.Data=indiciaData;
                end                
            elseif absKey==31
             %   disp('down')
                if ~isempty(obj.Data) && obj.indicia+1<=size(obj.Data,1)
                    obj.indicia=obj.indicia+1;
                    indiciaData=obj.Data;
                    indiciaData(obj.indicia,:)=strcat('<html><BODY bgcolor="green">',obj.Data(obj.indicia,:),'    </BODY></html>');
                    obj.hTable.Data=indiciaData;
                end
            end    
             
        end
        
    end
end