classdef myText<handle
   properties
       parent MainFigure  % 父类
       hthis              % text句柄
       haxes              % 作用的画布
       normPos double     % 归一化坐标
       coordPos double    % 画布坐标
       str                % 显示语句
   end
   properties (Access = private)
      normPosNotEmpty
      coordPosNotEmpty
   end
   methods
       function obj=myText(MainFigureObj)   % 构造程序
           obj.parent=MainFigureObj;
           obj.normPosNotEmpty=0;  % 初始normPos为空
           obj.coordPosNotEmpty=0; % 初始coordPos为空
       end
       function set.normPos(obj,value)      % 输入归一化坐标rmP(运行plotnormPos)
           if isempty(value)
               obj.normPosNotEmpty=0;
           else
               obj.normPosNotEmpty=1;
               if length(value)~=2
                   error('坐标输入必须为2个')
               end
           end
             obj.normPos=value;
             obj.plotnormPos;    
       end
       function set.coordPos(obj,value)     % 输入画布坐标（运行plotcoordPos）
           if isempty(value)
               obj.coordPosNotEmpty=0;
           else
               obj.coordPosNotEmpty=1;
               if length(value)~=2
                   error('坐标输入必须为2个')
               end
               if isempty(obj.haxes) || ~ishandle(obj.haxes)
                   error('必须输入axes')
               end
           end
           obj.coordPos=value;
           obj.plotcoordPos;
       end  
       function set.str(obj,value)          % 输入文字（根据实际情况运行运行plotnormPos或plotcoordPos）
           obj.str=value;
           if ~isempty(obj.hthis) && ishandle(obj.hthis)
               obj.hthis.String=value;
           elseif (isempty(obj.hthis) || ~ishandle(obj.hthis)) && ~isempty(obj.normPos) && isempty(obj.haxes)
               obj.plotnormPos;
           elseif (isempty(obj.hthis) || ~ishandle(obj.hthis)) && ~isempty(obj.coordPos) && ~isempty(obj.coordPos)
               obj.plotcoordPos;
           end 
       end       
       function value=get.normPos(obj)      % 获取归一化坐标（如果自身不为空则输出本值，如果为空则检验coordPos和haxes是否为空生成）
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
               warning('myText 缺少haxes')
               return
           end               

       end   
       function value=get.coordPos(obj)     % 获取画布坐标（如果自身不为空则输出本值，如果为空则检验normPos是否为空生成）
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
       end       % 获取显示文字（如果为空则输出x=和y=，如果是lValue则替换为y值，如果是vDate则替换为x值对应的日期，由parent.Data提供）
       function plotnormPos(obj)            % 由normPos定位显示  
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
       function plotcoordPos(obj)           % 由coordPos定位显示  
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
       function delete(obj)                 % 删除
           delete(obj.hthis);
       end      
   end
end