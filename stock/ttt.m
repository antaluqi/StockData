
%% =====================================================
% ���˷ֱ����ݣ���������������������������������
% http://vip.stock.finance.sina.com.cn/quotes_service/view/CN_TransListV2.php?num=90000&symbol=sh000001



% http://www.aigaogao.com/tools/default.html 
% δ�����ӿڣ�http://stock.gtimg.cn/data/view/ggdx.php?t=3&d=20&q=sh600503 �� �е� С��
% �����ӿڵĽ��� http://www.cnblogs.com/ibearpig/p/3646004.html18
% http://market.finance.sina.com.cn/downxls.php?date=2015-06-24&symbol=sh600415 % ������ʷÿ�շ�ʱͼ
% http://chagu.dingniugu.com/chaoying/cy.php?id=5 ��Ӯ���ݽӿڣ�ȫ��sh��Ʊʵʱ�� ��ϸ���ݽ��Ϳ� http://chagu.dingniugu.com/chaoying/index.asp
% �����ڻ����ݽӿڽ��� http://www.360doc.com/content/13/1009/14/3840306_320076250.shtml
%% ��ȡ�����̿�����===========================================
clear
clc
% ��Ʊ����
Code={'sh600415','sh600795','sz000725','sh600008','sh600383','sz002123'}; 
% ��Ѷ���ݽӿڵ�ַ��ͷ
urlHead='http://qt.gtimg.cn/q='
% ������ת���ɵ�ַ��ɲ���
C=strcat(Code,',');
urlAddress=strcat(urlHead,[C{:}]);
% ��ȡ��ҳ��Ϣ
[sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
if ~status
    error('��ȡ����\n')
end
% ������ʽ(����Ʊ��Ϣ�б������������)
expr1='(?<=v_)(.*?)(?=";)';
[datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
sourcefile=[date_tokens{:}]';
% ������ȡ��Ϣ
for i=1:length(sourcefile)
    % ������ʽ(��ȡ�ؼ�����)
   expr1='(?<==")(.*)';
   [datefile, date_tokens]= regexp(sourcefile{i}, expr1, 'match', 'tokens');
   sourcefile2=date_tokens{:};
    % �ָ���Ϣ
   ss=regexp(sourcefile2, '~', 'split');
    % �����ȡ����Ϣ
   S(i,:)=ss{:};
end
% ����
title={'δ֪','����','����','��ǰ�۸�','����','��','�ɽ������֣�','����','����','��һ','��һ�����֣�','���','��������֣�','����'...
        ,'���������֣�','����','���������֣�','����','���������֣�','��һ','��һ�����֣�','����','���������֣�','����','���������֣�'...
        ,'����','���������֣�','����','���������֣�','�����ʳɽ�','ʱ��','�ǵ�','�ǵ�%','���','���','�۸�/�ɽ������֣�/�ɽ���','�ɽ������֣�'...
        ,'�ɽ����','������','��ӯ��','[blank]','���','���','���','��ͨ��ֵ','����ֵ','�о���','��ͣ��','��ͣ��','[blank]'};
% ����������Ϣ���
S=[title',S']

%% ��ȡʵʱ�ʽ�����============================================================================================
clear
clc
% ��Ʊ����
Code={'sh600415','sh600795','sz000725','sh600008','sh600383','sz002123'}; 
% ��Ѷ���ݽӿڵ�ַ��ͷ
urlHead='http://qt.gtimg.cn/q='
% ������ת���ɵ�ַ��ɲ���
C=strcat('ff_',Code,',');
urlAddress=strcat(urlHead,[C{:}]);
% ��ȡ��ҳ��Ϣ
[sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
if ~status
    error('��ȡ����\n')
end
% ������ʽ(����Ʊ��Ϣ�б������������)
expr1='(?<=v_)(.*?)(?=";)';
[datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
sourcefile=[date_tokens{:}]';
for i=1:length(sourcefile)
    expr1='(?<=="s[hz])(.*)';
    [datefile, date_tokens]= regexp(sourcefile{i}, expr1, 'match', 'tokens');
     sourcefile2=date_tokens{:};
    % �ָ���Ϣ
    ss=regexp(sourcefile2, '~', 'split');
    % �����ȡ����Ϣ
    S(i,:)=ss{:};
end
  title={'����','��������','��������','����������','����������/�ʽ����������ܺ�','ɢ������','ɢ������','ɢ��������','ɢ��������/�ʽ����������ܺ�',...
              '�ʽ����������ܺ�1+2+5+6','δ֪','δ֪','����','����','δ֪','δ֪','δ֪','δ֪'};
   % colnames={'StockCode','MainInflow','MainOutflow','MainNetInflow','MainNetInflow/MainTotal','RetailInflow','RetailOutflow','RetailNetInflow','RetailNetInflow/RetailTotal','TotalFund','unknow1','unknow2','StockName','LastTime','unknow3','unknow4','unknow5','unknow6'};
   
   S=[title',S']
%% ��ȡ�̿ڷ�����============================================================================================
clear
clc
% ��Ʊ����
Code={'sh600415','sh600795','sz000725','sh600008','sh600383','sz002123'}; 
% ��Ѷ���ݽӿڵ�ַ��ͷ
urlHead='http://qt.gtimg.cn/q='
% ������ת���ɵ�ַ��ɲ���
C=strcat('s_pk',Code,',');
urlAddress=strcat(urlHead,[C{:}]);
% ��ȡ��ҳ��Ϣ
[sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
if ~status
    error('��ȡ����\n')
end
% ������ʽ(����Ʊ��Ϣ�б������������)
expr1='(?<=v_)(.*?)(?=";)';
[datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
sourcefile=[date_tokens{:}]';
% ������ȡ��Ϣ
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
 title={'����','���̴�','����С��','���̴�','����С��'};
 % colnames={'StockCode','BuyLargeQuantity','BuySmallQuantity','SellLargeQuantity','SellSmallQuantity'};
 S=[title',S']
%% ��ȡ��Ҫ��Ϣ:================================================================================================================= 

% clear
% clc
% ��Ʊ����
Code={'sh600415','sh600795','sz000725','sh600008','sh600383','sz002123'}; 
Code=a
%Code={'sh600123'};
% ��Ѷ���ݽӿڵ�ַ��ͷ
urlHead='http://qt.gtimg.cn/q=';
% ������ת���ɵ�ַ��ɲ���
C=strcat('s_',Code,',');
urlAddress=strcat(urlHead,[C{:}])
% ��ȡ��ҳ��Ϣ
[sourcefile, status] =urlread(sprintf(urlAddress(1:end-1)),'Charset','GBK');
if isempty(sourcefile)
    error('û�д˹�Ʊ����')
end
if ~status
    error('��ȡ����\n')
end
% ������ʽ(����Ʊ��Ϣ�б������������)
expr1='(?<=v_)(.*?)(?=";)';
[datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
sourcefile=[date_tokens{:}]';
if isempty(sourcefile)
    error('û�д˹�Ʊ����')
end
% ������ȡ��Ϣ
for i=1:length(sourcefile)
    % ������ʽ(��ȡ�ؼ�����)
   expr1='(?<==")(.*)';
   [datefile, date_tokens]= regexp(sourcefile{i}, expr1, 'match', 'tokens');
   sourcefile2=date_tokens{:};
    % �ָ���Ϣ
   ss=regexp(sourcefile2, '~', 'split');
    % �����ȡ����Ϣ
   S(i,:)=ss{:};

end
  title={'δ֪','����','����','��ǰ�۸�','�ǵ�','�ǵ�%','�ɽ���(��)','�ɽ���(��)','[blank]','����ֵ'};
  % colnames={'unknow1','StockName','StockCode','RealPrice','Rise','Yield','Volume','Amount','blank1','TotalMarketValue'};
  S=[title',S']
 




%% ========================================================================
% �����ݽӿڲ���
% clear
% clc
code='sh600118';
%url=['http://data.gtimg.cn/flashdata/hushen/4day/sh/',code,'.js?'] % ��Ѷ1�������ݽӿڣ���5�գ�
%url=['http://vip.stock.finance.sina.com.cn/quotes_service/view/CN_TransListV2.php?num=90000&symbol=',code] % ���˵��շֱ����ݣ���?
%url=['http://vip.stock.finance.sina.com.cn/q/view/download_gold_history.php?breed=AGTD&start=2015-01-01&end=2015-06-28'];%������ӿ�
%url=['http://money.finance.sina.com.cn/quotes_service/api/json_v2.php/CN_MarketData.getKLineData?symbol=',code,'&scale=5&ma=no&datalen=1023'] % ��� 5 15 30 60 ��������
 %url=['http://data.gtimg.cn/flashdata/hushen/monthly/',code,'.js?'] %  ��Ѷ�������ݽӿ�
 %url=[' http://market.finance.sina.com.cn/downxls.php?date=2015-06-25&symbol=',code] % ������ʷ�����ϸ
% url=['http://biz.finance.sina.com.cn/stock/flash_hq/kline_data.php?symbol=',code,'&end_date=20150726&begin_date=20150101'] % ����K������
 %url=['http://data.gtimg.cn/flashdata/hushen/daily/15/',code,'.js?maxage=43201'] % ��Ѷ��K������
 %url=['http://quotes.money.163.com/service/chddata.html?code=1000523&start=20080101&end=20150721&fields=TCLOSE;HIGH;LOW;TOPEN;LCLOSE;VOTURNOVER;VATURNOVER']%����K�߽ӿ�
 % ??????????????????????????????????????????????????????????????????????????????????????????????????????????????????
 
 % url=['http://stock.gtimg.cn/data/view/dataPro.php?t=1&p=30'] %  ��Ѷ�ۼ��Ƿ�ͳ�ƽӿ�(p=5 10 20 30 ��)
 %url=['http://stock.gtimg.cn/data/view/bdrank.php?&t=02/averatio&p=1&o=0&l=800&v=list_data']; % ��Ѷ����б�ӿ� t=01 02 03 04 ��Ѷ��ҵ���������ݣ���֪��Ϊʲô
 %url=['http://push3.gtimg.cn/q=bkhz012063,bkhz622010'] % ��Ѷ�������������Ϣ�ӿ�???????? q=bkhz012080   push ��ʲô����������
 % url=['http://stock.gtimg.cn/data/index.php?appn=rank&t=pt012047/chr&p=1&o=0&l=800&v=list_data'] %��Ѷ����Ʊ�б� t=pt012080
 %url=['http://ifzq.gtimg.cn/stock/relate/data/plate?code=sh600415&_var=_IFLOAD_2'] % ��Ʊ������� �����&_var=_IFLOAD_2 �ƺ��ò���
 %url=['http://ifzq.gtimg.cn/stock/relate/data/relate?code=sh600415&_var=_IFLOAD_1'] % ��˹�Ʊ��صĹ�Ʊ
 %url=['http://data.gtimg.cn/flashdata/hushen/minute/sh600415.js?maxage=10&0.9551210514741698'] % ���Ƶ��շ�������
 %url=['http://stock.gtimg.cn/data/index.php?appn=detail&action=data&c=sz000725&p=1'] %��Ѷ����Tick ˵����ÿ��16��00���ṩ���д���֤  pΪҳ��,û��ʲô����
 % url=['http://stock.finance.qq.com/cgi-bin/sstock/q_lhb_js?t=0&c=&b=&e=&p=1&l=&ol=6&o=desc'] % ������
%      c=code b=begin e=end 
% url=['http://market.finance.sina.com.cn/pricehis.php?symbol=sh600415&startdate=2015-07-03&enddate=2015-07-03'];  % �ּ۱�
 % ??????????????????????????????????????????????????????????????????????????????????????????????????????????????????
 % ����ѡ��
       % ��Ծ��
%url=['http://smartstock.gtimg.cn/get.php?_func=filter&_page=1&_pagesize=30&hs_hsl=0.05&hs_zf=0.03&hs_lb=1&_default=1&_du_r_t=0.5697151531087742']
                            %   hsl��������   hs_zf���Ƿ�    hs_lb������  _page��ҳ ��sourcefile����и�total �Ĳ�����¼����ÿҳ30���̶���
        % �ʽ��
%url=['http://smartstock.gtimg.cn/get.php?_func=filter&_page=1&_default=1&_pagesize=30&hs_zlzc5=0.05&hs_zf3=,0.10&hs_zllb1=1&_du_r_t=0.035006912366841']
                            % hs_zf3 n���Ƿ�   hs_zlzc5 n����������   hs_zllb ��������  
         %�б���
%url=['http://smartstock.gtimg.cn/get.php?_func=ybg&_page=1&_pagesize=30&type=hs_yb5&_default=1&_du_r_t=0.8024017374109134']         
                           % hs_yb5  ��5���б��ϵ��������ɣ�1��5��30�������и�mbjg����
         % �����ӹ�
%url=['http://smartstock.gtimg.cn/get.php?_func=lhb&_page=1&_pagesize=30&hs_lhb=0.01&_default=1&_du_r_t=0.6465128848526822']
                            % hs_lhb ��ȥһ���ϰ�Ƶ�γ���n��Ӫҵ����������
         % ָ���
% url=['http://smartstock.gtimg.cn/get.php?_func=zhibiao&_default=1&_page=1&_pagesize=30&zhibiao=hs_sgcx&_du_r_t=0.38738224070345545']
                             % ������ 1.MACD��棺DIF��DEA��� 2.�ɽ�����棺5�ճɽ���������10�ճɽ������߽�� 3.���߽�棺5���ƶ�������10���ƶ����߽�� 
% url=['http://smartstock.gtimg.cn/get.php?_func=zhibiao&_default=1&_page=1&_pagesize=30&zhibiao=hs_kzjy&_du_r_t=0.11432055607725688']   
                             %���м��� 1.20�պ�60�վ��߶�ͷ���� 2.����˹����߽�棨�ϴ�0�ᣩ
% url=['http://smartstock.gtimg.cn/get.php?_func=zhibiao&_default=1&_page=1&_pagesize=30&zhibiao=hs_cjdx&_du_r_t=0.1654977186127508']    
                              %�������� 1.20�պ�60�վ��߶�ͷ���� 2.20�վ��ߵ�������0 3.���������е�K���ϴ�0��
% url=['http://smartstock.gtimg.cn/get.php?_func=zhibiao&zf60=,0.3&_default=0&_page=1&_pagesize=30&zhibiao=hs_xsdf&_du_r_t=0.603116033435596']   
                               % ���ƴ��� 1.�ɼ۴�60���¸� 2.60���Ƿ����ó��� 30% ��zf60=��
% url=['http://smartstock.gtimg.cn/get.php?_func=zhibiao&gl10=,-0.1&_default=1&_page=1&_pagesize=30&zhibiao=hs_hdly&_du_r_t=0.7486800351130616'] 
                                % �������� 1.�ɼ�10�չ���С�� -10��gl10=��    2.�ɼ۵���Ѧ˹ͨ���¹�

%?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
% ����ѡ��
% url=['http://stock.gtimg.cn/data/view/dataPro.php?t=1&p=10']   % �ۼ��Ƿ����� p=5 10 20 30 {'�ۼ��Ƿ�'}
% url=['http://stock.gtimg.cn/data/view/dataPro.php?t=2&p=3']    % �������Ǹ��� p=3 5 7 {'��������'}
% url=['http://stock.gtimg.cn/data/view/dataPro.php?t=3&p=3']    % �����µ����� p=3 5 7 {'��������'}
% url=['http://stock.gtimg.cn/data/view/dataPro.php?t=4&p=5']    % ������ͳ�� p=5 10 20 60 120 {'�ۼƻ�����'}
% url=['http://stock.gtimg.cn/data/view/dataPro.php?t=5&p=1']     %������Ƶ�ָ��� p=1 2 3 4 5 {'�󵥻�����'}
% url=['http://stock.gtimg.cn/data/view/dataPro.php?t=6&p=1']     %����Ƶ�ָ��� p=1 2 3 4 5 {'�󵥻�����'}
% url=['http://stock.gtimg.cn/data/view/dataPro.php?t=7&p=1']     % �ɽ���ͻ������ p=1 {'�����ǵ���'}
% url=['http://stock.gtimg.cn/data/view/dataPro.php?t=8&p=1']     % Զ��ɱ����� p=1 {'Զ���'}
% url=['http://stock.gtimg.cn/data/view/dataPro.php?t=9&p=1']     % �������Ǹ��� p=1 {'����'}
%====================================================================================================================
% �ʽ�����ѡ��
%url=['http://stock.gtimg.cn/data/view/flow.php?t=1&dt=20150703&r=0.6092258914799902']  % �ʽ�����ȫ����{������������������������������������������ɢ������������ɢ��������������������������{�����ʽ��ʱ��ϸ}}
% url=['http://stock.gtimg.cn/data/view/flow.php?t=2'] % ��ҵ����ʽ������������� {�����룬������ƣ���������ʽ𣬰�������ʽ𣬰���ʽ���������δ֪��ռ���ɽ���}
%                                                                              % t=3? 4?
% url=['http://stock.gtimg.cn/data/view/flow.php?t=5'] % �������ʽ������������� {ͬ��} 
%  url=['http://stock.gtimg.cn/data/view/zldx.php?t=2'] % �������ּ���������ͬʱ���������ݣ���t=1�����գ�t=2�� 5�գ�{���룬�������ֶ��������ռ���գ�5�գ��ɽ���  }
                             % url=['http://stock.gtimg.cn/data/view/ggdx.php?t=3&d=9&q=sh603993,sh600649'] % �ʽ�n��(d=n)��������ϸ{�����֣��������֣�ɢ�����֣�����}
 % url=['http://stock.gtimg.cn/data/view/flow.php?t=7&d=1'] % �۵��������ֹɣ���
%  url=['http://stock.gtimg.cn/data/view/flow.php?t=8&d=1'] % �����������ֹɣ���
%  url=['http://stock.gtimg.cn/data/view/flow.php?t=9&d=1'] % �����ʽ�����ɣ���
%====================================================================================================================
% url=['http://chagu.dingniugu.com/chaoying/cy.php?id=5'] % ��ϸ���ݽ��Ϳ� http://chagu.dingniugu.com/chaoying/index.asp
%   url=['http://smartbox.gtimg.cn/s3/?q=zgzc&t=gp'] % ƴ������ת��
% url=['http://finance.sina.com.cn/realstock/company/sh600030/qianfuquan.js?d=2015-07-14'] % ǰ��Ȩ����
%  url=['http://finance.sina.com.cn/realstock/company/sz002111/houfuquan.js?d=2015-07-14'] % ��Ȩ����
url=['http://data.gtimg.cn/flashdata/hushen/fuquan/',code,'.js?maxage=6000000']
%����������������������������������������������������������������������������������������
% ��ȡ��ҳ��Ϣ
tic
[sourcefile, status] =urlread(sprintf(url),'Charset','GBK');
toc
if ~status
    error('��ȡ����\n')
end  
sourcefile
expr1='(?<=["~^])([\d.]+)(?=["~])';
[datefile, date_tokens]= regexp(sourcefile, expr1, 'match', 'tokens');
Val=[date_tokens{:}]';
t=cell2mat(cellfun(@(x) datenum([x(:,1:4),'/',x(5:6),'/',x(7:8)]),Val(1:3:end),'UniformOutput' ,false));
Val=[t,str2double([Val(2:3:end),Val(3:3:end)])]
%% Stock ��ű�
 % ��ֵ�����
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
% ����300 ��Ʊ������������
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
%��ͬ��Ʊ����б�������ͬ��Ʊ
% ���ã� '021006'    '��֤50'   '021283'    '����ͷ����'  '021052'    '�󶩵�'  '021008' '��֤100'    '021007'    '��֤180'   '021116'    '���鲢��'  
%              '021276'    'һ��һ·'   '021058'    '��������'   '021012'    'ԤӯԤ��'   '021037'    'ȯ���ز�'  '021031'    '�ͼ�'   '021240'    '�����ĸ�'   
% '021039' '���˶���'
BlockCode={ '021039','021012'};

Stock.BlockInfo(BlockCode)
if length(BlockCode)<2
    error('���������������Ĵ���')
end
for i=1:length(BlockCode)-1
    if i==1
        inn=innerjoin(Stock.BlockStock(BlockCode{i}),Stock.BlockStock(BlockCode{i+1}));
    else
        inn=innerjoin(inn,Stock.BlockStock(BlockCode{i+1}));
    end
end

inn

%% �鿴���й�Ʊ
clear all
clc
CodeName=Stock.StockList;
Code=CodeName(:,1);                     % ���й�Ʊ����
info=Stock.QuickInfo(Code);
List=info(~strcmp(info.State,'S'),:);  % ���е���ɽ��׹�Ʊ
load('TPStock.mat')
%List=List(:,{'Code','Name'});
TPStock=TPStock_ljzf(:,{'Code','Name'}); % 7��9��ͣ�ƵĹ�Ʊ�Ұ�30r���Ƿ���������
%TPStock=TPStock_lx(:,{'Code','Name'});% 7��9��ͣ�ƵĹ�Ʊ�Ұ������µ�������������
FPStock=innerjoin(TPStock,List) %���������б��غϵ�����
%% ͳ��ÿ�� ���ֵ���ֵ��ʱ��
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
%%  ��ֻ��Ʊ��ֵ�����Ч�Լ���
clear all 
clc
MaLen1=10;
MaLen2=30;
S=Stock('wk','Flash')
KData=S.Indicators({'MA','MA'},{MaLen1,MaLen2},{'2010-01-01','2012-07-15'});
V=eval(['KData.MA',num2str(MaLen1),'>=KData.MA',num2str(MaLen2)],';');
goldeni=strfind(V',[0,1])+1; % ���н��λ��
deadi=strfind(V',[1,0])+1;% ��������λ��
deadi=deadi(deadi>goldeni(1));% ��һ���������������
if length(deadi)<length(goldeni)
    deadi=[deadi,length(V)];
end
money=KData.Close(deadi)-KData.Close(goldeni);
totlemoney=cumsum(money);
totlemoney(end)
n=length(money)
plot(totlemoney)

%% ��ֻ��Ʊ��ͷ���߲��� 
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
% g=sortrows(gtyx(:,{'Y','Y2','HighY2','OpenY2'}),'Y') % ����������������
g=gtyx(:,{'Date','Y','Y2','HighY2','OpenY2'}); % ����������������
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
%% Ѱ�ҹ�ͷ����
clear
clc
SL=Stock.StockList; % ���ش������Ʊ�
SLCode=Stock.CodeCheck(SL(:,1))'; % �����׼��
SLCode=SLCode(strmatch('s',SLCode));% ѡ�����е�sh��sz��ͷ�Ĺ�Ʊ
info=Stock.Handicap(SLCode);        % �����̿���Ϣ
RealPrice=str2double(info.RealPrice); % ���¼۸�
High=str2double(info.High);           % ��߼۸�
Yield=str2double(info.Yield);         % ����������
HardenPrice=str2double(info.HardenPrice); % ������ͣ��

sortrows(info((RealPrice==High & RealPrice~=0 & Yield>0 & RealPrice<HardenPrice),{'Code','Name','RealPrice','High','Yield'}),'Yield')
%% ��ʷĳ�����й�Ʊ��ͷ����ͳ��
% tic;m=open('Data.mat');toc
clearvars -except m
clc
fn=fieldnames(m);
TradeDate=datestr(m.sh000001.K(:,1),'yyyymmdd'); % �н��׵�����
for n=1:size(TradeDate,1)
    eval(['Dgtyx.D',TradeDate(n,:),'={};'])
end

  hwait=waitbar(0,'��ȴ�>>>>>>>>');
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
       waitbar(i/length(fn),hwait,[num2str(i/length(fn)*100),'%',':',num2str(fn{i}),',',num2str(i),'/',num2str(length(fn))]);% ������   
      end
  end
close(hwait);% �رս�����
gtyx; % {'����','��߼۸�','���̼�','�����Ƿ�','�����Ƿ�','���տ����Ƿ�','��������Ƿ�'}
Dgtyx

 

%% �����������ؼ��ϲ����� 
clear
clc

BlockCode= '021008'; % ��֤100
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

%% �����������أ���Ѷ�ӿڣ�

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
            
  %% ������Ȩ
  
%   tic;KDataAll=open('Data.mat');toc
%    tic;fqDataAll=open('fq.mat');toc
  clearvars -except KDataAll fqDataAll
  clc
  type='R';
  fieldK=fieldnames(KDataAll);
  fieldFQ=fieldnames(fqDataAll);
  LfieldK=size(fieldK,1);
   hwait=waitbar(0,'��ȴ�>>>>>>>>');
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
       waitbar(i/LfieldK,hwait,[num2str(i/LfieldK*100),'%',':',num2str(fieldK{i}),',',num2str(i),'/',num2str(LfieldK)]);% ������
      
  end
  
   close(hwait);% �رս�����
  %% Ѱ�Ҿ��߽��Ĺ�Ʊ
%   clear
%   clc
%   S=StockAll
% S.ImportData('KL')
   Ma=S.Indicators({'MA'},{[5,20]})
  
  clearvars -except S Ma w
  CodeList=fieldnames(Ma); % �����б�
  L=length(CodeList);
  Gold=[];
  Dead=[];
  tic
  hwait=waitbar(0,'Ѱ��MA�������>>>>>>>>'); % ʱ��ͳ�ƿ�ʼ
  for i=1:L
      Code=CodeList{i};
      ma=eval(['Ma.',Code,';']);
      if size(ma,1)>=2 && ma(end-1,2)<ma(end-1,3) && ma(end,2)>=ma(end,3)
                  Gold=[Gold;Code];
      elseif size(ma,1)>=2 && ma(end-1,2)>ma(end-1,3) && ma(end,2)<=ma(end,3)         
                  Dead=[Dead;Code];
      end
    %  waitbar(i/L,hwait,[num2str(i/L*100),'%',':',num2str(CodeList{i}),',',num2str(i),'/',num2str(L)]);% ������
    waitbar(i/L,hwait);% ������
  end
  close(hwait);% �رս�����
  toc
    % ȥ��ͣ�ƵĹ�Ʊ
  Gold=StockAll.Handicap(cellstr(Gold));
  disp('���ɣ�')
  Gold(find(strcmp(Gold.State,'')),:)
  Dead=StockAll.Handicap(cellstr(Dead));
  disp('����ɣ�')
  Dead(find(strcmp(Dead.State,'')),:)
 %% Ѱ��ͻ��BOLL�Ϲ�ĸ���
   clear
  clc
  S=StockAll
 BOLL=S.Indicators({'BOLL'},{[26,2]})
 % clearvars -except S BOLL
  KL=S.KDataAll;
  CodeList=fieldnames(KL); % �����б�
  L=length(CodeList);
  hwait=waitbar(0,'Ѱ��ͻ��BOLL�Ϲ�>>>>>>>>'); % ʱ��ͳ�ƿ�ʼ
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
     waitbar(i/L,hwait);% ������
  end
  % ȥ��ͣ�ƵĹ�Ʊ
   result=StockAll.Handicap(cellstr(result));
  disp('ͻ��BOLL�Ϲ�ɣ�')
  result(find(strcmp(result.State,'')),:)
  close(hwait);% �رս�����
%% ������Ʊͻ��BOLL�Ϲ������Ʒ���
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

%% ����۸�����ߵľ��룬�ж�֧��λ������λ
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


%% ������ߵ���͵�ѹ��֧��λ

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





