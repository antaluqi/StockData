function out=CCIi(KData,Len,shift)
    if nargin<3
       shift=0;
    end
L=size(KData,1);      % 数据长度
Close=KData(:,3);
High=KData(:,4);
Low=KData(:,5);

%----------------------------
if isempty(KData)     % 如果数据为空则输出为空
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
            TYP=(High+Low+Close)/3;
            MATYP=MAi(TYP,Len);
            DataTYP=[];
            for j=0:Len-1
                DataTYP(:,j+1)=TYP(Len-j:L-j);
            end
            MD=NaN(L,1);
            MD(Len:end)=mad(DataTYP')';
            CCI=(TYP-MATYP)./(0.015*MD);
            out=CCI;
     %-------------------------------------------------------------------------------       
            
        end
   end
end
out=[nan(shift,size(out,2));out(1:end-shift,:)];
%----------------------------








