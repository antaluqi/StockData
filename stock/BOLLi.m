function out=BOLLi(FieldData,Len,Width,shift)
    if nargin<4
       shift=0;
    end
L=size(FieldData,1);      % 数据长度
if isempty(FieldData)     % 如果数据为空则输出为空
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