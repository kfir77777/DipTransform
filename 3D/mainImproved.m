clear; close all; clc;

addpath(genpath(('../third_party')));
modelsDir = '../3dmodels/';

%% Parameters
modelName = 'finalcats_stl';

resolution = 30;
pad = 3;
%pad = floor( ((sqrt(3) - 1)/(2 * sqrt(3))) * resolution + 1);
%numberOfAngles = (resolution)^2;
numberOfAngles = 600;

%% Model initialization
modelPath = strcat(modelsDir, modelName, '.stl');
Original = dippingPreprocessing(modelPath, resolution, pad);

h = showVoxel(Original, 'Original');
movegui(h,[70,250]);
%% Measure dip
tic
%angles = randi([0 179], 800, 2);
Rz = 0:20:359; Ry=-35:5:35;
angles = zeros(length(Ry)*length(Rz),2);
for i = 1:length(Ry) 
    for j=1:length(Rz)
        angles((i-1)*length(Rz)+j,:) = [Ry(i), Rz(j)]; 
    end
end
B = calcB(angles,size(Original));
slices = rotateAndDipImproved(Original, B);
toc; disp('Dipped');

%% Reconstruct
tic
[I, I_soft] = reconstructObject(slices, size(Original), B);

I_filtered = zeros(size(I));
I_filtered((pad+1):(end-pad), (pad+1):(end-pad),(pad+1):(end-pad)) = I((pad+1):(end-pad), (pad+1):(end-pad),(pad+1):(end-pad));
h = showVoxel(I_filtered, 'Reconstructed');
movegui(h,[650,250]);
toc; disp('reconstructObject');
E = calculateBinaryError(I_filtered,Original);

%save(strcat(modelName,'_res_',num2str(resolution),'.mat'),'-v7.3');

