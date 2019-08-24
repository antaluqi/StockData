classdef GBcMsgReqLink<ReqBase
  % 获取报价的发送消息类
    
    properties
            RspCode
            RspMsg
            again_flag
            branch_id
            cust_type_id
            is_lfv
            lan_ip
            term_type
            user_id
            user_key
            user_pwd
            user_type
            www_ip
    end
    
    methods
        function obj = GBcMsgReqLink()
            obj.RspCode = '';
            obj.RspMsg = '';
            obj.again_flag = '';
            obj.branch_id = '';
            obj.cust_type_id = '';
            obj.is_lfv = '';
            obj.lan_ip = '';
            obj.term_type = '';
            obj.user_id = '';
            obj.user_key = '';
            obj.user_pwd = '';
            obj.user_type = '';
            obj.www_ip = '';
        end

    end
end

