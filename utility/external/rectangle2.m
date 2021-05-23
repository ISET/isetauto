function [hand, rectStrct] = rectangle2(varargin)
% RECTANGLE2 is similar to Matlab's RECTANGLE function with the following
%   key difference.
%     * Position rectangles by their center points rather than by their lower left coordinate.  
%     * Supports creation of multiple rectangles with independent properties
%     * Outputs handles to patch object rather than rectangle
%     * Outputs rectangles parameters including vertices
%     * Option to rotate rectangles about their centers
%
%   RECTANGLE2(POS) creates rectangles in 2D coordinates. POS is an nx4
%   matrix [x y w h] specifying the center (x,y), width (w) and height 
%   (h) of n rectangles in data units on the current axes.
%
%   RECTANGLE2(CNT, WH) specifies the center, CNT, as an nx2 matrix of
%   [x,y] coordinates and the size, WH, as an nx2 matrix of widths and
%   heights. When either CNT or WH is 1x2 and the other is nx2 (n>1), 
%   the 1x2 parameter is replicated for all rectangles.  
%
%   RECTANGLE2(__,'Curvature',cur) adds curvature to the sides of the
%   rectangle. Different curvatures along the horizontal and vertical
%   edges is specified by an nx2 vector for n rectangles. The same length
%   of curvature will be applied to all sides when cur is a scalar.
%   Curvature is expressed by values between 0 (no curvature) and 1
%   (circular/elliptical). If only one row of values is supplied, the
%   same curvature will be applied to all rectangles.
%
%   RECTANGLE2(__,'Rotation',deg) defines the rotation of the rectangle
%   about its center in degrees.  Negative values rotate clockwise. If
%   only one value is supplied, the same rotation will be applied to
%   all rectangles.
%
%   RECTANGLE2(__,Name,Value) specifies rectangle properties using one
%   or more Name,Value pair arguments accepted by Matlab's rectangle
%   function. FaceColor and EdgeColor can be specified for n rectangles
%   by specifying an nx1 cell of character vectors or an nx3 matrix of 
%   rgb values.  LineStyle can also be an nx1 cell of characters. LineWidth
%   can be an nx1 vector of values for n rectangles.  
%
%   Postion (POS | CNT & WH) inputs and, if specified, curvature, rotation, 
%   FaceColor, EdgeColor, LineWidth, and LineStyle must either have the same 
%   number of rows or one row to be used for all rectangles.
%
%   RECTANGLE2(ax,__) specifies the axes.
%
%   [h, rect] = RECTANGLE2(__) returns an nx1 vector of patch handles, h,
%   for n rectangles and a structure, rect, containing data about the
%   rectangles.
%       rect.center(n,:) is 1x2 vector containing the (x,y) center points.
%       rect.size(n,:) is 1x2 vector containing (width,height).
%       rect.curvature(n,:) is 1x2 vector containing curvature inputs.
%       rect.rotation(n) is rotation (deg, negative is counterclockwise).
%       rect.verts{n} contains mx2 matrix of (x,y) verticies.
%       And additional Name-Value parameters in inputs. 
%
%   Example
%       See rectangle2_examples.mlx which accompanied this file on the
%       file exchange.
%
% See also RECTANGLE, PATCH
% Source: <a href = "https://www.mathworks.com/matlabcentral/fileexchange/85418">rectangle2</a>
% Author: <a href = "https://www.mathworks.com/matlabcentral/profile/authors/3753776-adam-danz">Adam Danz</a>
%{
Copyright (c) 2021, Adam Danz
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution
* Neither the name of  nor the names of its
  contributors may be used to endorse or promote products derived from this
  software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
%}
% Version History
% vs 1.0.0   210109   Initial update to FEX.
% vs 1.1.0   210109   Ax handle added to rectangle input; return hold-state; WH can have 1 row;
%                     added Face.VertexData and flexibly get/update verts from either; now creates
%                     patch objects instead (see [1]); updated documentation + examples mlx.
% vs 2.0.0   210111   rect.verts now in plotting order; now pos, cnt&wh, and some name-val pairs can be 
%                     1 row applied to all rects. Output suppressed unless requested; default opt params 
%                     use matlab defaults when possible; Fixed error when detecting Edge and Face properties. 
%                     Minor typo fixes in error msg; comment changes.

%% Input validity
% Get|create axis handle
if isscalar(varargin{1}) && isgraphics(varargin{1}, 'axes')
    narginchk(2,inf)
    ax = varargin{1};
    varargin(1) = [];
else
    narginchk(1,inf)
    ax = [];
end
% Extract position values which is either one nx4 matrix
% or two nx2 matrices.
assert(isnumeric(varargin{1}),'Position inputs must be numeric.')
if size(varargin{1},2)==4
    % POS inputs supplied
    rect.center = varargin{1}(:,1:2);
    rect.size = varargin{1}(:,3:4);
    varargin(1) = [];
elseif size(varargin{1},2)==2 && size(varargin{2},2)==2
    % CNT & WH inputs supplied
    rect.center = varargin{1};
    rect.size = varargin{2};
    varargin(1:2) = [];
else
    error('Positions must be specified either be an nx4 matrix or two nx2 matrices.')
end
% Get name-value pairs
p = inputParser();
p.FunctionName = mfilename;
p.KeepUnmatched = true;	%accept additional parameter value inputs; passed to rectangle()
addParameter(p, 'Curvature', get(0,'defaultRectangleCurvature'), @(x)validateattributes(x,{'numeric'},{'2d','>=',0,'<=',1}));
addParameter(p, 'Rotation', 0, @(x)validateattributes(x,{'numeric'},{'column'}));
addParameter(p, 'FaceColor', get(0,'defaultRectangleFaceColor'));  % Validated later
addParameter(p, 'EdgeColor', get(0,'defaultRectangleEdgeColor'));  % Validated later
addParameter(p, 'LineWidth', get(0,'defaultRectangleLineWidth'), @(x)validateattributes(x,{'numeric'},{'column'})); 
addParameter(p, 'LineStyle', get(0,'defaultRectangleLineStyle'), @(x)validateattributes(x,{'char','string','cell'},{'nonempty'}))
addParameter(p, 'Visible', true); % validation done later (see [2])
parse(p,varargin{:})

% Validate Visible param (see [2])
if (isnumeric(p.Results.Visible) || islogical(p.Results.Visible)) && isscalar(p.Results.Visible)
    visibleTF = logical(p.Results.Visible);
elseif ischar(p.Results.Visible) || (isa(p.Results.Visible,'string') && isStringScalar(p.Results.Visible))
    visibleTF = strcmpi('on',p.Results.Visible);
else
    error('Invalid Visible property. Use 1|0|true|false|''on''|''off''.')
end

% Extract curvature and rotation data
rect.curvature = repmat(p.Results.Curvature,1,3-size(p.Results.Curvature,2)); % copies col 1 if nx1
rect.rotation = p.Results.Rotation;

% FaceColor to cell (graphics functions will do further validation)
if ischar(p.Results.FaceColor)
    rect.FaceColor = {p.Results.FaceColor};
elseif isnumeric(p.Results.FaceColor)
    rect.FaceColor = mat2cell(p.Results.FaceColor, ones(size(p.Results.FaceColor,1),1),size(p.Results.FaceColor,2));
else
    rect.FaceColor = p.Results.FaceColor;
end

% EdgeColor to cell (graphics functions will do further validation)
if ischar(p.Results.EdgeColor)
    rect.EdgeColor = {p.Results.EdgeColor};
elseif isnumeric(p.Results.EdgeColor)
    rect.EdgeColor = mat2cell(p.Results.EdgeColor, ones(size(p.Results.EdgeColor,1),1),size(p.Results.EdgeColor,2));
else
    rect.EdgeColor = p.Results.EdgeColor;
end

% LineWidth will be numeric; LineStyle will be cell.
rect.LineWidth = p.Results.LineWidth; 
rect.LineStyle = cellstr(p.Results.LineStyle); 

% parameter size check
paramCount = [size(rect.center,1); size(rect.size,1); size(rect.curvature,1); size(rect.rotation,1);...
    size(rect.FaceColor,1); size(rect.EdgeColor,1); size(rect.LineWidth,1); size(rect.LineStyle,1)];
nRects = max(paramCount);
if ~all(ismember(paramCount,[1;nRects]))
    error(['Postion (POS | CNT & WH) inputs and, if specified, curvature, rotation, FaceColor, EdgeColor, '...
        'LineWidth, and LineStyle must either have the same number of rows or one row to be used for all rectangles.'])
end
    
% Check that rectangle centers have correct number of rows (1 or nRects)
if size(rect.center,1)==1
    rect.center = repelem(rect.center, nRects, 1);
end
% Check that rectangle sizes have correct number of rows (1 or nRects)
if size(rect.size,1)==1
    rect.size = repelem(rect.size, nRects, 1);
end
% Check that rectangle curvatures have correct number of rows (1 or nRects)
if size(rect.curvature,1)==1
    rect.curvature = repelem(rect.curvature, nRects, 1);
end
% Check that rectangle rotations have correct number of rows (1 or nRects)
if size(rect.rotation,1)==1
    rect.rotation = repelem(rect.rotation, nRects, 1);
end
% Check that rectangle FaceColor have correct number of rows (1 or nRects)
if size(rect.FaceColor,1)==1
    rect.FaceColor = repelem(rect.FaceColor, nRects, 1);
end
% Check that rectangle EdgeColor have correct number of rows (1 or nRects)
if size(rect.EdgeColor,1)==1
    rect.EdgeColor = repelem(rect.EdgeColor, nRects, 1);
end
% Check that rectangle LineWidth have correct number of rows (1 or nRects)
if size(rect.LineWidth,1)==1
    rect.LineWidth = repelem(rect.LineWidth, nRects, 1);
end
% Check that rectangle LineStyle have correct number of rows (1 or nRects)
if size(rect.LineStyle,1)==1
    rect.LineStyle = repelem(rect.LineStyle, nRects, 1);
end

% Prepare the unmatched rectangle() parameters.
% If a param is passed that isn't accepted by rectangle(), an error is thrown from rectangle() function.
unmatchNameVal = reshape([fieldnames(p.Unmatched)'; struct2cell(p.Unmatched)'], 1, []);

%% Produce rectangles
if isempty(ax)
    ax = gca();
end
originalHoldState = ishold(ax);
hold(ax,'on')
rotateFcn = @(theta)[cosd(theta) -sind(theta); sind(theta) cosd(theta)];
h = gobjects(size(rect.center,1),1);
rect.verts = cell(size(rect.center,1),1);
for i = 1:size(rect.center,1)
    rectHandle = rectangle(ax,'Position',[rect.center(i,:)-rect.size(i,:)/2, rect.size(i,:)],...
        'Curvature',rect.curvature(i,:),'FaceColor', rect.FaceColor{i},'EdgeColor',rect.EdgeColor{i},...
        'LineWidth',rect.LineWidth(i),'LineStyle',rect.LineStyle{i},unmatchNameVal{:},'Visible','on'); % Visible must be on, see [2].
    drawnow(); % needed to produce Edge|Face data
    % Get vertices from Edge unless it's empty, then get it from Face
    if isempty(rectHandle.Edge) % when LineStyle is None
        if isempty(rectHandle.Face) % when FaceColor is None
            error(['Rectangle edges and face cannot both be missing. Rectangle properties can be adjusted ' ...
                'aftewards using h=rectangle2(__); set(h,''LineStyle'',__,''LineWidth'',__).'])
        else
            verts = rectHandle.Face.VertexData;
            vertIdx = rectHandle.Face.VertexIndices;
        end
    else
        verts = rectHandle.Edge.VertexData;
        vertIdx = rectHandle.Edge.VertexIndices;
    end
    % Rotate & store verts
    verts = (rotateFcn(rect.rotation(i))*(verts(1:2,:)-rect.center(i,:)') + rect.center(i,:)')';
    % Create patch obj and delete rectangle (see [1]).
    if numel(rect.FaceColor{i})==4
        thisColor = rect.FaceColor{i};
        faceAlpha = thisColor(4);
    else
        faceAlpha = 1;
    end
    h(i) = patch(ax,'Faces',vertIdx,'Vertices',verts,'FaceColor',rectHandle.FaceColor,...
        'EdgeColor',rectHandle.EdgeColor,'LineStyle',rectHandle.LineStyle,...
        'LineWidth',rectHandle.LineWidth, 'FaceAlpha',faceAlpha);
    rect.verts{i} = verts(vertIdx,:); % put vertices in order
    delete(rectHandle)
    
    % Check if visible was specified (see [2])
    if ~visibleTF
        h(i).Visible = false;
    end
end
% Return original hold state
if ~originalHoldState
    hold(ax,'off')
end

%% Return outputs if requested
if nargout>0
    hand = h;
    if nargout > 1
        rectStrct = rect;
    end
end

%% Footnotes
% [1] Vs 1.0.0 merely rotated and updated the vertices of the rectangle object but when the
%   rectangle obj properties are updated later, the verticies are conter-rotated back to their
%   original position. To fix this, patch obects are created instead.
% [2] Rectangle visiblility must be on so the Edge and Face data are created. If user specifies
%   Visible,'off', that is applied later after the patches are created.
