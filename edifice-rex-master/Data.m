classdef Data < handle
    % DATA - Class Summary
    %   Store, process, and visualize image data for classification. Data
    %   classes are used to generate Features. Classifiers are run on
    %   Features. With test data, Classifiers can produce pixel
    %   confidence values and with validation data, Classifiers can produce
    %   Results which allow for a complete performance evaluation
    %
    %   Author:         Kyle Bradbury
    %   Email:          kyle.bradbury@duke.edu
    %   Organization:   Duke University Energy Initiative
    
    properties
        % Parameters for both testing & training data
        type            % training, validation, or testing
        directory       % data location relative to the current directory
        imageFilename   % string of the image file name
        imageData       % RGB image data
        imageSize       % size of the image
        nPixels         % number of pixels
        fileExists      % Flag for determining if a saved version of the file exists
        matFilename     % string to store the matlab version's file namedataset
        dataset         % Specifies which object detection dataset the data are
                        % being loaded from: the solar PV data or the building 
                        % detection dataset (takes on values 'buildings' or
                        % 'solar')
                
        % Parameters for training and validation data only
        labelFilename   % string of the label file name
        polygons        % polygons containing the ground truth object locations
        labels          % pixel labels (same size as original image)
    end
    
    methods
        %------------------------------------------------------------------
        % Data - Class Constructor
        %
        %   Loads the data from file along with any labels if the data are
        %   for training or validation purposes and saves the data to a
        %   file in the subfolder 'data'
        %------------------------------------------------------------------
        function D = Data(setupParameters)
            % Check the type of data (training or testing) and extract
            % approrpiate parameters
            D.imageFilename = setupParameters.imageFilename ;
            D.directory     = setupParameters.directory ;
            D.matFilename   = [D.imageFilename(1:end-4) '.mat'] ;
            D.dataset       = setupParameters.dataset ;
            D.type          = setupParameters.type ;
            
            % Check if the file exists in mat format already
            D.checkIfFileExists() ;

            % If the file exists load the mat file
            if D.fileExists
                D.loadData() ;
                
            % Otherwise load, process, and save the data    
            else 
                % Load the data from the image
                fprintf('Loading data from %s...\n', D.imageFilename)
                D.loadImageData() ;
                
                % Load labels for training or validation data
                if strcmpi(D.type,'training') || strcmpi(D.type,'validation')
                    D.labelFilename  = setupParameters.labelFilename ;
                    D.loadLabels() ;
                end
                
                % Save the data
                D.saveData() ;
            end
            fprintf('Completed loading data from %s.\n', D.imageFilename)
        end
        
        %------------------------------------------------------------------
        % loadImageData
        %
        %   Loads the image data from a file and calculates the image size
        %   and number of pixels in the image
        %------------------------------------------------------------------
        function D = loadImageData(D)
            
            % Loads the image data from file
            D.imageData = imread(fullfile(D.directory,D.imageFilename)) ;
            if size(D.imageData > 3) % Removes an excess channels beyond the three for RGB
                D.imageData = D.imageData(:,:,1:3) ;
            end
            
            % Calculate image size and the number of pixels
            D.imageSize = size(D.imageData) ;
            D.nPixels   = D.imageSize(1) * D.imageSize(2)  ;
        end
        
        %------------------------------------------------------------------
        % loadLabels
        %
        %   Extract any pixel labels from polygon annotations. This will
        %   produce either a '1' or a '0' (logical) for every pixel in the
        %   image
        %------------------------------------------------------------------
        function D = loadLabels(D)
            % Loads the polygons from file
            polygonData = load(fullfile(D.directory,D.labelFilename)) ;
            
            % Extract the polygons for the specific image in question
            if strcmpi(D.dataset,'buildings')
                D.extractPolygonsForImage_buildingData(polygonData.building_cell) ;
            elseif strcmpi(D.dataset,'solar')
                D.extractPolygonsForImage_solarData(polygonData.data) ;
            else
                error('Dataset not recognized')
            end
            
            % Get the pixels labels from the polygons
            D.getPixelLabelsFromPolygons() ;
        end
        
        %------------------------------------------------------------------
        % extractPolygonsForImage_solarData
        %
        %   Read in the polygon data from the source data to produce a cell
        %   array of polygons, stored in the 'polygons' property. This
        %   function is called ONLY for data from the solar PV dataset
        %------------------------------------------------------------------
        function D = extractPolygonsForImage_solarData(D,polygonData)
            % Extracts only the relevant polygons from the data
            imageNameField = 9 ;

            % Get the polygons from the specific image
            polygonsInImage = polygonData(:,imageNameField) ;
            imageNames = cell(size(polygonsInImage)) ;
            imageNames(:) = {D.imageFilename(1:end-4)} ;
            inImage = strcmp(imageNames,polygonsInImage) ;
            D.polygons = polygonData(inImage,end) ;
        end
        
        %------------------------------------------------------------------
        % extractPolygonsForImage_buildingData
        %
        %   Read in the polygon data from the source data to produce a cell
        %   array of polygons, stored in the 'polygons' property. This
        %   function is called ONLY for data from the buildings dataset
        %------------------------------------------------------------------
        function D = extractPolygonsForImage_buildingData(D,polygonData)
            % Get the polygons from the specific image
            xValues = polygonData(2:end,10) ;
            yValues = polygonData(2:end,11) ;
            
            nPolygons = length(xValues) ;
            D.polygons = cell(nPolygons,1) ;
            for iPolygon = 1:nPolygons
                cXValue = xValues{iPolygon} ;
                cYValue = yValues{iPolygon} ;
                lastx = find(isnan(cXValue),1,'first') ;
                lasty = find(isnan(cYValue),1,'first') ;
                D.polygons{iPolygon,1} = [cXValue(1:lastx-1)' cYValue(1:lasty-1)'] ;
            end
        end
        
        %------------------------------------------------------------------
        % getPixelLabelsFromPolygons
        %
        %   Convert from polygon vertices to pixel labels by checking
        %   whether or not each pixel falls within a polygon
        %------------------------------------------------------------------
        function D = getPixelLabelsFromPolygons(D)
            % Labels each pixel based on whether or not it is inside a
            % polygon
            rows = D.imageSize(1) ;
            cols = D.imageSize(2) ;
            
            D.labels = zeros(rows,cols) ;
            nPolygons = size(D.polygons,1) ;

            fprintf('|     Progress     |\n')
            progressIntervals = ceil(nPolygons/20) ;
            for iPoly = 1:nPolygons
                if ~mod(iPoly,progressIntervals)
                    fprintf('|')
                end
                polyMask = poly2mask(D.polygons{iPoly}(:,1), D.polygons{iPoly}(:,2), rows, cols) ;
                D.labels = D.labels | polyMask ;
            end
            fprintf('|\n') ;
        end
        
        %------------------------------------------------------------------
        % viewAddPolygons
        %
        %   Adds polygons to the existing axes. This takes four input
        %   values:
        %       edgeColor = color of the lines bordering the polygons
        %       edgeWidth = width of the lines bordering the polygons
        %       faceColor = color of polygon faces
        %       faceAlpha = transparency of polygon faces (between 0 and 1)
        %------------------------------------------------------------------
        function viewAddPolygons(D,edgeColor,edgeWidth,faceColor,faceAlpha)
            % Hold the existing figure to add polygons to
            hold on ;
            
            % Get number of polygons
            nPolygons = size(D.polygons,1) ;
            h = zeros(nPolygons,1) ;
            for iPoly = 1:nPolygons
                h(iPoly) = fill(D.polygons{iPoly}(:,1),D.polygons{iPoly}(:,2),'g') ;
            end
            set(h,'facealpha',faceAlpha,'edgecolor',edgeColor,'facecolor',faceColor,'linewidth',edgeWidth)
        end
        
        %------------------------------------------------------------------
        % viewImage
        %
        %   Displays the image in this dataset
        %------------------------------------------------------------------
        function viewImage(D)
            % Load the image
            image(D.imageData) ; axis image ;
        end
        
        %------------------------------------------------------------------
        % saveData
        %
        %   Saves the data to file for faster loading in the future
        %------------------------------------------------------------------
        function saveData(D)
            matFullFile = fullfile(D.directory,D.matFilename) ;
            save(matFullFile,'D')
        end
        
        %------------------------------------------------------------------
        % loadData
        %
        %   Load data from file
        %------------------------------------------------------------------
        function D = loadData(D)
            matFullFile         = fullfile(D.directory,D.matFilename) ;
            StoredData          = load(matFullFile,'D') ;
            D.directory         = StoredData.D.directory ;
            D.imageFilename     = StoredData.D.imageFilename ;
            D.imageData         = StoredData.D.imageData ;
            D.imageSize         = StoredData.D.imageSize ;
            D.nPixels           = StoredData.D.nPixels ;
            D.labelFilename     = StoredData.D.labelFilename ;
            D.polygons          = StoredData.D.polygons ;
            D.labels            = StoredData.D.labels ;
            D.fileExists        = StoredData.D.fileExists ;
            D.matFilename       = StoredData.D.matFilename ;
        end
        
        %------------------------------------------------------------------
        % checkIfFileExists
        %
        %   Check if the data directory and data file already exists
        %------------------------------------------------------------------
        function D = checkIfFileExists(D)
            % First check if the data folder exists:
            if ~(exist(D.directory, 'dir') == 7)
                mkdir(D.directory) ;
            end
            
            % Check if the file already exists in the folder
            matFullFile = fullfile(D.directory,D.matFilename) ;
            if exist(matFullFile, 'file') == 2
                D.fileExists = 1 ;
            else
                D.fileExists = 0 ;
            end
        end
    end
end