function out=SLOPEi(FieldData,Len)
% 计算数据斜率
L=size(FieldData,1);      % 数据长度
if isempty(FieldData)     % 如果数据为空则输出为空
    out=[];
else
    out=[];
    x=repmat([Len:-1:1],L,1);
    y=NaN(L,Len);  
    for i=0:Len-1
        y(Len:end,i+1)=FieldData(Len-i:L-i);
    end
    out=(Len*sum(x.*y,2)-sum(x,2).*sum(y,2))./(Len*sum(x.^2,2)-sum(x,2).^2);
end