classdef ReqBase<handle
    % 发送类消息基础类
    
    properties

    end
    
    methods
        function obj = ReqBase()

        end
        function str=ToString(obj)
            pList=fieldnames(obj);
            if isempty(pList)
                str='';
                return;
            end
            str='#';
            for i=1:length(pList)
                key=pList{i};
                value=getfield(obj,key);
                str=[str,key,'=',num2str(value),'#'];
            end
        end
    end
end

