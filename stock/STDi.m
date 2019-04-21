function out=STDi(FieldData,Len,shift)
    if nargin<3
       shift=0;
    end
    L=size(FieldData,1);      % 数据长度
    if isempty(FieldData)     % 如果数据为空则输出为空
        out=[];
    else
   out=[]; 
   for i=1:length(Len) % 每一个参数的循环
        N=Len(i);
        if L<N                       % 如果数据长度小于参数N则输出都为NaN
            out=[out,NaN(L,1)];
        else                                 % 如果数据正常则进行计算
            NData=[];  
            for j=0:N-1
                NData(:,j+1)=FieldData(N-j:L-j);
            end
            S=NaN(L,1);
            S(N:end)=std(NData,1,2);
            out=[out,S]; % 输出数据Cell化
        end
   end
   out=[nan(shift,size(out,2));out(1:end-shift,:)];
end