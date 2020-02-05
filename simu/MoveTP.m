classdef MoveTP<handle
   % �ƶ�ֹӯ����
    
    properties
       code       % ����
       S          % ����Դ
       Date       % ����
       data       % ����
       BASE_P     % �����۸�
       SELL_P      % ��̬�����۸�
       sell_P      % ��̬�����۸�
       SPACE      % ��̬�Ӽۻ���ռ�
       space      % ��̬�Ӽۻ���ռ�
       up         % �Ƿ����ϴ�Խ
       WAIT_T       % ��̬��ԥʱ��
       wait_T       % ��̬��ԥʱ��
       sellP_list  % ��̬�����۸��
       sell_point  % ������
    end
    
    methods
        function obj = MoveTP(code)
             obj.code=code;
        end
        
        % ���������趨
        function init(obj)
            obj.BASE_P=obj.data.Price(1);     % ������ �����Ƚϼ۸񣬿�������һ������̼۵�  
            obj.SELL_P=obj.BASE_P*(1+0.01);    % ���������۸�,�����趨Ϊ�����۸��ϸ����ٱ���
            obj.SPACE=0.001;                  % ���ۻ���ռ䣨���ʣ�
            obj.WAIT_T=2;                    % �ȴ�ʱ��
        end
        
        function set.code(obj,value)
            obj.S=Stock(value);
            obj.code=value;
        end
        
        function set.Date(obj,value)
            try
               obj.data=obj.S.HistoryTick(value);
               obj.Date=datetime(value);
            catch
               obj.data=[];
               obj.Date=[];
            end
        end
 
        function Loop(obj,dt)
            obj.Date=dt;
            obj.init;
            obj.sell_P=obj.SELL_P;
            obj.space=obj.SPACE;
            obj.up=0;
            obj.sellP_list=[];
            price=obj.data.Price;
            t=timeofday(datetime([datestr(obj.Date,'yyyy-mm-dd'),' 09:30'])+minutes(1:240));
            obj.sell_point={t(end),price(end)};
            obj.wait_T=obj.WAIT_T;        
            for i=1:length(price)
                if obj.up==-1
                    % �Ѿ�������������
                    obj.sellP_list=[obj.sellP_list,obj.sell_P];
                    continue;
                end 
                
                if price(i)<=obj.sell_P && obj.up==0
                    % �۸���������� & �Ǵ��ϴ�Խ����(�����κζ���)
                    obj.wait_T=obj.WAIT_T;
                elseif price(i)<=obj.sell_P && obj.up==1 && obj.wait_T>0
                    % �۸���ڻ���������� & Ϊ���ϴ�Խ���� & ��ԥʱ��δ����ά�ִ�Խ��ǣ���ԥʱ����٣�
                    obj.up=1;
                    obj.wait_T=obj.wait_T-1;
                    fprintf('��%d��%s����ԥ���۸�%.3f����SELL_P����%.3f��,��BASE_P����%.3f%%(��SELL_P����%.3f%%)\n',i,t(i),price(i),price(i)-obj.SELL_P,(price(i)-obj.BASE_P)/obj.BASE_P*100,(price(i)-obj.SELL_P)/obj.BASE_P*100);

                elseif price(i)<=obj.sell_P && obj.up==1 && obj.wait_T==0
                     % �۸���ڻ���������� & Ϊ���ϴ�Խ���� & ��ԥʱ���ѹ������򣬸��Ĵ�Խ��ǣ�
                    obj.up=-1;
                    obj.sell_point={t(i),price(i)};
                    fprintf('��%d��%s���������۸�%.3f����SELL_P����%.3f��,��BASE_P����%.3f%%(��SELL_P����%.3f%%)\n',i,t(i),price(i),price(i)-obj.SELL_P,(price(i)-obj.BASE_P)/obj.BASE_P*100,(price(i)-obj.SELL_P)/obj.BASE_P*100);
   
                elseif price(i)>obj.sell_P && price(i)<=obj.sell_P+obj.BASE_P*obj.space
                   % �۸���ڹ���ۣ���δ���ڻ������䣨���Ļ�ά�ִ�Խ��ǣ���ԥʱ�临ԭ��
                    obj.up=1;
                    obj.wait_T=obj.WAIT_T;
                elseif price(i)>obj.sell_P+obj.BASE_P*obj.space
                    % �۸���ڹ����+�����������Ļ�ά�ִ�Խ��ǣ���ԥʱ�临ԭ������۵�����
                    obj.up=1;
                    obj.wait_T=obj.WAIT_T;
                    obj.sell_P=price(i)-obj.BASE_P*obj.space;
                    fprintf('��%d��%s�������۸�������۸�%.3f����SELL_P����%.3f��,��BASE_P����%.3f%%(��SELL_P����%.3f%%)\n',i,t(i),price(i),price(i)-obj.SELL_P,(price(i)-obj.BASE_P)/obj.BASE_P*100,(price(i)-obj.SELL_P)/obj.BASE_P*100);

                else
                    disp('�������')
                end
                obj.sellP_list=[obj.sellP_list,obj.sell_P];
            end
            obj.plot
        end
        
        function plot(obj)
           d=datetime([datestr(obj.Date,'yyyy-mm-dd'),' 09:30']);
           t=timeofday(d+minutes(1:240));
           p=plot(t,obj.data.Price,'-o',t,obj.sellP_list');
           hold on
           plot(obj.sell_point{1},obj.sell_point{2},'r*')
           hold off
           title([obj.code,' ----  ',datestr(obj.Date,'yyyy-mm-dd')]);
        end
    end
end

