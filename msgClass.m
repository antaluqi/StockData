classdef msgClass< event.EventData 
    % �¼�����������
    properties
        msg
    end
    methods
        function obj=msgClass(value)
            obj.msg=value;
        end
    end
end