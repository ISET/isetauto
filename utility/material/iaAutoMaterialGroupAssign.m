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
        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type','substrate',...
            'kd value',rgbkd,...
            'ks value',rgbks,...
            'uroughness value', 0.0005,...
            'vroughness value', 0.0005);
        thisR.set('material','replace', materialKeys{ii}, newMat);

    elseif piContains(lower(materialKeys{ii}),'carpaint') &&...
            ~piContains(lower(materialKeys{ii}),'paint_base')
        rgbkd = piColorPick('random');
        rgbks = [0.15 0.15 0.15];

        % change material
        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type','substrate',...
            'kd value',rgbkd,...
            'ks value',rgbks,...
            'uroughness value', 0.0005,...
            'vroughness value', 0.0005);

        thisR.set('material','replace', materialKeys{ii}, newMat);

    elseif piContains(lower(materialKeys{ii}),'window')

        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type','glass',...
            'kr value',[400 0.5 800 0.5]);
        thisR.set('material','replace', materialKeys{ii}, newMat);

    elseif piContains(lower(materialKeys{ii}),'mirror') &&...
            ~strcmpi(materialKeys{ii},'paint_mirror')

        thisR.set('material', materialKeys{ii}, 'type', 'mirror');

    elseif piContains(lower(materialKeys{ii}),'lightsfront') ||...
            piContains(lower(materialKeys{ii}),'lightfront')

        thisR.set('material', materialKeys{ii}, 'type', 'glass');

    elseif piContains(lower(materialKeys{ii}),'lightsback') ||...
            piContains(lower(materialKeys{ii}),'lightback')

        rgbkr = [1 0.1 0.1];
        rgbkt = [0.7 0.1 0.1];

        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type','glass',...
            'kr value',rgbkr,...
            'kt value',rgbkt);

        thisR.set('material','replace', materialKeys{ii}, newMat);
    elseif piContains(lower(materialKeys{ii}),'chrome')

        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type', 'metal',...
            'k value', 'spds/metals/Ag.k.spd', ...
            'eta value', 'spds/metals/Ag.eta.spd');

        thisR.set('material','replace', materialKeys{ii}, newMat);

       spd_dir = [fileparts(thisR.outputFile),'/spds'];
       if ~exist(fullfile(spd_dir,'metals/Ag.k.spd'), 'file')
           copyfile(fullfile(piRootPath,'data','spds'), [fileparts(thisR.outputFile),'/spds']);
       end

    elseif piContains(lower(materialKeys{ii}),'wheel')

        thisR.set('material',materialKeys{ii}, 'type', 'uber');

    elseif piContains(lower(materialKeys{ii}),'rim')

        thisR.set('material',materialKeys{ii}, 'type', 'uber');

    elseif piContains(lower(materialKeys{ii}),'tire') ||...
            piContains(lower(materialKeys{ii}),'Rubber')

        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type', 'uber',...
            'roughness value',0.5,...
            'kd value', [0.01 0.01 0.01],...
            'ks value', [0.2 0.2 0.2]);

        thisR.set('material','replace', materialKeys{ii}, newMat);


    elseif piContains(lower(materialKeys{ii}),'plastic')

        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type', 'plastic',...
            'roughness value',0.1,...
            'kd value', [0.25 0.25 0.25],...
            'ks value', [0.25 0.25 0.25]);

        thisR.set('material','replace', materialKeys{ii}, newMat);

    elseif piContains(lower(materialKeys{ii}),'metal')

        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type', 'metal',...
            'k value', 'spds/metals/Ag.k.spd', ...
            'eta value', 'spds/metals/Ag.eta.spd');
        thisR.set('material','replace', materialKeys{ii}, newMat);

       spd_dir = [fileparts(thisR.outputFile),'/spds'];
       if ~exist(fullfile(spd_dir,'metals/Ag.k.spd'), 'file')
           source_dir = fullfile(iaRootPath,'data','spds');
           if exist(source_dir, 'dir')
              copyfile(source_dir, [fileparts(thisR.outputFile),'/spds']);
           end
       end

    elseif piContains(lower(materialKeys{ii}),'glass')

        thisR.set('material', materialKeys{ii}, 'type', 'glass');

%     elseif piContains(lower(mlist(ii)),'bodymat')
%         name = cell2mat(mlist(ii));
%         material = thisR.materials.list.(name);
%         target = thisR.materials.lib.substrate;
%         piMaterialAssign(thisR, material.name,target);
    elseif piContains(materialKeys{ii},'translucent')

        newMat = piMaterialCreate(materialKeys{ii}, ...
            'type', 'translucent',...
            'roughness value',0.1,...
            'reflect value', [0.5 0.5 0.5],...
            'transmit value', [0.5 0.5 0.5]);

        thisR.set('material','replace', materialKeys{ii}, newMat);

    elseif piContains(lower(materialKeys{ii}),'wall')
        % might change this for other types of random noise
        thisR.materials.list{ii}.texturebumpmap = 'windy_bump';

    else
        % Assign an default matte material.
        if ~piContains(materialKeys{ii},'paint_base')
            try
            thisR.set('material',materialKeys{ii}, 'type', 'uber');
            catch
                disp('catch');
            end
        end
    end
end

% Announce!
fprintf('%d materials assigned \n',ii);

end
