function obj = cameraSet(obj,cam_type, branchID)
% Place a camera on a road scene
%
% obj      - The road scene
% cam_type - The front, rear, or side camera types
% branchID - Specifies which car to use
%
% See also
%   roadgen

%%
thisCamNode =[];
% get all children under root node.
if ~exist('branchID','var')
    root_children = obj.recipe.assets.getchildren(1);
    n=1;
    for ii = 1:numel(root_children)
        thisBranch = obj.recipe.assets.Node{root_children(ii)};
        if piContains(thisBranch.name, 'car') && ... 
                piContains(thisBranch.name, '_m_B_I')&&...
                thisBranch.isInstance == 0
            thisBranchList{n} = thisBranch; %#ok<AGROW> 
            n = n+1;
        end
    end
    branchID = root_children(ii);
    thisAssetBranch = thisBranchList{randi(n-1)};
else
    thisAssetBranch = obj.recipe.assets.Node{branchID};
end

for ii = 1:numel(thisAssetBranch.extraNode.Node)
    if contains(thisAssetBranch.extraNode.Node{ii}.name,cam_type)
        thisCamNode = thisAssetBranch.extraNode.Node{ii};
        break;
    end
end

if isempty(thisCamNode)
    disp('***Camera type is not available.');
    return
end

% We want to make this use the same methods as in ISET3d.
% All camera set methods there also position and aim the camera.
% They also set the focal distance and aperture and such.
%
% In this case the function is really place the camera on the car pointing
% in some direction.
%
assestTransForm = piTransformCompose(thisAssetBranch.translation{1},thisAssetBranch.rotation{1}, [1,1,1]);
CamLocalTranform= piTransformCompose(thisCamNode.translation{1}, thisCamNode.rotation{1}, [1,1, 1]);

newCamTransform = assestTransForm * CamLocalTranform;
% [T, R, S] = piTransformDecompose(newCamTransform);

from_points = newCamTransform(:,4);
at_points = newCamTransform(:,3);
at_points = at_points * -1;
at_points  = at_points + from_points;

lookAt.from = from_points(1:3);
lookAt.to   = at_points(1:3);
lookAt.up   = [0 0 1];

obj.recipe.set('lookat',lookAt);
fprintf('-->Camera is set on %s(ID:%d) with \n  From:[ %.2f %.2f %.2f] \n    To:[ %.2f %.2f %.2f]\n',...
    thisAssetBranch.name,branchID,...
    from_points(1),from_points(2),from_points(3),...
    at_points(1),at_points(2),at_points(3));

end


