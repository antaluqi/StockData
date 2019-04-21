classdef MA<indicationBase
    % MAָ���࣬�̳���indicationBase��
    %-------------------------
    % MA(f,20) % 20�վ���
    %-------------------------
    properties
    end
    methods 
        function obj=MA(hMainFigure,propertie) % ���캯��
            if nargin ==0
                hMainFigure=[];
            end
            obj=obj@indicationBase(hMainFigure);
            obj.type='MA';
            obj.axesName='CandleAxes';
            obj.propNo=1;     % ָ�����1��
            obj.DataNo=1;     % ��������1��
            obj.pField={'MA'};% �����б�ͷ��ǰ׺
            obj.propertie=propertie; % ���ز���
        end
        function plot(obj) %���ӿ�ʵ�֣���ͼ
            delete(obj.hthis) % ����ɾ��֮ǰ�ľ��
            if obj.show==1    % ��ʾ����Ҫ��
                if isempty(obj.Data) % DataΪ�������hthis
                    obj.hthis=[];
                elseif size(obj.Data,2)==obj.DataNo+1  % �������ݸ���������ʼ��ͼ
                    haxes=findobj(obj.parent.hfig,'tag',obj.axesName);  % ���û����ľ�� 
                    obj.hthis=plot(obj.Data(:,2),'parent',haxes);       % ��ͼ
                else
                    error('MA����Data��������')
                end
            end
        end
        function str=getValueStr(obj,x)        %�����أ�ȡ��ָ����ַ�����ʾ��xΪcoordPos��X���꣩
            if isempty(x)
                str=['MA:'];
                return
            end
            i=max(min(round(x),size(obj.Data,1)),1); % ȡֵ�����ݷ�Χ֮��
            pStr=strjoin(arrayfun(@(x) num2str(x),obj.propertie,'UniformOutput',0),'_'); % �����ַ�������[15,2]��Ϊ'15_2'            
            str=['MA[',pStr,']:',sprintf('%8.2f',obj.Data(i,2)),32];
            rgbColor=obj.hthis.Color;
            rgbColorStr=strjoin(cellfun(@(x) num2str(x),num2cell(rgbColor),'UniformOutput',0),',');
            str=['\color[rgb]{',rgbColorStr,'}',str];
        end
    end
    methods(Access = 'protected')
    end
    methods (Static)
        function propSet(parent,indObj)
            if nargin==1
                indProp(parent,mfilename,{'����'});
            elseif nargin==2
                indProp(parent,mfilename,{'����'},indObj);
            end
            disp(['����',mfilename,'�����趨'])
        end
    end
end