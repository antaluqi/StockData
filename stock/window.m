function out=window(arr,w)
   out=[];   
   if length(arr)<w
       return;
   end
   out=[];
   for i=0:w-1
       out=[out,[nan(i,1);arr(1:end-i)]];    
   end
   return;


end

