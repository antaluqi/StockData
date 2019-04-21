classdef Channel<customizaBass
    %-----------------------
    % ͨ�����������죩
    % Channel(f)
    %-----------------------
    properties
    end
    properties (Access = 'protected')
        p % �ߵ�һά�ع�ϵ��
    end
    methods
        function obj=Channel(hMainFigure) % ���캯��
            obj.type='Channel';      % ����
            obj.parent=hMainFigure;  % ����
            obj.stepEnd=3;           % ����������3
            obj.step=0;              % ��ʼ����0
            obj.motionSwitch=1;      % ����ƶ�������
            obj.buttonSwitch=1;      % �����������
        end
        function calculation(obj)         %�����أ�����
            if isempty(obj.haxes)     % ����Ϊ���򲻼���
                return
            end     
            if ~isempty(obj.normPos)  % ������겻Ϊ�������
                switch obj.step    % ������ִ�м���      
                    case 0   % �״ε��ǰ��ֻ��text��   
                        delete(obj.hthis) % ɾ��֮ǰ���ܴ��ڵľ��
                        obj.hthis=[];
                        if isempty(obj.textInfo) % ���texy����Ϊ�����½�
                            obj.textInfo=[myText(obj.parent),myText(obj.parent),myText(obj.parent)];
                        end
                        % �ƶ�����text����������֣�ֻ�ƶ���ʾ��һ�����ڶ����͵�����û��ʾ��
                        obj.textInfo(1).str='lValue';
                        obj.textInfo(1).normPos=obj.normPos;
                        obj.textInfo(2).str=''; 
                        obj.textInfo(3).str=''; 
                    case 1 % �״ε����һ�������ߺ�����text��
                        obj.haxesFinal=obj.haxes;     % ȷ�����û���
                        % ����text����������֣�ֻ�ƶ���ʾ�ڶ�������һ���������ǰ�����ֵ���������Ծɲ���ʾ��
                        obj.textInfo(2).str='lValue';
                        obj.textInfo(2).normPos=obj.normPos;
                        obj.textInfo(3).str=''; 
                        %---------------------------------------
                         %ͨ��ǰ����text�����꣨x,y��һά�ع������ϵ����������ֱ���뻭����Ե�ĽӴ���(X,Y)
                        x=[obj.textInfo(1).normPos(1),obj.textInfo(2).normPos(1)];% ����text��x����
                        y=[obj.textInfo(1).normPos(2),obj.textInfo(2).normPos(2)];% ����text��y����
                        % �����Ĺ�һ������
                        XPosLim=[obj.haxesFinal.Position(1),obj.haxesFinal.Position(1)+obj.haxesFinal.Position(3)];
                        YPosLim=[obj.haxesFinal.Position(2),obj.haxesFinal.Position(2)+obj.haxesFinal.Position(4)];
                        if x(1)==x(2)   % ����Ǵ�ֱ������Ӧ���
                            X=x;
                            Y=YPosLim;
                            obj.p=[inf,inf];
                        elseif y(1)==y(2)% �����ˮƽ����ֱ�����
                            Y=y;
                            X=XPosLim;
                            obj.p=[0 0];
                        else             % ����ͽ���һά���Իع�
                            obj.p=polyfit(x,y,1);          % һά���Իع�ϵ��
                            Yval=polyval(obj.p,XPosLim);   % �ûع�ϵ���ͻ�����X���귽λ������ֱ���Ƿ񳬳��˻�����Y���귽λ
                            Y=min(max(Yval,YPosLim(1)),YPosLim(2));% ֱ�ߵ�Y����ѡ���ڷ�Χ֮�ڵļ���ֵ�����������ѡ���Եֵ��
                            X=polyval(polyfit(y,x,1),Y);           % ͨ��Yֵ����ع�����Xֵ
                        end
                        %---------------------------------------
                        if all(isempty(obj.hthis)) || all(~ishandle(obj.hthis)) % ����������һ��ֱ�߶���
                            obj.hthis=annotation(obj.parent.hfig,'line',X,Y,'tag','Channel1');
                        elseif length(obj.hthis)>1
                            delete(obj.hthis(2:end))
                            obj.hthis=obj.hthis(1);
                        end
                        % ����������õ�ֱ�ߵ�����
                        obj.hthis.X=X;
                        obj.hthis.Y=Y;     
                    case 2 % �ڶ��ε��������ƽ�п����ߺ�����text��
                        % ����text����������֣�ֻ�ƶ���ʾ����������һ���͵ڶ����������ǰ�����ֵ��
                        obj.textInfo(3).str='lValue';
                        obj.textInfo(3).normPos=obj.normPos;                        
                        %---------------------------------------
                        % ͨ����һ���ߵ�б��p(1),���������������ֱ��Ӧ���е�Y��ؾ࣬�Ӷ�ȷ���ڶ����ߵĻع�ϵ�����ټ���ڶ����ߵ�����
                        XPosLim=[obj.haxesFinal.Position(1),obj.haxesFinal.Position(1)+obj.haxesFinal.Position(3)];
                        YPosLim=[obj.haxesFinal.Position(2),obj.haxesFinal.Position(2)+obj.haxesFinal.Position(4)];
                        x=obj.textInfo(3).normPos(1);
                        y=obj.textInfo(3).normPos(2);
                        if all(obj.p==[inf,inf]) % �����ˮƽ����ֱ�����
                            X=[x x];
                            Y=YPosLim;
                        elseif all(obj.p==[0 0]) % �����ˮƽ����ֱ�����
                            X=XPosLim;
                            Y=[y,y];
                        else
                            b=y-obj.p(1)*x;  % ͨ����һ���ߵ�б��p(1),���������������ֱ��Ӧ���е�Y��ؾ�
                            obj.p(2)=b;      % ȷ���ڶ����ߵĻع�ϵ��
                            Yval=polyval(obj.p,XPosLim); % �ûع�ϵ���ͻ�����X���귽λ������ֱ���Ƿ񳬳��˻�����Y���귽λ
                            Y=min(max(Yval,YPosLim(1)),YPosLim(2)); % ֱ�ߵ�Y����ѡ���ڷ�Χ֮�ڵļ���ֵ�����������ѡ���Եֵ��
                            X=(Y-obj.p(2))./obj.p(1);  % ͨ��Yֵ����ع�����Xֵ
                        end
                        %---------------------------------------
                        % ���������ڶ���ֱ�߶���
                        if length(obj.hthis)==1 || ~ishandle(obj.hthis(2))
                            obj.hthis(2)=annotation(obj.parent.hfig,'line',X,Y,'tag','Channel2');
                        end
                        % ����������õ�ֱ�ߵ�����
                        obj.hthis(2).X=X;
                        obj.hthis(2).Y=Y;    
                        
                    otherwise
                end
            end
        end
        function plot(obj)                %�����أ����ƣ��˴����ã�
        end
    end
    methods(Access = 'protected')
        function storeCoord(obj)          %�����أ�����ͼ�εĻ�������
            normPos=[obj.textInfo.normPos];
            obj.coordTemp=obj.parent.norm2coord(reshape(normPos,2,[])');
        end
        function replot(obj,scr,data)     %�����أ���������ı���ػ�
            % ��Ҫ˼·���ض�λ����text�����꣬���ظ�calculation��step-2����
            if ~isempty(obj.hthis) && all(ishandle(obj.hthis)) && obj.step==obj.stepEnd && ~isempty(obj.coordTemp)
                normPos=obj.parent.coord2norm(obj.coordTemp,obj.haxesFinal.Tag);
                for i=1:length(obj.textInfo)
                    obj.textInfo(i).normPos=normPos(i,:);
                end
                x=[obj.textInfo(1).normPos(1),obj.textInfo(2).normPos(1)];
                y=[obj.textInfo(1).normPos(2),obj.textInfo(2).normPos(2)];
                XPosLim=[obj.haxesFinal.Position(1),obj.haxesFinal.Position(1)+obj.haxesFinal.Position(3)];
                YPosLim=[obj.haxesFinal.Position(2),obj.haxesFinal.Position(2)+obj.haxesFinal.Position(4)];
                if x(1)==x(2)
                    obj.p=[inf,inf];
                    X1=x;
                    Y1=YPosLim;
                    X2=[obj.textInfo(3).normPos(1),obj.textInfo(3).normPos(1)];
                    Y2=YPosLim;
                elseif y(1)==y(2)
                    obj.p=[0 0];
                    X1=XPosLim;
                    Y1=y;
                    X2=XPosLim;
                    Y2=[obj.textInfo(3).normPos(2),obj.textInfo(3).normPos(2)];
                else
                    obj.p=polyfit(x,y,1);
                    Yval=polyval(obj.p,XPosLim);
                    Y1=min(max(Yval,YPosLim(1)),YPosLim(2));
                    X1=polyval(polyfit(y,x,1),Y1);
                    x2=obj.textInfo(3).normPos(1);
                    y2=obj.textInfo(3).normPos(2);
                    b=y2-obj.p(1)*x2;
                    obj.p(2)=b;
                    Yval=polyval(obj.p,XPosLim);
                    Y2=min(max(Yval,YPosLim(1)),YPosLim(2));
                    X2=(Y2-obj.p(2))./obj.p(1);
                end
                    obj.hthis(1).X=X1;
                    obj.hthis(1).Y=Y1;
                    obj.hthis(2).X=X2;
                    obj.hthis(2).Y=Y2;                    
               
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