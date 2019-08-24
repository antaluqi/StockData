classdef ReqT8002<ReqBase
    % 关闭发送的消息类
    properties
        oper_flag
        user_id
        user_type
    end
    
    methods
        function obj = ReqT8002()
            obj.oper_flag='0';
            obj.user_id='';
            obj.user_type='';
        end
    end
end

