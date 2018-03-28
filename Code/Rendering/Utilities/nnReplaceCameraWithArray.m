function [ outCameras ] = nnReplaceCameraWithArray( cameras, numHorz, numVert, horzStride, vertStride )

outCameras = cell(size(cameras));

for c=1:length(cameras)
    
    for c2=1:length(cameras{c})
        
        upDir = cameras{c}(c2).upDir;
        lookDir = cameras{c}(c2).lookAt - cameras{c}(c2).position;
        
        sensorPlaneUp = upDir - lookDir*upDir';
        sensorPlaneUp = sensorPlaneUp/norm(sensorPlaneUp);
        
        sensorPlaneSide = cross(sensorPlaneUp,lookDir);
        sensorPlaneSide = sensorPlaneSide/norm(sensorPlaneSide);
        
        horzStart = -(numHorz-1)/2 * horzStride;
        vertStart = -(numVert-1)/2 * vertStride;
        
        cameraArray = repmat(cameras{c}(c2),numHorz*numVert,1);
        
        for i=1:numHorz
            for j=1:numVert
                
                horzPos = horzStart + (i-1)*horzStride;
                vertPos = vertStart + (j-1)*vertStride;
                
                currentPos = cameras{c}(c2).position + horzPos*sensorPlaneSide + vertPos*sensorPlaneUp;
                
                cameraArray((i-1)*numVert + j).position = currentPos;
                
            end
        end
        
        outCameras{c} = cat(1,outCameras{c},cameraArray);
    end
end

end

