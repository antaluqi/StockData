function out=MAMAi(FieldData,Len1,Len2,shift)
    if nargin<4
       shift=0;
    end
    if length(FieldData)<min(Len1,Len2)
        out=nan(length(FieldData),1);
    else
        M1=MAi(FieldData,Len1-1);
        M2=MAi(FieldData,Len2-1);
        out=(Len1*(Len2-1)*M2-Len2*(Len1-1)*M1)/(Len2-Len1);
        out=[nan(shift,1);out(1:end-shift,:)];
    end

end
