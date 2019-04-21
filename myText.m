classdef myText<handle
   properties
       parent MainFigure  % ����
       hthis              % text���
       haxes              % ���õĻ���
       normPos double     % ��һ������
       coordPos double    % ��������
       str                % ��ʾ���
   end
   properties (Access = private)
      normPosNotEmpty
      coordPosNotEmpty
   end
   methods
       function obj=myText(MainFigureObj)   % �������
           obj.parent=MainFigureObj;
           obj.normPosNotEmpty=0;  % ��ʼnormPosΪ��
           obj.coordPosNotEmpty=0; % ��ʼcoordPosΪ��
       end
       function set.normPos(obj,value)      % �����һ������rmP(����plotnormPos)
           if isempty(value)
               obj.normPosNotEmpty=0;
           else
               obj.normPosNotEmpty=1;
               if length(value)~=2
                   error('�����������Ϊ2��')
               end
           end
             obj.normPos=value;
             obj.plotnormPos;    
       end
       function set.coordPos(obj,value)     % ���뻭�����꣨����plotcoordPos��
           if isempty(value)
               obj.coordPosNotEmpty=0;
           else
               obj.coordPosNotEmpty=1;
               if length(value)~=2
                   error('�����������Ϊ2��')
               end
               if isempty(obj.haxes) || ~ishandle(obj.haxes)
                   error('��������axes')
               end
           end
           obj.coordPos=value;
           obj.plotcoordPos;
       end  
       function set.str(obj,value)          % �������֣�����ʵ�������������plotnormPos��plotcoordPos��
           obj.str=value;
           if ~isempty(obj.hthis) && ishandle(obj.hthis)
               obj.hthis.String=value;
           elseif (isempty(obj.hthis) || ~ishandle(obj.hthis)) && ~isempty(obj.normPos) && isempty(obj.haxes)
               obj.plotnormPos;
           elseif (isempty(obj.hthis) || ~ishandle(obj.hthis)) && ~isempty(obj.coordPos) && ~isempty(obj.coordPos)
               obj.plotcoordPos;
           end 
       end       
       function value=get.normPos(obj)      % ��ȡ��һ�����꣨�������Ϊ���������ֵ�����Ϊ�������coordPos��haxes�Ƿ�Ϊ�����ɣ�
           if obj.normPosNotEmpty==0 && obj.coordPosNotEmpty==0 
               value=[];
               return
           end
           if obj.normPosNotEmpty==1
               value=obj.normPos;
               return
           end     
           if obj.normPosNotEmpty==0 && obj.coordPosNotEmpty==1 && ~isempty(obj.haxes)
               value=obj.parent.coord2norm(obj.coordPos,obj.haxes.Tag);
               return
           end    
           if obj.normPosNotEmpty==0 && obj.coordPosNotEmpty==1 && isempty(obj.haxes)
               value=[];
               warning('myText ȱ��haxes')
               return
           end               

       end   
       function value=get.coordPos(obj)     % ��ȡ�������꣨�������Ϊ���������ֵ�����Ϊ�������normPos�Ƿ�Ϊ�����ɣ�
           if obj.normPosNotEmpty==0 && obj.coordPosNotEmpty==0 
               value=[];
               return
           end
           if obj.coordPosNotEmpty==1
               value=obj.coordPos;
               return
           end     
           if obj.normPosNotEmpty==1 && obj.coordPosNotEmpty==0 
               value=obj.parent.norm2coord(obj.normPos);
               return
           end             
       end        
       function value=get.str(obj)
                if isempty(obj.coordPos)
                    value=obj.str;
                    return
                end
                if isempty(obj.str)
                    value=['x=',num2str(obj.coordPos(1)),',y=',num2str(obj.coordPos(2))];
                    return
                end
                coordX=max(min(round(obj.coordPos(1)),size(obj.parent.Data,1)),1);
                strGet=strrep(obj.str,'vDate',datestr(obj.parent.Data.dates(coordX),'yyyy-mm-dd'));
                strGet=strrep(strGet,'lValue',mat2str(roundn(obj.coordPos(2),-2)));
                value=strGet; 
       end       % ��ȡ��ʾ���֣����Ϊ�������x=��y=�������lValue���滻Ϊyֵ�������vDate���滻Ϊxֵ��Ӧ�����ڣ���parent.Data�ṩ��
       function plotnormPos(obj)            % ��normPos��λ��ʾ  
           if isempty(obj.normPos)
               return
           end
           if isempty(obj.hthis) || ~ishandle(obj.hthis) || ~isa(obj.hthis,'matlab.graphics.shape.TextBox')
               delete(obj.hthis)
               obj.hthis=annotation(obj.parent.hfig,'textbox',[obj.normPos,0,0],'String',{obj.str},'FitBoxToText','on','EdgeColor','none','FontSize',8,'VerticalAlignment','top');
           else
               obj.hthis.Position=[obj.normPos,0,0];
               obj.hthis.String={obj.str};
           end
           
       end 
       function plotcoordPos(obj)           % ��coordPos��λ��ʾ  
            if isempty(obj.coordPos) || isempty(obj.haxes) || ~ishandle(obj.haxes)
               return
            end 
            if isempty(obj.hthis) || ~ishandle(obj.hthis) || ~isa(obj.hthis,'matlab.graphics.primitive.Text')
                delete(obj.hthis)
                obj.hthis=text(obj.coordPos(1),obj.coordPos(2),obj.str,'parent',obj.haxes,'FontSize',8,'VerticalAlignment','top');
            else
                obj.hthis.Parent=obj.haxes;
                obj.hthis.Position=obj.coordPos;
                obj.hthis.String=obj.str;
            end
            
           
       end
       function delete(obj)                 % ɾ��
           delete(obj.hthis);
       end      
   end
end