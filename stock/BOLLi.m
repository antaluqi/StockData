function out=BOLLi(FieldData,Len,Width,shift)
    if nargin<4
       shift=0;
    end
L=size(FieldData,1);      % ���ݳ���
if isempty(FieldData)     % �������Ϊ�������Ϊ��
    out=[];
else
    out=[];
    ma=MAi(FieldData,Len);
    std=STDi(FieldData,Len);
    bollup=ma+Width*std;
    bolldown=ma-Width*std; 
    out=[out,ma,bollup,bolldown];
end
out=[nan(shift,size(out,2));out(1:end-shift,:)];