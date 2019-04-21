function out=BIASi(FieldData,LeadLen,LagLen)
    if nargin<4
       shift=0;
    end
L=size(FieldData,1);      % ���ݳ���
if isempty(FieldData)     % �������Ϊ�������Ϊ��
    out=[];
else
    out=[];
    LeadMA=MAi(FieldData,LeadLen);
    LagMA=MAi(FieldData,LagLen);
    bias=100*(LeadMA-LagMA)./LagMA;
    % out=num2cell([out,bias]);
    out=[out,bias];
end
out=[nan(shift,size(out,2));out(1:end-shift,:)];