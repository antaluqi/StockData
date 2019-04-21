function out=indicators(Data,type ,ParameterList)
fn=fieldnames(Data); % �����б�
fnL=length(fn);      % �������
hwait=waitbar(0,'��ȴ�>>>>>>>>'); % ʱ��ͳ�ƿ�ʼ
tic
for i=1:fnL % ÿ����Ʊѭ��
    Code=fn{i}                        % ��ȡ����
    KData=eval(['Data.',Code]);  % ��ȡ��ǰ��ƱK������
    if  isempty(KData)  % ���K�����ݲ�Ϊ�գ�������ĵ�һ��Ϊ����
        outData=[];
    else
        outData=KData(:,1);

    for j=1:length(type) % ѭ������ָ��
        switch type{j}
            case 'MA'
                Len=ParameterList{j};
                FieldData=KData(:,3); % ���ڼ�������� ��������ʱĬ��Ϊ���̼�
                mai=MAi(FieldData,Len);
                outData=[outData,mai];
            case 'STD'
                Len=ParameterList{j};
                FieldData=KData(:,3); % ���ڼ�������� ��������ʱĬ��Ϊ���̼�
                stdi=STDi(FieldData,Len);
                outData=[outData,stdi];
            case 'HHigh'
                Len=ParameterList{j};
                FieldData=KData(:,4); % ��߼�
                hhighi=HHighi(FieldData,Len);
                outData=[outData,hhighi];
            case 'LLow'
                Len=ParameterList{j};
                FieldData=KData(:,5); % ��ͼ�
                llowi=LLow(FieldData,Len);
                outData=[outData,llowi];
            case 'EMA'
                Len=ParameterList{j};
                FieldData=KData(:,3); % ���ڼ�������� ��������ʱĬ��Ϊ���̼�
                emai=EMAi(FieldData,Len);
                outData=[outData,emai];
            case 'SMA'
                Len=ParameterList{j};
                FieldData=KData(:,3); % ���ڼ�������� ��������ʱĬ��Ϊ���̼�
                emai=SMAi(FieldData,Len);
                outData=[outData,emai];                
            case 'MACD'
                if length(ParameterList{j})~=3
                    error('MACD ������������')
                end
                LeadLen=ParameterList{j}(1);
                LagLen=ParameterList{j}(2);
                DIFFLen=ParameterList{j}(3);
                FieldData=KData(:,3); % ���ڼ�������� ��������ʱĬ��Ϊ���̼�
                macdi=MACDi(FieldData,LeadLen,LagLen,DIFFLen);
                outData=[outData,macdi];
            case 'BOLL'
                if length(ParameterList{j})==1
                    Len=ParameterList{j}(1);
                    Width=2;
                elseif length(ParameterList{j})==2
                    Len=ParameterList{j}(1);
                    Width=ParameterList{j}(2);
                else
                    error('BOLL ������������')
                end                

                FieldData=KData(:,3); % ���ڼ�������� ��������ʱĬ��Ϊ���̼�
                bolli=BOLLi(FieldData,Len,Width);
                outData=[outData,bolli];
            case 'BIAS'
                if length(ParameterList{j})==1
                    LeadLen=1;
                    LagLen=ParameterList{j}(1);
                elseif length(ParameterList{j})==2
                    LeadLen=ParameterList{j}(1);
                    LagLen=ParameterList{j}(2);
                else
                    error('BOLL ������������')
                end
                FieldData=KData(:,3); % ���ڼ�������� ��������ʱĬ��Ϊ���̼�
                biasi=BIASi(FieldData,LeadLen,LagLen);
                outData=[outData,biasi];     
            case 'KDJ'
                if length(ParameterList{j})~=3
                    error('KDJ ������������')
                end
                Len= ParameterList{j}(1);
                M1=ParameterList{j}(2);
                M2=ParameterList{j}(3);
                kdji=KDJi(KData,Len,M1,M2);
                outData=[outData,kdji];    
            case 'RSI'
                Len= ParameterList{j};
                FieldData=KData(:,3); % ���̼�
                rsii=RSIi(FieldData,Len);
                outData=[outData,rsii];
            case 'OBV'

            case 'LB'
                if isempty( ParameterList{j})
                    Len=5;
                else
                    Len= ParameterList{j};
                end
                FieldData=KData(:,6); % �ɽ���
                lbi=LBi(FieldData,Len);
                outData=[outData,lbi];
            case'SAR'
                Len= ParameterList{j};
                sari=SARi(KData,Len);
                outData=[outData,sari];
            case 'DMI'
                if length(ParameterList{j})~=2
                    error('DMI ������������')
                end
                N= ParameterList{j}(1);
                M= ParameterList{j}(2);
                dmii=DMIi(KData,N,M);
                outData=[outData,dmii];
            case 'CCI'
                Len= ParameterList{j};
                ccii=CCIi(KData,Len);
                outData=[outData,ccii];
            case 'PSY'
                Len= ParameterList{j};
                FieldData=KData(:,3); % �ɽ���
                psyi=PSYi(FieldData,Len);
                outData=[outData,psyi];
            otherwise
        end % switch
    end
    
        % outData=[cellstr(datestr(outData(:,1),'yyyy-mm-dd')),num2cell(outData(:,2:end))];%cell���
        
    end
    eval(['out.',Code,'=outData;']) %�ϲ���Struct������
    waitbar(i/fnL,hwait,[num2str(i/fnL*100),'%',':',Code,',',num2str(i),'/',num2str(fnL)]);% ������
    
end
close(hwait);% �رս�����
toc