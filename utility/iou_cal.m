% IOU Intersection over union score.
%   The inputs can be two masks with the same dimensions
%   (binary,int,float,double matrices), or two vectors holding the
%   coordinates of the vertices of the bounding boxes,
%   ([xmin,ymin,xmax,ymax]), or a matrix Nx4 and a 1x4 vector. In the last
%   case, the output is a vector with the IOU score of mask2 with each one
%   of the bounding boxes in mask1
%
%   d = iou(in1,in2)
%
%   Stavros Tsogkas, <stavros.tsogkas@ecp.fr>
%   Last update: October 2014

% TODO: update help
function d = iou_cal(in1,in2)

% inputs are bounding box vectors   
if (isvector(in1) && numel(in1) == 4) && (isvector(in2) && numel(in2) == 4) 
    intersectionBox = [max(in1(1:2), in2(1:2)), min(in1(3:4), in2(3:4))];
    iw = intersectionBox(3)-intersectionBox(1)+1;
    ih = intersectionBox(4)-intersectionBox(2)+1;
    if iw>0 && ih>0
        % compute overlap as area of intersection / area of union
        unionArea = (in1(3)-in1(1)+1)*(in1(4)-in1(2)+1)+...
                    (in2(3)-in2(1)+1)*(in2(4)-in2(2)+1)- iw*ih;
        d = iw*ih/unionArea;
    else
        d = 0;
    end
% inputs are bounding box matrices
elseif size(in1,2) == 4 && size(in2,2) == 4
    intersectionBox = [max(in1(:,1), in2(:,1)), max(in1(:,2), in2(:,2)),...
                       min(in1(:,3), in2(:,3)), min(in1(:,4), in2(:,4))];
    iw = intersectionBox(:,3)-intersectionBox(:,1)+1;
    ih = intersectionBox(:,4)-intersectionBox(:,2)+1;
    unionArea = bsxfun(@minus, in1(:,3), in1(:,1)-1) .*...
                bsxfun(@minus, in1(:,4), in1(:,2)-1)  +...
                bsxfun(@minus, in2(:,3), in2(:,1)-1) .*...
                bsxfun(@minus, in2(:,4), in2(:,2)-1)  - iw.*ih;    
    d = iw .* ih ./ unionArea;
    d(iw <= 0 | ih <= 0) = 0;
% inputs are binary masks    
elseif ismatrix(in1) && ismatrix(in2) 
    assert(isequal(size(in1),size(in2)),'Masks must have the same dimensions')
    u = nnz(in1 | in2);
    if u > 0
        d = nnz(in1 & in2) / u;
    else
        d = 0;
    end    
else
    error('Input must be two logical masks or two bounding box vector/matrices')
end