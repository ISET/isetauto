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

for ii = 1:numel(thisR.materials.list)
    try
    materialName = thisR.materials.list{ii}.name;
    catch
        % no material name, continue to set next material.
        continue;
    end
    if  piContains(lower(thisR.materials.list{ii}.name),'carbody') &&...
             ~piContains(lower(thisR.materials.list{ii}.name),'paint_base')
        % We seem to always be picking a random color for the car body
        % pain base.  This could get adjusted.
        %         if piContains(mlist(ii),'black')
        %             colorkd = piColorPick('black');
        %         elseif piContains(mlist(ii),'white')
        %             colorkd = piColorPick('white');
        %         else
        % Default
        %         end
        rgbkd = piColorPick('random');
        rgbks = [0.15 0.15 0.15];
        
        % change material 
        % this way seems not working right now
        newMat = piMaterialCreate(materialName, ...
            'type','substrate',...
            'kd value',rgbkd,...
            'ks value',rgbks,...
            'uroughness value', 0.0005,...
            'vroughness value', 0.0005);
        thisR.set('material','replace', materialName, newMat);
        
    elseif piContains(lower(thisR.materials.list{ii}.name),'carpaint') &&...
            ~piContains(lower(thisR.materials.list{ii}.name),'paint_base')
        rgbkd = piColorPick('random');
        rgbks = [0.15 0.15 0.15];
        
        % change material
        newMat = piMaterialCreate(materialName, ...
            'type','substrate',...
            'kd value',rgbkd,...
            'ks value',rgbks,...
            'uroughness value', 0.0005,...
            'vroughness value', 0.0005);
        
        thisR.set('material','replace', materialName, newMat);
        
    elseif piContains(lower(thisR.materials.list{ii}.name),'window')
        
        newMat = piMaterialCreate(materialName, ...
            'type','glass',...        
            'kr value',[400 0.5 800 0.5]);
        thisR.set('material','replace', materialName, newMat);
        
    elseif piContains(lower(thisR.materials.list{ii}.name),'mirror') &&...
            ~strcmpi(thisR.materials.list{ii}.name,'paint_mirror')
        
        thisR.set('material', materialName, 'type', 'mirror');
        
    elseif piContains(lower(thisR.materials.list{ii}.name),'lightsfront') ||...
            piContains(lower(thisR.materials.list{ii}.name),'lightfront')
        
        thisR.set('material', materialName, 'type', 'glass');
        
    elseif piContains(lower(thisR.materials.list{ii}.name),'lightsback') ||...
            piContains(lower(thisR.materials.list{ii}.name),'lightback')
        
        rgbkr = [1 0.1 0.1];
        rgbkt = [0.7 0.1 0.1];
        
        newMat = piMaterialCreate(materialName, ...
            'type','glass',...
            'kr value',rgbkr,...
            'kt value',rgbkt);
        
        thisR.set('material','replace', materialName, newMat);
    elseif piContains(lower(thisR.materials.list{ii}.name),'chrome')
        
        newMat = piMaterialCreate(materialName, ...
            'type', 'metal',...
            'k value', 'spds/metals/Ag.k.spd', ...
            'eta value', 'spds/metals/Ag.eta.spd');
        
        thisR.set('material','replace', materialName, newMat);
        
        copyfile(fullfile(piRootPath,'data','spds'), [fileparts(thisR.outputFile),'/spds']);
        
    elseif piContains(lower(thisR.materials.list{ii}.name),'wheel')

        thisR.set('material',materialName, 'type', 'uber');
        
    elseif piContains(lower(thisR.materials.list{ii}.name),'rim')
        
        thisR.set('material',materialName, 'type', 'uber');
        
    elseif piContains(lower(thisR.materials.list{ii}.name),'tire')
        
        newMat = piMaterialCreate(materialName, ...
            'type', 'uber',...
            'roughness value',0.5,...
            'kd value', [0.01 0.01 0.01],...
            'ks value', [0.2 0.2 0.2]);
    
        thisR.set('material','replace', materialName, newMat);

        
    elseif piContains(lower(thisR.materials.list{ii}.name),'plastic')

        newMat = piMaterialCreate(materialName, ...
            'type', 'plastic',...
            'roughness value',0.1,...
            'kd value', [0.25 0.25 0.25],...
            'ks value', [0.25 0.25 0.25]);
        
        thisR.set('material','replace', materialName, newMat);
        
    elseif piContains(lower(thisR.materials.list{ii}.name),'metal')
        
        newMat = piMaterialCreate(materialName, ...
            'type', 'metal',...
            'k value', 'spds/metals/Ag.k.spd', ...
            'eta value', 'spds/metals/Ag.eta.spd');
       
        thisR.set('material','replace', materialName, newMat);
       
        copyfile(fullfile(piRootPath,'data','spds'), [fileparts(thisR.outputFile),'/spds']);
        
    elseif piContains(lower(thisR.materials.list{ii}.name),'glass')
        
        thisR.set('material', materialName, 'type', 'glass');

%     elseif piContains(lower(mlist(ii)),'bodymat')
%         name = cell2mat(mlist(ii));
%         material = thisR.materials.list.(name);
%         target = thisR.materials.lib.substrate;
%         piMaterialAssign(thisR, material.name,target);
    elseif piContains(thisR.materials.list{ii}.name,'translucent')
        
        newMat = piMaterialCreate(materialName, ...
            'type', 'translucent',...
            'roughness value',0.1,...
            'reflect value', [0.5 0.5 0.5],...
            'transmit value', [0.5 0.5 0.5]);
        
        thisR.set('material','replace', materialName, newMat);
        
    elseif piContains(lower(thisR.materials.list{ii}.name),'wall')
        % might change this for other types of random noise
        thisR.materials.list{ii}.texturebumpmap = 'windy_bump';
        
    else
        % Assign an default matte material.
        if ~piContains(thisR.materials.list{ii}.name,'paint_base')
            try
            thisR.set('material',materialName, 'type', 'uber');
            catch
                disp('catch');
            end
        end
    end
end

% Announce!
fprintf('%d materials assigned \n',ii);

end

