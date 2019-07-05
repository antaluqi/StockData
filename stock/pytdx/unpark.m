function out=unpark(data,type)
   if length(strfind(type,'H'))*2+length(strfind(type,'I'))*4+length(strfind(type,'S'))+length(strfind(type,'B'))~=length(data)
       error('���ݳ��������͸�����ƥ��');
   end
   out=[];
   pos=1;
   for i=1:length(type)
       if type(i)=='B'
            out=[out,double(data(pos))];
            pos=pos+1;
       elseif type(i)=='H'
            out=[out,double(typecast(uint8(data(pos:pos+1)),'uint16'))];
            pos=pos+2;
       elseif type(i)=='I'
            out=[out,double(typecast(uint8(data(pos:pos+3)),'uint32'))];
            pos=pos+4;
       elseif type(i)=='S'
            out=[out,double(data(pos))];
            pos=pos+1;
       else
           error(['type:',type(i),'������']);
       end
   end
end