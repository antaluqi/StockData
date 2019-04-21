function out=PSYi(FieldData,Len,shift)
    if nargin<3
       shift=0;
    end
L=size(FieldData,1);      % ���ݳ���
Close=FieldData;
%-------------------------------------------------------------------------------
if isempty(FieldData)     % �������Ϊ�������Ϊ��
    out=[];
else
   out=[]; 
   for i=1:length(Len) % ÿһ��������ѭ��
        N=Len(i);
        if L<N                       % ������ݳ���С�ڲ���N�������ΪNaN
            out=[out,NaN(L,1)];
        else    
            % ���������������м���
            %-------------------------------------------------------------------------------
            RC=[NaN;Close(2:end)>Close(1:end-1)];
            DataRC=[];
            for j=0:Len-1
                DataRC(:,j+1)=RC(Len-j:L-j);
            end
            CountRCN=NaN(L,1);
            CountRCN(Len:end)=sum(DataRC,2);
            PSY=CountRCN/Len*100;
            out=PSY;
     %-------------------------------------------------------------------------------       
            
        end
   end
end
out=[nan(shift,size(out,2));out(1:end-shift,:)];







