function out=get_history_minute_time_data(market,code,data)
  t = tcpip('119.147.212.81', 7709,'NetworkRole','Client');%连接这个ip和这个端口的TCP服务器，60秒超时，缓冲大小10240
   set(t,'InputBufferSize',4500);
   set(t,'Timeout',10);
   fopen(t);
   setup1=[12 2 24 147 0 1 3 0 3 0 13 0 1];
   setup2=[12 2 24 148 0 1 3 0 3 0 13 0 2];
   setup3=[12 3 24 153 0 1 32 0 32 0 219 15 213 208 201 204 214 164 168 175 0 0 0 143 194 37 64 19 0 0 213 0 201 204 189 240 215 234 0 0 0 2];
    fwrite(t,setup1);
    receive = fread(t, 16)';
    zipsize=double(typecast(uint8(receive(end-3:end-2)),'uint16'));
    unzipsize=double(typecast(uint8(receive(end-1:end)),'uint16'));
    body_buf = zlibdecode(uint8(fread(t,zipsize)'));

    fwrite(t,setup2);
    receive = fread(t, 16)';
    zipsize=double(typecast(uint8(receive(end-3:end-2)),'uint16'));
    unzipsize=double(typecast(uint8(receive(end-1:end)),'uint16'));
    body_buf = zlibdecode(uint8(fread(t,zipsize)'));

    fwrite(t,setup3);
    receive = fread(t, 16)';
    zipsize=double(typecast(uint8(receive(end-3:end-2)),'uint16'));
    unzipsize=double(typecast(uint8(receive(end-1:end)),'uint16'));
    body_buf = zlibdecode(uint8(fread(t,zipsize)'));
   cmd=[data,market,double(code)];
   type='IBSSSSSS';
   cmd=[12,1,48,0,1,1,13,0,13,0,180,15,park(cmd,type)];
   fwrite(t,cmd);
   receive = fread(t, 16)';
   zipsize=double(typecast(uint8(receive(end-3:end-2)),'uint16'));
   unzipsize=double(typecast(uint8(receive(end-1:end)),'uint16'));
   if zipsize<16
        out=[];
   else
        body_buf = zlibdecode(uint8(fread(t,zipsize)'));
        pos=1;
        num=double(typecast(body_buf(1:2),'uint16'));
        last_price = 0;
        pos=pos+ 6;
        %prices = [];
        out=[];
        for i=1:num
            [price_raw, pos] = get_price(body_buf, pos);
            [reversed1, pos] = get_price(body_buf, pos);
            [vol, pos] = get_price(body_buf, pos);
            last_price = last_price + price_raw;
            price=double(last_price)/100;
            out=[out;[price,double(vol)]];
        end
   end
   
end