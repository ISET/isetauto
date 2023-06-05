classdef actor < matlab.mixin.Copyable
    %ACTOR Dynamic Elements in our scenes
    %   Place and animage assets for running scenarios
    %
    % D. Cardinal, Stanford University, June, 2023
    %
    properties
        name;
        assetType;
        branchID;
        position;
        rotation;
        velocity;
    end
    
    methods
        function obj = actor(inputArg1,inputArg2)
            %ACTOR Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Property1 + inputArg;
        end
    end
end

