classdef VOLUME<indicationBase
    % VOLUMEָ���࣬�̳���indicationBase��
    %-------------------------
    % VOLUME(f,1)
    %-------------------------
    properties      
    end
    methods
        function obj=VOLUME(hMainFigure,propertie) % ���캯��
            if nargin ==0
                hMainFigure=[];
            end
            obj=obj@indicationBase(hMainFigure);
            obj.type='VOLUME';
            obj.axesName='IndicatorsAxes1';
            obj.propNo=1;            % ָ�����1��
            obj.DataNo=2;            % ��������1��
            obj.pField={'Volume'};   % �����б�ͷ��ǰ׺
            obj.propertie=propertie; % �������
        end
        function calculation(obj)                  %�����أ��������ݣ�һ���״������õ���Volume�б���ͨ��calculation������
            if ~isempty(obj.parent) && ~isempty(obj.parent.DataSource) % ��ҪMainFigure�е�DataSource����
                % �ҳ�Candleָ�������
                if ~isempty(obj.parent) && isa(obj.parent,'MainFigure') && ~isempty(obj.parent.indObjArr)
                   candleObj=obj.parent.indObjArr(strcmp({obj.parent.indObjArr.type},'CANDLE')); 
                else
                    candleObj=[];
                end
                % ����ĵ�ԭʼVolume���ݣ���ͨ��Candleָ�����ȷ���ǵ���Ϣ
                if ~isempty(candleObj) && ~isempty(candleObj.Data)
                    iUp=candleObj.Data(:,5)<=candleObj.Data(:,4);
                    iDown=~iUp;
                    VolumeData=candleObj.Data(:,[1,6]);
                else
                    tableData=S.HistoryDaily(today-720,today); % ����
                    iUp=tableData.Open<=tableData.Close;
                    iDown=~iUp;                   
                    VolumeData=[datenum(tableData.Date),tableData.Volume];% ȡ����Ӧ�ֶ�����
                end
                % ������Volume���ݣ���Ϊʱ�䡢�ǡ���������Ϣ
                obj.Data=[VolumeData(:,1),VolumeData(:,2).*iUp,VolumeData(:,2).*iDown];
            else
                error('MainFigureû������Դ')
            end
        end
        function plot(obj)                         %���ӿ�ʵ�֣���ͼ
            delete(obj.hthis) % ����ɾ��֮ǰ�ľ��
            if obj.show==1      % ��ʾ����Ҫ��
                if isempty(obj.Data) % DataΪ�������hthis
                    obj.hthis=[];
                elseif size(obj.Data,2)==obj.DataNo+1 % �������ݸ���������ʼ��ͼ
                    haxes=findobj(obj.parent.hfig,'tag',obj.axesName);      %���û����ľ�� 
                    up=bar(obj.Data(:,2),'parent',haxes,'facecolor','r');   % ������
                    down=bar(obj.Data(:,3),'parent',haxes,'facecolor','g'); % ������
                    obj.hthis=[up,down];
                else
                    error('BOLL����Data��������')
                end
            end
        end
        function reload(obj)                       % MainFigur��Data�ı���Ӧ���� 
            reLoadData=obj.parent.Data; % ȡ��MainFigur��Data����(fts��ʽ)
            if ~isempty(reLoadData)     % ���MainFigur��Data���ݲ�Ϊ����ȡ����ָ���ֶβ���ֵobj.Data�����ػ�
                iUp=fts2mat(reLoadData.Open)<=fts2mat(reLoadData.Close);
                iDown=~iUp;
                VolumeData=fts2mat(extfield(reLoadData,strcat(obj.pField))); % ȡ������BOll15_2��MA10���ֶ����ݣ����������ݶκϲ�
                obj.Data=[reLoadData.dates,VolumeData.*iUp,VolumeData.*iDown];
            else                        % ���MainFigur��Data����Ϊ�������������� 
                obj.calculation;
            end

        end
        function str=getValueStr(obj,x)            %�����أ�ȡ��ָ����ַ�����ʾ��xΪcoordPos��X���꣩
            if isempty(x)
                str='Volume:';
                return
            end
            i=max(min(round(x),size(obj.Data,1)),1);% ȡֵ�����ݷ�Χ֮��
            str=['Volume: ',sprintf('%8.0f',obj.Data(i,2)+obj.Data(i,3)),'   '];
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