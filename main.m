% *************************************
% * Bruno De Filippo                  *
% * Ph.D Student                      *
% * Digicomm Group                    *
% * University of Bologna             *
% * email: bruno.defilippo@unibo.it   *
% *************************************

clearvars
clc

seed=2025;
rng(seed);

fileName = "non_uniform_distributions.mat";

%% Parameters
latRange = [49.2, 50.0];  % Minimum and maximum latitude in the service area (in degrees)
lonRange = [5.3, 6.9];  % Minimum and maximum longitude in the service area (in degrees)

nUsers = 1e3;  % Average number of users to be generated

%% Generate user locations with NTCP
[userLat, userLon] = getUserLocation(fileName, nUsers, latRange, lonRange);

%% Plot user locations
figure;
geoscatter(userLat, userLon);
