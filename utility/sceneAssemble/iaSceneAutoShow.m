function iaSceneAutoShow(sceneR)
%% this is a plot function to show bird view of placed objects

%% define color map
colormap.car         = [0.2 0.2 0.9 0.9];    
colormap.truck       = [0.8 0.8 0.1 0.9];   
colormap.bus         = [0.8 0.8 0.6 0.9];    

colormap.pedestrian  = [0.7 0.1 0.1 0.9];    
colormap.bicycle     = [0.5 0.5 0.1 0.9];

colormap.tree        = [0.2 0.7 0.2 0.75];    
colormap.building    = [0.3 0.3 0.3 0.75];   
colormap.billboard   = [0.5 0.5 0.5 0.75];    
colormap.callbox     = [0.55 0.55 0.55 0.75]; 
colormap.bench       = [0.6 0.6 0.6 0.75];    
colormap.trashcan    = [0.45 0.45 0.45 0.75]; 
colormap.station     = [0.4 0.4 0.4 0.75];    
colormap.bikerack    = [0.45 0.45 0.45 0.75]; 
colormap.streetlight = [0.7 0.7 0.7 0.75];    


%%
figure(1);

Ids = sceneR.assets.getchildren(1);

nn = 1;
legendlist = [];
legendColor = [];
for ii = 1: length(Ids)
    thisNode = sceneR.assets.get(Ids(ii));
    if strcmp(thisNode.type,'branch') ...
            && isfield(thisNode,'class') ...
             
        L = thisNode.size.l;
        W = thisNode.size.w;
        rotation = thisNode.rotation(:,2);
        % building's pivot is different from other assets, so it's shown in
        % pibuilidngplace
        if ~strcmp(thisNode.class, 'building')
            rectangle2([thisNode.translation(1), thisNode.translation(3), L, W], ...
                'Rotation', -rotation(1), ...
                'FaceColor', colormap.(thisNode.class),...
                'EdgeColor', colormap.(thisNode.class));hold on
%             plot(thisNode.translation(1), thisNode.translation(3),'o');
        hold on
        end
        if nn>1
            if ~strcmp(legendlist{nn-1}, thisNode.class)
                legendlist{nn} = thisNode.class;
                nn = nn + 1;
            end
        else
            legendlist{1} = thisNode.class; 
            nn = nn + 1;
        end
    end
end 
drawnow();

for ii = 1:numel(legendlist)
    hl(ii) = patch([0 0 0 0], [0 0 0 0], colormap.(legendlist{ii})(1:3));
end


% draw camera
x = [sceneR.lookAt.from(1), sceneR.lookAt.to(1)];
y = [sceneR.lookAt.from(3), sceneR.lookAt.to(3)];
text(sceneR.lookAt.from(1), sceneR.lookAt.from(3), 'camera','FontSize',12);
directionAngle = atan(diff(x)/diff(y));
objectDistance = sceneR.get('object distance');
FOV = 90;
theta = FOV*pi/180; 
a1  = pi/2-directionAngle-theta/2;
a2  = a1 + theta;
t   = linspace(a1,a2,32);
x0  = sceneR.lookAt.from(1);
y0  = sceneR.lookAt.from(3);
x   = x0 + objectDistance*cos(t);
y   = y0 + objectDistance*sin(t);

fill([x0,x,x0],[y0,y,y0],'r','EdgeColor','none','FaceAlpha',0.5);
% Legend
legendlist{ii+1} = 'camera';
legend(hl,legendlist,'location','northeastoutside');
axis equal; grid on
title(' SCENEAUTO : Bird view of assembled scene');

savefig('SceneAuto-birdview.fig');
end