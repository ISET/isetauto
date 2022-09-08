function iaAutoMaterialGroupAssignV4(thisR, randomassign)
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
    thisMat = thisR.get('material',materialKeys{ii});
    thisMatName = lower(materialKeys{ii});
    if contains(thisMatName,{'carbody','carpaint'}) 
        if contains(thisMatName,{'carbody_','carpaint_'})
            randomassign = false;
        end

        if strcmp(thisMat.type, 'coatedconductor')
            continue;
        end

        if exist('randomassign','Var') && randomassign
            reflectance = piColorPick('random');
        else
            reflectance = thisMat.reflectance.value;
        end

        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type','coatedconductor',...
            'reflectance value',reflectance);

        if strcmp(thisMat.roughness.type, 'float')
            newMat.conductorroughness.value = randi(5)* 1e-1+0.2;
        else
            newMat.conductorroughness = thisMat.roughness;
        end        
        newMat.interfaceroughness.value = 0.0001;
        thisR.set('material','replace', materialKeys{ii}, newMat);

%     elseif piContains(thisMatName,'window') || ...
%             piContains(thisMatName,'windshield')
% 
%         newMat = piMaterialCreate(materialKeys{ii}, ...
%             'type', 'dielectric','eta','glass-BK7');
%         thisR.set('material','replace', materialKeys{ii}, newMat);

    elseif piContains(thisMatName,'mirror') &&...
            ~strcmpi(materialKeys{ii},'paint_mirror')
        
        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type', 'conductor','eta','metal-Ag-eta','k','metal-Ag-k');

        thisR.set('material','replace', materialKeys{ii}, newMat);

    
    elseif piContains(thisMatName,'chrome') || ...
            piContains(thisMatName,'wheel') || ...
            piContains(thisMatName,'rim') ||...
            piContains(thisMatName,'metal')
    
        if exist('randomassign','Var') && randomassign
            newMat = piMaterialPresets('metal-ag',materialKeys{ii});
            newMat = newMat.material;
        else
            newMat = piMaterialCreate(materialKeys{ii}, 'type', 'conductor');
            newMat.reflectance = thisMat.reflectance;
        end
        
        if strcmp(thisMat.roughness.type, 'float')
            newMat.roughness.value  = rand(1)*0.1;
        else
            newMat.roughness = thisMat.roughness;
        end

        thisR.set('material','replace', materialKeys{ii}, newMat);

    elseif piContains(thisMatName,'tire') ||...
            piContains(thisMatName,'Rubber')

        if exist('randomassign','Var') && randomassign
        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type', 'coateddiffuse',...
            'reflectance', [ 0.03 0.03 0.032 ]);
        else
            newMat = piMaterialCreate(materialKeys{ii}, ...
            'type', 'coateddiffuse');
            newMat.reflectance = thisMat.reflectance;
        end

        if strcmp(thisMat.roughness.type, 'float')
            newMat.roughness.value  = 0.01;
        else
            newMat.roughness = thisMat.roughness;
        end

        thisR.set('material','replace', materialKeys{ii}, newMat);

    elseif contains(thisMatName,'clearglass') && ...
            ~contains(thisMatName,'red')
        
        if exist('randomassign','Var') && randomassign
            MatList = piMaterialPresets('glass list');
            randIndex = randi(numel(MatList));
            newMat = piMaterialPresets(MatList{randIndex},materialKeys{ii});
            newMat = newMat.material;
        else
            newMat = piMaterialCreate(materialKeys{ii}, ...
                'type', 'dielectric','eta',thisMat.eta.value);
        end
        thisR.set('material','replace', materialKeys{ii}, newMat);
%       
%     elseif contains(thisMatName,'glass') && ...
%             contains(thisMatName,'red')
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
