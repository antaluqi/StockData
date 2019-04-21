classdef msgClass< event.EventData 
    % 事件传递数据类
    properties
        msg
    end
    methods
        function obj=msgClass(value)
            obj.msg=value;
        end
    end
end