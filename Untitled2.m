% clear
% clc
%close all
function track = Untitled2(file)
%% Inisialisasi
load svmstruct_all7;
% file='[2a]renggang-3-orang.avi';

vid=mmreader(file);
nframes= vid.numberofframes;


wSize=[64,128];
X=[];
tt=1;
orang=0;
persontrack={};
persontrack2={};
observasi=[];
prediksi=[];

[pathstr,name,ext] = fileparts(file);
k = strfind(name, '.');
if size(k,2)==0
    bg = read(vid ,1);
elseif size(k,2)==1
    bg = imread('bg-lodaya.png');
elseif size(k,2)==2
    bg = imread('bg-lodaya2.png');
end
% imbg = imcrop(bg,wDetect);
%% Proses tiap frame
tic
for i=1:nframes
    disp(['frame ke ',num2str(i)]);

im = read(vid ,i);
% im2 = imcrop(im,wDetect);

if size(k,2)==0
im3 = bg-im;
wDetect=[170 150 319 279];
level = 0.2;
else
im3 = uint8(abs(double(im)-double(bg)));
wDetect=[170 170 319 239];
level = 0.01;
end

imgray = rgb2gray(im3);

imshow(im);
rectangle('Position',wDetect,'LineWidth',2, 'EdgeColor','y');
hold all
featureVector={};
boxPoint={};
box={};
jk3=[];
state=[];
temp=[];
temp2=[];
fcount=1;
Npop_particles=200;

imbw=im2bw(imgray,level);
%imbw = imfill(imbw, 'holes');
SE = strel('rectangle',[25 10]);
BW1 = imerode(imbw,SE);
BW2 = imdilate(BW1,SE);

BW3 = imcrop(BW2,wDetect);
imgray = imcrop(imgray,wDetect);

L = bwlabel(BW3);
B = reshape(L,1,[]);
for q=1:max(B)
[r, c] = find(L==q);
as=[c, r];
jk3=[jk3; floor(mean(as))];
end

    if size(jk3,1)~=0
    
for jj=1:size(jk3,1)
    skala=1;
    x=jk3(jj,1);
    y=jk3(jj,2);
    for p=1:4
    xp=x-floor(wSize(1)/skala/2);
    yp=y-floor(wSize(2)/skala/2);
if yp<0 || yp+floor(wSize(2)/skala)>wDetect(4) || xp<0 || xp+floor(wSize(1)/skala)>wDetect(3)
       featureVector{p,fcount} = zeros(3780,1);
    else
    img = imcrop(imgray,[xp yp floor(wSize(1)/skala-1) floor(wSize(2)/skala-1)]);
    img = imresize(img,[128 64]);
    featureVector{p,fcount} = HoG(double(img));
end
    boxPoint{p,fcount} = [xp,yp,skala];
    box{p,fcount} = [x,y];
    
    skala=skala-0.05;
    end
    fcount = fcount+1;
end
    end
    
   
if isempty('featureVector')==0

Pa=cell2mat(reshape(featureVector,1,[]));
bb=cell2mat(reshape(boxPoint,[],1));
bbb=cell2mat(reshape(box,[],1));

lebel = ones(size(Pa,2),1);
predictions = svmperfclassify(Pa',lebel,model);

for qq=1:size(featureVector,2)
    for w=p*(qq-1)+1:p*qq
    if predictions(w)>0
bBox = bb(w,:);
Box = bbb(w,:);
rectangle('Position',[wDetect(1)+bBox(1) wDetect(2)+bBox(2) wSize(1)-1 wSize(2)-1],'LineWidth',2, 'EdgeColor','r');
plot(wDetect(1)+Box(1),wDetect(2)+Box(2),'-.+r')
hold all
state=[state;Box bBox];
break
    end
    end
    
end

end

% for w=1:size(state,1)
%     pperson{i,w}=[wDetect(1)+state(w,1) wDetect(2)+state(w,2)];
% end


if exist('person','var')==0 && isempty(state)==0
    person=state;
elseif exist('person','var')==1 && isempty(state)==0
    v=1;
    w=1;
for z=1:size(person,1)
    for m=1:size(state,1)
        if state(m,1)~=0 && state(m,2)~=0
        if person(z,1)+25>state(m,1)&& state(m,1)>person(z,1)-25 
                person(z,:)=state(m,:);
                temp2(w,:)=state(m,:);
                state(m,:)=zeros(size(state(m,:)));
                w=w+1;
        else
            temp(v,:)=state(m,:);
            v=v+1;
        end
        end
    end
end
temp=unique(temp,'rows');
if isempty(temp)==0 && isempty(temp2)==0
temp=setdiff(temp,temp2,'rows');
end
person=[person;temp];
person=sortrows(person);
end

if exist('person','var')==1 && isempty(persontrack)==1 && isempty(temp)==1
    
    for q=1:size(person,1)
    X1 = randi([wDetect(2)+person(q,2)-10,wDetect(2)+person(q,2)+10], 1, Npop_particles);
    X2 = randi([wDetect(1)+person(q,1)-5,wDetect(1)+person(q,1)+5], 1, Npop_particles);
    X3 = zeros(2, Npop_particles);
    X=[X1;X2;X3];
    
    [X XX]=particlefilter2(BW2,X);
    persontrack{tt}=X;
    %persontrack2{tt}=XX;
    tt=tt+1;
    end
    
elseif isempty(persontrack)==0 && isempty(temp)==0
    
    for q=1:size(temp,1)
    X1 = randi([wDetect(2)+temp(q,2)-10,wDetect(2)+temp(q,2)+10], 1, Npop_particles);
    X2 = randi([wDetect(1)+temp(q,1)-5,wDetect(1)+temp(q,1)+5], 1, Npop_particles);
    X3 = zeros(2, Npop_particles);
    X=[X1;X2;X3];
    
    [X XX]=particlefilter2(BW2,X);
    persontrack{tt}=X;
    %persontrack2{tt}=XX;
    tt=tt+1;
    end
    
elseif isempty(persontrack)==0 && isempty(temp)==1
    if mod(i,5)<0
        BW4=isnan(BW2);
    else
        BW4=BW2;
    end
    for q=1:size(persontrack,2)
        X2=cell2mat(persontrack(:,q));
        if isempty(X2)==0
        
        [X XX]=particlefilter2(BW4,X2);
        persontrack{q}=X;
        %persontrack2{q}=XX;
        end
    end
end

if isempty(persontrack)==0
for w=1:size(persontrack,2)
    pt=permute(cell2mat(persontrack(:,w)),[2 1]);
    if isempty(pt)==0
    pt=floor(pt(:,1:2));
    pt=unique(pt,'rows');
    if mean(pt(:,2))-30<wDetect(1) || mean(pt(:,2))+30>wDetect(1)+wDetect(3) || mean(pt(:,1))-50<wDetect(2) || mean(pt(:,1))+50>wDetect(2)+wDetect(4)
       orang=orang+1;
    else
    plot(mean(pt(:,2)), mean(pt(:,1)), '.')
    rectangle('Position',[mean(pt(:,2))-30, mean(pt(:,1))-50,60,100],'Curvature',[1,1],'EdgeColor','b');
    hold all
     %pred{i,w}=[prediksi; mean(pt(:,2)), mean(pt(:,1))];
    end
    end
end

% for w=1:size(persontrack2,2)
%     pt=permute(cell2mat(persontrack2(:,w)),[2 1]);
%     if isempty(pt)==0
%     pt=floor(pt(:,1:2));
%     pt=unique(pt,'rows');
%     obs{i,w}=[observasi; mean(pt(:,2)), mean(pt(:,1))];
%     end
% end
end

hold off
drawnow
end
toc

%%
% figure;
% 
% for i=1:size(obs,2)
%     plot1=cell2mat(obs(:,i));
%     p1=plot(plot1(:,1),size(obs(:,i),1)-size(plot1,1)+1:size(obs(:,i),1),'-r');
%     hold on
% end
% for i=1:size(pred,2)
%     plot2=cell2mat(pred(:,i));
%     p2=plot(plot2(:,1),size(pred(:,i),1)-size(plot2,1)+1:size(pred(:,i),1),'-g');
%     hold on
% end
% for i=1:size(pperson,2)
%     plot3=cell2mat(pperson(:,i));
%     p3=plot(plot3(:,1),size(pperson(:,i),1)-size(plot3,1)+1:size(pperson(:,i),1),'.b');
%     hold on
% end
% hold off
% title('Hasil deteksi dan tracking')
% xlabel('piksel x')
% ylabel('frame ke n')
% xlim([170 490])
% ylim('auto')
% hleg = legend([p1,p2,p3],'Koreksi','Prediksi','Deteksi HOG',...
%               'Location','NorthEastOutside');
% 
% %%
% for i=1:size(pred,2)
% T=cell2mat(pred(:,i));
% P=cell2mat(obs(:,i));
% X=errperf(T(:,1),P(:,1),'ae');
% Y=errperf(T(:,2),P(:,2),'ae');
% Vmean(i,:)=[mean(X) mean(Y)];
% end
% 
% MAEx=mean(Vmean(:,1));
% MAEy=mean(Vmean(:,2));
% disp(['MAE-x = ',num2str(MAEx)])
% disp(['MAE-y = ',num2str(MAEy)])
track=size(persontrack,2);
disp(['Jumlah orang = ',num2str(track)])

end