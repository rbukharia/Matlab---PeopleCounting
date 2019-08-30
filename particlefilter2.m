%clear,clc,close all
function [X XX]=particlefilter2(imbw,X)
%video='[1]renggang-2-orang.avi';
%k=64;
%person=[85 191 3 4];
%% Parameters

F_update = [1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1];
% 
% Npop_particles = 4000;

Xstd_rgb = 1;
Xstd_pos = 1;
Xstd_vec = 1;

Xrgb_trgt = [1; 1;];

%% Loading Movie

% vr = VideoReader(video);
% %Nfrm_movie = floor(vr.Duration * vr.FrameRate);
% %for i=1:floor(Nfrm_movie/3)
%     v1=read(vr, 1);
%     v2=read(vr, i);
%     v3=v1-v2;
%     v3= imcrop(v3,[170 150 319 279]);
%     vgray=rgb2gray(v3);
%     for l=1:size(v3,1)
%         for m=1:size(v3,2)
%            if vgray(l,m)>60
%                v3(l,m,:)=255;
%            else
%                v3(l,m,:)=0;
%            end
%            
%         end
%     end
%    %vr2.data=v3;
%    %disp(['i: ',num2str(i)])
% %end
% 
% Npix_resolution = [vr.Width vr.Height];


%% Object Tracking by Particle Filter
% if X2==1
%     X = create_particles(Npix_resolution, Npop_particles);
% else
%     X=X2;
% end
%for k = 1:floor(Nfrm_movie/3)
%    disp(['k: ',num2str(k)])
    % Getting Image
    Y_k = imbw;
    % Forecasting
    XX = update_particles(F_update, Xstd_pos, Xstd_vec, X);
    
    % Calculating Log Likelihood
    L = calc_log_likelihood(Xstd_rgb, Xrgb_trgt, XX(1:2, :), Y_k);
    
    % Resampling
    X = resample_particles(XX, L);

    % Showing Image
%     show_particles(X, Y_k); 
%    show_state_estimated(X, Y_k);

end

