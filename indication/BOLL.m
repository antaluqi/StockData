classdef BOLL<indicationBase
    % BOLLָ���࣬�̳���indicationBase��
    %-------------------------
    % BOLL(f,[20,2]) % 20�ա�2����׼��ִ�
    %-------------------------
    properties
    end
    methods 
        function obj=BOLL(hMainFigure,propertie) % ���캯��
            if nargin ==0
                hMainFigure=[];
            end
            obj=obj@indicationBase(hMainFigure);
            obj.type='BOLL';
            obj.axesName='CandleAxes';
            obj.propNo=2;     % ָ�����1��
            obj.DataNo=3;     % ��������1��
            obj.pField={'BOllMid','BOllUp','BOllDown'};% �����б�ͷ��ǰ׺
            obj.propertie=propertie; % �������
        end
        function plot(obj)                       %���ӿ�ʵ�֣���ͼ
            delete(obj.hthis) % ����ɾ��֮ǰ�ľ��
            if obj.show==1    % ��ʾ����Ҫ��
                if isempty(obj.Data) % DataΪ�������hthis
                    obj.hthis=[];
                elseif size(obj.Data,2)==obj.DataNo+1 % �������ݸ���������ʼ��ͼ
                    haxes=findobj(obj.parent.hfig,'tag',obj.axesName); % ���û����ľ�� 
                    obj.hthis=plot(obj.Data(:,2:end),'parent',haxes);  % ��ͼ
                else
                    error('BOLL����Data��������')
                end
            end
        end
        function str=getValueStr(obj,x)          %�����أ�ȡ��ָ����ַ�����ʾ��xΪcoordPos��X���꣩
            if isempty(x)
                str=['BOLL:'];
                return
            end
            i=max(min(round(x),size(obj.Data,1)),1);% ȡֵ�����ݷ�Χ֮��
            pStr=strjoin(arrayfun(@(x) num2str(x),obj.propertie,'UniformOutput',0),','); % �����ַ�������[15,2]��Ϊ'15_2'
            
            Color=cellfun(@(x) num2str(x),get(obj.hthis,'Color'),'UniformOutput',0);
            colorStr=cellfun(@(x) regexp(x,'[ ]+', 'split'),Color,'UniformOutput',0);
            colorStr=cellfun(@(x) strjoin(x,','),colorStr,'UniformOutput',0);
            
            str=['BOLL[',pStr,'] ( \color[rgb]{',colorStr{2},'}Up:',sprintf('%8.2f',obj.Data(i,3)),',   \color[rgb]{',colorStr{1},'}Mid:',sprintf('%8.2f',obj.Data(i,2)),',   \color[rgb]{',colorStr{3},'}Down:',sprintf('%8.2f',obj.Data(i,4)),')   '];
        end
    end
    methods (Static)
        function propSet(parent,indObj)
            if nargin==1
                indProp(parent,mfilename,{'����','��׼��'});
            elseif nargin==2
                indProp(parent,mfilename,{'����','��׼��'},indObj);
            end
            disp(['����',mfilename,'�����趨'])
        end
    end
end