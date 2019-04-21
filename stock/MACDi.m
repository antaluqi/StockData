function out=MACDi(FieldData,LeadLen,LagLen,DIFFLen,shift)
    if nargin<5
       shift=0;
    end
    L=size(FieldData,1);      % 数据长度
 if isempty(FieldData)     % 如果数据为空则输出为空
        out=[];
 else
    out=[];
    %-------------------------------------------------------
    LeadEMA=EMAi(FieldData,LeadLen);
    LagEMA=EMAi(FieldData,LagLen);
    DIFF=LeadEMA-LagEMA;
    DEA=EMAi(DIFF,DIFFLen);
    MACD=2*(DIFF-DEA);
    %-------------------------------------------------------
    out=[DIFF,DEA,MACD];
    out=[nan(shift,size(out,2));out(1:end-shift,:)];
end