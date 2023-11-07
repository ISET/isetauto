function iaBirdEyeView(thisR)
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

classList = {'car', 'truck', 'bus', 'pedestrian', 'bicycle', 'motorcycle'};
%%
figure;

Ids = thisR.assets.getchildren(1);
assetInfo = assetlib();
nn = 1;
legendlist = [];
legendColor = [];
for ii = 2: numel(Ids)
    thisNode = thisR.assets.get(Ids(ii));
    if strcmp(thisNode.type,'branch') && ~thisNode.isObjectInstance
        [inClass,class] = CheckObjectClass(thisNode.name, classList);
        if ~inClass, continue;end
        tmp = strsplit(thisNode.name,'_');
        index = find(contains(tmp,class));
        assetName = [tmp{index},'_',tmp{index+1}];
        thisAsset = assetInfo(assetName);

        length = thisAsset.size(1);
        width = thisAsset.size(2);
        center = [length-thisAsset.frontoverhang(1) 0];
        theta = pi/2-thisNode.rotation{1}(1);
        translation = [thisNode.translation{1}(1), thisNode.translation{1}(2)];
        % building's pivot is different from other assets, so it's shown in
        % pibuilidngplace
        if ~strcmp(class, 'building')
  

            h = rectangle2([thisNode.translation{1}(1), thisNode.translation{1}(2), length, width], ...
                'FaceColor', colormap.(class),...
                'EdgeColor', colormap.(class));
            rotate(h, center+translation, theta);
            text(thisNode.translation{1}(1), thisNode.translation{1}(2),thisNode.name(10:end));
            %             plot(thisNode.translation(1), thisNode.translation(3),'o');
            hold on
        end
        %         if nn>1
%             if ~strcmp(legendlist{nn-1}, class)
        legendlist{nn} = thisNode.name(10:end);
        coloList{nn} = colormap.(class);
                nn = nn + 1;
%             end
%         else
%             legendlist{1} = thisNode.class; 
%             nn = nn + 1;
%         end
    end
end 
drawnow();

for ii = 1:numel(legendlist)
    hl(ii) = patch([0 0 0 0], [0 0 0 0], coloList{ii}(1:3));
end


% draw camera
x = [thisR.lookAt.from(1), thisR.lookAt.to(1)];
y = [thisR.lookAt.from(2), thisR.lookAt.to(2)];
text(thisR.lookAt.from(1), thisR.lookAt.from(2), 'camera','FontSize',12);
directionAngle = atan(diff(x)/diff(y));
objectDistance = thisR.get('object distance')+30;
FOV = 90;
theta = FOV*pi/180; 
a1  = directionAngle+theta/2;
a2  = a1 + theta;
t   = linspace(a1,a2,32);
x0  = thisR.lookAt.from(1);
y0  = thisR.lookAt.from(2);
x   = x0 + objectDistance*cos(t);
y   = y0 + objectDistance*sin(t);

fill([x0,x,x0],[y0,y,y0],'r','EdgeColor','none','FaceAlpha',0.5);
% Legend
legendlist{ii+1} = 'camera';
legend(hl,legendlist,'location','northeastoutside','NumColumns',2);
axis equal; grid on
title(' Bird view of assembled scene');

savefig('SceneAuto-birdview.fig');
end


function [bool,class] = CheckObjectClass(name, classList)
bool = false; class = [];
for ii = 1:numel(classList)
    if contains(name, classList{ii})
        class = classList{ii};
        bool = true;
    end
end

end