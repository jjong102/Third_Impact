function [delta] = genDelta(x,y,yaw,xt,yt, v)
global Ld0 L x_ref y_ref
Ld = Ld0+v*0.5;
alpha = atan2(yt - y, xt - x) - yaw;
alpha = atan2(sin(alpha), cos(alpha));          
delta = atan2(2*L*sin(alpha), Ld);
end
