function out=CMAi(FieldData,Len,shift)
    if nargin<3
       shift=0;
    end
    if length(FieldData)<Len
        out=nan(length(FieldData),1);
    else
        out=MAi(FieldData,Len-1);
        out=[nan(shift,size(out,2));out(1:end-shift,:)];
    end
end

