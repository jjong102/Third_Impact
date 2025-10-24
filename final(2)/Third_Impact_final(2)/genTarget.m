function [Xt] = genTarget(x, y)
    global x_ref y_ref  Ld0 x_ref2 y_ref2 presentLane
  
    if presentLane == 1
        X_ref = x_ref;
        Y_ref = y_ref;
    else
        X_ref = x_ref2;
        Y_ref = y_ref2;
    end

    [~, i_near] = min((X_ref-x).^2 + (Y_ref-y).^2);

    Ld = Ld0;
    ds = 0.35;
    i_t = i_near + ceil(Ld0/ds);
    
    if i_t>length(X_ref)
        i_t = mod(i_t,length(X_ref));
    end
    xt = X_ref(i_t); yt = Y_ref(i_t);
    Xt = [xt;yt];
    
end