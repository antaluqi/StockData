function out=DMIi(KData,N,M,shift)
    if nargin<4
       shift=0;
    end
L=size(KData,1);      % 数据长度
if isempty(KData)     % 如果数据为空则输出为空
    out=[];
else
   out=[]; 
        if L<N                  % 如果数据长度小于参数N则输出都为NaN
            out=[out,NaN(L,1)];
        else    
            % 如果数据正常则进行计算
            %-------------------------------------------------------------------------------
% Close=cell2mat(KData(:,3));
% High=cell2mat(KData(:,4));
% Low=cell2mat(KData(:,5));
Close=KData(:,3);
High=KData(:,4);
Low=KData(:,5);

TR1=High-Low;%当日的最高价减去当日的最低价的价差
TR2=abs(High-[NaN;Close(1:end-1)]);% 当日的最高价减去前一日的收盘价的价差
TR3=abs(Low-[NaN;Close(1:end-1)]);% 当日的最低价减去前一日的收盘价的价差
Temp=max([TR1,TR2,TR3],[],2);% TR 取三者最大值
TR=MAi(Temp,N)*N ;
HD=High-[NaN;High(1:end-1)];
LD=[NaN;Low(1:end-1)]-Low;
Temp=(HD>0 & HD>LD).*HD;
DMP=MAi(Temp,N)*N;
Temp=(LD>0 & LD>HD).*LD;
DMM=MAi(Temp,N)*N;
PDI=DMP*100./TR;
MDI=DMM*100./TR;
Temp=abs(MDI-PDI)./(MDI+PDI)*100;
ADX=MAi(Temp,M);

if L<M
    ADXR=NaN(L,1);
else
    ADXR=(ADX+[NaN(M,1);ADX(1:end-M)])/2;
end
out=[PDI,MDI,ADX,ADXR];
     %-------------------------------------------------------------------------------       
            
        end
end
out=[nan(shift,size(out,2));out(1:end-shift,:)];





















