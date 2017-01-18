classdef Classifier < handle
    % CLASSIFIER - Class Summary
    %
    %   Train and classify features previously extracted from data. Each
    %   classifier must be first trained after its initialized in order to
    %   be able to classify validation or test data. With validation data a
    %   full result is possible to be output through a performance
    %   comparison with ground truth, for test data, the classifier
    %   confidence values, or scores, are output
    %
    %   Author:         Kyle Bradbury
    %   Email:          kyle.bradbury@duke.edu
    %   Organization:   Duke University Energy Initiative
    
    properties
        status              % trained, untrained
        trainingFeatures    % available if trained
        trainingData        % available if trained
        classifierModel     % stores trained classifier
        type = 'linear discriminant' ; % specified for each classifier class
    end
    
    methods
        %------------------------------------------------------------------
        % Classifier - Class Constructor
        %
        %   Initialize an untrained classifier
        %------------------------------------------------------------------
        function C = Classifier()
            C.status = 'untrained' ;
        end
        
        %------------------------------------------------------------------
        % train
        %
        %   Train the classifier. The classification algorithm in this
        %   method is a linear discriminant (consider modifying this)
        %------------------------------------------------------------------
        function C = train(C,Features)
            fprintf('Training %s classifier...\n', C.type)
            C.trainingFeatures = Features ;
            C.trainingData = Features.dataSource ;
            values = Features.features ;
            labels = Features.labels ;
            C.classifierModel = fitcdiscr(values,labels,'DiscrimType','quadratic') ;
            C.status = 'trained' ;
        end
        
        %------------------------------------------------------------------
        % classifyValidationData
        %
        %   Use a trained classifier to classify validation data and score
        %   performance through the Result class
        %------------------------------------------------------------------
        function result = classifyValidationData(C,Features)
            if strcmp(C.status,'trained')
                fprintf('Classifying data with %s...\n', C.type)
                % Generate result
                [~, score] = predict(C.classifierModel,Features.features) ;
                result = Result(score(:,2),Features.labels,Features.dataSource,C.trainingData) ;
            else
                error('Classifier must be trained')
            end
        end
        
        %------------------------------------------------------------------
        % classifyTestData
        %
        %   Use a trained classifier to classify test data and output the
        %   confidence values, or scores
        %------------------------------------------------------------------
        function scores = classifyTestData(C,Features)
            if strcmp(C.status,'trained')
                fprintf('Classifying data with %s...\n', C.type)
                % Generate result
                [~, scores] = predict(C.classifierModel,Features.features) ;
            else
                error('Classifier must be trained')
            end
        end
    end
end

