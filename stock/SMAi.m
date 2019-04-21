function out=SMAi(FieldData,Len,shift)
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
            %-----------------------------------------------------
            %k = 2/(N+ 1); % ָ��EMAϵ��
            k = 1/Len; % ָ��SMAϵ�� 
                        % ����SMAvalue
             FieldData(isnan(FieldData))=0;
            SMAvalue = zeros(length(FieldData), 1);
            SMAvalue(1:N-1) = FieldData(1:N-1);
            
            for j = N:length(FieldData)
                SMAvalue(j) = k*( FieldData(j)-SMAvalue(j-1) ) + SMAvalue(j-1);
            end
            out=[out,SMAvalue]; % �������Cell��
            %-----------------------------------------------------
        end
        
    end
    out=[nan(shift,size(out,2));out(1:end-shift,:)];
end