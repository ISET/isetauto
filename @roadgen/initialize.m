function obj = initialize(obj)

onRoadOBJNames  = fieldnames(obj.onroad);
offRoadOBJNames = fieldnames(obj.offroad);

for ii = 1:numel(onRoadOBJNames)
    obj.onroad.(onRoadOBJNames{ii}).placedList = [];
end

for ii = 1:numel(offRoadOBJNames)
    obj.offroad.(offRoadOBJNames{ii}).placedList = [];
end

end

