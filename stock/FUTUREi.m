function out=FUTUREi(c,h,l,Len)
% ���㲻ͬ����������̼ۣ���߼ۣ���ͼۣ��Լ���λ��
L=size(c,1);      % ���ݳ���
if isempty(c) || Len>=L    % �������Ϊ�������Ϊ��
    out=[];
else
    vh=[];
    vl=[];
    for i=1:Len
       vh=[vh,[h(i+1:L);NaN(i,1)]];  
       vl=[vl,[l(i+1:L);NaN(i,1)]];  
    end
    [hh,ihh]=max(vh,[],2,'includenan');
    [ll,ill]=min(vl,[],2,'includenan');
    cc=[c(Len+1:L);NaN(Len,1)];
    % �����N����߼ۣ���߼�λ�ã�N����ͼۣ���ͼ�λ�ã�N�����̼ۣ�
    out=[hh,ihh,ll,ill,cc];
end