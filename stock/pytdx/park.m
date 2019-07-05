function out=park(data,type)
  if length(data)~=length(type)
     error('数据长度与类型个数不匹配');
  end
  out=uint8([]);
  for i=1:length(data)
       if type(i)=='B'
          out=[out,uint8(data(i))];
       elseif type(i)=='H'
          out=[out,typecast(uint16(data(i)),'uint8')];
       elseif type(i)=='I'
          out=[out,typecast(uint32(data(i)),'uint8')];
       elseif type(i)=='S'
          out=[out,uint8(data(i))];
       else
           error(['type:',type(i),'不存在']);
       end
  end

end

