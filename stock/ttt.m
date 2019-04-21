
%% =====================================================
% 新浪分笔数据？？？？？？？？？？？？？？？？？
% http://vip.stock.finance.sina.com.cn/quotes_service/view/CN_TransListV2.php?num=90000&symbol=sh000001



% http://www.aigaogao.com/tools/default.html 
% 未开发接口：http://stock.gtimg.cn/data/view/ggdx.php?t=3&d=20&q=sh600503 大单 中单 小单
% 几个接口的介绍 http://www.cnblogs.com/ibearpig/p/3646004.html18
% http://market.finance.sina.com.cn/downxls.php?date=2015-06-24&symbol=sh600415 % 新浪历史每日分时图
% http://chagu.dingniugu.com/chaoying/cy.php?id=5 超赢数据接口（全部sh股票实时） 详细数据解释看 http://chagu.dingniugu.com/chaoying/index.asp
% 新浪期货数据接口介绍 http://www.360doc.com/content/13/1009/14/3840306_320076250.shtml
%% 获取最新盘口数据===========================================
clear
clc
% 股票代码
Code={'sh600415','sh600795','sz000725','sh600008','sh600383','sz002123'}; 
% 腾讯数据接口地址开头
urlHead='http://qt.gtimg.cn/q='
% 将代码转换成地址组成部分
C=strcat(Code,',');
urlAddress=strcat(urlHead,[C{:}]);
% 读取网页信息
[sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
if ~status
    error('读取错误\n')
end
% 正则表达式(将股票信息列表化方便逐个操作)
expr1='(?<=v_)(.*?)(?=";)';
[datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
sourcefile=[date_tokens{:}]';
% 逐行提取信息
for i=1:length(sourcefile)
    % 正则表达式(提取关键内容)
   expr1='(?<==")(.*)';
   [datefile, date_tokens]= regexp(sourcefile{i}, expr1, 'match', 'tokens');
   sourcefile2=date_tokens{:};
    % 分割信息
   ss=regexp(sourcefile2, '~', 'split');
    % 组合提取的信息
   S(i,:)=ss{:};
end
% 标题
title={'未知','名字','代码','当前价格','昨收','今开','成交量（手）','外盘','内盘','买一','买一量（手）','买二','买二量（手）','买三'...
        ,'买三量（手）','买四','买四量（手）','买五','买五量（手）','卖一','卖一量（手）','卖二','卖二量（手）','卖三','卖三量（手）'...
        ,'卖四','卖四量（手）','卖五','卖五量（手）','最近逐笔成交','时间','涨跌','涨跌%','最高','最低','价格/成交量（手）/成交额','成交量（手）'...
        ,'成交额（万）','换手率','市盈率','[blank]','最高','最低','振幅','流通市值','总市值','市净率','涨停价','跌停价','[blank]'};
% 将标题与信息组合
S=[title',S']

%% 获取实时资金流向：============================================================================================
clear
clc
% 股票代码
Code={'sh600415','sh600795','sz000725','sh600008','sh600383','sz002123'}; 
% 腾讯数据接口地址开头
urlHead='http://qt.gtimg.cn/q='
% 将代码转换成地址组成部分
C=strcat('ff_',Code,',');
urlAddress=strcat(urlHead,[C{:}]);
% 读取网页信息
[sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
if ~status
    error('读取错误\n')
end
% 正则表达式(将股票信息列表化方便逐个操作)
expr1='(?<=v_)(.*?)(?=";)';
[datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
sourcefile=[date_tokens{:}]';
for i=1:length(sourcefile)
    expr1='(?<=="s[hz])(.*)';
    [datefile, date_tokens]= regexp(sourcefile{i}, expr1, 'match', 'tokens');
     sourcefile2=date_tokens{:};
    % 分割信息
    ss=regexp(sourcefile2, '~', 'split');
    % 组合提取的信息
    S(i,:)=ss{:};
end
  title={'代码','主力流入','主力流出','主力净流入','主力净流入/资金流入流出总和','散户流入','散户流出','散户净流入','散户净流入/资金流入流出总和',...
              '资金流入流出总和1+2+5+6','未知','未知','名字','日期','未知','未知','未知','未知'};
   % colnames={'StockCode','MainInflow','MainOutflow','MainNetInflow','MainNetInflow/MainTotal','RetailInflow','RetailOutflow','RetailNetInflow','RetailNetInflow/RetailTotal','TotalFund','unknow1','unknow2','StockName','LastTime','unknow3','unknow4','unknow5','unknow6'};
   
   S=[title',S']
%% 获取盘口分析：============================================================================================
clear
clc
% 股票代码
Code={'sh600415','sh600795','sz000725','sh600008','sh600383','sz002123'}; 
% 腾讯数据接口地址开头
urlHead='http://qt.gtimg.cn/q='
% 将代码转换成地址组成部分
C=strcat('s_pk',Code,',');
urlAddress=strcat(urlHead,[C{:}]);
% 读取网页信息
[sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
if ~status
    error('读取错误\n')
end
% 正则表达式(将股票信息列表化方便逐个操作)
expr1='(?<=v_)(.*?)(?=";)';
[datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
sourcefile=[date_tokens{:}]';
% 逐行提取信息
for i=1:length(sourcefile)
    expr1='(?<=s[hz])(.*?)(?==")';
    [datefile, date_tokens]= regexp(sourcefile{i}, expr1, 'match', 'tokens');
    Shead=[date_tokens{:}];
    expr1='(?<==")(.*)';
    [datefile, date_tokens]= regexp(sourcefile{i}, expr1, 'match', 'tokens');
     ss=date_tokens{:};
     ss = regexp(ss, '~', 'split');
     S(i,:)=[Shead,ss{:}];
end
 title={'代码','买盘大单','买盘小单','卖盘大单','卖盘小单'};
 % colnames={'StockCode','BuyLargeQuantity','BuySmallQuantity','SellLargeQuantity','SellSmallQuantity'};
 S=[title',S']
%% 获取简要信息:================================================================================================================= 

% clear
% clc
% 股票代码
Code={'sh600415','sh600795','sz000725','sh600008','sh600383','sz002123'}; 
Code=a
%Code={'sh600123'};
% 腾讯数据接口地址开头
urlHead='http://qt.gtimg.cn/q=';
% 将代码转换成地址组成部分
C=strcat('s_',Code,',');
urlAddress=strcat(urlHead,[C{:}])
% 读取网页信息
[sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
if isempty(sourcefile)
    error('没有此股票数据')
end
if ~status
    error('读取错误\n')
end
% 正则表达式(将股票信息列表化方便逐个操作)
expr1='(?<=v_)(.*?)(?=";)';
[datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
sourcefile=[date_tokens{:}]';
if isempty(sourcefile)
    error('没有此股票数据')
end
% 逐行提取信息
for i=1:length(sourcefile)
    % 正则表达式(提取关键内容)
   expr1='(?<==")(.*)';
   [datefile, date_tokens]= regexp(sourcefile{i}, expr1, 'match', 'tokens');
   sourcefile2=date_tokens{:};
    % 分割信息
   ss=regexp(sourcefile2, '~', 'split');
    % 组合提取的信息
   S(i,:)=ss{:};

end
  title={'未知','名字','代码','当前价格','涨跌','涨跌%','成交量(手)','成交量(万)','[blank]','总市值'};
  % colnames={'unknow1','StockName','StockCode','RealPrice','Rise','Yield','Volume','Amount','blank1','TotalMarketValue'};
  S=[title',S']
 




%% ========================================================================
% 各数据接口测试
% clear
% clc
code='sh600118';
%url=['http://data.gtimg.cn/flashdata/hushen/4day/sh/',code,'.js?'] % 腾讯1分钟数据接口（近5日）
%url=['http://vip.stock.finance.sina.com.cn/quotes_service/view/CN_TransListV2.php?num=90000&symbol=',code] % 新浪当日分笔数据？？?
%url=['http://vip.stock.finance.sina.com.cn/q/view/download_gold_history.php?breed=AGTD&start=2015-01-01&end=2015-06-28'];%贵金属接口
%url=['http://money.finance.sina.com.cn/quotes_service/api/json_v2.php/CN_MarketData.getKLineData?symbol=',code,'&scale=5&ma=no&datalen=1023'] % 最近 5 15 30 60 分钟数据
 %url=['http://data.gtimg.cn/flashdata/hushen/monthly/',code,'.js?'] %  腾讯周线数据接口
 %url=[' http://market.finance.sina.com.cn/downxls.php?date=2015-06-25&symbol=',code] % 新浪历史逐笔明细
% url=['http://biz.finance.sina.com.cn/stock/flash_hq/kline_data.php?symbol=',code,'&end_date=20150726&begin_date=20150101'] % 新浪K线数据
 %url=['http://data.gtimg.cn/flashdata/hushen/daily/15/',code,'.js?maxage=43201'] % 腾讯日K线数据
 %url=['http://quotes.money.163.com/service/chddata.html?code=1000523&start=20080101&end=20150721&fields=TCLOSE;HIGH;LOW;TOPEN;LCLOSE;VOTURNOVER;VATURNOVER']%网易K线接口
 % ??????????????????????????????????????????????????????????????????????????????????????????????????????????????????
 
 % url=['http://stock.gtimg.cn/data/view/dataPro.php?t=1&p=30'] %  腾讯累计涨幅统计接口(p=5 10 20 30 天)
 %url=['http://stock.gtimg.cn/data/view/bdrank.php?&t=02/averatio&p=1&o=0&l=800&v=list_data']; % 腾讯板块列表接口 t=01 02 03 04 腾讯行业板块会少数据，不知道为什么
 %url=['http://push3.gtimg.cn/q=bkhz012063,bkhz622010'] % 腾讯板块名字行情信息接口???????? q=bkhz012080   push 是什么？？？？？
 % url=['http://stock.gtimg.cn/data/index.php?appn=rank&t=pt012047/chr&p=1&o=0&l=800&v=list_data'] %腾讯板块股票列表 t=pt012080
 %url=['http://ifzq.gtimg.cn/stock/relate/data/plate?code=sh600415&_var=_IFLOAD_2'] % 股票所属板块 后面的&_var=_IFLOAD_2 似乎用不到
 %url=['http://ifzq.gtimg.cn/stock/relate/data/relate?code=sh600415&_var=_IFLOAD_1'] % 与此股票相关的股票
 %url=['http://data.gtimg.cn/flashdata/hushen/minute/sh600415.js?maxage=10&0.9551210514741698'] % 疑似当日分钟数据
 %url=['http://stock.gtimg.cn/data/index.php?appn=detail&action=data&c=sz000725&p=1'] %腾讯当日Tick 说明中每天16：00后提供，有待验证  p为页数,没有什么卵用
 % url=['http://stock.finance.qq.com/cgi-bin/sstock/q_lhb_js?t=0&c=&b=&e=&p=1&l=&ol=6&o=desc'] % 龙虎榜
%      c=code b=begin e=end 
% url=['http://market.finance.sina.com.cn/pricehis.php?symbol=sh600415&startdate=2015-07-03&enddate=2015-07-03'];  % 分价表
 % ??????????????????????????????????????????????????????????????????????????????????????????????????????????????????
 % 智能选股
       % 活跃股
%url=['http://smartstock.gtimg.cn/get.php?_func=filter&_page=1&_pagesize=30&hs_hsl=0.05&hs_zf=0.03&hs_lb=1&_default=1&_du_r_t=0.5697151531087742']
                            %   hsl：换手率   hs_zf：涨幅    hs_lb：量比  _page：页 （sourcefile最后有个total 的参数记录数，每页30条固定）
        % 资金股
%url=['http://smartstock.gtimg.cn/get.php?_func=filter&_page=1&_default=1&_pagesize=30&hs_zlzc5=0.05&hs_zf3=,0.10&hs_zllb1=1&_du_r_t=0.035006912366841']
                            % hs_zf3 n日涨幅   hs_zlzc5 n日主力增仓   hs_zllb 主力量比  
         %研报股
%url=['http://smartstock.gtimg.cn/get.php?_func=ybg&_page=1&_pagesize=30&type=hs_yb5&_default=1&_du_r_t=0.8024017374109134']         
                           % hs_yb5  ：5日研报上调评级个股（1，5，30）其中有个mbjg参数
         % 敢死队股
%url=['http://smartstock.gtimg.cn/get.php?_func=lhb&_page=1&_pagesize=30&hs_lhb=0.01&_default=1&_du_r_t=0.6465128848526822']
                            % hs_lhb 过去一年上榜频次超过n的营业部操作个股
         % 指标股
% url=['http://smartstock.gtimg.cn/get.php?_func=zhibiao&_default=1&_page=1&_pagesize=30&zhibiao=hs_sgcx&_du_r_t=0.38738224070345545']
                             % 曙光初现 1.MACD金叉：DIF与DEA金叉 2.成交量金叉：5日成交量均线与10日成交量均线金叉 3.均线金叉：5日移动均线与10日移动均线金叉 
% url=['http://smartstock.gtimg.cn/get.php?_func=zhibiao&_default=1&_page=1&_pagesize=30&zhibiao=hs_kzjy&_du_r_t=0.11432055607725688']   
                             %空中加油 1.20日和60日均线多头排列 2.凯恩斯多空线金叉（上穿0轴）
% url=['http://smartstock.gtimg.cn/get.php?_func=zhibiao&_default=1&_page=1&_pagesize=30&zhibiao=hs_cjdx&_du_r_t=0.1654977186127508']    
                              %超级短线 1.20日和60日均线多头排列 2.20日均线导数大于0 3.超级短线中的K线上穿0轴
% url=['http://smartstock.gtimg.cn/get.php?_func=zhibiao&zf60=,0.3&_default=0&_page=1&_pagesize=30&zhibiao=hs_xsdf&_du_r_t=0.603116033435596']   
                               % 蓄势待发 1.股价创60日新高 2.60日涨幅不得超过 30% （zf60=）
% url=['http://smartstock.gtimg.cn/get.php?_func=zhibiao&gl10=,-0.1&_default=1&_page=1&_pagesize=30&zhibiao=hs_hdly&_du_r_t=0.7486800351130616'] 
                                % 海底捞月 1.股价10日乖离小于 -10（gl10=）    2.股价跌破薛斯通道下轨

%?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
% 技术选股
% url=['http://stock.gtimg.cn/data/view/dataPro.php?t=1&p=10']   % 累计涨幅个股 p=5 10 20 30 {'累计涨幅'}
% url=['http://stock.gtimg.cn/data/view/dataPro.php?t=2&p=3']    % 连续上涨个股 p=3 5 7 {'连续天数'}
% url=['http://stock.gtimg.cn/data/view/dataPro.php?t=3&p=3']    % 连续下跌个股 p=3 5 7 {'连续天数'}
% url=['http://stock.gtimg.cn/data/view/dataPro.php?t=4&p=5']    % 换手率统计 p=5 10 20 60 120 {'累计换手率'}
% url=['http://stock.gtimg.cn/data/view/dataPro.php?t=5&p=1']     %大卖单频现个股 p=1 2 3 4 5 {'大单换手率'}
% url=['http://stock.gtimg.cn/data/view/dataPro.php?t=6&p=1']     %大买单频现个股 p=1 2 3 4 5 {'大单换手率'}
% url=['http://stock.gtimg.cn/data/view/dataPro.php?t=7&p=1']     % 成交量突增个股 p=1 {'换手涨跌率'}
% url=['http://stock.gtimg.cn/data/view/dataPro.php?t=8&p=1']     % 远离成本个股 p=1 {'远离度'}
% url=['http://stock.gtimg.cn/data/view/dataPro.php?t=9&p=1']     % 量增价涨个股 p=1 {'量比'}
%====================================================================================================================
% 资金流向选股
%url=['http://stock.gtimg.cn/data/view/flow.php?t=1&dt=20150703&r=0.6092258914799902']  % 资金流向全览，{主力流入总量，主力流出总量，主力净流入量，散户流入总量，散户流出总量，主力净流入量，{当日资金分时明细}}
% url=['http://stock.gtimg.cn/data/view/flow.php?t=2'] % 行业板块资金净流入流出排名 {版块代码，版块名称，版块流入资金，版块流出资金，版块资金净流入量，未知，占版块成交比}
%                                                                              % t=3? 4?
% url=['http://stock.gtimg.cn/data/view/flow.php?t=5'] % 概念板块资金净流入流出排名 {同上} 
%  url=['http://stock.gtimg.cn/data/view/zldx.php?t=2'] % 主力增仓减仓排名（同时有两个数据）（t=1：当日，t=2： 5日）{代码，主力增仓额，主力增仓占当日（5日）成交比  }
                             % url=['http://stock.gtimg.cn/data/view/ggdx.php?t=3&d=9&q=sh603993,sh600649'] % 资金n日(d=n)增减仓明细{总增仓，主力增仓，散户增仓，日期}
 % url=['http://stock.gtimg.cn/data/view/flow.php?t=7&d=1'] % 价跌主力增仓股？？
%  url=['http://stock.gtimg.cn/data/view/flow.php?t=8&d=1'] % 价涨主力减仓股？？
%  url=['http://stock.gtimg.cn/data/view/flow.php?t=9&d=1'] % 主力资金放量股？？
%====================================================================================================================
% url=['http://chagu.dingniugu.com/chaoying/cy.php?id=5'] % 详细数据解释看 http://chagu.dingniugu.com/chaoying/index.asp
%   url=['http://smartbox.gtimg.cn/s3/?q=zgzc&t=gp'] % 拼音代码转换
% url=['http://finance.sina.com.cn/realstock/company/sh600030/qianfuquan.js?d=2015-07-14'] % 前复权数据
%  url=['http://finance.sina.com.cn/realstock/company/sz002111/houfuquan.js?d=2015-07-14'] % 后复权数据
url=['http://data.gtimg.cn/flashdata/hushen/fuquan/',code,'.js?maxage=6000000']
%》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》》
% 读取网页信息
tic
[sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
toc
if ~status
    error('读取错误\n')
end  
sourcefile
expr1='(?<=["~^])([\d.]+)(?=["~])';
[datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
Val=[date_tokens{:}]';
t=cell2mat(cellfun(@(x) datenum([x(:,1:4),'/',x(5:6),'/',x(7:8)]),Val(1:3:end),'UniformOutput' ,false));
Val=[t,str2double([Val(2:3:end),Val(3:3:end)])]
%% Stock 类脚本
 % 均值金叉检测
clear all 
clc
MaLen1=10;
MaLen2=20;
S=Stock.BlockStock( '021007');
CodeList=S.Code(2:end);

for i=1:length(CodeList)
    Stock=Stock(CodeList{i});
    IndData=Stock.Indicators({'Ma','Ma'},{MaLen1,MaLen2},{'2015-07-01','2015-07-10'});
    eval(['Ind.',Stock.Code,'=IndData;']);
    clear IndData Stock
end
Ind
a=eval(['structfun(@(x) x.Ma',num2str(MaLen1),'(end)>x.Ma',num2str(MaLen2),'(end) && x.Ma',num2str(MaLen1),'(end-1)<x.Ma',num2str(MaLen2),'(end-1),Ind,''UniformOutput'',0);']);
% a=structfun(@(x) x.Ma5(end)>x.Ma10(end) && x.Ma5(end-1)<x.Ma10(end-1),Ind,'UniformOutput',0);
name=fieldnames(a);
name(cell2mat(struct2cell(a)))
%% ==========================================================================
% 沪深300 股票建立对象数组
clear all 
clc
BlockCode= '021008';
BlockList=Stock.BlockStock(BlockCode);
Code=BlockList{2:end,3}
%Code={'sh600123','sh600508','sh600415','sz000565'}';
comm=strcat('Stock(''',Code,''',''Flash''),')';
comm=strcat(comm{:});
['a=[',comm(1:end-1),']']
a=eval(['[',comm(1:end-1),']'])
PE=[a.PE]'

%% =============================================================
%不同股票版块列表中找相同股票
% 常用： '021006'    '上证50'   '021283'    '中字头概念'  '021052'    '大订单'  '021008' '中证100'    '021007'    '上证180'   '021116'    '重组并购'  
%              '021276'    '一带一路'   '021058'    '定向增发'   '021012'    '预盈预增'   '021037'    '券商重仓'  '021031'    '低价'   '021240'    '电力改革'   
% '021039' '振兴东北'
BlockCode={ '021039','021012'};

Stock.BlockInfo(BlockCode)
if length(BlockCode)<2
    error('至少输入两个版块的代码')
end
for i=1:length(BlockCode)-1
    if i==1
        inn=innerjoin(Stock.BlockStock(BlockCode{i}),Stock.BlockStock(BlockCode{i+1}));
    else
        inn=innerjoin(inn,Stock.BlockStock(BlockCode{i+1}));
    end
end

inn

%% 查看复市股票
clear all
clc
CodeName=Stock.StockList;
Code=CodeName(:,1);                     % 所有股票代码
info=Stock.QuickInfo(Code);
List=info(~strcmp(info.State,'S'),:);  % 所有当天可交易股票
load('TPStock.mat')
%List=List(:,{'Code','Name'});
TPStock=TPStock_ljzf(:,{'Code','Name'}); % 7月9日停牌的股票且按30r日涨幅降序排列
%TPStock=TPStock_lx(:,{'Code','Name'});% 7月9日停牌的股票且按连续下跌天数降序排列
FPStock=innerjoin(TPStock,List) %计算两个列表重合的数据
%% 统计每天 最高值最低值的时间
clear all
clc
S=Stock('zgwx','Flash')
Lowest=[];
Highest=[];
for i=datenum('2014-01-01'):datenum('2014-07-01')
    
    Tick=S.HistoryTick(datestr(i,'yyyy-mm-dd'));
    if ~isempty(Tick)
        p1=find(Tick.Price==min(Tick.Price));
        p2=find(Tick.Price==max(Tick.Price));
        Lowest=[Lowest;datenum(Tick.Time{p1})];
        Highest=[Highest;datenum(Tick.Time{p2})];
    end
end
Hstr=datestr(Highest);
Lstr=datestr(Lowest);
Ht=str2num(strcat(Hstr(:,13:14),Hstr(:,16:17)));
Lt=str2num(strcat(Lstr(:,13:14),Lstr(:,16:17)));
subplot(1,2,1)
hist(Ht,570)
subplot(1,2,2)
hist(Lt,570)
%%  单只股票均值金叉有效性检验
clear all 
clc
MaLen1=10;
MaLen2=30;
S=Stock('wk','Flash')
KData=S.Indicators({'MA','MA'},{MaLen1,MaLen2},{'2010-01-01','2012-07-15'});
V=eval(['KData.MA',num2str(MaLen1),'>=KData.MA',num2str(MaLen2)],';');
goldeni=strfind(V',[0,1])+1; % 所有金叉位置
deadi=strfind(V',[1,0])+1;% 所有死叉位置
deadi=deadi(deadi>goldeni(1));% 第一个金叉后的所有死叉
if length(deadi)<length(goldeni)
    deadi=[deadi,length(V)];
end
money=KData.Close(deadi)-KData.Close(goldeni);
totlemoney=cumsum(money);
totlemoney(end)
n=length(money)
plot(totlemoney)

%% 单只股票光头阳线测试 
clear all 
clc
Code='sz000525'
S=Stock(Code)
KData=S.HistoryDaily('2012-01-01',today)

Close=KData.Close;
Open=KData.Open;
Y=[NaN;(Close(2:end)-Close(1:end-1))./Close(1:end-1)]*100;
Y2=[Y(2:end);NaN];
COY=((Close-Open)./Open)*100;

KData.Y=num2cell(roundn(Y,-2));
KData.Y2=num2cell(roundn(Y2,-2));
KData.COY=num2cell(roundn(COY,-2));

High=KData.High;
HY2=[(High(2:end)-Close(1:end-1))./Close(1:end-1);NaN]*100;
KData.HighY2=num2cell(roundn(HY2,-2));

Open=KData.Open;
OpenY2=[(Open(2:end)-Close(1:end-1))./Close(1:end-1);NaN]*100;
KData.OpenY2=num2cell(roundn(OpenY2,-2));
gtyx=KData((Close>Open & Close==High & Y<9.7 & COY>1),:)
% g=sortrows(gtyx(:,{'Y','Y2','HighY2','OpenY2'}),'Y') % 按当日收益率排序
g=gtyx(:,{'Date','Y','Y2','HighY2','OpenY2'}); % 按当日收益率排序
fz=0.8;
money=10000;
for i=1:size(g,1)
     
    if g.OpenY2{i}>=fz
        money=money*(1+g.OpenY2{i}/100);
        M(i)=money;
        jg{i}='open';
    elseif g.OpenY2{i}<fz & g.HighY2{i}>=fz
        money=money*(1+fz/100);
        M(i)=money;
        jg{i}='fz';
    else
        money=money*(1+g.Y2{i}/100);
        M(i)=money;
        jg{i}='close';
    end
end
g.M=M';
g.jg=jg'
%% 寻找光头阳线
clear
clc
SL=Stock.StockList; % 下载代码名称表
SLCode=Stock.CodeCheck(SL(:,1))'; % 代码标准化
SLCode=SLCode(strmatch('s',SLCode));% 选择其中的sh和sz开头的股票
info=Stock.Handicap(SLCode);        % 最新盘口信息
RealPrice=str2double(info.RealPrice); % 最新价格
High=str2double(info.High);           % 最高价格
Yield=str2double(info.Yield);         % 当日收益率
HardenPrice=str2double(info.HardenPrice); % 当日涨停价

sortrows(info((RealPrice==High & RealPrice~=0 & Yield>0 & RealPrice<HardenPrice),{'Code','Name','RealPrice','High','Yield'}),'Yield')
%% 历史某日所有股票光头阳线统计
% tic;m=open('Data.mat');toc
clearvars -except m
clc
fn=fieldnames(m);
TradeDate=datestr(m.sh000001.K(:,1),'yyyymmdd'); % 有交易的日期
for n=1:size(TradeDate,1)
    eval(['Dgtyx.D',TradeDate(n,:),'={};'])
end

  hwait=waitbar(0,'请等待>>>>>>>>');
   for i=1:length(fn)
      Code=fn{i};
      KData=eval(['m.',Code,'.K;']);
      
      if ~size(KData,1)<=1
          c=cell2mat(KData(:,3));
          o=cell2mat(KData(:,2));
          h=cell2mat(KData(:,4));
          Y=[NaN;(c(2:end)-c(1:end-1))./c(1:end-1)]*100;
          Y2=[Y(2:end);NaN];
          HY2=[(h(2:end)-c(1:end-1))./c(1:end-1);NaN]*100;
          COY=((c-o)./o)*100;
          
          KData=[KData(:,[1,3,4]),num2cell([Y,Y2,COY,HY2])];
          g=KData(c==h & c>o & Y<9.97 & COY>1,:);
          
          if ~isempty(g)
              for j=1:size(g,1)
                  dd=datestr(g{j,1},'yyyymmdd');
                  dd=['D',dd];
                  try eval(['Dgtyx.',dd,';'])
                      eval(['Dgtyx.',dd,'=[Dgtyx.',dd,';[Code,g(j,:)]];']);
                  catch
                      eval(['Dgtyx.',dd,'=[Code,g(j,:)];']);
                  end
              end
          end
          
          eval(['gtyx.',Code,'=g;'])
       waitbar(i/length(fn),hwait,[num2str(i/length(fn)*100),'%',':',num2str(fn{i}),',',num2str(i),'/',num2str(length(fn))]);% 进度条   
      end
  end
close(hwait);% 关闭进度条
gtyx; % {'日期','最高价格','收盘价','当日涨幅','次日涨幅','当日开收涨幅','次日最高涨幅'}
Dgtyx

 

%% 批量数据下载及合并测试 
clear
clc

BlockCode= '021008'; % 中证100
BlockList=Stock.BlockStock(BlockCode);
CodeList=BlockList{2:end,3};
%CodeList={'600123','600588'};


KListOld=Stock.HistoryK(CodeList,'2008-07-01','2015-07-15');
KListNew=Stock.HistoryK(CodeList,'2008-07-10','2015-07-20');



fm=fieldnames(KListOld);

tic
for i=1:length(fm)
    if eval(['isempty(KListB.',fm{i},')'])
       eval(['KListNew.',fm{i},'=KListOld.',fm{i},';']);
    end
    if eval(['isempty(KListOld.',fm{i},')'])
        eval(['KList.',fm{i},'=[];'])
    else
        eval(['KList.',fm{i},'=union(KListOld.',fm{i},',KListNew.',fm{i},');'])
    end
end
toc

%% 批量数据下载（腾讯接口）

             tic
            SL=Stock.StockList;
            toc
            SLCode=Stock.CodeCheck(SL(:,1))';
            SLCode=SLCode(strmatch('s',SLCode));
           tic
            m=StockAll.DownloadKData(SLCode,2);
            toc
%             tic
%             fqData=StockAll.DownloadFQData(SLCode) 
%             toc
            
  %% 批量复权
  
%   tic;KDataAll=open('Data.mat');toc
%    tic;fqDataAll=open('fq.mat');toc
  clearvars -except KDataAll fqDataAll
  clc
  type='R';
  fieldK=fieldnames(KDataAll);
  fieldFQ=fieldnames(fqDataAll);
  LfieldK=size(fieldK,1);
   hwait=waitbar(0,'请等待>>>>>>>>');
  for i=1: LfieldK
      Code=fieldK{i};
      if isempty(strmatch(Code,fieldFQ))
          eval(['KDataAll',type,'.',Code,'=KDataAll.',Code,';'])
      else
          KData=eval(['KDataAll.',Code,'.K;']);
           KData=[datenum(KData(:,1)),cell2mat(KData(:,2:end))];
          fqData=eval(['fqDataAll.',Code,';']);
          if ~isempty(fqData)
              fqData(:,3)=cumprod(fqData(:,3));
          end
                switch type
                    case 'L'
                        for j=1:size(fqData,1)
                            if j==1
                                dayi=KData(:,1)<fqData(j);
                            else
                                dayi=KData(:,1)<fqData(j) & KData(:,1)>=fqData(j-1);
                            end
                            KData(dayi,2:end-1)=KData(dayi,2:end-1)*fqData(j,2);
                        end
                        
                    case 'R'
                        %--------------------------------
                        
                        for j=1:size(fqData,1)
                            if j==size(fqData,1)
                                dayi=KData(:,1)>=fqData(j);
                            else
                                dayi=KData(:,1)>=fqData(j) & KData(:,1)<fqData(j+1);
                            end
                            KData(dayi,2:end-1)=KData(dayi,2:end-1)*fqData(j,3);
                        end
                        %--------------------------------
                    otherwise
                end
          %KData=[cellstr(datestr(KData(:,1),'yyyy-mm-dd')),num2cell(KData(:,2:end))];
          eval(['KDataAll',type,'.',Code,'=KData;']);
      end
       waitbar(i/LfieldK,hwait,[num2str(i/LfieldK*100),'%',':',num2str(fieldK{i}),',',num2str(i),'/',num2str(LfieldK)]);% 进度条
      
  end
  
   close(hwait);% 关闭进度条
  %% 寻找均线金叉的股票
%   clear
%   clc
%   S=StockAll
% S.ImportData('KL')
   Ma=S.Indicators({'MA'},{[5,20]})
  
  clearvars -except S Ma w
  CodeList=fieldnames(Ma); % 代码列表
  L=length(CodeList);
  Gold=[];
  Dead=[];
  tic
  hwait=waitbar(0,'寻找MA金叉死叉>>>>>>>>'); % 时间统计开始
  for i=1:L
      Code=CodeList{i};
      ma=eval(['Ma.',Code,';']);
      if size(ma,1)>=2 && ma(end-1,2)<ma(end-1,3) && ma(end,2)>=ma(end,3)
                  Gold=[Gold;Code];
      elseif size(ma,1)>=2 && ma(end-1,2)>ma(end-1,3) && ma(end,2)<=ma(end,3)         
                  Dead=[Dead;Code];
      end
    %  waitbar(i/L,hwait,[num2str(i/L*100),'%',':',num2str(CodeList{i}),',',num2str(i),'/',num2str(L)]);% 进度条
    waitbar(i/L,hwait);% 进度条
  end
  close(hwait);% 关闭进度条
  toc
    % 去掉停牌的股票
  Gold=StockAll.Handicap(cellstr(Gold));
  disp('金叉股：')
  Gold(find(strcmp(Gold.State,'')),:)
  Dead=StockAll.Handicap(cellstr(Dead));
  disp('死叉股：')
  Dead(find(strcmp(Dead.State,'')),:)
 %% 寻找突破BOLL上轨的个股
   clear
  clc
  S=StockAll
 BOLL=S.Indicators({'BOLL'},{[26,2]})
 % clearvars -except S BOLL
  KL=S.KDataAll;
  CodeList=fieldnames(KL); % 代码列表
  L=length(CodeList);
  hwait=waitbar(0,'寻找突破BOLL上轨>>>>>>>>'); % 时间统计开始
  result=[];
  for i=1:L
     Code=CodeList{i}; 
    bollmid=eval(['BOLL.',Code,'(:,2);']);
    bollup=eval(['BOLL.',Code,'(:,3);']);
    bolldown=eval(['BOLL.',Code,'(:,4);']);
    Close=eval(['KL.',Code,'(:,3);']);
    if size(Close,1)>1
        if Close(end)>bollup(end) && Close(end-1)<bollup(end-1)
            result=[result;Code];
        end
    end
     waitbar(i/L,hwait);% 进度条
  end
  % 去掉停牌的股票
   result=StockAll.Handicap(cellstr(result));
  disp('突破BOLL上轨股：')
  result(find(strcmp(result.State,'')),:)
  close(hwait);% 关闭进度条
%% 单个股票突破BOLL上轨后的走势分析
clear
clc
Code='lg'
Len=20;
Width=2;
HLen=5;
threshold=5;
S=Stock(Code);
ind=S.Indicators({'BOLL','Highest'},{[Len,Width],HLen},{'2008-01-01',today});
bollup=eval(['ind.BOllUp',num2str(Len),'_',num2str(Width)]);
bollmid=eval(['ind.BOllMid',num2str(Len),'_',num2str(Width)]);
bolldown=eval(['ind.BOllDown',num2str(Len),'_',num2str(Width)]);
Date=ind.Date;
Close=ind.Close;
Highest=eval(['ind.High',num2str(HLen)]);
BreakUp=[];
BreakUpi=0;
for i=2:length(Close)
    if Close(i)>bollup(i) & Close(i-1)<bollup(i-1)
       BreakUp=[BreakUp;i];
       BreakUpi=[BreakUpi;1];
    else
       BreakUpi=[BreakUpi;0];
    end
end
HafterLen=[Highest(HLen+1:end);nan(HLen,1)];
CafterLen=[Close(HLen+1:end);nan(HLen,1)];

rateH=(HafterLen-Close)./Close*100;
rateH(~(BreakUpi>0))=0;
rateC=(CafterLen-Close)./Close*100;
rateC(~(BreakUpi>0))=0;

rate=(rateH>=threshold)*threshold+(rateH<threshold).*rateC;
sumrate=cumsum(rate);
result=[Close,bollup,HafterLen,CafterLen,rateH,rateC,rate,sumrate];
Name={'Date','Close','bollup','HafterLen','CafterLen','rateH','rateC','rate','sumrate'};
cell2table([Date(BreakUp),num2cell(result(BreakUp,:))],'VariableNames',Name)

%% 计算价格与均线的距离，判断支撑位与阻力位
% clear
% %clearvars -except w
% clc
% S=StockAll;
DataName='MAList'
if ~isstruct(S.TempData) | (isstruct(S.TempData) & ~isfield(S.TempData,DataName) )
    MA=S.Indicators({'MA'},{[5 10 20 30]});
    S.TempData.MAList=MA;
else
    MA=S.TempData.MAList;
end


flash=StockAll.Handicap('sh000001');
flashtime=flash.LastTime{:};
if datenum([flashtime(1:4),'-',flashtime(5:6),'-',flashtime(7:8)],'yyyy-mm-dd')>S.KDataAll.sh000001(end,1)
    f=S.DownloadData('Flash');
    f2=f(strcmp(f.State,'') & ~strcmp(f.RealPrice,'0.00') ,{'Code','RealPrice'});
    fn=f2.Code;
    L=height(f2);
    tic
    for i=1:L
      Code=fn{i};
      Close=str2double(f2{strcmp(f2.Code,Code),{'RealPrice'}});
      MAData=eval(['MA.',Code,'(end,2:end);']);
      Data=(Close-MAData)./Close*100;
      eval(['out.',Code,'=Data;'])
    end
    toc
else
    fn=fieldnames(S.KDataAll);
    L=length(fn);
    tic
    for i=1:L
        Code=fn{i};
        Close=eval(['S.KDataAll.',Code,'(end,3);']);
        MAData=eval(['MA.',Code,'(end,2:end);']);
        Data=(Close-MAData)./Close*100;
        eval(['out.',Code,'=Data;'])
    end
    toc
end

out


%% 搜索最高点最低点压力支撑位

clc
S=Stock('zgwx');
K=S.HistoryDaily('2015-01-01','2015-11-27');
High=K.High;
Low=K.Low;

Level=[High,[0;High(1:end-1)]<=High & [High(2:end);0]<High,Low,[0;Low(1:end-1)]>=Low & [Low(2:end);0]>Low]
L=length(High);
% for i=1:L
%    Value=Level(i,1);
%    
%  
% end

%%
clc
%clear
S=StockAll;
CodeList=S.CodeList;
CodeListHead=cellfun(@(x) x(1:2),CodeList,'UniformOutput',0);
CodeListEnd=cellfun(@(x) x(3:end),CodeList,'UniformOutput',0);
CodeList=strcat(CodeListEnd,'.',CodeListHead)
for i=1000:1100
    i
 [w_wsd_data_0,w_wsd_codes_0,w_wsd_fields_0,w_wsd_times,w_wsd_errorid,w_wsd_reqid]=w.wsd('600118.SH','close,BOLL','ED-7D','2016-10-13','BOLL_N=26','BOLL_Width=2','BOLL_IO=3','Fill=Previous')  ;
end


%%
clear
clc
m=matfile('Data.mat');
p=properties(m);
tic
for i=2:length(p)
    [num2str(i),'/',num2str(length(p))]
    eval(['m.',p{2},';']);
end
toc

%%
% clear
% clc
% S=StockAll;
% S.ImportData('KL');
p=fieldnames(S.KDataAll);
tic
for i=1:length(p)
    [num2str(i),'/',num2str(length(p))]
    eval(['S.KDataAll.',p{2},';']);
end
toc





