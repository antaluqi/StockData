function out=SARi(KData,Len,shift)
    if nargin<3
       shift=0;
    end
L=size(KData,1);      % 数据长度
if isempty(KData)     % 如果数据为空则输出为空
    out=[];
else
   out=[]; 
   for i=1:length(Len) % 每一个参数的循环
        N=Len(i);
        if L<N+20                      % 如果数据长度小于参数N则输出都为NaN
            out=[out,NaN(L,1)];
        else    
            % 如果数据正常则进行计算
            %-------------------------------------------------------------------------------
Close=KData(:,3);
High=KData(:,4);
Low=KData(:,5);
HH=HHighi(High,Len);
LL=LLowi(Low,Len);
[~,mini]=min(Low(Len:Len+20));
[~,maxi]=max(High(Len:Len+20));
if abs(mini-10)<abs(maxi-10)
    starti=mini+Len;
else
    starti=maxi+Len;
end
AF=0.02;
SAR=NaN(L,1);
if starti==mini % 首个SAR计算
    SAR(starti)=LL(starti);
    SAR(starti+1)=SAR(starti)+AF*(HH(starti)-SAR(starti));
    type='up';
else
    SAR(starti)=HH(starti);
    SAR(starti+1)=SAR(starti)+AF*(LL(starti)-SAR(starti));
    type='down';
end


for i=starti+1:L-1
    switch type
        case 'up' % 上升通道
            
            if Low(i)<SAR(i) % 翻转为空判断
                SAR(i+1)=HH(i);
                AF=0.02;
                type='down';
            else % 正常上升通道计算
                if HH(i+1)>HH(i) % 判断AF是否增加
                    AF=min(AF+0.02,0.2);
                end
                SAR(i+1)=SAR(i)+AF*(HH(i)-SAR(i));
            end
            
        case 'down'
            if High(i)>SAR(i) % 翻转为多判断
                SAR(i+1)=LL(i);
                AF=0.02;
                type='up';
            else % 正常下降通道计算
                if LL(i+1)<LL(i) % 判断AF是否增加
                    AF=min(AF+0.02,0.2);
                end
                SAR(i+1)=SAR(i)+AF*(LL(i)-SAR(i));
            end
            
    end
end
out=SAR;

     %-------------------------------------------------------------------------------       
            
        end
   end
end
out=[nan(shift,size(out,2));out(1:end-shift,:)];










