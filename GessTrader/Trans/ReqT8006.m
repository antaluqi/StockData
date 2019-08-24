classdef ReqT8006<ReqBase
    % 登陆的发送消息类
    properties
        bank_no
        login_ip
        net_agent
        net_envionment
        oper_flag
        user_id
        user_id_type
        user_pwd
        user_type
    end
    
    methods
        function obj = ReqT8006()
            obj.bank_no = '';
            obj.login_ip = '';
            obj.net_agent = '';
            obj.net_envionment = '';
            obj.oper_flag = '0';
            obj.user_id = '';
            obj.user_id_type = '';
            obj.user_pwd = '';
            obj.user_type = '';
        end

    end
end

