classdef ReqT6002<ReqBase
    % 交易信息查询的发送类
    
    properties
            alm_view_field
            curr_page
            login_branch_id
            login_teller_id
            oper_flag
            paginal_num
            query_id
            prod_code
            exch_code
            b_offset_flag 
    end
    
    methods
        function obj = ReqT6002()
            % public ArrayListMsg alm_view_field = new ArrayListMsg();
            obj.alm_view_field='';
            obj.curr_page = 1;
            obj.login_branch_id ='';
            obj.login_teller_id ='';
            obj.oper_flag = 1;
            obj.paginal_num = 0;
            obj.query_id = '';
            obj.prod_code='';
            obj.exch_code='';
            obj.b_offset_flag='';          
        end

    end
end

