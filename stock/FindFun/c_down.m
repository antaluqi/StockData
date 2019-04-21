function [Val,Title]=c_down(Data)
    date=Data(:,1);
    open=Data(:,2);
    close=Data(:,3);
    high=Data(:,4);
    low=Data(:,5);
    c_up=Data(:,7);
    c_down=Data(:,8);
    r3_mid=Data(:,12);
    r3_up=Data(:,13);
    r3_down=Data(:,14);
    rate=(c_down-[NaN;close(1:end-1)])./[NaN;close(1:end-1)];
    i=open>c_down & low<c_down & r3_down>0.01 & r3_up>0;
    Val=[date,rate,open,low,c_down,r3_down,r3_up];
    Title={'Date','Rate_down','Open','Low','c_down','r3_down','r3_up'};
    Val=Val(i,:);
    