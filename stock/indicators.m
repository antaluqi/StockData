function out=indicators(Data,type ,ParameterList)
fn=fieldnames(Data); % 代码列表
fnL=length(fn);      % 代码个数
hwait=waitbar(0,'请等待>>>>>>>>'); % 时间统计开始
tic
for i=1:fnL % 每个股票循环
    Code=fn{i}                        % 获取代码
    KData=eval(['Data.',Code]);  % 获取当前股票K线数据
    if  isempty(KData)  % 如果K线数据不为空，则输出的第一列为日期
        outData=[];
    else
        outData=KData(:,1);

    for j=1:length(type) % 循环计算指标
        switch type{j}
            case 'MA'
                Len=ParameterList{j};
                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                mai=MAi(FieldData,Len);
                outData=[outData,mai];
            case 'STD'
                Len=ParameterList{j};
                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                stdi=STDi(FieldData,Len);
                outData=[outData,stdi];
            case 'HHigh'
                Len=ParameterList{j};
                FieldData=KData(:,4); % 最高价
                hhighi=HHighi(FieldData,Len);
                outData=[outData,hhighi];
            case 'LLow'
                Len=ParameterList{j};
                FieldData=KData(:,5); % 最低价
                llowi=LLow(FieldData,Len);
                outData=[outData,llowi];
            case 'EMA'
                Len=ParameterList{j};
                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                emai=EMAi(FieldData,Len);
                outData=[outData,emai];
            case 'SMA'
                Len=ParameterList{j};
                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                emai=SMAi(FieldData,Len);
                outData=[outData,emai];                
            case 'MACD'
                if length(ParameterList{j})~=3
                    error('MACD 参数个数不对')
                end
                LeadLen=ParameterList{j}(1);
                LagLen=ParameterList{j}(2);
                DIFFLen=ParameterList{j}(3);
                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
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
                    error('BOLL 参数个数不对')
                end                

                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
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
                    error('BOLL 参数个数不对')
                end
                FieldData=KData(:,3); % 用于计算的数据 ，这里暂时默认为收盘价
                biasi=BIASi(FieldData,LeadLen,LagLen);
                outData=[outData,biasi];     
            case 'KDJ'
                if length(ParameterList{j})~=3
                    error('KDJ 参数输入有误')
                end
                Len= ParameterList{j}(1);
                M1=ParameterList{j}(2);
                M2=ParameterList{j}(3);
                kdji=KDJi(KData,Len,M1,M2);
                outData=[outData,kdji];    
            case 'RSI'
                Len= ParameterList{j};
                FieldData=KData(:,3); % 收盘价
                rsii=RSIi(FieldData,Len);
                outData=[outData,rsii];
            case 'OBV'

            case 'LB'
                if isempty( ParameterList{j})
                    Len=5;
                else
                    Len= ParameterList{j};
                end
                FieldData=KData(:,6); % 成交量
                lbi=LBi(FieldData,Len);
                outData=[outData,lbi];
            case'SAR'
                Len= ParameterList{j};
                sari=SARi(KData,Len);
                outData=[outData,sari];
            case 'DMI'
                if length(ParameterList{j})~=2
                    error('DMI 参数输入有误')
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
                FieldData=KData(:,3); % 成交量
                psyi=PSYi(FieldData,Len);
                outData=[outData,psyi];
            otherwise
        end % switch
    end
    
        % outData=[cellstr(datestr(outData(:,1),'yyyy-mm-dd')),num2cell(outData(:,2:end))];%cell输出
        
    end
    eval(['out.',Code,'=outData;']) %合并到Struct变量中
    waitbar(i/fnL,hwait,[num2str(i/fnL*100),'%',':',Code,',',num2str(i),'/',num2str(fnL)]);% 进度条
    
end
close(hwait);% 关闭进度条
toc