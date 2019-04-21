function out=EMAi(FieldData,Len,shift)
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
            %-----------------------------------------------------
            k = 2/(N+ 1); % 指定EMA系数
                        % 计算EMAvalue
            EMAvalue = zeros(length(FieldData), 1);
            EMAvalue(1:N-1) = FieldData(1:N-1);
            
            for j = N:length(FieldData)
                EMAvalue(j) = k*( FieldData(j)-EMAvalue(j-1) ) + EMAvalue(j-1);
            end
            out=[out,EMAvalue]; % 输出数据Cell化
            %-----------------------------------------------------
        end
        
    end
    out=[nan(shift,size(out,2));out(1:end-shift,:)];
end