classdef Comm<handle
    properties
    end
    events
    end
    methods
        function obj=Comm
        end
    end
    methods (Static)
        function ftsData=table2fts(tableData)
            if ~isa(tableData,'table')
                error('需要转换的数据应为table')
            end
            names=tableData.Properties.VariableNames;
            ftsData=fints(datenum(tableData.Date),tableData{:,2:end},names(2:end));
        end
        function outObj=setFindObj(MainFigureObj,findType,type,prop)
            if nargin <2
                error('至少输入两个参数MainFigureObj和findType')
            elseif nargin <3
                type=[];
            elseif nargin <4
                prop=[];
            else
                error('setFindObj输入参数个数有误')
            end
            validateattributes(MainFigureObj, {'MainFigure'}, {'scalar'});
            indArr=MainFigureObj.indObjArr;
            if isempty(indArr)
                outObj=[];
                return
            end
            switch findType
                case 'CANDLE'
                    outObj=indArr(strcmp({indArr.type},'CANDLE'));
                case 'noCANDLE'
                    outObj=indArr(~strcmp({indArr.type},'CANDLE'));
                otherwise
                    error('setFindObj的type参数输入有误')
            end
            if ~isempty(outObj) && ~isempty(type) && ~isempty(prop)
                eval(['[outObj.',type,']=deal(',num2str(prop),');']);
            elseif ~isempty(outObj) && ~isempty(type) && isempty(prop)
                eval(['arrayfun(@(x) x.',type,',outObj);'])
            end
            
            
        end
        function NameList=indFileName
            NameList={};
            dirNameList={'indication','customiza'};
            for i=1:length(dirNameList)
                mfileList=dir([cd,'\',dirNameList{i},'\*.m']);
                indName=cellfun(@(x) x(1:end-2),{mfileList.name},'UniformOutput',0);
                isBase=strfind(indName,'Base');
                NameList=[NameList;indName(cellfun(@(x) isempty(x),isBase))'];
            end
        end
        function hexColor=rgb2hex(rgbColor)
            if all(rgbColor<=1 & rgbColor>=0)
                Color=round(rgbColor*255);
            elseif all(round(rgbColor)==rgbColor)
                Color=rgbColor;
            end
            hexColor=['#',reshape(dec2hex(Color,2)',1,6)];
        end
        function out=pointLevel(f)
            errorRate=0.001;
            Data=f.Data;
            Low=fts2mat(Data.Low);
            High=fts2mat(Data.High);  
            Close=fts2mat(Data.Close);  
            Open=fts2mat(Data.Open); 
            
            iLow=min([Low,[0;Low(1:end-1)],[Low(2:end);0]],[],2)==Low;
            iHigh=max([High,[0;High(1:end-1)],[High(2:end);0]],[],2)==High;
            
            lowPoint=[Low(iLow),find(iLow>0)];
            highPoint=[High(iHigh),find(iHigh>0)];
            
            lowLevelLeft=zeros(size(lowPoint,1),1);
            lowLevelRight=lowLevelLeft;
            lowTest=lowLevelLeft;
            lowRevTest=lowLevelLeft;
            lowBeCross=lowLevelLeft;
            
            highLevelLeft=zeros(size(highPoint,1),1);
            highLevelRight=highLevelLeft;
            highTest=highLevelLeft;
            highRevTest=highLevelLeft;
            highBeCross=highLevelLeft;
            
            for i=1:size(lowPoint,1)
                leftSmallPos=max(lowPoint(lowPoint(1:i,1)<lowPoint(i,1),2));
                rightSmallPos=min(lowPoint(find(lowPoint(i:end,1)<lowPoint(i,1))+i-1,2));
                if isempty(leftSmallPos)
                    leftSmallPos=lowPoint(1,2);
                end
                if isempty(rightSmallPos)
                    rightSmallPos=lowPoint(end,2);
                end
                hhleft=max(High(leftSmallPos:lowPoint(i,2)));
                lowLevelLeft(i)=(lowPoint(i,1)-hhleft)/hhleft;                
                hhright=max(High(lowPoint(i,2):rightSmallPos));
                lowLevelRight(i)=(hhright-lowPoint(i,1))/lowPoint(i,1);
                
                lowTest(i)=sum(abs((Low(lowPoint(i,2):end)-lowPoint(i,1))/lowPoint(i,1))<=errorRate |...
                           (Low(lowPoint(i,2):end)<Close(lowPoint(i,2):end) & Low(lowPoint(i,2):end)<Open(lowPoint(i,2):end) & Low(lowPoint(i,2):end)<=lowPoint(i,1) & Close(lowPoint(i,2):end)>=lowPoint(i,1) & Open(lowPoint(i,2):end)>=lowPoint(i,1)))-1;
                           
                lowRevTest(i)=sum(abs((High(lowPoint(i,2):end)-lowPoint(i,1))/lowPoint(i,1))<=errorRate |...
                           (High(lowPoint(i,2):end)> Close(lowPoint(i,2):end) & High(lowPoint(i,2):end)>Open(lowPoint(i,2):end) & High(lowPoint(i,2):end)>=lowPoint(i,1) & Close(lowPoint(i,2):end)<=lowPoint(i,1) & Open(lowPoint(i,2):end)<=lowPoint(i,1) ));   
               
                %lowBeCross(i)=sum(lowPoint(i,1)>min(High(lowPoint(i,2):end),Low(lowPoint(i,2):end)) &  lowPoint(i,1)<max(High(lowPoint(i,2):end),Low(lowPoint(i,2):end)));
                 lowBeCross(i)=min(Low(lowPoint(i,2):end))<lowPoint(i,1); 
                %-------------------------------       
%                 if lowPoint(i,2)==312
%                     jj=abs((High(lowPoint(i,2):end)-lowPoint(i,1))/lowPoint(i,1))<=errorRate |...
%                            (High(lowPoint(i,2):end)> Close(lowPoint(i,2):end) & High(lowPoint(i,2):end)>Open(lowPoint(i,2):end) & High(lowPoint(i,2):end)>=lowPoint(i,1) & Close(lowPoint(i,2):end)<=lowPoint(i,1) & Open(lowPoint(i,2):end)<=lowPoint(i,1) );
%                     
%                     Date=Data.dates(lowPoint(i,2):end);
%                     datestr(Date(jj),'yyyy-mm-dd')
%                 end
                %-------------------------------       
            end
            for i=1:size(highPoint,1)
                leftBigPos=max(highPoint(highPoint(1:i,1)>highPoint(i,1),2));
                rightBigPos=min(highPoint(find(highPoint(i:end,1)>highPoint(i,1))+i-1,2));
                if isempty(leftBigPos)
                    leftBigPos=highPoint(1,2);
                end
                if isempty(rightBigPos)
                    rightBigPos=highPoint(end,2);
                end                
                llleft=min(Low(leftBigPos:highPoint(i,2)));
                highLevelLeft(i)=(highPoint(i,1)-llleft)/llleft; 
                llright=min(Low(highPoint(i,2):rightBigPos));
                highLevelRight(i)=(llright-highPoint(i,1))/highPoint(i,1);       
                
                highTest(i)=sum(abs((High(highPoint(i,2):end)-highPoint(i,1))/highPoint(i,1))<=errorRate |...
                           (High(highPoint(i,2):end)> Close(highPoint(i,2):end) & High(highPoint(i,2):end)>Open(highPoint(i,2):end) & High(highPoint(i,2):end)>=highPoint(i,1) & Close(highPoint(i,2):end)<=highPoint(i,1) & Open(highPoint(i,2):end)<=highPoint(i,1) ))-1;
                highRevTest(i)=sum(abs((Low(highPoint(i,2):end)-highPoint(i,1))/highPoint(i,1))<=errorRate |...
                           (Low(highPoint(i,2):end)<Close(highPoint(i,2):end) & Low(highPoint(i,2):end)<Open(highPoint(i,2):end) & Low(highPoint(i,2):end)<=highPoint(i,1) & Close(highPoint(i,2):end)>=highPoint(i,1) & Open(highPoint(i,2):end)>=highPoint(i,1) ));        
                
               % highBeCross(i)=sum(highPoint(i,1)>min(High(highPoint(i,2):end),Low(highPoint(i,2):end)) &  highPoint(i,1)<max(High(highPoint(i,2):end),Low(highPoint(i,2):end)));
                 highBeCross(i)=max(High(highPoint(i,2):end))>highPoint(i,1);
               %-------------------------------       
%                 if highPoint(i,2)==428
%                    llleft 
%                    llright
%                 end
                %-------------------------------                 
            
            
            end    
            outLow=[lowPoint,lowLevelLeft,lowLevelRight,lowTest,lowRevTest,lowBeCross];
            outHigh=[highPoint,highLevelLeft,highLevelRight,highTest,highRevTest,highBeCross];
            out={outLow,outHigh}; % [最低价/最高价，位置，左边降幅/涨幅，右边涨幅/降幅，正向被测试次数,反向被测试次数]
        end
        function out=findFibonacci(f)
            rate=0.10;
            pl=Comm.pointLevel(f);
            ll=pl{1};
            hh=pl{2};
            llFit=ll(ll(:,7)==0 & [0;ll(1:end-1,7)]~=0 & (ll(:,3)<-rate & ll(:,4)>rate),:);
            hhFit=hh(hh(:,7)==0 & [0;hh(1:end-1,7)]~=0 & (hh(:,3)>rate & hh(:,4)<-rate),:);
            
            fpoint=[];
            for i=1:size(llFit,1)
                ihhFit=hhFit(hhFit(:,2)>llFit(i,2),:);
                if ~isempty(ihhFit)
                    startPointX=llFit(i,2);
                    startPointY=llFit(i,1);
                    endPointX=ihhFit(1,2);
                    endPointY=ihhFit(1,1);
                    fpoint=[fpoint;[startPointX,endPointX,startPointY,endPointY,1]];
                end
            end
            for i=1:size(hhFit,1)
                illFit=llFit(llFit(:,2)>hhFit(i,2),:);
                if ~isempty(illFit)
                    startPointX=hhFit(i,2);
                    startPointY=hhFit(i,1);
                    endPointX=illFit(1,2);
                    endPointY=illFit(1,1);
                    fpoint=[fpoint;[startPointX,endPointX,startPointY,endPointY,0]];
                end
                result=cell2table([cellstr(repmat(f.DataSource.Code,size(fpoint,1),1)),num2cell(sortrows(fpoint,1))],'VariableNames',{'Code','point1','point2','price1','price2','upOrdown'});
                f.hResultTable.Data=result;
                
                out=result;
            end
        end
    end
end