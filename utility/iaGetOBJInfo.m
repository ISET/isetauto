function OBJInfo = iaGetOBJInfo(thisR, ieObject,seg)

if strcmp(ieObject.type,'scene')
    ieObject = sceneSet(ieObject, 'display mode','hdr');
    rgb = sceneGet(ieObject,'rgb image');

else
    ieObject = oiSet(ieObject, 'display mode','hdr');
    rgb = oiGet(ieObject,'rgb image');

end
figure;imshow(rgb);

h = drawpoint();

pos= round(h.Position);

% this is the object ID
objectId = seg(pos(2), pos(1));

Ids = thisR.assets.getchildren(1);

nn = 0;
for ii = 1: numel(Ids)
    thisNode = thisR.assets.get(Ids(ii));
   isObjectInstance = false;
   if thisNode.isObjectInstance && ~isfield(thisNode, 'instanceCount')
       isObjectInstance = true;
   elseif ~thisNode.isObjectInstance && isfield(thisNode, 'instanceCount') &&...
           ~isempty(thisNode.instanceCount)
       isObjectInstance = true;
   end
    if isObjectInstance
        nn = nn+1;
        if nn == objectId
            OBJInfo = thisNode;
            break
        end
    end
end

h.Label = sprintf('%s', thisNode.name(10:end));

fprintf(' %s \n Pos: %f %f %f \n YRot: %f \n', ...
    thisNode.name, thisNode.translation{1},thisNode.rotation{1}(1));

end

