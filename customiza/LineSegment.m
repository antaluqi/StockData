classdef LineSegment<customizaBass
    %-----------------------
    % �߶�
    % LineSegment(f)
    %-----------------------
    properties
    end
    methods
        function obj=LineSegment(hMainFigure) % ���캯��
            obj.type='LineSegment';
            obj.parent=hMainFigure;
            hMainFigure.customizeObjArr=[hMainFigure.customizeObjArr,obj];% ���Է��븸���� 
            obj.stepEnd=2;
            obj.step=0;
            obj.motionSwitch=1;
            obj.buttonSwitch=1;                 
        end
        function calculation(obj)             %�����أ�����
            if isempty(obj.haxes)    % ����Ϊ���򲻼���      
                return
            end
            if ~isempty(obj.normPos) % ������겻Ϊ�������
                switch obj.step % ������ִ�м���
                    case 0 % �״ε��ǰ��ֻ��text��
                        delete(obj.hthis) % ɾ��֮ǰ���ܴ��ڵľ��
                        obj.hthis=[];
                        if isempty(obj.textInfo) % ���texy����Ϊ�����½�
                            obj.textInfo=[myText(obj.parent),myText(obj.parent)];
                        end
                        % �ƶ�����text����������֣�ֻ�ƶ���ʾ��һ�����ڶ���û��ʾ��
                        obj.textInfo(1).str=num2str(roundn(obj.coordPos(2),-2));
                        obj.textInfo(1).haxes=obj.haxes;
                        obj.textInfo(1).coordPos=obj.coordPos;
                        obj.textInfo(2).str='';
                    case 1 % �״ε����һ��������text��
                        obj.haxesFinal=obj.haxes; % ȷ�����û���
                        % ����text����������֣�ֻ�ƶ���ʾ�ڶ�������һ���������ǰ�����ֵ��
                        obj.textInfo(2).str=num2str(roundn(obj.coordPos(2),-2));
                        obj.textInfo(2).haxes=obj.haxes;
                        obj.textInfo(2).coordPos=obj.coordPos;
                        if isempty(obj.hthis) || ~ishandle(obj.hthis) % ���������ߵľ����ʹ��coordPos���꣩
                            obj.hthis=line([obj.textInfo(1).coordPos(1),obj.textInfo(2).coordPos(1)],[obj.textInfo(1).coordPos(2),obj.textInfo(2).coordPos(2)],'parent',obj.haxesFinal);
                        end
                        % �ƶ������ߵ�����
                        obj.hthis.XData=[obj.textInfo(1).coordPos(1),obj.textInfo(2).coordPos(1)];
                        obj.hthis.YData=[obj.textInfo(1).coordPos(2),obj.textInfo(2).coordPos(2)];
                    otherwise
                end
            end
        end
        function plot(obj)                    %�����أ����ƣ��˴����ã�
        end
    end
    methods(Access = 'protected')
        function storeCoord(obj)              %�����أ�����ͼ�εĻ������꣨�˴�ʹ����coordPos���ƣ���������Ϊ�޲�����
        end
        function replot(obj,scr,data)         %�����أ���������ı���ػ棨�˴�ʹ����coordPos���ƣ���������Ϊ�޲�����
        end      
    end
    methods (Static)
        function propSet(parent)
            eval([mfilename,'(parent)']);
            disp(['����',mfilename,'�����趨'])
        end
    end
end