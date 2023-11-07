function coord = iaGet3DCoord(ieObject)
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

x = ieObject.metadata.coordinates(pos(1),pos(2),1);
y = ieObject.metadata.coordinates(pos(1),pos(2),2);
z = ieObject.metadata.coordinates(pos(1),pos(2),3);

coord = [z, x, y];
h.Label =['XYZ: ' num2str(z),' ', num2str(x),' ', num2str(y)];

end