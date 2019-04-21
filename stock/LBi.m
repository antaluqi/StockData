function out=LBi(FieldData,Len,shift)
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
        else    
            % 如果数据正常则进行计算
            %-------------------------------------------------------------------------------

Volume=FieldData;
for j=1:Len
    DataVolume(:,j)=Volume(5-j+1:L-j+1);
end
VolumeLen=NaN(L,1);
VolumeLen(6:end)=sum(DataVolume(1:end-1,:),2);
out=Len*Volume./VolumeLen;

     %-------------------------------------------------------------------------------       
            
        end
   end
end
out=[nan(shift,size(out,2));out(1:end-shift,:)];



