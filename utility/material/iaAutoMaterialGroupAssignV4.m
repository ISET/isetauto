function iaAutoMaterialGroupAssignV4(thisR)
% Map materials.list names into material data using piMaterialAssign
%
% Syntax:
%   iaMaterialGroupAssign(recipe)
%
% Describe:
%  This function manages the material assignments when there are many
%  asset parts. The known part names of the objects in a car or pedestrian
%  (bodymat) is assigned an appropriate material.
%
%  This function processes each of the keys in the materials.list. It looks
%  for a substring in the key name that identifies the type of material. It
%  then creates an appropriate material, given the string, and replaces the
%  current material with one that is designed to match the string.  For
%  example, carpaint or carbody or window.
%
% Materials recognized in this function
%   (carbody ~paint_base), carpaint , window, mirror, lightsfront,
%   lightsback, chrome, wheel, rim, tire, plastic, metal, glass, bodymat,
%   translucent, wall, paint_base
%
% ZL, Vistasoft Team, 2018
% Updated with new iset3d-v4 features, Zhenyi, 2022
%
% See also
%  piMaterial*

%% A scene has a set of materials represented in its recipe

materialKeys = keys(thisR.materials.list);

for ii = 1:numel(materialKeys)
    if  contains(lower(materialKeys{ii}),{'carbody','carpaint'}) && ...
            ~contains(lower(materialKeys{ii}),{'carbody_','carpaint_'})
        
        rgb = piColorPick('random');

        randomRoughness = randi(50)* 1e-4;

        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type','coateddiffuse',...
            'reflectance value',rgb,...
            'roughness value',randomRoughness);
        thisR.set('material','replace', materialKeys{ii}, newMat);

%     elseif piContains(lower(materialKeys{ii}),'window') || ...
%             piContains(lower(materialKeys{ii}),'windshield')
% 
%         newMat = piMaterialCreate(materialKeys{ii}, ...
%             'type', 'dielectric','eta','glass-BK7');
%         thisR.set('material','replace', materialKeys{ii}, newMat);

    elseif piContains(lower(materialKeys{ii}),'mirror') &&...
            ~strcmpi(materialKeys{ii},'paint_mirror')
        
        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type', 'conductor','eta','metal-Ag-eta','k','metal-Ag-k');

        thisR.set('material','replace', materialKeys{ii}, newMat);

%     elseif contains(lower(materialKeys{ii}),'clearglass') 
%         
%         newMat = piMaterialCreate(materialKeys{ii}, ...
%             'type', 'dielectric','eta','glass-BK7');
%         thisR.set('material','replace', materialKeys{ii}, newMat);
    
    elseif piContains(lower(materialKeys{ii}),'chrome') || ...
            piContains(lower(materialKeys{ii}),'wheel') || ...
            piContains(lower(materialKeys{ii}),'rim') ||...
            piContains(lower(materialKeys{ii}),'metal')

        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type', 'conductor', ...
            'eta','metal-Ag-eta','k','metal-Ag-k',...
            'roughness',0.2);

        thisR.set('material','replace', materialKeys{ii}, newMat);

%     elseif piContains(lower(materialKeys{ii}),'tire') ||...
%             piContains(lower(materialKeys{ii}),'Rubber')
% 
%         newMat = piMaterialCreate(materialKeys{ii}, ...
%             'type', 'coateddiffuse',...
%             'roughness',5.8,...
%             'reflectance', [ 0.03 0.03 0.032 ]);
% 
%         thisR.set('material','replace', materialKeys{ii}, newMat);

%     elseif contains(lower(materialKeys{ii}),'glass') && ...
%             ~contains(lower(materialKeys{ii}),'red')
% 
%         newMat = piMaterialCreate(materialKeys{ii}, ...
%             'type', 'dielectric','eta','glass-BK7');
%         thisR.set('material','replace', materialKeys{ii}, newMat);
% 
%     elseif contains(lower(materialKeys{ii}),'glass') && ...
%             contains(lower(materialKeys{ii}),'red')
%         
%         thisMat = thisR.materials.list(materialKeys{ii});
%         
%         newMat_glass = piMaterialCreate([materialKeys{ii}, '_mix_glass'], ...
%             'type', 'dielectric','eta','glass-BK7');
%         newMat_reflectance = piMaterialCreate([materialKeys{ii}, '_mix_reflectance'], ...
%             'type', 'coateddiffuse',...
%             'reflectance', [ 0.99 0.01 0.01 ], ...
%             'roughness',0);
%         newMat_mix = piMaterialCreate(materialKeys{ii})



    else
        % do nothing
        
    end
end

% Announce!
fprintf('%d materials assigned \n',numel(materialKeys));

end
