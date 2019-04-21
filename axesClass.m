classdef axesClass<handle
    %-------------------------------------
    % axesClass.add 增加一个画布
    % axesClass.remove('IndicatorsAxes1') 移除名为IndicatorsAxes1的画布
    % axesClass.axesList 画布句柄列表
    %-------------------------------------
  properties 
      parent        % 父级
      area double   % 所有画布的范围，需要预设
      axesList      % 所有画布句柄列表，动态获取
      axesText      % 所有画布指标显示集合，为containers.Map数据格式
      motionSwitch  % 鼠标移动响应开关
      
  end 
  properties(Access='protected')
      listenerWBM   % 窗口鼠标移动事件监听对象
      listenerWBD   % 窗口鼠标点击事件监听对象
  end
  properties(Access=private)
      CandleAxesAreaY double % CandleAxes与其他axes的Y的比值，需要预设
  end
  methods
      function obj=axesClass(MainFigureObj) % 构造函数
          obj.parent=MainFigureObj;
          obj.area=[0.04,0.96;0.2,0.95];% axes所占据的范围，x[0.04,0.96],y[0.2,0.95]
          obj.CandleAxesAreaY=3;        % CandleAxes与其他axes的Y的比值
          obj.axesText=containers.Map;  % 指标数据显示数组集合
          haxes=axes('Tag','CandleAxes','pos',[obj.area(:,1)',obj.area(:,2)'-obj.area(:,1)'],'parent',obj.parent.hfig,'nextplot','add','xtick',[],'FontSize',7);
         %------------------------------设置Candle画布的指标显示text，并放入axesText集合中
          CandleText=myText(obj.parent);
          CandleText.normPos=[haxes.Position(1),haxes.Position(2)+haxes.Position(4)-0.005];
          CandleText.str='CandleAxes';
          obj.axesText('CandleAxes')=CandleText;
          %------------------------------
          obj.listenerWBD=addlistener(obj.parent,'WindowButtonDown',@obj.Wdown);% 监听鼠标点击事件
          
      end
      function add(obj)                     % 增加一个画布
          i=length(obj.axesList);   % 已有画布数        
          if i==0 % 如果没有画布，则增加一块CandleAxes画布
             axes('Tag','CandleAxes','pos',[obj.area(:,1)',obj.area(:,2)'-obj.area(:,1)'],'parent',obj.parent.hfig,'nextplot','add','xtick',[],'FontSize',7);
             return
          end 
          if i>0  % 如果画布数大于1，则增加一块IndicatorsAxes画布，编号按照顺序排列，已有画布按比例缩小
              CandleAxes=findobj(obj.parent.hfig,'type','axes','tag','CandleAxes');    % CandleAxes画布
              indAxes=findobj(obj.parent.hfig,'type','axes','-not','tag','CandleAxes');% 非CandleAxes画布
              if isempty(CandleAxes)
                  error('缺少主画布CandleAxes')
              end
              % 所有画布的范围
              XStart=obj.area(1,1);
              XEnd=obj.area(1,2);
              YStart=obj.area(2,1);
              YEnd=obj.area(2,2);
              dot=(YEnd-YStart)/(i+obj.CandleAxesAreaY);% 最小比例单位尺度
              CandleAxes.Position=[XStart,YEnd-dot*obj.CandleAxesAreaY,XEnd-XStart,dot*obj.CandleAxesAreaY];% CandleAxes画布位置
              for j=1:i-1 % 重新分配各IndicatorsAxes画布位置和indText的位置（CandleAxes画布的indText位置在顶端，不需要改）
                  indAxes(j).Position=[XStart,YEnd-dot*(j+obj.CandleAxesAreaY),XEnd-XStart,dot];
                  indText=obj.axesText(indAxes(j).Tag);
                  obj.axesText(indAxes(j).Tag)=indText;
                  indText.position=[indAxes(j).Position(1),indAxes(j).Position(2)+indAxes(j).Position(4)-0.005];
              end
              
              if isempty(indAxes) % 按照已有画布名称分配新画布名称
                  tag='IndicatorsAxes1';
              else
                  nameList={indAxes.Tag};
                  for n=1:10
                      if ~any(ismember(nameList,['IndicatorsAxes',num2str(n)]))
                          tag=['IndicatorsAxes',num2str(n)];
                          break
                      end
                  end
              end
              % 生成新画布和新indText
              haxes=axes('Tag',tag,'pos',[XStart,YStart,XEnd-XStart,dot],'parent',obj.parent.hfig,'nextplot','add','xtick',[],'FontSize',7);
              indText=myText(obj.parent);
              indText.normPos=[haxes.Position(1),haxes.Position(2)+haxes.Position(4)-0.005];
              indText.str=tag;
              obj.axesText(tag)=indText;
              if i>0 % 关联各个axes的X轴
                  XLim=CandleAxes.XLim;
                  linkaxes(obj.axesList,'x');
                  CandleAxes.XLim=XLim;
              end
          end
          
      end
      function remove(obj,tag)              % 移除一个画布
          i=length(obj.axesList);% 已有画布数 
          if i==0
              return
          end
          % 检测是否有这个tag命名的画布
          tagAxes=findobj(obj.parent.hfig,'type','axes','tag',tag);
          if isempty(tagAxes)
             error(['没有找到名为',tag,'的画布'])
          end
          
          delete(tagAxes)           % 删除这块画布
          delete(obj.axesText(tag));% 删除这块画布的axesText
          obj.axesText.remove(tag); % 在axesText容器中移除

          i=max(i-1,0); % 画布数减少1（最少为0）
          if i==0       % 到画布数为0时不再操作
              return
          end   
          
          CandleAxes=findobj(obj.parent.hfig,'type','axes','tag','CandleAxes');    % CandleAxes画布句柄
          indAxes=findobj(obj.parent.hfig,'type','axes','-not','tag','CandleAxes');% 非CandleAxes画布句柄
          % 所有画布的范围
          XStart=obj.area(1,1);
          XEnd=obj.area(1,2);
          YStart=obj.area(2,1);
          YEnd=obj.area(2,2);
          % 最小比例单位尺度
          dot=(YEnd-YStart)/(i-1+obj.CandleAxesAreaY);
          CandleAxes.Position=[XStart,YEnd-dot*obj.CandleAxesAreaY,XEnd-XStart,dot*obj.CandleAxesAreaY];% CandleAxes画布位置
          for j=1:i-1 % 重新分配各IndicatorsAxes画布位置和indText的位置（CandleAxes画布的indText位置在顶端，不需要改）
              indAxes(j).Position=[XStart,YEnd-dot*(j+obj.CandleAxesAreaY),XEnd-XStart,dot];
              indText=obj.axesText(indAxes(j).Tag);
              indText.position=[indAxes(j).Position(1),indAxes(j).Position(2)+indAxes(j).Position(4)-0.005];
          end
          
      end
      function value=get.axesList(obj)      % 获取画布handle集合
          if isempty(obj.parent) || isempty(obj.parent.hfig)||~ishandle(obj.parent.hfig)
              value=[];
              return
          end
          value=findobj(obj.parent.hfig,'type','axes');
      end
      %-------------------------------set和get(在protected中实现，可以继承)
      function set.parent(obj,value)        % 父级
          if ~isempty(value)
              validateattributes(value, {'MainFigure'}, {'scalar'});
              obj.parent=value;
          end
          set_parent(obj,value);
      end
      function set.motionSwitch(obj,value)  % 开关-鼠标移动响应
          set_motionSwitch(obj,value);
          obj.motionSwitch=value;
      end
  end
  methods(Access = 'protected')
      function set_parent(obj,value)        % 设置父级 激活开关状态
          obj.motionSwitch=obj.motionSwitch;
      end
      function set_motionSwitch(obj,value)  % 设置开关-鼠标移动响应
          if isempty(obj.parent) || ishandle(obj.parent)
              return
          end
          delete(obj.listenerWBM)
          if value==0
              obj.listenerWBM=[];
          else
              obj.listenerWBM=addlistener(obj.parent,'WindowButtonMotion',@obj.Wmotion);
          end
      end
      function Wmotion(obj,scr,data)        % 屏幕鼠标移动相应程序，通过各指标的getValueStr取得显示文字并组合显示
          pixelPos=get(obj.parent.hfig,'currentpoint');
          coordPos=obj.parent.pixel2coord(pixelPos);
          if isempty(coordPos)
              return
          end
          coordPosX=coordPos(1);
          % 指标对象中axes名称集合（用unique去重复）{'CandleAxes',IndicatorsAxes1,IndicatorsAxes2,...}
          axNa=unique({obj.parent.indObjArr.axesName});
          % 将指标对象按照画布分类d={[1x2 indicationBase],[Voluem]}
          d=cellfun(@(x) obj.parent.indObjArr(strcmp({obj.parent.indObjArr.axesName},x)),axNa,'UniformOutput',0);
          % 分别对d中每组指标运行getValueStr函数取得显示字符串，存储于strcell
          strcell={};
          for i=1:length(d)
              istrcell=strjoin(arrayfun(@(x) x.getValueStr(coordPosX),d{i},'UniformOutput',0));%=========================
              strcell{end+1}=istrcell;
          end
          % 将strcell分配到各axes的myText中去
          myTextObj=cellfun(@(x) obj.axesText(x),axNa,'UniformOutput',0);
          myText=[myTextObj{:}];
          [myText.str]=deal(strcell{:});
      end
      function Wdown(obj,scr,data)          % 屏幕鼠标点击相应程序
          switch (get(gcbf,'SelectionType'))
              case 'open'
                  pixelPos=get(obj.parent.hfig,'currentpoint');
                  coordPos=obj.parent.pixel2coord(pixelPos);
                  d=obj.parent.Data(round(coordPos(1)));
                  pointDate=datestr(d.dates,'yyyy-mm-dd');
                  tick=obj.parent.DataSource.HistoryTick(pointDate);
                  tickFigure=figure ;
                  tickAxes=axes('Tag','tickAxes','parent',tickFigure,'nextplot','add','xtick',[],'FontSize',7);
                  plot(tick.Price,'parent',tickAxes)
          end
      end
      
  end
  
end