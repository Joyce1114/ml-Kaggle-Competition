%% Demo Object Identification Code for the Kaggle Competition: Edifice Rex
%   This code is meant to help you walk through what the steps for object
%   identification are in practice. This code is not perfect, nor is it
%   intended to, but it is a starting point for you to develop in novel
%   ways. Feel free to modify any/all of it or use something completely
%   different.
%
%   For example, you could jump write into the Features and Classifer
%   classes and rewrite the feature extraction and classification
%   techniques to implement your own idea.
%
%   NOTE: To use the code below please place all Kaggle data files in a 
%   subfolder called 'data' in the same directory as where this file is 
%   located
%
%   Author:         Kyle Bradbury
%   Email:          kyle.bradbury@duke.edu
%   Organization:   Duke University Energy Initiative

%% Load the data
% Load training data
paramTraing.imageFilename = 'Norfolk_01_training.tif' ;
paramTraing.directory     = 'data' ;
paramTraing.labelFilename = 'Norfolk_01_buildingCell.mat' ;
paramTraing.dataset       = 'buildings' ;
paramTraing.type          = 'training' ;

TrainingData = Data(paramTraing) ;

% Load validation data
paramValidation.imageFilename = 'Norfolk_02_validation.tif' ;
paramValidation.directory     = 'data' ;
paramValidation.labelFilename = 'Norfolk_02_buildingCell.mat' ;
paramValidation.dataset       = 'buildings' ;
paramValidation.type          = 'validation' ;

ValidationData = Data(paramValidation) ;

% Load Kaggle test data
paramTest.imageFilename = 'Norfolk_03_testing.tif' ;
paramTest.directory     = 'data' ;
paramTest.dataset       = 'buildings' ;
paramTest.type          = 'testing' ;

TestingData = Data(paramTest) ;

%% View training data
%Polygon plotting parameters
edgeColor = 'g' ;
edgeWidth = 1 ;
faceColor = 'g' ;
faceAlpha = 0 ;

% Plot the traiçççning and test data
figure('color','white')
subplot(1,2,1)
TrainingData.viewImage() ;
TrainingData.viewAddPolygons(edgeColor,edgeWidth,faceColor,faceAlpha) ;
title('Training Data')

subplot(1,2,2)
ValidationData.viewImage() ;
ValidationData.viewAddPolygons(edgeColor,edgeWidth,faceColor,faceAlpha) ;
title('Testing Data')

%% Extract features
TrainingFeatures = Features(TrainingData) ;
ValidationFeatures = Features(ValidationData) ;
TestingFeatures = Features(TestingData) ;

%% Train classifier
FldClassifier = Classifier() ;
FldClassifier.train(TrainingFeatures) ;

%% Run the trained classifier on the test data
Result = FldClassifier.classifyValidationData(ValidationFeatures) ;

%% Plot the results
figure('color','white')
subplot(1,2,1) ; Result.plotRoc() ;
subplot(1,2,2) ; Result.plotPr() ;

%% Show resulting confidence map
figure('color','white')
h(1) = subplot(1,2,1) ;
ValidationData.viewImage() ;
h(2) = subplot(1,2,2) ;
Result.plotConfidenceMap('showpolygons')
linkaxes(h,'xy')

%% Run the classifier on the test data to produce a Kaggle submission
filename = 'kaggleSubmission01.csv' ;
scores = FldClassifier.classifyTestData(TestingFeatures) ;
scores = scores(:,2) ;
nValues = length(scores) ;
id = (1:nValues)' ;

dataToWrite = [id scores]' ;
fid = fopen(filename, 'w');
fprintf(fid, 'id,score\n'); % Write headings
fprintf(fid, '%d,%3f\n',dataToWrite) ; % Write data
fclose(fid) ;