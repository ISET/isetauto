function [ scenes ] = assembleSceneFiles( hints, names, values, varargin )

p = inputParser;
p.addParameter('conditionFiles',{},@iscell);
p.parse(varargin{:});
inputs = p.Results;

% If we pass a cell array of condition files, then we read the files
if ~isempty(inputs.conditionFiles)
    values = {};
    for i=1:length(inputs.conditionFiles)
        [names, vals] = rtbParseConditions(inputs.conditionFiles{i});
        values = cat(1,values,vals);
    end
end

    

searchColumnNames = {'objPosFile'
    'type'
    'lens'
    'microlens'
    'mode'
    'pixelSamples'
    'fNumber'
    'filmDiagonal'
    'distance'
    'orientation'
    'height'
    'PTR'
    'defocus'
    'diffraction'
    'chromaticAberration'
    'lookAtObject'};

searchColumnIDs = zeros(1,length(names));
for i=1:length(searchColumnNames)
    searchColumnIDs = searchColumnIDs | strcmp(names(:),searchColumnNames{i})';
end

if isstruct(hints)
    resultPath = rtbWorkingFolder('hints',hints,...
        'rendererSpecific',true,...
        'folderName','renderings');
else
    resultPath = hints;
end

radianceFileIDs = strcmp(values(:,strcmp(names,'mode')),'radiance');
radianceConditions = values(radianceFileIDs,:);



for f=1:size(radianceConditions,1);
    fprintf('Assembling scene %i/%i\n',f,size(radianceConditions,1));
    
   scenes(f).radiance = fullfile(resultPath,sprintf('%s.mat',radianceConditions{f,1})); 
   
   estimate = radianceConditions(f,:);
   for j=1:length(names)
       if ~strcmp(names{j},'mode')
        scenes(f).(names{j}) = estimate{strcmp(names,names{j})};
       end
   end
   
   
   estimate(strcmp(names,'diffraction')) = {'false'};
   estimate(strcmp(names,'chromaticAberration')) = {'false'};
   estimate(strcmp(names,'defocus')) = {'0'};
   
   % Mesh
   estimate(strcmp(names,'mode')) = {'mesh'}; 
   id = searchCellArray(values(:,searchColumnIDs),estimate(searchColumnIDs));
  
   scenes(f).mesh = [];
   if sum(id) == 1
       scenes(f).mesh = fullfile(resultPath,sprintf('%s.mat',values{id,1}));
   elseif sum(id) > 1
       fprintf('More than one match\n');
   end
   
   %{
   % Depth
   estimate(strcmp(names,'mode')) = {'depth'};
   id = searchCellArray(values(:,searchColumnIDs),estimate(searchColumnIDs));
   
   scenes(f).depth = [];
   if sum(id) == 1
       scenes(f).depth = fullfile(resultPath,sprintf('%s.mat',values{id,1}));
   elseif sum(id) > 1
       fprintf('More than one match\n');
   end
   
   % Material
   estimate(strcmp(names,'mode')) = {'material'};
   id = searchCellArray(values(:,searchColumnIDs),estimate(searchColumnIDs));
   
   scenes(f).depth = [];
   if sum(id) == 1
       scenes(f).depth = fullfile(resultPath,sprintf('%s.pbrt',values{id,1}));
   elseif sum(id) > 1
       fprintf('More than one match\n');
   end
   %}
   
   
    
end

end

function [ id ] = searchCellArray(array, ref)

id = true(size(array,1),1);

for i=1:size(array,2)
    res = cellfun(@(x) isequal(x,ref{i}),array(:,i));
    id = id & res;
end

end

