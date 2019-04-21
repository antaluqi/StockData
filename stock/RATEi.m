function out=RATEi(FieldData,Len,shift)
if nargin<3
   shift=0;
end
% 计算不同间隔数据的收益率
L=size(FieldData,1);      % 数据长度
if isempty(FieldData) || Len>=L     % 如果数据为空则输出为空
    out=nan(size(FieldData,1),size(FieldData,2));
else
    y=FieldData;
    yy=[NaN(Len-1,size(y,2));y(1:L-Len+1,:)];
    out=(y-yy)./yy;
end
out=[nan(shift,size(out,2));out(1:end-shift,:)];