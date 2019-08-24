classdef ReqP4001<ReqBase
    % 交易的发送消息类
    properties
            acct_no
            b_market_id
            bank_no
            bs
            client_serial_no
            cov_type
            cust_id
            deli_flag
            entr_amount
            entr_price
            match_type
            offset_flag
            oper_flag
            order_send_type
            prod_code
            src_match_no
    end
    
    methods
        function obj = ReqP4001()
            obj.acct_no ='';
            obj.b_market_id ='';
            obj.bank_no ='';
            obj.bs ='';
            obj.client_serial_no = '';
            obj.cov_type ='';
            obj.cust_id = '';
            obj.deli_flag = '';
            obj.entr_amount = 0;
            obj.entr_price = '';
            obj. match_type = "1";
            obj.offset_flag = '';
            obj.oper_flag = 1;
            obj.order_send_type = '1';
            obj. prod_code ='';
            obj.src_match_no = '';
        end

    end
end

