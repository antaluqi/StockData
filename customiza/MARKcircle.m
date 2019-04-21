classdef MARKcircle<customizaBass
    %---------------------------
    % ���Ȧ
    % p=MARKcircle(f)
    % p.propertie={'CandleAxes','2016-09-07','2016-09-12'};
    % p.propertie={haxes,'2016-09-07','2016-09-12'};
    % p.propertie={haxes,101,103,15.6,16.1};
    %---------------------------
    properties
        propertie % ����
    end
    methods
        function obj=MARKcircle(hMainFigure) % ���캯��
            if nargin ==0
                hMainFigure=[];
            end
            obj=obj@customizaBass(hMainFigure); % ���ø��๹�캯��
            obj.type='MARKcircle';              % ����
        end
        function calculation(obj)            %�����أ�����
            if ~isempty(obj.parent) && ~isempty(obj.parent.indObjArr)
                % �ڲ�����ȡ�����û���
                if all(ishandle(obj.propertie{1})) && strcmp(obj.propertie{1}.Tag,'axes') % �ڲ���(1)����ǻ����������Ϊ��ǰ�������
                    haxes=obj.propertie{1};
                elseif ischar(obj.propertie{1})                 % ������ַ���ͨ�����������ҵ�������� 
                    axesName=obj.propertie{1};   
                    haxes=findobj(obj.parent.hfig,'tag',axesName);
                else
                    error('Mark����propertie������һ������ӦΪaxes�����axes����')
                end  
                % �ڲ�����ȡ�ÿ�ʼ���ںͽ�����������
                startDay=datenum(obj.propertie{2});
                endDay=datenum(obj.propertie{3});
                % ָ�������������
                if isempty(haxes)
                    error(['δ�ҵ���Ϊ',axesName,'��axes.'])
                end
                %-------------------------------------------
               % �������Ϊ5����������ĸ�Ϊʵ�����괫���Data�����غ���
                if length(obj.propertie)==5
                    yLow=obj.propertie{4};
                    yHigh=obj.propertie{5};
                    obj.Data={haxes,startDay,yLow,endDay-startDay,yHigh-yLow};
                    return
                end
                % ����ʼ����Y����
                % �ҵ�CANDLEָ�����                
                ind=obj.parent.indObjArr;
                indCandle=ind(strcmp({ind.type},'CANDLE'));                
                if ~isempty(indCandle) % CANDLEָ�����������
                    Dates=indCandle.Data(:,1); % ��CANDLEָ������Data��ȡ��������
                    if ~ismember(startDay,Dates) || ~ismember(endDay,Dates)  %�����������ڲ��ڵ�ǰCANDLEָ������������У��򷵻ؿյ�Data(����ͼ)
                        obj.Data=[];
                        warning([datestr(startDay,'yyyy-mm-dd'),'��',datestr(endDay,'yyyy-mm-dd'),'����Candle������'])
                        return
                    end
                    % ����������ڴ�����ǰCANDLEָ������������У����������Yֵ
                    yLow=min(indCandle.Data((Dates>=startDay & Dates<=endDay),3)); % ȡ�������ڵ���ͼ�
                    yHigh=max(indCandle.Data((Dates>=startDay & Dates<=endDay),2));% ȡ�������ڵ���߼�
                    iStart=find(Dates==startDay);                                  % ȡ�ÿ�ʼ���ڵĺ�����
                    iEnd=find(Dates==endDay);                                      % ȡ�ý������ڵĺ�����
                    leaveDot=diff(haxes.YLim)*0.05;                                % ƫ���������ݻ������������
                    % ��ϳ����ݣ�xֵȡʵ��ֵ���Ա�ֵ���м�ֵ��
                    obj.Data={haxes,iStart-0.5,yLow-leaveDot,iEnd-iStart+1,yHigh-yLow+2*leaveDot};
                else
                    error('Candle����Ϊ�գ�������������MARK������')
                end
            else
            end
        end
        function plot(obj)                   %�����أ���ͼ
            delete(obj.hthis)       % ɾ��֮ǰ���ܴ��ڵľ��
            if isempty(obj.Data)    % ���ݲ���Ϊ��
                obj.hthis=[];
            else
                haxes=obj.Data{1};                         % ȡ�û������
                x=obj.Data{2};                             % X���꣨���£�
                weigth=obj.Data{3};                        % X�����ȣ����ң�
                y=obj.Data{4};                             % Y���꣨���£�
                high=obj.Data{5};                          % Y�����ȣ��ߣ�
                obj.hthis=imrect(haxes,[x,weigth,y,high]); % ��ͼ
                obj.parent.notify('limChange');            % ��������ͼ�����п��ܻ�ı����귶Χ�����Է����仯֪ͨ
                setColor(obj.hthis,'r');                   % ��ɫ
            end
        end
        function set.propertie(obj,value)    %  ����������ڸ������ӵĲ�����
            obj.propertie=value;
            set_propertie(obj,value);
        end
    end
    methods(Access = 'protected')
        function set_hthis(obj,value)        %�����أ����þ��������ϲ��ð󶨵����Ӧ������
        end 
        function set_propertie(obj,value)    % ���ò���������calculation����
            obj.calculation;
        end
        function set_beDestroied(obj,value)  %�����أ������Ƿ����٣���������resultTable��ע��hmark��
            if value==1
                try
                    obj.parent.customizeObjArr([obj.parent.customizeObjArr.beDestroied]==1)=[];
                catch
                    disp('set_beDestroied��ɾ��customizeObjArr�еĶ���ʱ�д�����')
                end
                try
                    obj.parent.hResultTable.hmark=[];
                catch
                    disp('set_beDestroied��ɾ��customizeObjArr�еĶ���ʱ�д�����')
                end                
            end
        end
        function value=get_beSelected(obj)   % (����) ���ܱ�ѡ��
            value=0;
        end
    end
    methods (Static)
        function propSet(parent)
            disp(['����',mfilename,'�����趨'])
        end
    end  
end