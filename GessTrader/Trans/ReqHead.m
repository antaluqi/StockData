classdef ReqHead<handle
    % 消息头
    properties
            area_code
            branch_id
            c_teller_id1
            c_teller_id2
            exch_code
            msg_flag
            msg_len
            msg_type
            seq_no
            term_type
            user_id
            user_type
    end
    
    methods
        function obj = ReqHead()
            obj.area_code = '';
            obj.branch_id = '';
            obj.c_teller_id1 = '';
            obj.c_teller_id2 = '';
            obj.exch_code = '';
            obj.msg_flag = '';
            obj.msg_len = '';
            obj.msg_type = '';
            obj.seq_no = '';
            obj.term_type = '';
            obj.user_id = '';
            obj.user_type = '';
        end
         
        function seqno=GetSeqNo(obj)
            SEQ_NO=1; % 实际应为在10 以内循环加1
            seqno=[lower(dec2hex(int32(str2double(datestr(now,'HHMMSSFFF'))))),num2str(SEQ_NO)];
            
        end
        
        function str=ToString(obj)
            obj.seq_no=obj.GetSeqNo;
            str=[Fill(obj.seq_no,' ',8,'R'),...
                          Fill(obj.msg_type,' ',1,'R'),...
                          Fill(obj.exch_code,' ',4,'R'),...
                          Fill(obj.msg_flag,' ',1,'R'),...
                          Fill(obj.term_type,' ',2,'R'),...
                          Fill(obj.user_type,' ',2,'R'),...
                          Fill(obj.user_id,' ',10,'R'),...
                          Fill(obj.area_code,' ',4,'R'),...
                          Fill(obj.branch_id,' ',12,'R'),...
                          Fill(obj.c_teller_id1,' ',10,'R'),...
                          Fill(obj.c_teller_id2,' ',10,'R'),...
                          ];
        end
    end
end

