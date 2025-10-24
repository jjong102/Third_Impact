function changedLane = laneChange(u)

ds = 0.35;
safeDist = 20;

poseOfEgo = u(1:4);
poseOfExtra{2} = u(5:8);
poseOfExtra{3} = u(9:12);
poseOfExtra{4} = u(13:16);
poseOfExtra{5} = u(17:20);

for i=2:5
    lane{i} = 0;
    idx{i} = 0;
    distFromEgo{i} = 0;
end

global x_ref y_ref x_ref2 y_ref2 presentLane count Ts

if count < 2/Ts
    count = count + 1;
else
    
    for i=2:5
        [dist1,idx1] = min((x_ref-poseOfExtra{i}(1)).^2 + (y_ref-poseOfExtra{i}(2)).^2);
        [dist2,idx2] = min((x_ref2-poseOfExtra{i}(1)).^2 + (y_ref2-poseOfExtra{i}(2)).^2);

        if dist1<=dist2
            lane{i} = 1;
            idx{i} = idx1;
        else
            lane{i} = 2;
            idx{i} = idx2;
        end
        distFromEgo{i} = sqrt( (poseOfEgo(1)-poseOfExtra{i}(1))^2 + (poseOfEgo(2)-poseOfExtra{i}(2))^2 );
        

        if lane{i} == presentLane && distFromEgo{i}<safeDist
            presentLane = 3-presentLane;
            count = 0;
            break;
        end
    end
end
changedLane = presentLane;