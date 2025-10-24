function [Xt] = genTarget(x,y)
    global x_ref y_ref ss Ld0
    [~, i_near] = min((x_ref-x).^2 + (y_ref-y).^2);
    Ld = Ld0;
    s_target = ss(i_near) + Ld;
    i_t = find(ss >= s_target, 1, 'first');
    if isempty(i_t)
        i_t = numel(ss); 
    end
    xt = x_ref(i_t); yt = y_ref(i_t);
    Xt = [xt;yt];
end