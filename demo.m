%%% Setup
% restoredefaultpath;
close, clear, clc;

%%% Path
addpath(fullfile(pwd,'utils'));

%%% Params
params.debug = 1;
clc;

%%% Load video
load(fullfile('trafficdb','traffic_patches.mat'));
V = im2double(imgdb{100}); % show_3dvideo(V);

%%% Observed entries
%Omega = ones(size(V));
%Omega = randi([0 1],size(V));
[~,Omega] = subsampling(V, 0.75);
%[~,Omega] = subsampling(V, 0.15); 
% show_3dvideo(Omega);

%% Matrix completion
clc;
params.algs_path = 'algs_mc';
params.algs_name = get_algs_name(params);
displog('--- Matrix Completion ---');
for alg = 1:size(params.algs_name,2)
  %alg = 1;
  displog(['Current algorithm: ' params.algs_name(alg).name]);
  params.current_algorithm = alg;
  
  %%% Load algorithm
  current_alg_name = params.algs_name(params.current_algorithm).name;
  current_alg_path = fullfile(params.algs_path,current_alg_name);
  displog(['Loading algorithm: ' current_alg_name]);
  addpath(genpath(current_alg_path));
  
  %%% Matrix completion
  displog('Performing matrix completion');
  M = convert_video3d_to_2d(V); % imagesc(M)
  Idx = convert_video3d_to_2d(Omega); % imagesc(Idx)
  M(M == 0) = 1e-3;
  M = M.*Idx; % imagesc(M)
  params_mc.M = M;
  params_mc.Idx = Idx;
  M_hat = run_mc(params_mc); % imagesc(M_hat)
  
  % Build background model
  M_bg = mean(M_hat,2);
  I_bg = reshape(M_bg,size(V,1),size(V,2));
  if(params.debug)
    clf,imshow(I_bg);
    pause(1);
  end
  
  rmpath(genpath(current_alg_path));
  %break;
end
clear alg seq;
