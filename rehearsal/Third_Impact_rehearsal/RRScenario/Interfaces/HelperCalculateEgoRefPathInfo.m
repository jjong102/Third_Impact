classdef HelperCalculateEgoRefPathInfo < matlab.System
    % HelperCalculateEgoRefPathInfo calculates Ego Reference Path with the
    % path points received from RoadRunner Scenario Path action. The output
    % ego reference path has the following information 
    % x, y, theta, kappa and speed 
    %  information.
    %
    % NOTE: The name of this System Object and it's functionality may
    % change without notice in a future release, or the System Object
    % itself may be removed.
    %

    % Copyright 2022-2023 The MathWorks, Inc.

    properties(Nontunable)
        %EgoSpeed Ego Speed
        EgoSpeed = 0;

        %SpaceResolution Space Resolution
        SpaceResolution = 0.1;
        
        %DefaultEgoRefPath Ego Reference Path Structure
        DefaultEgoRefPath  = Simulink.Bus.createMATLABStruct("BusEgoRefPath");
    end

    % Pre-computed constants
    properties(Access = private)
        EgoRefPath
    end

    methods(Access = protected)
        function [egoRefPath] = stepImpl(obj, PathAction)
            egoRefPath = obj.DefaultEgoRefPath;

            % Get trajectory information from path action from RRS
            if ~isempty(PathAction)
                egoPath = PathAction.PathTarget.Path; % waypoints [x,y,z]
                numPts = double(PathAction.PathTarget.NumPoints);
                
                %Calculate refpath attributes by interpolating the egoPath
                %from RoadRunner.
                [refPathInfo, interpolatedArcLengths] = calculateRefPathAttributes(obj, egoPath(1:numPts,1:3), obj.SpaceResolution);
                numPts = size(interpolatedArcLengths,1);
                egoRefPath.x(1:numPts)  = refPathInfo(:).x;
                egoRefPath.y(1:numPts) = refPathInfo(:).y;
                egoRefPath.theta(1:numPts) = refPathInfo(:).theta;
                egoRefPath.kappa(1:numPts) = refPathInfo(:).kappa;
                egoRefPath.speed(1:numPts) = ones(numPts,1)*obj.EgoSpeed;
                egoRefPath.arcLength(1:numPts) = interpolatedArcLengths;
                egoRefPath.numPoints = numPts;

                % Update EgoRefPath
                obj.EgoRefPath = egoRefPath;
            end

            %Update the output with refpath calculated during the initial
            %step of simulation.
            egoRefPath = obj.EgoRefPath;
        end


        function [refPath, interpolatedArcLengths] = calculateRefPathAttributes(obj, path, discretizationDist)
            % calculateRefPathAttributes function interpolates the RR path points at even
            % intervals specified by the discretizationDist and then calculates the
            % refpath info.
            
            % Calculate path length
            [arcLength,~,~] = curvature(obj, path);

            %Calculate number of points on path
            numPts = round(arcLength(end)/discretizationDist);
            
            %Calculate the equally spaced intervals
            s = linspace(0, arcLength(end), numPts);
            
            %Interpolate the x values in path for the equal intervals
            interpX = interp1(arcLength, path(:,1), s, 'spline');
            
            %Interpolate the y values in path for the equal intervals
            interpY = interp1(arcLength, path(:,2), s, 'spline');
            
            %Initialize z with zeros
            z = zeros(1, length(interpX));
            
            %Interpolate the y values in path for the equal intervals
            interpZ = interp1(arcLength, path(:,3), s, 'spline');

            %Concatenate X, Y, and Z 
            InterpolatedPathX_Y_Z = cat(2,interpX',interpY',interpZ');
                
            %Calculate the new interpolated arc length
            [interpolatedArcLengths,~,~] = curvature(obj, InterpolatedPathX_Y_Z);
            
            %Calculate the refpath for the interpolated x, y, and Z. 
            refPath = convPath2RefPath(obj, InterpolatedPathX_Y_Z);
        end

        function refPath = convPath2RefPath(obj, path)
            %convPath2RefPath computes ref path info (theta, kappa, elevation, grade,
            %bank) from the path points.
            refPath = referencePath(obj, numel(path(:,1)));
            [s, theta, kappa] = thetaKappaFit(obj, path(:,1:2));
            x = path(:,1);
            y = path(:,2);
            elev = path(:,3);
            denom = gradient(s);
            denom(denom==0)= 0.001;
            grade = gradient(elev)./denom;
            bank = zeros(length(s), 1);
            refPath.s = s;
            refPath.x = x;
            refPath.y = y;
            refPath.theta = theta;
            refPath.kappa = kappa;
            refPath.elev = elev;
            refPath.grade = grade;
            refPath.bank = bank;
        end

        function out = referencePath(obj, numPoints)
            %Initialize refpath info output with zeros
            out = struct('s', zeros(numPoints, 1), ...
                'x', zeros(numPoints, 1), ...
                'y', zeros(numPoints, 1), ...
                'theta', zeros(numPoints, 1), ...
                'kappa', zeros(numPoints, 1), ...
                'elev', zeros(numPoints, 1), ...
                'grade', zeros(numPoints, 1), ...
                'bank', zeros(numPoints, 1), ...
                'speed', ones(numPoints, 1)*-1,...
                'time', ones(numPoints, 1)*-1,...
                'waitTime', ones(numPoints, 1)*-1); %%#ok<NASGU>
        end

        function [s,theta,kappa] = thetaKappaFit(obj, waypointsIn)
            %thetaKappaFit computes theta and kappa from the waypoints.
            dx = diff(waypointsIn(:,1));
            dy = diff(waypointsIn(:,2));
            temp = atan2(dy,dx);
            theta = [temp(1);temp];
            temp = sqrt(dx.^2+dy.^2);
            s = [0;cumsum(temp)];
            if size(waypointsIn,1)>2
                kappa = lineCurvature2D(obj, waypointsIn);
            else % when there are only two points assuming line
                kappa = [0;0];
            end
            kappa(kappa>1) =0; % miss fit
        end

        function kappa = lineCurvature2D(obj, Vertices, Lines)
            % This function calculates the curvature of a 2D line. It first fits
            % polygons to the points. Then calculates the analytical curvature from
            % the polygons;

            % If no line-indices, assume a x(1) connected with x(2), x(3) with x(4) ...
            if(nargin<3)
                Lines=[(1:(size(Vertices,1)-1))' (2:size(Vertices,1))'];
            end

            % Get left and right neighbor of each points
            Na=zeros(size(Vertices,1),1); Nb=zeros(size(Vertices,1),1);
            Na(Lines(:,1))=Lines(:,2); Nb(Lines(:,2))=Lines(:,1);

            % Check for end of line points, without a left or right neighbor
            checkNa=Na==0; checkNb=Nb==0;
            Naa=Na; Nbb=Nb;
            Naa(checkNa)=find(checkNa); Nbb(checkNb)=find(checkNb);

            % If no left neighbor use two right neighbors, and the same for right...
            Na(checkNa)=Nbb(Nbb(checkNa)); Nb(checkNb)=Naa(Naa(checkNb));

            % Correct for sampeling differences
            Ta=-sqrt(sum((Vertices-Vertices(Na,:)).^2,2));
            Tb=sqrt(sum((Vertices-Vertices(Nb,:)).^2,2));

            % If no left neighbor use two right neighbors, and the same for right...
            Ta(checkNa)=-Ta(checkNa); Tb(checkNb)=-Tb(checkNb);

            % Fit a polygons to the vertices
            % x=a(3)*t^2 + a(2)*t + a(1)
            % y=b(3)*t^2 + b(2)*t + b(1)
            % we know the x,y of every vertice and set t=0 for the vertices, and
            % t=Ta for left vertices, and t=Tb for right vertices,
            x = [Vertices(Na,1) Vertices(:,1) Vertices(Nb,1)];
            y = [Vertices(Na,2) Vertices(:,2) Vertices(Nb,2)];
            M = [ones(size(Tb)) -Ta Ta.^2 ones(size(Tb)) zeros(size(Tb)) zeros(size(Tb)) ones(size(Tb)) -Tb Tb.^2];
            invM=inverse3(obj, M);
            a = zeros(size(M,1),3);
            b = zeros(size(M,1),3);
            a(:,1)=invM(:,1,1).*x(:,1)+invM(:,2,1).*x(:,2)+invM(:,3,1).*x(:,3);
            a(:,2)=invM(:,1,2).*x(:,1)+invM(:,2,2).*x(:,2)+invM(:,3,2).*x(:,3);
            a(:,3)=invM(:,1,3).*x(:,1)+invM(:,2,3).*x(:,2)+invM(:,3,3).*x(:,3);
            b(:,1)=invM(:,1,1).*y(:,1)+invM(:,2,1).*y(:,2)+invM(:,3,1).*y(:,3);
            b(:,2)=invM(:,1,2).*y(:,1)+invM(:,2,2).*y(:,2)+invM(:,3,2).*y(:,3);
            b(:,3)=invM(:,1,3).*y(:,1)+invM(:,2,3).*y(:,2)+invM(:,3,3).*y(:,3);

            % Calculate the curvature from the fitted polygon
            kappa = 2*(a(:,2).*b(:,3)-a(:,3).*b(:,2)) ./ ((a(:,2).^2+b(:,2).^2).^(3/2));
        end
        
        function  Minv  = inverse3(obj, M)
            % This function does inv(M) , but then for an array of 3x3 matrices
            adjM = zeros(size(M,1),3,3);
            adjM(:,1,1)=  M(:,5).*M(:,9)-M(:,8).*M(:,6);
            adjM(:,1,2)=  -(M(:,4).*M(:,9)-M(:,7).*M(:,6));
            adjM(:,1,3)=  M(:,4).*M(:,8)-M(:,7).*M(:,5);
            adjM(:,2,1)=  -(M(:,2).*M(:,9)-M(:,8).*M(:,3));
            adjM(:,2,2)=  M(:,1).*M(:,9)-M(:,7).*M(:,3);
            adjM(:,2,3)=  -(M(:,1).*M(:,8)-M(:,7).*M(:,2));
            adjM(:,3,1)=  M(:,2).*M(:,6)-M(:,5).*M(:,3);
            adjM(:,3,2)=  -(M(:,1).*M(:,6)-M(:,4).*M(:,3));
            adjM(:,3,3)=  M(:,1).*M(:,5)-M(:,4).*M(:,2);
            detM=M(:,1).*M(:,5).*M(:,9)-M(:,1).*M(:,8).*M(:,6)-M(:,4).*M(:,2).*M(:,9)+M(:,4).*M(:,8).*M(:,3)+M(:,7).*M(:,2).*M(:,6)-M(:,7).*M(:,5).*M(:,3);
            Minv=bsxfun(@rdivide,adjM,detM);
        end

        function [R,M,k] = circumcenter(obj, A,B,C)
            % Center and radius of the circumscribed circle for the triangle ABC
            %  A,B,C  3D coordinate vectors for the triangle corners
            %  R      Radius
            %  M      3D coordinate vector for the center
            %  k      Vector of length 1/R in the direction from A towards M
            %         (Curvature vector)
            D = cross(B-A,C-A);
            b = norm(A-C);
            c = norm(A-B);
            if nargout == 1
                a = norm(B-C);     % slightly faster if only R is required
                R = a*b*c/2/norm(D);
                if norm(D) == 0
                    R = Inf;
                end
                return
            end
            E = cross(D,B-A);
            F = cross(D,C-A);
            G = (b^2*E-c^2*F)/norm(D)^2/2;
            M = A + G;
            R = norm(G);  % Radius of curvature
            if R == 0
                k = G;
            elseif norm(D) == 0
                R = Inf;
                k = D;
            else
                k = G'/R^2;   % Curvature vector
            end
        end

        function [L,R,k] = curvature(obj, X)
            % Radius of curvature and curvature vector for 2D or 3D curve
            %  [L,R,k] = curvature(X)
            %   X:   2 or 3 column array of x, y (and possibly z) coordiates
            %   L:   Cumulative arc length
            %   R:   Radius of curvature
            %   k:   Curvature vector
            % The scalar curvature value is 1./R
            N = size(X,1);
            dims = size(X,2);
            if dims == 2
                X = [X,zeros(N,1)];  % Use 3D expressions for 2D as well
            end
            L = zeros(N,1);
            R = NaN(N,1);
            k = NaN(N,3);
            for i = 2:N-1
                [R(i),~,k(i,:)] = circumcenter(obj, X(i,:)',X(i-1,:)',X(i+1,:)');
                L(i) = L(i-1)+norm(X(i,:)-X(i-1,:));
            end
            if norm(X(1,:)-X(end,:)) < 1e-10 % Closed curve.
                [R(1),~,k(1,:)] = circumcenter(obj, X(end-1,:)',X(1,:)',X(2,:)');
                R(end) = R(1);
                k(end,:) = k(1,:);
                L(end) = L(end-1) + norm(X(end,:)-X(end-1,:));
            end
            i = N;
            L(i) = L(i-1)+norm(X(i,:)-X(i-1,:));
            if dims == 2
                k = k(:,1:2);
            end
        end

        function icon = getIconImpl(obj)
            % Define icon for System block
            icon = [mfilename("class"), newline, newline];
        end

        function interface = getInterfaceImpl(~)
            import matlab.system.interface.*;
            interface = [Input("in1", Message), ...
                Output("out1", Data)];
        end

        function [out1] = getOutputDataTypeImpl(~)
            out1 = "Bus: BusEgoRefPath";
        end
    end

    methods(Access = protected, Static)
        function simMode = getSimulateUsingImpl
            % Return only allowed simulation mode in System block dialog
            simMode = "Interpreted execution";
        end
    end
end
