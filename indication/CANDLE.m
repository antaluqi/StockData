classdef CANDLE<indicationBase
    % CANDLEָ���࣬�̳���indicationBase��
    %-------------------------
    % CANDLE(f,[720,100]) % ���ݷ�Χ720�죬��ʾ���100��
    %-------------------------
    properties
    end
    methods 
        function obj=CANDLE(hMainFigure,propertie)% ���캯��
            if nargin ==0
                hMainFigure=[];
            end
            obj=obj@indicationBase(hMainFigure);
            obj.type='CANDLE';
            obj.axesName='CandleAxes';
            obj.propNo=2;            % ��������2�������ݳ��Ⱥ���ʾ���ȣ�
            obj.DataNo=4;            % ����������Ӧ����5�У��̳еı׶ˣ����Կ�������Ӧ�޸ģ�
            obj.propertie=propertie; % ���ò���
        end
        function calculation(obj)                 %�����أ��������ݣ�һ���״������õ���Candle�б���ͨ��calculation������
            if ~isempty(obj.parent) && ~isempty(obj.parent.DataSource)
                S=obj.parent.DataSource;
                h=S.HistoryDaily(today-obj.propertie(1),today,'L');
                obj.Data=[datenum(h.Date),h.High,h.Low,h.Close,h.Open,h.Volume];
            end
        end        
        function plot(obj)                        %���ӿ�ʵ�֣���ͼ

            delete(obj.hthis)
            if obj.show==1
                if isempty(obj.Data)
                    obj.hthis=[];
                elseif size(obj.Data,2)==obj.DataNo+2%���������������⣬��Ҫ�޸�
                    %---------------------------
                    % Candle������Lineͼ�ι�ͬ������һ��ͼ��ʱ������Candle�ᷢ������
                    % ������Candle���Ƶ�ʱ����ʱ����һ��ͼ�㣨λ����CandleAxes��ͬ������һ��Ҫ������ͼ���X��������
                    hCandleAxes=findobj(obj.parent.hfig,'tag',obj.axesName);
                    haxesTemp=axes('parent',obj.parent.hfig,'position',hCandleAxes.Position);
                    linkaxes([hCandleAxes,haxesTemp],'x')
                    %---------------------------
                    axes(haxesTemp);
                    %---------------------------
                    %����ͨcandle���ƣ����Ա���ʱ�����л��Ʋ����Ŀյ����������Ҫ������ȡ��
                    %������ɫ����ʾ����
                    candle(obj.Data(:,5),obj.Data(:,2),obj.Data(:,3),obj.Data(:,4));
                    hcdl_vl = findobj(gca, 'Type', 'line');
                    hcdl_bx = findobj(gca, 'Type', 'patch');
                    obj.hthis=[hcdl_vl(:); hcdl_bx(:)];
                    ch = get(gca,'children');
                    set(ch(1),'FaceColor','g');
                    set(ch(2),'FaceColor','r');
                    showTime=[size(obj.Data,1)-obj.propertie(2),size(obj.Data,1)];
                    haxesTemp.XLim=[showTime(1)-0.5,showTime(2)+0.5];
                    
                    %---------------------------
                    % ����ʱͼ���ϻ��Ƶ�Candle��Parent����ת����CandleAxesͼ�㲢ɾ����ʱͼ��
                    [obj.hthis.Parent]=deal(hCandleAxes);
                    delete(haxesTemp)
                    %---------------------------
                else
                    error('CANDLE����Data��������')
                end
            end
        end
        function str=getValueStr(obj,x)           %�����أ�ȡ��ָ����ַ�����ʾ��xΪcoordPos��X���꣩
            if isempty(x)
                str=['���ڣ� '];
                return
            end
            i=max(min(round(x),size(obj.Data,1)),1); % ȡֵ�����ݷ�Χ֮��
            d=obj.Data(i,:);
            str=['����:',datestr(d(1),'yyyy-mm-dd'),'  ��:',sprintf('%8.2f',d(5)),' ��:',sprintf('%8.2f',d(2)),'  ��:',sprintf('%8.2f',d(3)),'  ��:',sprintf('%8.2f',d(4)),10];
        end
        function delete(obj) %����������
            if ~isempty(obj.parent)
               obj.parent=[];
            end
            delete(obj.hthis)
        end
    end
    methods(Access = 'protected')

    end
    methods (Static)
        function propSet(parent)
            eval([mfilename,'(parent)']);
            disp(['����',mfilename,'�����趨'])
        end
    end
end