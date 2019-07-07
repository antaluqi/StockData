function [intdata,pos]=get_price(data,pos)
      pos_byte = 6;
      bdata =double(data(pos));
      intdata=double(bitand(bdata,63));
      if bitand(bdata,64)
        sign = 1;
      else
        sign = 0;
      end
      if bitand(bdata,128)
         while 1
             pos=pos+ 1;
             bdata =double(data(pos));
             intdata=intdata+bitshift(bitand(bdata,127),pos_byte);
             pos_byte=pos_byte+7;
             if bitand(bdata,128)
                 
             else
                 break;
             end
           end
      end
      pos=pos+1;
      if sign
          intdata = -intdata;
      end   
end

