function out=SLOPEi(FieldData,Len)
% ��������б��
L=size(FieldData,1);      % ���ݳ���
if isempty(FieldData)     % �������Ϊ�������Ϊ��
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