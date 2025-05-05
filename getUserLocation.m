function [userLat, userLon] = getUserLocation(fileName, nUsers, latRange, lonRange)
% This function samples a Non-Terrestrial Cluster Process in a latitude/longitude range to obtain non-uniformly distributed user locations.
%
% Input:
% - fileName: name/path of the .mat file containing the NTCP statistics
% - nUsers: average number of user locations to be generated
% - latRange: vector of minimum and maximum latitude in the coverage area (in degrees)
% - lonRange: vector of minimum and maximum longitude in the coverage area (in degrees)
%
% Output:
% - userLat: vector of user latitudes (in degrees)
% - userLon: vector of user longitudes (in degrees)
%
% *************************************
% * Bruno De Filippo                  *
% * Ph.D Student                      *
% * Digicomm Group                    *
% * University of Bologna             *
% * email: bruno.defilippo@unibo.it   *
% *************************************

    % Get minimum and maximum latitude and longitude in the service area
    minLat = min(latRange);
    maxLat = max(latRange);
    minLon = min(lonRange);
    maxLon = max(lonRange);

    % Compute the size of the coverage area (in m^2)
    EarthModel = referenceSphere('Earth');
    areaSize = areaquad(minLat, minLon, maxLat, maxLon, EarthModel);
    
    % Gaussian mixture distribution in lat, lon -------------------------------
    load(fileName, 'pd_clusters', 'pd_weights_large', 'pd_weights_small', 'pd_vars_large', 'pd_vars_small', 'pd_ecc_large', 'pd_ecc_small', 'large_proportion');
    
    % Extract the number of clusters from the corresponding Probability Distribution object
    nClusters = round(random(pd_clusters) * areaSize);
    
    % Split in large and small clusters
    nLargeClusters = round(nClusters * large_proportion);
    nSmallClusters = nClusters - nLargeClusters;
    
    % Create the clusters geographical size through the variance and the eccentricity distributions (in meters)
    clustersVarsX = [random(pd_vars_large, 1, nLargeClusters), random(pd_vars_small, 1, nSmallClusters)];
    clustersEcc = [random(pd_ecc_large, 1, nLargeClusters), random(pd_ecc_small, 1, nSmallClusters)];
    
    % Compute variance on y axis through the eccentricity of the clusters
    clustersVarsY = clustersVarsX .* clustersEcc;
    
    % Create clusters size vector through the weight distributions
    clustersWeights = [random(pd_weights_large, 1, nLargeClusters), random(pd_weights_small, 1, nSmallClusters)];
    
    % Normalize wrt the average number of users
    clustersWeights = clustersWeights ./ sum(clustersWeights) .* nUsers;
    
    % Remove empty clusters
    nonEmptyMask = clustersWeights > 0;
    clustersWeights = clustersWeights(nonEmptyMask);
    clustersVarsX = clustersVarsX(nonEmptyMask);
    clustersVarsY = clustersVarsY(nonEmptyMask);
    
    % Generate number of users per cluster as Poisson Process 
    clustersNUsers = poissrnd(clustersWeights);
    
    % Remove empty clusters again
    nonEmptyMask = clustersNUsers > 0;
    clustersNUsers = clustersNUsers(nonEmptyMask);
    clustersVarsX = clustersVarsX(nonEmptyMask);
    clustersVarsY = clustersVarsY(nonEmptyMask);
    nClusters = sum(nonEmptyMask);           % Update total number of clusters
    nUsers = sum(clustersNUsers);              % Update total number of users
    
    % Uniformly generate clusters centers
    clustersLat = rand(nClusters, 1) * (maxLat-minLat) + minLat;       % Centers' latitude
    clustersLon = rand(nClusters, 1) * (maxLon-minLon) + minLon;       % Centers' longitude
    
    % Generate clusters rotation as uniformly distributed between -1 and 1 (correlation coefficient in bivariate gaussian distribution)
    clustersRho = rand(1, nClusters) .* 2 - 1;
    
    % Bivariate Gaussian average
    mu = [0, 0];
    
    % Initialize lat/lon vectors
    userLat = zeros(nUsers, 1);
    userLon = zeros(nUsers, 1);
    vectorPos = 1;                  % Index to fill the lat/lon vectors
    
    for k_clusters = 1:nClusters
        % Generate covariance matrix
        sigma = [clustersVarsX(k_clusters), clustersRho(k_clusters) .* sqrt(clustersVarsX(k_clusters)) .* sqrt(clustersVarsY(k_clusters));
                 clustersRho(k_clusters) .* sqrt(clustersVarsX(k_clusters)) .* sqrt(clustersVarsY(k_clusters)), clustersVarsY(k_clusters)];
    
        % Generate users' position in meters from reference (0, 0)
        userXY = mvnrnd(mu, sigma, clustersNUsers(k_clusters));
        userX = userXY(:, 1);
        userY = userXY(:, 2);
    
        % Compute users' distance from reference (0, 0)
        dist_users = sqrt(userX.^2 + userY.^2);        

        %Compute users' angle wrt east direction (Pi must be summed next to obtain angles between 0 and 360)
        userX(userX == 0) = 1e-10;  % Avoid division by 0
        angle_users = atan(userY ./ userX);
        angle_users(2 - sign(userX) + sign(userY) > 0) = angle_users(2 - sign(userX) + sign(userY) > 0) + pi;     % Sum Pi to users in 2nd, 3rd or 4th quadrant
        angle_users(1 - sign(userX) + sign(userY) == 0) = angle_users(1 - sign(userX) + sign(userY) == 0) + pi;   % Sum Pi again to users in 4th quadrant
        angle_users = mod(360 - (angle_users - (pi/2)) * 180/pi, 360);      % Wrt north direction, in degrees, clockwise
    
        % Compute arc length between reference (0, 0) and users in degrees
        dist_users_deg = rad2deg(dist_users / EarthModel.MeanRadius);

        % Compute lat/lon from reference (in lat lon), arc distance and direction
        [userLat(vectorPos:vectorPos + clustersNUsers(k_clusters) - 1), userLon(vectorPos:vectorPos + clustersNUsers(k_clusters) - 1)] = reckon(clustersLat(k_clusters), clustersLon(k_clusters), dist_users_deg, angle_users);
    
        % Update index
        vectorPos = vectorPos + clustersNUsers(k_clusters);
    end
end