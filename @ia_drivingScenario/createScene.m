function scene = createScene(varargin)
%CREATESCENE Create the scene as it would appear at a specific time

% The motivation is that for an AEB scenario, once we know how far away the
% vehicle is, and the movement of the pedestrian, we can calculate at what
% time/distance the vehicle needs to be able to detect the pedestrian in
% order to be able to stop quickly enough.

% As an optimization, rather than rendering every frame (very expensive)
% from the beginning of the scenaro, we can render the critical frame where
% the vehicle really needs to have identified the pedestrian, and then use
% that scene as a "metric scene" to evaluate various imaging options.

end

