classdef ia_drivingScenario < drivingScenario
    %IA_DRIVINGSCENARIO our custom version of a driving scenario

    
    properties
    end
    
    methods
        function ds = ia_drivingScenario(varargin)

            % Let the Matlab driving scenario set things up first
            % ds now contains a "blank slate" scenario
            try
                %parseInputs(ds, varargin{:});
            catch ME
                throwAsCaller(ME);
            end
        end
    end
end

