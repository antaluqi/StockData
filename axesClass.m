classdef axesClass<handle
    %-------------------------------------
    % axesClass.add ����һ������
    % axesClass.remove('IndicatorsAxes1') �Ƴ���ΪIndicatorsAxes1�Ļ���
    % axesClass.axesList ��������б�
    %-------------------------------------
  properties 
      parent        % ����
      area double   % ���л����ķ�Χ����ҪԤ��
      axesList      % ���л�������б���̬��ȡ
      axesText      % ���л���ָ����ʾ���ϣ�Ϊcontainers.Map���ݸ�ʽ
      motionSwitch  % ����ƶ���Ӧ����
      
  end 
  properties(Access='protected')
      listenerWBM   % ��������ƶ��¼���������
      listenerWBD   % ����������¼���������
  end
  properties(Access=private)
      CandleAxesAreaY double % CandleAxes������axes��Y�ı�ֵ����ҪԤ��
  end
  methods
      function obj=axesClass(MainFigureObj) % ���캯��
          obj.parent=MainFigureObj;
          obj.area=[0.04,0.96;0.2,0.95];% axes��ռ�ݵķ�Χ��x[0.04,0.96],y[0.2,0.95]
          obj.CandleAxesAreaY=3;        % CandleAxes������axes��Y�ı�ֵ
          obj.axesText=containers.Map;  % ָ��������ʾ���鼯��
          haxes=axes('Tag','CandleAxes','pos',[obj.area(:,1)',obj.area(:,2)'-obj.area(:,1)'],'parent',obj.parent.hfig,'nextplot','add','xtick',[],'FontSize',7);
         %------------------------------����Candle������ָ����ʾtext��������axesText������
          CandleText=myText(obj.parent);
          CandleText.normPos=[haxes.Position(1),haxes.Position(2)+haxes.Position(4)-0.005];
          CandleText.str='CandleAxes';
          obj.axesText('CandleAxes')=CandleText;
          %------------------------------
          obj.listenerWBD=addlistener(obj.parent,'WindowButtonDown',@obj.Wdown);% ����������¼�
          
      end
      function add(obj)                     % ����һ������
          i=length(obj.axesList);   % ���л�����        
          if i==0 % ���û�л�����������һ��CandleAxes����
             axes('Tag','CandleAxes','pos',[obj.area(:,1)',obj.area(:,2)'-obj.area(:,1)'],'parent',obj.parent.hfig,'nextplot','add','xtick',[],'FontSize',7);
             return
          end 
          if i>0  % �������������1��������һ��IndicatorsAxes��������Ű���˳�����У����л�����������С
              CandleAxes=findobj(obj.parent.hfig,'type','axes','tag','CandleAxes');    % CandleAxes����
              indAxes=findobj(obj.parent.hfig,'type','axes','-not','tag','CandleAxes');% ��CandleAxes����
              if isempty(CandleAxes)
                  error('ȱ��������CandleAxes')
              end
              % ���л����ķ�Χ
              XStart=obj.area(1,1);
              XEnd=obj.area(1,2);
              YStart=obj.area(2,1);
              YEnd=obj.area(2,2);
              dot=(YEnd-YStart)/(i+obj.CandleAxesAreaY);% ��С������λ�߶�
              CandleAxes.Position=[XStart,YEnd-dot*obj.CandleAxesAreaY,XEnd-XStart,dot*obj.CandleAxesAreaY];% CandleAxes����λ��
              for j=1:i-1 % ���·����IndicatorsAxes����λ�ú�indText��λ�ã�CandleAxes������indTextλ���ڶ��ˣ�����Ҫ�ģ�
                  indAxes(j).Position=[XStart,YEnd-dot*(j+obj.CandleAxesAreaY),XEnd-XStart,dot];
                  indText=obj.axesText(indAxes(j).Tag);
                  obj.axesText(indAxes(j).Tag)=indText;
                  indText.position=[indAxes(j).Position(1),indAxes(j).Position(2)+indAxes(j).Position(4)-0.005];
              end
              
              if isempty(indAxes) % �������л������Ʒ����»�������
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
              % �����»�������indText
              haxes=axes('Tag',tag,'pos',[XStart,YStart,XEnd-XStart,dot],'parent',obj.parent.hfig,'nextplot','add','xtick',[],'FontSize',7);
              indText=myText(obj.parent);
              indText.normPos=[haxes.Position(1),haxes.Position(2)+haxes.Position(4)-0.005];
              indText.str=tag;
              obj.axesText(tag)=indText;
              if i>0 % ��������axes��X��
                  XLim=CandleAxes.XLim;
                  linkaxes(obj.axesList,'x');
                  CandleAxes.XLim=XLim;
              end
          end
          
      end
      function remove(obj,tag)              % �Ƴ�һ������
          i=length(obj.axesList);% ���л����� 
          if i==0
              return
          end
          % ����Ƿ������tag�����Ļ���
          tagAxes=findobj(obj.parent.hfig,'type','axes','tag',tag);
          if isempty(tagAxes)
             error(['û���ҵ���Ϊ',tag,'�Ļ���'])
          end
          
          delete(tagAxes)           % ɾ����黭��
          delete(obj.axesText(tag));% ɾ����黭����axesText
          obj.axesText.remove(tag); % ��axesText�������Ƴ�

          i=max(i-1,0); % ����������1������Ϊ0��
          if i==0       % ��������Ϊ0ʱ���ٲ���
              return
          end   
          
          CandleAxes=findobj(obj.parent.hfig,'type','axes','tag','CandleAxes');    % CandleAxes�������
          indAxes=findobj(obj.parent.hfig,'type','axes','-not','tag','CandleAxes');% ��CandleAxes�������
          % ���л����ķ�Χ
          XStart=obj.area(1,1);
          XEnd=obj.area(1,2);
          YStart=obj.area(2,1);
          YEnd=obj.area(2,2);
          % ��С������λ�߶�
          dot=(YEnd-YStart)/(i-1+obj.CandleAxesAreaY);
          CandleAxes.Position=[XStart,YEnd-dot*obj.CandleAxesAreaY,XEnd-XStart,dot*obj.CandleAxesAreaY];% CandleAxes����λ��
          for j=1:i-1 % ���·����IndicatorsAxes����λ�ú�indText��λ�ã�CandleAxes������indTextλ���ڶ��ˣ�����Ҫ�ģ�
              indAxes(j).Position=[XStart,YEnd-dot*(j+obj.CandleAxesAreaY),XEnd-XStart,dot];
              indText=obj.axesText(indAxes(j).Tag);
              indText.position=[indAxes(j).Position(1),indAxes(j).Position(2)+indAxes(j).Position(4)-0.005];
          end
          
      end
      function value=get.axesList(obj)      % ��ȡ����handle����
          if isempty(obj.parent) || isempty(obj.parent.hfig)||~ishandle(obj.parent.hfig)
              value=[];
              return
          end
          value=findobj(obj.parent.hfig,'type','axes');
      end
      %-------------------------------set��get(��protected��ʵ�֣����Լ̳�)
      function set.parent(obj,value)        % ����
          if ~isempty(value)
              validateattributes(value, {'MainFigure'}, {'scalar'});
              obj.parent=value;
          end
          set_parent(obj,value);
      end
      function set.motionSwitch(obj,value)  % ����-����ƶ���Ӧ
          set_motionSwitch(obj,value);
          obj.motionSwitch=value;
      end
  end
  methods(Access = 'protected')
      function set_parent(obj,value)        % ���ø��� �����״̬
          obj.motionSwitch=obj.motionSwitch;
      end
      function set_motionSwitch(obj,value)  % ���ÿ���-����ƶ���Ӧ
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
      function Wmotion(obj,scr,data)        % ��Ļ����ƶ���Ӧ����ͨ����ָ���getValueStrȡ����ʾ���ֲ������ʾ
          pixelPos=get(obj.parent.hfig,'currentpoint');
          coordPos=obj.parent.pixel2coord(pixelPos);
          if isempty(coordPos)
              return
          end
          coordPosX=coordPos(1);
          % ָ�������axes���Ƽ��ϣ���uniqueȥ�ظ���{'CandleAxes',IndicatorsAxes1,IndicatorsAxes2,...}
          axNa=unique({obj.parent.indObjArr.axesName});
          % ��ָ������ջ�������d={[1x2 indicationBase],[Voluem]}
          d=cellfun(@(x) obj.parent.indObjArr(strcmp({obj.parent.indObjArr.axesName},x)),axNa,'UniformOutput',0);
          % �ֱ��d��ÿ��ָ������getValueStr����ȡ����ʾ�ַ������洢��strcell
          strcell={};
          for i=1:length(d)
              istrcell=strjoin(arrayfun(@(x) x.getValueStr(coordPosX),d{i},'UniformOutput',0));%=========================
              strcell{end+1}=istrcell;
          end
          % ��strcell���䵽��axes��myText��ȥ
          myTextObj=cellfun(@(x) obj.axesText(x),axNa,'UniformOutput',0);
          myText=[myTextObj{:}];
          [myText.str]=deal(strcell{:});
      end
      function Wdown(obj,scr,data)          % ��Ļ�������Ӧ����
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