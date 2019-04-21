function out=KDJi(KData,Len,M1,M2,shift)
    if nargin<5
       shift=0;
    end
L=size(KData,1);
Close=KData(:,3);
High=KData(:,4);
Low=KData(:,5);

HH=HHighi(High,Len);
LL=LLowi(Low,Len);


RSV=100*(Close-LL)./(HH-LL);
K=SMAi(RSV,M1);
D=SMAi(K,M2);
J=3*K-2*D;
out=[K,D,J];
out=[nan(shift,size(out,2));out(1:end-shift,:)];