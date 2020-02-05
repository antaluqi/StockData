classdef MoveBuy<handle
    % �ƶ��������
    
    properties
       code       % ����
       S          % ����Դ
       Date       % ����
       data       % ����
       BASE_P     % �����۸�
       BUY_P      % ��̬����۸�
       buy_P      % ��̬����۸�
       SPACE      % ��̬���ۻ���ռ�
       RESET      % �������׵�ƫ�����ֵ
       space      % ��̬���ۻ���ռ�
       down       % �Ƿ����´�Խ
       WAIT_T       % ��̬��ԥʱ��
       wait_T       % ��̬��ԥʱ��
       buyP_list  % ��̬����۸��
       buy_point  % ������
    end
    
    methods
        function obj = MoveBuy(code)
            obj.code=code;
        end
        
        % ���������趨
        function init(obj)
            obj.BASE_P=obj.data.Price(1);     % ������ �����Ƚϼ۸񣬿�������һ������̼۵�  
            obj.BUY_P=obj.BASE_P*(1-0.00);    % ��������۸�,�����趨Ϊ�����۸��¸����ٱ���
            obj.SPACE=0.001;                  % ���ۻ���ռ䣨���ʣ�
            obj.RESET=0.001;
            obj.WAIT_T=2;                     % �ȴ�ʱ��
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
            obj.buy_P=obj.BUY_P;
            obj.space=obj.SPACE;
            obj.down=0;
            obj.buyP_list=[];
            obj.buy_point={};
            price=obj.data.Price;
            t=timeofday(datetime([datestr(obj.Date,'yyyy-mm-dd'),' 09:30'])+minutes(1:240));
            obj.buy_point={t(end),price(end)};
            obj.wait_T=obj.WAIT_T;
            for i=1:length(price)
                
                if obj.down==-1
                    % �Ѿ�����������
                    obj.buyP_list=[obj.buyP_list,obj.buy_P];
                    continue;
                end
                
                if price(i)>=obj.buy_P && obj.down==0
                      % �۸���ڹ���� & �Ǵ��´�Խ����(�����κζ���)
                    obj.wait_T=obj.WAIT_T;
                elseif  price(i)>=obj.buy_P && obj.down==1 && obj.wait_T>0
                    % �۸���ڻ���ڹ���� & Ϊ���´�Խ���� & ��ԥʱ��δ����ά�ִ�Խ��ǣ���ԥʱ����٣�   
                    obj.down=1;
                    obj.wait_T=obj.wait_T-1;
                    fprintf('��%d��%s����ԥ���۸�%.3f����BUY_P����%.3f��,��BASE_P����%.3f%%(��BUY_P����%.3f%%)\n',i,t(i),price(i),price(i)-obj.BUY_P,(price(i)-obj.BASE_P)/obj.BASE_P*100,(price(i)-obj.BUY_P)/obj.BASE_P*100);

                elseif  price(i)>=obj.buy_P && obj.down==1 && obj.wait_T==0 && (price(i)-obj.BUY_P)/obj.BASE_P<obj.RESET
                    % �۸���ڻ���ڹ���� & Ϊ���´�Խ���� & ��ԥʱ���ѹ� & �۸�ƫ���С����ֵ�����򣬸��Ĵ�Խ��ǣ�
                    obj.down=-1;
                    obj.buy_point={t(i),price(i)};
                    fprintf('��%d��%s�����򣬼۸�%.3f����BUY_P����%.3f��,��BASE_P����%.3f%%(��BUY_P����%.3f%%)\n',i,t(i),price(i),price(i)-obj.BUY_P,(price(i)-obj.BASE_P)/obj.BASE_P*100,(price(i)-obj.BUY_P)/obj.BASE_P*100);
                elseif  price(i)>=obj.buy_P && obj.down==1 && obj.wait_T==0 && (price(i)-obj.BUY_P)/obj.BASE_P>=obj.RESET
                    % �۸���ڻ���ڹ���� & Ϊ���´�Խ���� & ��ԥʱ���ѹ� & �۸�ƫ��ȴ��ڵ�����ֵ���������򣬻�ԭ��
                    obj.down=0;
                    obj.buy_P=obj.BUY_P;
                    obj.wait_T=obj.WAIT_T;
                    fprintf('��%d��%s���۸�ƫ����󣬸�ԭ���۸�%.3f����BUY_P����%.3f��,��BASE_P����%.3f%%(��BUY_P����%.3f%%)\n',i,t(i),price(i),price(i)-obj.BUY_P,(price(i)-obj.BASE_P)/obj.BASE_P*100,(price(i)-obj.BUY_P)/obj.BASE_P*100);
                elseif price(i)<obj.buy_P && price(i)>=obj.buy_P-obj.BASE_P*obj.space
                    % �۸���ڹ���ۣ���δ���ڻ������䣨���Ļ�ά�ִ�Խ��ǣ���ԥʱ�临ԭ��
                    obj.down=1;
                    obj.wait_T=obj.WAIT_T;
                elseif price(i)<obj.buy_P-obj.BASE_P*obj.space
                    % �۸���ڹ����+�����������Ļ�ά�ִ�Խ��ǣ���ԥʱ�临ԭ������۵�����
                    obj.down=1;
                    obj.wait_T=obj.WAIT_T;
                    obj.buy_P=price(i)+obj.BASE_P*obj.space;
                    fprintf('��%d��%s������۸�������۸�%.3f����BUY_P����%.3f��,��BASE_P����%.3f%%(��BUY_P����%.3f%%)\n',i,t(i),price(i),price(i)-obj.BUY_P,(price(i)-obj.BASE_P)/obj.BASE_P*100,(price(i)-obj.BUY_P)/obj.BASE_P*100);

                else
                    fprintf('��%d��%s,�������\n',i,t(i))
                end
                obj.buyP_list=[obj.buyP_list,obj.buy_P];
                
            end
            obj.plot
        end
        
        function plot(obj)
           d=datetime([datestr(obj.Date,'yyyy-mm-dd'),' 09:30']);
           t=timeofday(d+minutes(1:240));
           p=plot(t,obj.data.Price,'-o',t,obj.buyP_list');
           hold on
           plot(obj.buy_point{1},obj.buy_point{2},'r*')
           hold off
           title([obj.code,' ----  ',datestr(obj.Date,'yyyy-mm-dd')]);
        end
    end
end

