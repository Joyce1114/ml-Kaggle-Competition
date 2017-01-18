classdef Features < handle
    % FEATURES - Class Summary
    %
    %   The Features class takes a Data class object as an input and
    %   extracts features from it for use with the Classifier class.
    %
    %   Author:         Kyle Bradbury
    %   Email:          kyle.bradbury@duke.edu
    %   Organization:   Duke University Energy Initiative
    
    properties
        dataSource  % Points to the original data
        featureType % Brief descriptor of the type of features that are extracted
        windowSize  % Radius of the window size for calculating features from (i.e. mean and variance for the example) 
        nFeatures   % Total number of features that will be calculated
        features    % Variable in which to store the extracted features
        labels      % Labels for each of the features (only non-empty for training and validation data)
    end
    
    methods
        %------------------------------------------------------------------
        % Features - Class Constructor
        %
        %   Extract features 
        %------------------------------------------------------------------
        function F = Features(Data)
            % Set parameters
            F.dataSource = Data ;
            classdef Features < handle
    % FEATURES - Class Summary
    %
    %   The Features class takes a Data class object as an input and
    %   extracts features from it for use with the Classifier class.
    %
    %   Author:         Kyle Bradbury
    %   Email:          kyle.bradbury@duke.edu
    %   Organization:   Duke University Energy Initiative
    
    properties
        dataSource  % Points to the original data
        featureType % Brief descriptor of the type of features that are extracted
        windowSize  % Radius of the window size for calculating features from (i.e. mean and variance for the example) 
        nFeatures   % Total number of features that will be calculated
        features    % Variable in which to store the extracted features
        labels      % Labels for each of the features (only non-empty for training and validation data)
    end
    
    methods
        %------------------------------------------------------------------
        % Features - Class Constructor
        %
        %   Extract features 
        %------------------------------------------------------------------
        function F = Features(Data)
            % Set parameters
            F.dataSource = Data ;
               
            % Load, process, and save the data
            fprintf('Extracting features from %s...\n', F.dataSource.imageFilename)
            F.extractFeatures() ;
            F.extractLabels() ;
            fprintf('Completed loading data from %s.\n', F.dataSource.imageFilename)
        end
        
        %------------------------------------------------------------------
        % extractAllFeatures
        %
        %   Extract all the features from the dataset. In this case the
        %   mean and variance are calculated form a 3-by-3 window around
        %   each pixel and is calculated for each of the three color
        %   channels for a total of 6 features (consider modifying this)
        %------------------------------------------------------------------
        function F = extractFeatures(F)
            
            % Create convolutional mask
            F.nFeatures = 24 ; %
            F.windowSize =10 ; %
            F.featureType = 'channel_mean_and_variance' ;
            windowDiameter = 2*F.windowSize-1 ;
            nPixelsInWindow = windowDiameter^2 ;
            convMask = ones(windowDiameter) ;
            gray = rgb2gray(F.dataSource.imageData) ;
            % Extract each of the three color channels
            pixels = double(F.dataSource.imageData) ;
            [Gmag1, Gdir1] = imgradient(F.dataSource.imageData(:,:,1),'prewitt');
            [Gmag2, Gdir2] = imgradient(F.dataSource.imageData(:,:,2),'prewitt');
            [Gmag3, Gdir3] = imgradient(gray,'prewitt');
            R = imadjust(F.dataSource.imageData(:,:,1),[0.2,0.7],[0,1]);
            G = imadjust(F.dataSource.imageData(:,:,2),[0.2,0.7],[0,1]);
            % Initialize feature vector
            F.features = nan(F.dataSource.nPixels,F.nFeatures) ;
            ran = entropyfilt(F.dataSource.imageData);
            en1 = entropyfilt(R);
            en2 = entropyfilt(G);
            engray = entropyfilt(gray);
            for iChannel = 1:3
                % Extract features
                cChannel = squeeze(pixels(:,:,iChannel)) ;
                cChannelMean       = (1/nPixelsInWindow) * conv2(cChannel,convMask,'same') ;
                cChannelMeanSquare = (1/nPixelsInWindow) * conv2(cChannel.^2,convMask,'same') ;
                cChannelVariance   = cChannelMeanSquare - cChannelMean.^2 ;
                cChannelStd=sqrt(cChannelVariance);
                % Store the features
                F.features(:,2*(iChannel-1)+1) = cChannelMean(:) ;
                F.features(:,2*iChannel)       = cChannelVariance(:) ;
                F.features(:,6+iChannel)=cChannelStd(:);
            end
            F.features(:,10)=R(:);
            F.features(:,11)=G(:);
            F.features(:,12)=gray(:);
            num1 = ran(:,:,1);
            F.features(:,13)=num1(:);
            F.features(:,14)=en1(:);
            F.features(:,15)=en2(:);
            F.features(:,16)=engray(:);
            F.features(:,17)=Gmag1(:);
            F.features(:,18)=Gdir1(:);
             F.features(:,19)=Gmag2(:);
            F.features(:,20)=Gdir2(:);
             F.features(:,21)=Gmag3(:);
            F.features(:,22)=Gdir3(:);
            num2 = ran(:,:,2);
            F.features(:,23)=num2(:);
            num3 = ran(:,:,3);
            F.features(:,24)=num3(:);
        end
        
        %------------------------------------------------------------------
        % extractLabels
        %
        %   Extract pixel labels (reshape into a vector of values)
        %------------------------------------------------------------------
        function F = extractLabels(F)
            F.labels = double(F.dataSource.labels(:)) ;
        end
    end
end


            % Load, process, and save the data
            fprintf('Extracting features from %s...\n', F.dataSource.imageFilename)
            F.extractFeatures() ;
            F.extractLabels() ;
            fprintf('Completed loading data from %s.\n', F.dataSource.imageFilename)
        end
        
        %------------------------------------------------------------------
        % extractAllFeatures
        %
        %   Extract all the features from the dataset. In this case the
        %   mean and variance are calculated form a 3-by-3 window around
        %   each pixel and is calculated for each of the three color
        %   channels for a total of 6 features (consider modifying this)
        %------------------------------------------------------------------
       
        %------------------------------------------------------------------
        % extractLabels
        %
        %   Extract pixel labels (reshape into a vector of values)
        %------------------------------------------------------------------
        function F = extractLabels(F)
            F.labels = double(F.dataSource.labels(:)) ;
        end
    end
end

