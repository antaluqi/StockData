classdef Fibonacci<customizaBass
    %---------------------------
    % 쳲�������
    % Fibonacci(f)
    %---------------------------
    properties
    end
    methods
        function obj=Fibonacci(hMainFigure) % ���캯��   
            obj.type='Fibonacci';    % ����
            obj.parent=hMainFigure;  % ����
            obj.stepEnd=2;           % ����������2
            obj.step=0;              % ��ʼ����0
            obj.motionSwitch=1;      % ����ƶ�������
            obj.buttonSwitch=1;      % �����������
        end
        function calculation(obj)           %�����أ�����
            if isempty(obj.haxes)    % ����Ϊ���򲻼���
                return
            end
            if ~isempty(obj.normPos) % ������겻Ϊ�������
                area=obj.parent.axesObj.area;
                [left,right]=deal(area(1,1),area(1,2));
                 x=obj.normPos(1);
                 y=obj.normPos(2);       
                switch obj.step % ������ִ�м���
                    case 0 % �״ε��ǰ
                        firstLineX=[left,right];        % ��ʼ������X��������ȣ�
                        firstLineY=[y,y];               % ��ʼ������Y�����Ĺ�һ�����꣩
                        firstLineTextPos=[right-0.1,y]; % ��ʼ��text��������
                        firstLineTextStr='��ʼ:lValue'; % ��ʼ��text��������
                        % ��ֵ��Data��containers.Map����
                        obj.Data=containers.Map({'firstLineX','firstLineY','firstLineTextPos','firstLineTextStr'},{firstLineX,firstLineY,firstLineTextPos,firstLineTextStr});
                    case 1 % �״ε����
                        firstLineX=obj.Data('firstLineX'); % ��ʼ������X��ȡ�����ڼ��㣩
                        firstLineY=obj.Data('firstLineY'); % ��ʼ������Y��ȡ�����ڼ��㣩
                        endLineX=[left,right]; % ����������X��������ȣ�
                        endLineY=[y,y];        % ����������Y�����Ĺ�һ�����꣩
                        line618X=[left,right]; % 0.618������X��������ȣ�
                        line618Y=(endLineY-firstLineY)*0.618+firstLineY; % 0.618������Y������õ���
                        line382X=[left,right]; % 0.328������X��������ȣ�
                        line382Y=(endLineY-firstLineY)*0.382+firstLineY;% 0.328������Y������õ���
                        firstLineTextPos=obj.Data('firstLineTextPos'); % ��ʼ��text�������� 
                        endLineTextPos=[right-0.1,endLineY(1)];        % ������text�������� 
                        line618TextPos=[right-0.1,line618Y(1)];        % 0.618��text�������� 
                        line382TextPos=[right-0.1,line382Y(1)];        % 0.382��text�������� 
                        firstLineTextStr=obj.Data('firstLineTextStr'); % ��ʼ��text�������� 
                        endLineTextStr='����:lValue';                  % ������text��������
                        line618TextStr='0.618��::lValue';              % 0.618��text��������
                        line382TextStr='0.382��::lValue';              % 0.382��text��������
                        % ��ֵ��Data��containers.Map����
                        Key={'firstLineX','firstLineY','endLineX','endLineY','line618X','line618Y','line382X','line382Y'...
                            ,'firstLineTextPos','endLineTextPos','line618TextPos','line382TextPos','firstLineTextStr','endLineTextStr','line618TextStr','line382TextStr'};
                        Value={firstLineX,firstLineY,endLineX,endLineY,line618X,line618Y,line382X,line382Y...
                            ,firstLineTextPos,endLineTextPos,line618TextPos,line382TextPos,firstLineTextStr,endLineTextStr,line618TextStr,line382TextStr};
                        obj.Data=containers.Map(Key,Value);
                    otherwise
                end
            end
        end
        function plot(obj)                  %�����أ�����
            switch obj.step % ���������
                case 0 % �״ε��ǰ
                    % ����������ʼ�߶���
                    if length(obj.hthis)>1 || isempty(obj.hthis) ||(length(obj.hthis)==1 && ~ishandle(obj.hthis)) 
                        delete(obj.hthis)
                        obj.hthis=annotation(obj.parent.hfig,'line',obj.Data('firstLineX'),obj.Data('firstLineY'),'tag','crossLine_level');    %ˮƽ��
                        delete(obj.textInfo)
                        obj.textInfo=[myText(obj.parent),myText(obj.parent),myText(obj.parent),myText(obj.parent)];
                    end
                    % ���俪ʼ�ߵ����������
                    obj.hthis.X=obj.Data('firstLineX');
                    obj.hthis.Y=obj.Data('firstLineY');
                    obj.textInfo(1).str=obj.Data('firstLineTextStr') ; 
                    obj.textInfo(1).normPos=obj.Data('firstLineTextPos') ;
                case 1 % �״ε����
                    if length(obj.hthis)~=4 % ���������ߡ�0.618�ߡ�0.382�ߵĶ���
                        delete(obj.hthis);
                        firstLine=annotation(obj.parent.hfig,'line',obj.Data('firstLineX'),obj.Data('firstLineY'),'tag','crossLine_level');
                        endLine=annotation(obj.parent.hfig,'line',obj.Data('endLineX'),obj.Data('endLineY'),'tag','crossLine_level');
                        line618=annotation(obj.parent.hfig,'line',obj.Data('line618X'),obj.Data('line618Y'),'tag','crossLine_level');
                        line382=annotation(obj.parent.hfig,'line',obj.Data('line618X'),obj.Data('line382Y'),'tag','crossLine_level');
                        obj.hthis=[firstLine,endLine,line618,line382];
                    end
                    % ��������ߡ�0.618�ߡ�0.382�ߵĶ�������������
                    obj.hthis(2).X=obj.Data('endLineX');
                    obj.hthis(2).Y=obj.Data('endLineY');
                    obj.hthis(3).X=obj.Data('line618X');
                    obj.hthis(3).Y=obj.Data('line618Y');
                    obj.hthis(4).X=obj.Data('line618X');
                    obj.hthis(4).Y=obj.Data('line382Y');
                    obj.textInfo(2).str=obj.Data('endLineTextStr');
                    obj.textInfo(2).normPos=obj.Data('endLineTextPos');
                    obj.textInfo(3).str=obj.Data('line618TextStr');
                    obj.textInfo(3).normPos=obj.Data('line618TextPos');
                    obj.textInfo(4).str=obj.Data('line382TextStr');
                    obj.textInfo(4).normPos=obj.Data('line382TextPos');

                otherwise
            end
        end

    end
    methods(Access = 'protected') 
        function storeCoord(obj)           %�����أ�����ͼ�εĻ������꣨���ڻ�������ı����ػ棩
            normX=cell2mat({obj.hthis.X}');
            normY=cell2mat({obj.hthis.Y}');
            pointStart=[normX(:,1),normY(:,1)];
            pointEnd=[normX(:,2),normY(:,2)];
            coordStart=obj.parent.norm2coord(pointStart);
            coordEnd=obj.parent.norm2coord(pointEnd);
            obj.coordTemp=[coordStart;coordEnd];
        end
        function replot(obj,scr,data)      %�����أ���������ı���ػ�
            if ~isempty(obj.hthis) && all(ishandle(obj.hthis)) && length(obj.hthis)==4 && ~isempty(obj.coordTemp)
                normPos=obj.parent.coord2norm(obj.coordTemp,obj.haxesFinal.Tag);
                normPosStart=normPos(1:4,:);
                y=normPosStart(:,2);
                [obj.hthis.Y]=deal([y(1),y(1)],[y(2),y(2)],[y(3),y(3)],[y(4),y(4)]);
                textBox=[obj.textInfo.hthis];
                for i=1:length(textBox)
                    textBox(i).Position(2)=y(i);
                end
                obj.Data('firstLineY')=[y(1),y(1)];
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