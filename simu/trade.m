classdef trade<handle
    %TRADE �˴���ʾ�йش����ժҪ
    %   �˴���ʾ��ϸ˵��
    
    properties
        code                % ����
        data;               % ����
        s_funds;            % ��ʼ�ʽ�
        s_can_use_funds;    % ��ʼ�����ʽ�
        s_amount;           % ��ʼ֤ȯ����
        s_can_use_amount;   % ��ʼ����֤ȯ����
        
        tdate;              % ��ǰ������
        funds;              % �ʽ�
        can_use_funds;      % �����ʽ�
        amount;             % ֤ȯ����
        can_use_amount;     % ����֤ȯ����
        dealLog             % �ɽ���¼
        entrustsLog         % ί�м�¼
    end
    
    methods
        function obj = trade(code,data)
            obj.code=code;
            obj.data=data;
            obj.s_funds=100000;
            obj.s_can_use_funds=100000;
            obj.s_amount=0;
            obj.s_can_use_amount=0;
            obj.init;
        end
        
        function init(obj)
            obj.funds=obj.s_funds;
            obj.can_use_funds=obj.s_can_use_funds;
            obj.amount=obj.s_amount;
            obj.can_use_amount=obj.s_can_use_amount; 
            obj.tdate=obj.data.Date(1);
            obj.dealLog=[];
            obj.entrustsLog=[];
        end
        
        function set.tdate(obj,value)
                
               if isempty(obj.tdate) || value>obj.tdate
                 obj.can_use_funds=obj.funds;
                 obj.can_use_amount=obj.amount;
               end
                obj.tdate=datetime(value);
        end
        
        function out=buy(obj,dt,money,amt)
            if dt<obj.tdate       % �����ղ���С�����ڽ�����
                disp('�����ղ���С�����ڽ�����')
                obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'����',money,amt,'ʧ��',['������',dt,'����С�����ڽ�����',obj.tdate]}];
                out=0;
                return;
            end

            if ~((dt==obj.tdate && money*amt<=obj.can_use_funds) || (dt>obj.tdate && money*amt<obj.funds)) % �ʽ���빻
                disp('�ʽ���빻')
                obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'����',money,amt,'ʧ��',['�ʽ���빻funds:',num2str(obj.funds),'/can_use_fund:',num2str(obj.can_use_funds),'<money:',num2str(money),'��amt:',num2str(amt)]}];
                out=0;
                return;
            end
            if ~any(dt==obj.data.Date) % �������ڱ�������������
                disp('�������ڱ�������������')
                obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'����',money,amt,'ʧ��','�������ڱ�������������'}];
               out=0;
               return;
            end
            
            
            if money>obj.data.High(dt)|| money<obj.data.Low(dt) % ���׼۸�����ڵ������ݷ�Χ��
              disp('���׼۸�����ڵ������ݷ�Χ��')  
              obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'����',money,amt,'ʧ��',['���׼۸�',num2str(money),'�����ڵ������ݷ�Χ��(Low:',num2str(obj.data.Low(dt)),',High:',num2str(obj.data.High(dt)),')']}];
               out=0;
               return;                
            end
            
            obj.tdate=dt;
            
            obj.funds=obj.funds-money*amt;
            obj.can_use_funds=obj.can_use_funds-money*amt;
            obj.amount=obj.amount+amt;
            obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'����',money,amt,'�ɹ�','null'}];
            obj.dealLog=[obj.dealLog;{obj.tdate,'����',money,amt}];
            out=1;
        end
        
        function out=cell(obj,dt,money,amt)
            if dt<obj.tdate       % �����ղ���С�����ڽ�����
                 disp('�����ղ���С�����ڽ�����')
                 obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'����',money,-amt,'ʧ��',['������',dt,'����С�����ڽ�����',obj.tdate]}];
                out=0;
                return;
            end
            
            if ~any(dt==obj.data.Date) % �������ڱ�������������
                 disp('�������ڱ�������������')
                 obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'����',money,-amt,'ʧ��','�������ڱ�������������'}];
               out=0;
               return;
            end     
            

            if ~((dt==obj.tdate && amt<=obj.can_use_amount) || (dt>obj.tdate && amt<=obj.amount))  % ����֤ȯ�������빻
                 disp('����֤ȯ�������빻')
                 obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'����',money,-amt,'ʧ��',['����֤ȯ����amount:',num2str(obj.amount),'/can_use_funds:',num2str(obj.can_use_amount),'<amt:',num2str(amt)]}];
                out=0;
                return;
            end
            
            if money>obj.data.High(dt)|| money<obj.data.Low(dt) % ���׼۸�����ڵ������ݷ�Χ��
                disp('���׼۸�����ڵ������ݷ�Χ��') 
                obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'����',money,-amt,'ʧ��',['���׼۸�',num2str(money),'�����ڵ������ݷ�Χ��(Low:',num2str(obj.data.Low(dt)),',High:',num2str(obj.data.High(dt)),')']}];
               
               out=0;
               return;                
            end            
            
            obj.tdate=dt;
            obj.amount=obj.amount-amt;
            obj.can_use_amount=obj.can_use_amount-amt;
            obj.funds=obj.funds+money*amt;
            obj.entrustsLog=[obj.entrustsLog;{datetime(dt),'����',money,-amt,'�ɹ�','null'}];
            obj.dealLog=[obj.dealLog;{obj.tdate,'����',money,-amt}];
            out=1;
            
        end
        
        function out=getDealHis(obj)
            out=table2timetable(cell2table(obj.dealLog));
            out.Properties.VariableNames ={'Opt','Price','iAmt'};
            out.Properties.DimensionNames{1}='Date';
            out.Amt=cumsum(out.iAmt);
            out.iMoney=-out.Price.*out.iAmt;
            out.Money=cumsum(out.iMoney)+obj.s_funds;
        end
        
        function out=getEntrustsHis(obj)
            out=table2timetable(cell2table(obj.entrustsLog));
            out.Properties.VariableNames ={'Opt','Price','Amt','Succ','Info'};
            out.Properties.DimensionNames{1}='Date';            
        end
        
        function out=getDayHis(obj)
            out=[];
            dh=obj.getDealHis;
             for i=1:height(dh)
                 if i==1
                     iOut=obj.data(obj.data.Date<dh.Date(i),{'Close'});
                     iOut.Amt=zeros(height(iOut),1);
                     iOut.Money=obj.s_funds*ones(height(iOut),1);
                     out=[out;iOut];
                 else
                     iOut=obj.data(obj.data.Date>=dh.Date(i-1) & obj.data.Date<dh.Date(i),{'Close'});
                     iOut.Amt=ones(height(iOut),1)*dh.Amt(i-1);
                     iOut.Money=dh.Money(i-1)*ones(height(iOut),1);
                     out=[out;iOut];
                 end
             end
             iOut=obj.data(obj.data.Date>=dh.Date(end),{'Close'});
             iOut.Amt=ones(height(iOut),1)*dh.Amt(end);
             iOut.Money=dh.Money(end)*ones(height(iOut),1);
             out=[out;iOut];
             out.Value=out.Money+out.Amt.*out.Close;
             if obj.amount==0
               out=out(obj.entrustsLog{1,1}:obj.tdate,:);
             else
               out=out(obj.entrustsLog{1,1}:obj.data.Date(end),:);  
             end
        end
    end
end

