function str=Fill(v_sSrc,v_cFill,v_iLen,v_cDire)
    if length(v_sSrc)>=v_iLen
        str=v_sSrc;
        return;
    end
    str=repmat(v_cFill,1,v_iLen);
    if strcmp(v_cDire,'R')
        str(1:length(v_sSrc))=v_sSrc;
    elseif strcmp(v_cDire,'L')
        str(end-length(v_sSrc)+1:end)=v_sSrc;
    else
        error('fill函数的v_cDire参数输入错误，应该为R或L');
    end

end