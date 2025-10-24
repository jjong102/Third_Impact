function [e_dist, e_ang] = genError(x,y,yaw)

% e_dist = 0;
% e_ang = 0;

global x_ref y_ref


[~, i_near] = min((x_ref-x).^2 + (y_ref-y).^2);


if i_near == length(x_ref)
    dx_ref = x_ref(1)-x_ref(i_near);
    dy_ref = y_ref(1)-y_ref(i_near);
else
    dx_ref = x_ref(i_near+1)-x_ref(i_near);
    dy_ref = y_ref(i_near+1)-y_ref(i_near);
end

dx = x-x_ref(i_near);
dy = y-y_ref(i_near);


e_ang = yaw-atan2(dy_ref,dx_ref);

sig = sign(atan2(dy,dx)-atan2(dy_ref,dx_ref));

e_dist = sig*sqrt(dx^2 + dy^2);

end

