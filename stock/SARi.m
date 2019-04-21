function out=SARi(KData,Len,shift)
    if nargin<3
       shift=0;
    end
L=size(KData,1);      % ���ݳ���
if isempty(KData)     % �������Ϊ�������Ϊ��
    out=[];
else
   out=[]; 
   for i=1:length(Len) % ÿһ��������ѭ��
        N=Len(i);
        if L<N+20                      % ������ݳ���С�ڲ���N�������ΪNaN
            out=[out,NaN(L,1)];
        else    
            % ���������������м���
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
if starti==mini % �׸�SAR����
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
        case 'up' % ����ͨ��
            
            if Low(i)<SAR(i) % ��תΪ���ж�
                SAR(i+1)=HH(i);
                AF=0.02;
                type='down';
            else % ��������ͨ������
                if HH(i+1)>HH(i) % �ж�AF�Ƿ�����
                    AF=min(AF+0.02,0.2);
                end
                SAR(i+1)=SAR(i)+AF*(HH(i)-SAR(i));
            end
            
        case 'down'
            if High(i)>SAR(i) % ��תΪ���ж�
                SAR(i+1)=LL(i);
                AF=0.02;
                type='up';
            else % �����½�ͨ������
                if LL(i+1)<LL(i) % �ж�AF�Ƿ�����
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










