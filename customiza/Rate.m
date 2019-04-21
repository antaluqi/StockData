classdef Rate<customizaBass
    %-----------------------
    % ���������
    % Rate(f)
    %-----------------------
    properties
    end
    methods
        function obj=Rate(hMainFigure) % ���캯��
            obj.type='Rate';           % ����
            obj.parent=hMainFigure;    % ����
            obj.stepEnd=2;             % ����������2
            obj.step=0;                % ��ʼ����0
            obj.motionSwitch=1;        % ����ƶ�������
            obj.buttonSwitch=1;        % �����������
        end
        function calculation(obj)      %�����أ�����
            if isempty(obj.haxes)      % ����Ϊ���򲻼���
                return
            end            
            if ~isempty(obj.normPos)   % ������겻Ϊ�������
                area=obj.parent.axesObj.area;
                [left,right]=deal(area(1,1),area(1,2));
                 x=obj.normPos(1);
                 y=obj.normPos(2);                
                switch obj.step % ������ִ�м���
                    case 0 % �״ε��ǰ
                        firstLineX=[left,right];        % ��ʼ������X��������ȣ�
                        firstLineY=[y,y];               % ��ʼ������Y�����Ĺ�һ�����꣩
                        firstLineTextPos=[right-0.1,y]; % ��ʼ��text��������
                        firstLineTextStr='0%:lValue';   % ��ʼ��text��������
                        % ��ֵ��Data��containers.Map����
                        obj.Data=containers.Map({'firstLineX','firstLineY','firstLineTextPos','firstLineTextStr'},{firstLineX,firstLineY,firstLineTextPos,firstLineTextStr});
                    case 1 % �״ε����
                        firstLineX=obj.Data('firstLineX'); % ��ʼ������X��ȡ�����ڼ��㣩
                        firstLineY=obj.Data('firstLineY'); % ��ʼ������Y��ȡ�����ڼ��㣩
                        endLineX=[left,right];             % ����������X��������ȣ�
                        endLineY=[y,y];                    % ����������Y�����Ĺ�һ�����꣩
                        firstLineTextPos=obj.Data('firstLineTextPos'); % ��ʼ��text�������� 
                        endLineTextPos=[right-0.1,endLineY(1)];        % ������text��������
                        firstLineTextStr=obj.Data('firstLineTextStr'); % ��ʼ��text��������
                                                                       % ������������
                        End=roundn(obj.parent.norm2coord([0.5,y]),-2); 
                        Start=roundn(obj.parent.norm2coord([0.5,firstLineY(1)]),-2);
                        str=[num2str(roundn(100*(End(2)-Start(2))/Start(2),-2)),'%:lValue'];
                        endLineTextStr=str;                            % ������text��������
                        % ��ֵ��Data��containers.Map����
                        Key={'firstLineX','firstLineY','endLineX','endLineY'...
                            ,'firstLineTextPos','endLineTextPos','firstLineTextStr','endLineTextStr'};
                        Value={firstLineX,firstLineY,endLineX,endLineY...
                            ,firstLineTextPos,endLineTextPos,firstLineTextStr,endLineTextStr};
                        obj.Data=containers.Map(Key,Value);
                    otherwise
                end
            end
        end     
        function plot(obj)             %�����أ�����
            switch obj.step % ���������
                case 0  % �״ε��ǰ
                    % ����������ʼ�߶���
                    if length(obj.hthis)>1 || isempty(obj.hthis) ||(length(obj.hthis)==1 && ~ishandle(obj.hthis))
                        delete(obj.hthis)
                        obj.hthis=annotation(obj.parent.hfig,'line',obj.Data('firstLineX'),obj.Data('firstLineY'),'tag','crossLine_level');    %ˮƽ��
                        delete(obj.textInfo)
                        obj.textInfo=[myText(obj.parent),myText(obj.parent)];
                    end
                    % ���俪ʼ�ߵ����������
                    obj.hthis.X=obj.Data('firstLineX');
                    obj.hthis.Y=obj.Data('firstLineY');
                    obj.textInfo(1).str=obj.Data('firstLineTextStr') ; 
                    obj.textInfo(1).normPos=obj.Data('firstLineTextPos') ;
                case 1 % �״ε����
                    if length(obj.hthis)~=2 % ���������ߡ�0.618�ߡ�0.382�ߵĶ���
                        delete(obj.hthis);
                        firstLine=annotation(obj.parent.hfig,'line',obj.Data('firstLineX'),obj.Data('firstLineY'),'tag','crossLine_level');
                        endLine=annotation(obj.parent.hfig,'line',obj.Data('endLineX'),obj.Data('endLineY'),'tag','crossLine_level');
                        obj.hthis=[firstLine,endLine];
                    end
                    % ��������ߡ�0.618�ߡ�0.382�ߵĶ�������������
                    obj.hthis(2).X=obj.Data('endLineX');
                    obj.hthis(2).Y=obj.Data('endLineY');
                    obj.textInfo(2).str=obj.Data('endLineTextStr');
                    obj.textInfo(2).normPos=obj.Data('endLineTextPos');
                otherwise
            end
        end        
    end
    methods(Access = 'protected')
        function storeCoord(obj)       %�����أ�����ͼ�εĻ������꣨���ڻ�������ı����ػ棩
            normX=cell2mat({obj.hthis.X}');
            normY=cell2mat({obj.hthis.Y}');
            pointStart=[normX(:,1),normY(:,1)];
            pointEnd=[normX(:,2),normY(:,2)];
            coordStart=obj.parent.norm2coord(pointStart);
            coordEnd=obj.parent.norm2coord(pointEnd);
            obj.coordTemp=[coordStart;coordEnd];
        end
        function replot(obj,scr,data)  %�����أ���������ı���ػ�
            if ~isempty(obj.hthis) && all(ishandle(obj.hthis)) && obj.step==obj.stepEnd && ~isempty(obj.coordTemp)
                normPos=obj.parent.coord2norm(obj.coordTemp,obj.haxesFinal.Tag);
                normPosStart=normPos(1:4,:);
                y=normPosStart(:,2);
                [obj.hthis.Y]=deal([y(1),y(1)],[y(2),y(2)]);
                textBox=[obj.textInfo.hthis];
                for i=1:length(textBox)
                    textBox(i).Position(2)=y(i);
                end
                obj.Data('firstLineY')=[y(1),y(1)];
                obj.Data('endLineY')=[y(2),y(2)];
                firstLineTextPos=obj.Data('firstLineTextPos');
                firstLineTextPos(2)=y(1);
                obj.Data('firstLineTextPos')=firstLineTextPos;
            end            
        end              
    end
    methods (Static)
        function propSet(parent)
            eval([mfilename,'(parent)']);
            disp(['����',mfilename,'�����趨'])
        end
    end
end