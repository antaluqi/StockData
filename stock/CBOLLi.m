function out = CBOLLi(FieldData,Len,Width,shift)
    if nargin<4
       shift=0;
    end
    % 根据当前数据计算的下一个周期收盘价与布林带交叉时候的金额
    if length(FieldData)<Len 
        out=nan(length(FieldData),2);
    else
    w=window(FieldData,Len-1);
    a=(Len-1)^2-(Len-1)*Width^2;
    b=(2*Width^2-2*(Len-1))*sum(w,2);
    c=(1+Width^2)*sum(w,2).^2-Len*Width^2*sum(w.^2,2);
    up=(-b+sqrt(b.^2-4.*a.*c))/(2*a);
    down=(-b-sqrt(b.^2-4.*a.*c))/(2*a);
    out=[up,down];
    out=[nan(shift,size(out,2));out(1:end-shift,:)];
end

