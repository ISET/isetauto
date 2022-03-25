function in = randomPointsInPolygon(x,y,n)
% x, y are coordinates that define a polygon
% n is the number of points that will randomized.
% the result points inside the polygon is not equal to n
% A larger number n generates a large number of points inside the polygon
%
%{
p = linspace(0,2.*pi,9);
x = 1.2*cos(p)';
y = 1.2*sin(p)';
in = randomPointsInPolygon(x,y,500)
figure

plot(x,y) % polygon
axis equal

hold on
plot(pointX(in),pointY(in),'r+') % points inside
plot(pointX(~in),pointY(~in),'bo') % points outside
hold off
%}

pointX = (max(x)-min(x)).*rand(n,1) + min(x);
pointY = (max(y)-min(y)).*rand(n,1) + min(y);
in = inpolygon(pointX, pointY, x, y);
end

