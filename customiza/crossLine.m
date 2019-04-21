classdef crossLine<customizaBass
    % ʮ������
    properties
        midRange % �����ն���С
    end
    methods
        function obj=crossLine(hMainFigure) % ���캯��
            obj.type='crossLine';    % ����
            obj.parent=hMainFigure;  % ����
            obj.midRange=0.01;       % �����ն���С
            obj.motionSwitch=1;      % ����ƶ������� 
            obj.buttonSwitch=0;      % ����������ر�
        end
        function calculation(obj)           %�����أ����㣨�˴�������ͼ��
            if isempty(obj.parent) || isempty(obj.haxes) % �������Ϊ����ɾ���������
                delete(obj.hthis)
                try
                    delete([obj.textInfo.hthis])
                end
                return
            end
            %----------------------------------------------------------����
            if ~isempty(obj.normPos)  % ������㲻Ϊ�յ����������
                area=obj.parent.axesObj.area;
                [left,right,bottom,top]=deal(area(1,1),area(1,2),area(2,1),area(2,2)); %����axes�ķ�Χ
                x=obj.normPos(1); % ����һ������X
                y=obj.normPos(2); % ����һ������Y
                leftlX=[left,x-obj.midRange];     % ����ߵ�X����
                leftlY=[y,y];                     % ����ߵ�Y����
                rightlX=[x+obj.midRange,right];   % �ұ��ߵ�X����
                rightlY=[y,y];                    % �ұ��ߵ�Y����
                bottomvX=[x,x];                   % �±��ߵ�X����
                bottomvY=[bottom,y-obj.midRange]; % �±��ߵ�Y����
                topvX=[x,x];                      % �ϱ��ߵ�X����
                topvY=[y+obj.midRange,top];       % �ϱ��ߵ�Y����
                ltextPos=[right,y];               % �����ұ�text������
                vtextPos=[x,top];                 % �����ϱ�text������
                ltextStr='lValue';                % �����ұ�text�����֣�ʵ�ʵ�Yֵ��
                vtextStr='vDate';                 % �����ϱ�text�����֣�����ֵ��
                %------------------------------------------------------��ͼ
                if isempty(obj.hthis) || all(~ishandle(obj.hthis)) % �״ν���ͼ�ζ���
                    leftl=annotation(obj.parent.hfig,'line',leftlX,leftlY,'tag','left_level');            %�����
                    rightl=annotation(obj.parent.hfig,'line',rightlX,rightlY,'tag','right_level');        %�ұ���
                    bottomv=annotation(obj.parent.hfig,'line',bottomvX,bottomvY,'tag','bottom_vertical'); %�±���
                    topv=annotation(obj.parent.hfig,'line',topvX,topvY,'tag','top_vertical');             %�ϱ���
                    obj.hthis=[leftl,rightl,bottomv,topv]; % ���ͼ�ξ��
                end
                % ֮��ÿ��ֻ��ͼ�ζ����������
                leftl=obj.hthis(1);
                rightl=obj.hthis(2);
                bottomv=obj.hthis(3);
                topv=obj.hthis(4);
                leftl.X=leftlX;
                leftl.Y=leftlY;
                rightl.X=rightlX;
                rightl.Y=rightlY;
                bottomv.X=bottomvX;
                bottomv.Y=bottomvY;
                topv.X=topvX;
                topv.Y=topvY;
                
                if isempty(obj.textInfo)  || all(~ishandle([obj.textInfo.hthis])) % �״ν���text����
                    obj.textInfo=[myText(obj.parent),myText(obj.parent)];
                end
                % ֮��ÿ��ֻ��text����������������
                htext=[obj.textInfo.hthis];
                %[htext.Visible]=deal('on');
                obj.textInfo(1).str=ltextStr;
                obj.textInfo(2).str=vtextStr;
                obj.textInfo(1).normPos=ltextPos;
                obj.textInfo(2).normPos=vtextPos;
                %---------------------------------------------------------
            end
            
        end
        function plot(obj)                  %�����أ���ͼ���˴����ã�    
        end
        function delete(obj)                %�����أ�ɾ��ָ�꣨����һ��CrossLineSwitch=0��
            obj.parent.CrossLineSwitch=0;
            delete(obj.listenerWBM);
            delete(obj.listenerWBD);
            delete(obj.listenerLC);
            delete(obj.hthis);
            obj.beDestroied=1;
        end
    end
    methods(Access = 'protected')
        function set_motionSwitch(obj,value)% ����ƶ���������
            set_motionSwitch@customizaBass(obj,value);
            if value==0
                delete(obj.hthis)
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