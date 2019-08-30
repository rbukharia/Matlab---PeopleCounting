clc;
clear;
close all;

%% Inisialisasi
FileName=uigetfile('*.jpg;*.jpeg;*.avi'); %membuka file image/video
dot = regexp(FileName,'\.');
switch(FileName(dot+1:end))
case {'jpg','jpeg'}
    X=imread(FileName);    
case {'avi'}
V = aviread(FileName);
for j=300:300
      %fname=['Example-', num2str(j) '.jpg'];
      %imwrite(V(j).cdata,fname,'jpeg');
      X=V(j).cdata;
      %vector=blockvector;
        %mov = immovie(A);
      %implay(mov)
end
end

cell=8;
block=2;
bins=9;

%% Preprocessing
A=imresize(X, [128 64]); %merubah ukuran image menjadi 64x128 pixel

%kompresi gamma
%y=10/9; %nilai gamma
%I=255*(A/255^(1/y)); %rumus kompresi gamma

gray=rgb2gray(A); %merubah ke grayscale
pic=double(gray);
total_p=size(pic,1)/cell-1;
total_q=size(pic,2)/cell-1;
%% Histogram of Oriented Gradients

for p=1:total_p
    for q=1:total_q
        for r=p:p+block-1
            for s=q:q+block-1
                for bin=1:bins
                    startI=(r-1)*cell+1;
                      endI=(r)*cell;
                    startJ=(s-1)*cell+1;
                      endJ=(s)*cell;
                        
                   Z=zeros(endI-startI+1,endJ-startJ+1);
                    
                         for i=startI:endI
                             for j=startJ:endJ
                                 
                                 if (i<size(pic,1)-1)    
                                        Sx=(pic(i+2,j))-(pic(i,j));
                                    if Sx==0
                                        Sx = Sx+0.0001;
                                    end
                                 end
                                    if (j<size(pic,2)-1)    
                                        Sy=(pic(i,j+2))-(pic(i,j));
                                    end
                                    
                                    Im(i,j)=(sqrt(Sx.^2+Sy.^2)); %gradiens
                                    Io(i,j)=(((atan(Sy/Sx)+(pi/2))*180)./pi);%degrees
                                 
                                 if((Io(i,j)>=(bin-1)*bins+1)&&(Io(i,j)<(bin)*bins))
                                    Z(i-startI+1,j-startJ+1)=1;
                                 end
                                 if(bin>1)
                                    if((Io(i,j)>=(bin-2)*bins+1+bins/2)&&(Io(i,j)<(bin-1)*bins))
                                       Z(i-startI+1,j-startJ+1)=1-abs(Io(i,j)-(bin*bins-bins/2))/bins;
                                    end
                                 end
                                 if(bin<180/bins)
                                    if((Io(i,j)>=(bin)*bins+1)&&(Io(i,j)<(bin+1)*bins-bins/2))
                                       Z(i-startI+1,j-startJ+1)=1-abs(Io(i,j)-(bin*bins-bins/2))/bins;
                                    end
                                 end
                             end
                         end
                            OrientationBin(p, q ,bin) = sum(sum( Z .* Im(startI:endI,startJ:endJ)));
                end
            subplot(total_p,total_q, (p-1)*total_q+q);
            vector=permute(OrientationBin(p,q,:),[3,2,1]);
            bar(vector);
            %remove xticks and yticks
            set(gca,'xtick',[],'ytick',[]);
            
            end
        end
        
    end
end

%% Output
savefile = 'matlab.mat';
save(savefile,'OrientationBin');
figure,imshow(uint8(Im));
