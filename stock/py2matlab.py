import tushare as ts
import pandas.io.sql as sql
import pandas as pd
import numpy as np
import threading
import datetime,time
from queue import Queue
import io
from sqlalchemy import create_engine
import scipy.io as sio

# tushare 下载+ postgresql 存储=========================================================================================
class DownLode_TS_thread:
    def __init__(self):
        #conn = psycopg2.connect(database="testDB", user="postgres", password="123456", host="localhost", port="5432")
        self._database="testDB"
        self._user='postgres'
        self._password='123456'
        self._host='localhost'
        self._post='5432'
        self.table_name='aa'

        self.index_field='code'
        self.index_name='code_index'
        self.startDay_df=pd.DataFrame([])

        self.DL_threadNo = 10  # 下载线程数
        self.SV_threadNo = 2  # 存储线程数
        self.S = 0  # 代码列表截取初始位置
        self.L = -1 # 代码列表截取结束位置

        self._check_tablename=1 # 表存在检查标志
        self.queue = Queue()  # 输入队列（代码）
        self.queue_out = Queue()  # 输出队列（数据）
        self.unload = Queue()  # 未下载名单

    # 下载函数
    def download(self,start='1991-01-01',end=datetime.datetime.today().strftime('%Y-%m-%d'),if_exist='replace'):
        # 检测日期输入
        if datetime.datetime.strptime(end, '%Y-%m-%d') < datetime.datetime.strptime(start, '%Y-%m-%d'):
            raise RuntimeError('起始日期晚于结束日期')

        # 追加还是覆盖
        self.engine = create_engine('postgresql+psycopg2://%s:%s@%s:%s/%s' % (self._user, self._password, self._host, self._post, self._database))
        if if_exist=='append' and self.engine.has_table(self.table_name):
            self._check_tablename = -1
            conn = self.engine.raw_connection()
            cur = conn.cursor()
            query = "select distinct code,max(date) as lastDate from aa group by code"
            self.startDay_df=sql.read_sql(query, self.engine)
            self.startDay_df['start_date']=self.startDay_df['lastdate']+datetime.timedelta(days=1)
            try:
                cur.execute('drop index %s' % (self.index_name))
                conn.commit()
            except Exception as e:
                print(e)
            conn.close()



        # 向输入队列里加载代码
        stock_list1 = ts.get_stock_basics().index.tolist()[self.S:self.L]
        stock_list1 = stock_list2=ts.get_index().code.tolist()
        stock_list=list(map(lambda x:'sh'+x if x[0]=='6' else 'sz'+x,stock_list1))+list(map(lambda x:'sh'+x if x[0]=='0' else 'sz'+x,stock_list2))
        stock_list=stock_list[self.S:self.L]
        for code in stock_list:
            self.queue.put(code)


        # 生产者模式（下载数据）
        for i in range(self.DL_threadNo):
           p = threading.Thread(name='下载线程-'+str(i),target=self.from_k, args=(start,end,))
           p.setDaemon(True)
           p.start()

        # 消费者模式(储存数据)
        conn_list=[]

        for j in range(self.SV_threadNo):
            conn = self.engine.raw_connection()
            conn_list.append(conn)
            c = threading.Thread(name='存储线程-' + str(j), target=self.to_psql, args=(conn,))
            c.setDaemon(True)
            c.start()

        # 队列绑定主线程，计算运行时间
        s = datetime.datetime.now()
        self.queue.join()
        e = datetime.datetime.now()
        self.queue_out.join()
        #--------------------------------------------
        for i,conn in enumerate(conn_list):   # conn提交
            conn.commit()
            conn.close()
            print("conn_%s 已经提交 %s"%(i,datetime.datetime.now()))

        #conn=psycopg2.connect(database=self._database, user=self._user, password=self._password, host=self._host, port=self._post) # 加索引
        conn = self.engine.raw_connection()
        cur=conn.cursor()
        cur.execute("CREATE INDEX %s ON %s (%s)"%(self.index_name,self.table_name,self.index_field),conn)
        conn.commit()
        print("建立索引成功")
        conn.close()
        #--------------------------------------------
        e2 = datetime.datetime.now()

        print('download_k下载时间: ')
        print(e-s)
        print('download_k存储时间: ')
        print(e2 - s)
        print('未下载名单：')
        print(self.unload.queue)

    # 下载线程调用函数
    def from_k(self,start,end):
        while True:
            if self.queue.qsize()==0:
                break
            datas=pd.DataFrame()
            code = self.queue.get()
            startD=start
            if not self.startDay_df.empty:
                try:
                    startDatetime=self.startDay_df[self.startDay_df['code'] == code].start_date.tolist()[0]
                    startD=datetime.datetime.strftime(startDatetime,'%Y-%m-%d')
                    print("%s 的开始日为 %s" % (code, startD))

                except Exception as e:
                    startD=start
                    print("%s 的开始日为 %s,%s"%(code,startD,e))

            try:
                datas = ts.get_k_data(code,start=startD,end=end,ktype='D',autype='qfq')
                # if not datas.empty:
                #     datas['ma5']=datas.close.rolling(window=5).mean()
                #     datas['ma10'] = datas.close.rolling(window=10).mean()
                #     datas['ma20'] = datas.close.rolling(window=20).mean()
                #     datas['ma30'] = datas.close.rolling(window=30).mean()
            except Exception as e:
                print('%s发生错误%s' % (code,e))
                self.unload.put(code)
            if not datas.empty:
                self.queue_out.put([code, datas])
            print(threading.current_thread().getName() + '  ' + code + '已经下载，剩余(%s)' % (self.queue.qsize()))
            self.queue.task_done()

    # 下载线程调用函数
    def to_psql(self,conn):
       cur=conn.cursor()
       while True:
            [code, data] = self.queue_out.get()
            # -----------------------------------------------------------
            # 检测表是否存在
            while self._check_tablename!=-1:
                if self._check_tablename==0:
                    continue
                if self._check_tablename==1:
                    self._check_tablename=0
                    self.table_from_df(data)
                    self._check_tablename=-1
            # -----------------------------------------------------------
            self.executemany(cur, data) # 批量导入
            print(threading.current_thread().getName() + '  ' + code + '===已经储存，剩余(%s)' % (self.queue_out.qsize()))
            self.queue_out.task_done()

    # 批量导入函数
    def executemany(self, cur, df):
        # 方法来自stockflow的大牛,导入速度快
        output = io.StringIO()
        df.to_csv(output, sep='\t', header=False, index=False)
        output.seek(0)
        contents = output.getvalue()
        cur.copy_from(output, self.table_name, null="")

    # 根据Dataframe数据建表
    def table_from_df(self,data):
        conn = self.engine.raw_connection()
        cur=conn.cursor()
        d = data.to_records(index=False)
        # 检测表是否存在
        if self.engine.has_table(self.table_name):
            cur.execute('drop table %s' % (self.table_name))
            conn.commit()

        # 转换为建表数据
        type_conv = {'object': 'text', 'float64': 'real', 'int64': 'int'}
        names = d.dtype.names
        str = []
        # 根据字段名称和类型生成建表语句
        for n in names:
            if n.lower() == 'date':
                str.append(n + ' ' + 'date')
            elif  n.lower() == 'datetime':
                str.append(n + ' ' + 'timestamp')
            elif   n.lower() == 'time':
                str.append(n + ' ' + 'time')
            else:
                str.append(n + ' ' + type_conv[d.dtype[n].name])
        colume_str = ',\n'.join(str)
        query = 'CREATE TABLE public.%s(%s) ' % (self.table_name, colume_str)
        cur.execute(query)
        conn.commit()


# 保存Mat文件
def save_Mat():
    engine = create_engine('postgresql+psycopg2://%s:%s@%s:%s/%s' % ('postgres', '123456', 'localhost', '5432', 'testDB'))

    if not engine.has_table('aa'):
        raise RuntimeError('表%s不存在于%s中' % ('aa','testDB'))

    s=datetime.datetime.now()

    sqlStr="select distinct code from aa"
    code_list=sql.read_sql(sqlStr,engine).code.tolist()
    r={}
    for code in code_list:
        print(code)
        sqlStr="select * from aa where code = '%s'"%(code)
        df=sql.read_sql(sqlStr,engine)
        #df.date=df.date.apply(lambda x:time.mktime(x.timetuple()))/86400+719529
        df.date = df.date.apply(lambda x:(x-datetime.date(1970,1,1)).days)+719529
        r[code]=df.as_matrix(['date','open','close','high','low','volume'])
    r['colume_name']=np.array([[['date'],['open'],['close'],['high'],['low'],['volume']]], dtype=object)
    sio.savemat('../Data/Data', r)
    e = datetime.datetime.now()
    print(e-s)
# save_Mat()

# ts实时数据保存在postgresql
def real2psql():
    s = datetime.datetime.now()
    df = ts.get_day_all()
    df['date']=datetime.datetime.today().strftime('%Y-%m-%d')
    e1 = datetime.datetime.now()
    real_time_table = 'rr'
    engine = create_engine(
        'postgresql+psycopg2://%s:%s@%s:%s/%s' % ('postgres', '123456', 'localhost', '5432', 'testDB'))
    conn = engine.raw_connection()
    cur = conn.cursor()
    # 如果该表已经存在则删除
    if engine.has_table(real_time_table):
        #sql.execute('truncate table ' + real_time_table, engine)
        cur.execute('truncate table ' + real_time_table)
        output = io.StringIO()
        df.to_csv(output, sep='\t', header=False, index=False)
        output.seek(0)
        contents = output.getvalue()
        cur.copy_from(output, real_time_table, null="")
    else:
        df.to_sql(real_time_table, engine,index=False)
        cur.execute("CREATE INDEX realdata_index ON rr (code)")
    conn.commit()
    conn.close()
    e2 = datetime.datetime.now()
    print('数据下载time= %s' % (e1 - s))
    print('存储time= %s' % (e2 - s))
#real2psql()
