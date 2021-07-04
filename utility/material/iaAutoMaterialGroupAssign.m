function iaAutoMaterialGroupAssign(thisR)
% Map materials.list names into material data using piMaterialAssign
%
% Brief syntax:
%   iaMaterialGroupAssign(recipe)
%
% Describe:
%  This function was built by ZL to manage the material assignments
%  when there are many asset parts. This is frequently the case in the
%  isetauto driving scenes. The known part names are from cars or
%  pedestrian (bodymat).  This list is
%
%  This function processes all the entries in the materials.list in
%  the recipe and invokes the piMaterialAssign for the cars in the
%  isetauto simulation. That function assigns the material to the
%  recipe.  This information is used by PBRT to render the object
%  materials.
%
% Materials recognized in this function
%   (carbody ~paint_base), carpaint , window, mirror, lightsfront, lightsback
%   chrome, wheel, rim, tire, plastic, metal, glass, bodymat, translucent,
%   wall, paint_base
%
% ZL, Vistasoft Team, 2018
% Updated with new iset3d features, Zhenyi, 2021
%
% See also
%  piMaterial*

%% A scene has a set of materials represented in its recipe

% Check whether each entry in mlist contains a known string, such as
% 'carbody'.  If it does contain that string, do a particular
% assignment using (piMaterialAssign).
%
% For each string in the mlist, there is a rule that converts the
% string to a particular material definition in PBRT. That conversion
% is implemented in the if then/else statement below.
%
% The mlist entry might be, say, 'carbody black'.  Then we would
% assign the colorkd to the materal, and we would assign the material
% with the colorkd to the recipe.
materialKeys = keys(thisR.materials.list);

for ii = 1:numel(materialKeys)
    if  piContains(lower(materialKeys{ii}),'carbody') &&...
             ~piContains(lower(materialKeys{ii}),'paint_base')

%         rgb = piColorPick('random');
        rgb = [0.7 0.7 0.7];

        % change material
        % this way seems not working right now
        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type','coateddiffuse',...
            'reflectance value',rgb,...
            'roughness value',0.01);
        thisR.set('material','replace', materialKeys{ii}, newMat);

    elseif piContains(lower(materialKeys{ii}),'carpaint') &&...
            ~piContains(lower(materialKeys{ii}),'paint_base')
        
%         rgb = piColorPick('random');
        rgb = [0.7 0.1 0.1];

        % change material
        % this way seems not working right now
        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type','coateddiffuse',...
            'reflectance',rgb,...
            'roughness',0.01);
        thisR.set('material','replace', materialKeys{ii}, newMat);

    elseif piContains(lower(materialKeys{ii}),'window')

        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type', 'dielectric','eta','glass-BK7');
        thisR.set('material','replace', materialKeys{ii}, newMat);

    elseif piContains(lower(materialKeys{ii}),'mirror') &&...
            ~strcmpi(materialKeys{ii},'paint_mirror')
        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type', 'conductor','eta','metal-Ag-eta','k','metal-Ag-k');

        thisR.set('material','replace', materialKeys{ii}, newMat);

    elseif piContains(lower(materialKeys{ii}),'lightsfront') ||...
            piContains(lower(materialKeys{ii}),'lightfront')
        
        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type', 'dielectric','eta','glass-BK7');
        thisR.set('material','replace', materialKeys{ii}, newMat);

    elseif piContains(lower(materialKeys{ii}),'lightsback') ||...
            piContains(lower(materialKeys{ii}),'lightback')

        rgbkr = [1 0.1 0.1];
        rgbkt = [0.7 0.1 0.1];

        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type','dielectric',...
            'eta',1.3);
        thisR.set('material','replace', materialKeys{ii}, newMat);
    elseif piContains(lower(materialKeys{ii}),'chrome') || ...
            piContains(lower(materialKeys{ii}),'wheel') || ...
            piContains(lower(materialKeys{ii}),'rim') ||...
            piContains(lower(materialKeys{ii}),'metal')

        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type', 'coateddiffuse',...
            'reflectance', [ 0.64 0.64 0.64 ], ...
            'roughness',0.075);

        thisR.set('material','replace', materialKeys{ii}, newMat);

    elseif piContains(lower(materialKeys{ii}),'tire') ||...
            piContains(lower(materialKeys{ii}),'Rubber')

        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type', 'coateddiffuse',...
            'roughness',5.8,...
            'reflectance', [ 0.03 0.03 0.032 ]);

        thisR.set('material','replace', materialKeys{ii}, newMat);


%     elseif piContains(lower(materialKeys{ii}),'plastic')
% 
%         newMat = piMaterialCreate(materialKeys{ii}, ...
%             'type', 'coateddiffuse',...
%             'roughness value',0.1);
% 
%         thisR.set('material','replace', materialKeys{ii}, newMat);

    elseif piContains(lower(materialKeys{ii}),'glass')

        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type', 'dielectric','eta','glass-BK7');
        thisR.set('material','replace', materialKeys{ii}, newMat);

%     elseif piContains(lower(mlist(ii)),'bodymat')
%         name = cell2mat(mlist(ii));
%         material = thisR.materials.list.(name);
%         target = thisR.materials.lib.substrate;
%         piMaterialAssign(thisR, material.name,target);
%     elseif piContains(materialKeys{ii},'translucent')
% 
%         newMat = piMaterialCreate(materialKeys{ii}, ...
%             'type', 'translucent',...
%             'roughness value',0.1,...
%             'reflect value', [0.5 0.5 0.5],...
%             'transmit value', [0.5 0.5 0.5]);
% 
%         thisR.set('material','replace', materialKeys{ii}, newMat);

%     elseif piContains(lower(materialKeys{ii}),'wall')
%         % might change this for other types of random noise
%         thisR.materials.list{ii}.texturebumpmap = 'windy_bump';

    else
        % do nothing
        
        % Assign an default matte material.
%         if ~piContains(materialKeys{ii},'paint_base')
%             try
%             thisR.set('material',materialKeys{ii}, 'type', 'uber');
%             catch
%                 disp('catch');
%             end
%         end
    end
end

% Announce!
fprintf('%d materials assigned \n',ii);

end
