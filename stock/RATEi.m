function out=RATEi(FieldData,Len,shift)
if nargin<3
   shift=0;
end
% ���㲻ͬ������ݵ�������
L=size(FieldData,1);      % ���ݳ���
if isempty(FieldData) || Len>=L     % �������Ϊ�������Ϊ��
    out=nan(size(FieldData,1),size(FieldData,2));
else
    y=FieldData;
    yy=[NaN(Len-1,size(y,2));y(1:L-Len+1,:)];
    out=(y-yy)./yy;
end
out=[nan(shift,size(out,2));out(1:end-shift,:)];