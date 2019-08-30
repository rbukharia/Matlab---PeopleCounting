load matlab.mat
xdata = meas(51:end,3:4);
group = species(51:end);
svmStruct = svmtrain(xdata,group,'showplot',true);

species = svmclassify(svmStruct,[5 2],'showplot',true);
hold on;plot(5,2,'ro','MarkerSize',12);hold off

species = 'virginica';