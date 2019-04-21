classdef myFig < dynamicprops 
    
    properties %(Access = private)
        hfig
        fSet
    end

    methods
        function this = myFig(hfig)
            validateattributes(hfig, {'matlab.ui.Figure'}, {'scalar'});
            this.hfig = hfig;
            %create all the figure properties as dependent dynamic properties:
            for propname = properties(hfig)'
                metaprop = addprop(this, propname{1});
                metaprop.Dependent = true;
                metaprop.SetMethod = @(this, varargin) SetDispatch(this, propname{1}, varargin{:});
                metaprop.GetMethod = @(this) GetDispatch(this, propname{1});
                this.fSet.(propname{1})=hfig.(propname{1});
            end
            this.Color='b'
        end     
        function show(this)
            if ishandle(this.hfig)
                figure(this.hfig);
            else
                f=figure;
                for name=fieldnames(this.fSet)'
                    try
                       f.(name{1})=this.fSet.(name{1});
                    catch
                        this.fSet.(name{1})=f.(name{1});
                        disp(['无法设置属性：',name{1}])
                    end
                end
                this.hfig=f;
            end
        end
    end
    methods (Access = private)
        function SetDispatch(this, propname, varargin)
            %called whenever a dependent dynamic property is set.
            %just dispatch to the figure property
            if ishandle(this.hfig)
               this.hfig.(propname) = varargin{:};
               this.fSet.(propname) = varargin{:};
            else
                this.fSet.(propname) = varargin{:};
            end
        end
        function varargout = GetDispatch(this, propname)
            %called whenever a dependent dynamic property is read.
            %just dispatch to the figure property
            if ishandle(this.hfig)
               varargout{:} = this.hfig.(propname);
            else
                varargout{:}=this.fSet.(propname);
            end
        end
    end
end
