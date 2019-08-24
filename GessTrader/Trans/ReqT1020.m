classdef ReqT1020<ReqBase
  % 获取客户信息的发送类
    
    properties
            acct_no
            is_check_stat
            oper_flag
            qry_cust_info
            qry_defer
            qry_forward
            qry_fund
            qry_storage
            qry_surplus
    end
    
    methods
        function obj = ReqT1020()
            obj.acct_no = '';
            obj.is_check_stat = '1';
            obj.oper_flag = 0;
            obj.qry_cust_info = '0';
            obj.qry_defer = '0';
            obj.qry_forward = '0';
            obj.qry_fund = '0';
            obj.qry_storage = '0';
            obj.qry_surplus = '0';
        end

    end
end

