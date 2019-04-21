function out=MAi(FieldData,Len,shift)
    if nargin<3
       shift=0;
    end
    L=size(FieldData,1);      % ���ݳ���
    if isempty(FieldData)     % �������Ϊ�������Ϊ��
        out=[];
    else
       out=[];
       for i=1:length(Len) % ÿһ��������ѭ��
            N=Len(i);
            if L<N                       % ������ݳ���С�ڲ���N�������ΪNaN
                out=[out,NaN(L,1)];
            else                                 % ���������������м���
                NData=[];  
                for j=0:N-1
                    NData(:,j+1)=FieldData(N-j:L-j);
                end
                Avg=NaN(L,1);
                Avg(N:end)=mean(NData,2);
                out=[out,Avg];
            end
       end
       out=[nan(shift,size(out,2));out(1:end-shift,:)];
end