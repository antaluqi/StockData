function out=FUTUREi(c,h,l,Len)
% 计算不同间隔数据收盘价，最高价，最低价，以及其位置
L=size(c,1);      % 数据长度
if isempty(c) || Len>=L    % 如果数据为空则输出为空
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
    % 输出（N日最高价，最高价位置，N日最低价，最低价位置，N日收盘价）
    out=[hh,ihh,ll,ill,cc];
end