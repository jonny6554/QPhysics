

classdef SLMPixelGroup < handle
%     This class is an SLMPixelGroupement. It allows the user to apply an action to multiple pixels, or one pixel, at a time. 
%     It is possible to :
%         -Construct the SLMPixelGroup. 
%         -Change and get the location in the SLMpixelGroup.
%         -Change and get the value of a pixel.
%         -Randomize the values of all the pixels in the group to one
%         specific value.
%         -Add gratings to the group.
%         -Select and deselect all the pixels in the group.
%         -Transfer a pixel line to another pixel group.
%         -Get the size of the group.
% 
%     SLMPixelGroup is a subclass of handle: if you copy its handle, it will not
%     copy the object but rather just a reference towards that object.
    properties (SetAccess = private)
        pixelGroup; %Contains all the pixels.
        columns; %Current number of columns in the array.
        lines; %Current number of lines in the array.
        overlayPercent; %Indicates the amount that the group is overlayed with the others.
    end
    properties (Constant, Access = private)
       DEFAULT_INITIAL_PIXEL_VALUE = 255; 
       X_GRATING_NAMES = {'x','X','length'} %Possible grating names. The first one is stored as the grating type.
       Y_GRATING_NAMES = {'y','Y','width','height'} %Possible grating names. The firs one is strored as the grating type.
    end
    methods
        
        
        function object = SLMPixelGroup(m, n, overlayPercent, varargin)
%             The constructor of the class. When the pixel group is first
%             initialized, it is assumed that the pixels are black. 
%                 @object : the new SLMPixelGroup object created.
%                 @m : the number of lines of the pixel array.
%                 @n : the number of columns of the pixel array.

            %(Declaration and definition) of variables
            initialPixelGrayscale = object.DEFAULT_INITIAL_PIXEL_VALUE;
            %Module
            %No need to treat error on varargin because the constructor of
            %SLMPixel does it.
            if (object.isNumeric(m,n,overlayPercent) && object.isWhole(m,n) && m > 0 && n > 0 && overlayPercent > 0 && overlayPercent <= 1 && nargin >= 3 && nargin <= 4)
                if (nargin==4)
                   initialPixelGrayscale = varargin{1};
                end
                object.overlayPercent = overlayPercent;
                object.pixelGroup = SLMPixel;
                for i = 1:m
                    for j = 1:n
                        object.pixelGroup(i,j) = SLMPixel(initialPixelGrayscale);
                    end
                end
                SLMPixelGroup.refreshSize(object);
            elseif(~object.isNumeric(m,n,overlayPercent) || nargin == 4 && ~object.isNumeric(varargin{1}))
                errorNotice.message = ['One of the folowing values is not numeric: m : ', class(m),', n : ', class(n), ', overlay percent : ', class(overlayPercent)];
                errorNotice.identifier= 'SLMPixelGroup:NAN';
                if (length(varargin) == 1)
                    errorNotice.message = [errorNotice.message, ' or initial grayscale : ', class(varargin{1})]; 
                end
                errorNotice.message = [errorNotice.message, '!'];
                error(errorNotice);
            elseif ~(object.isWhole(m,n) && m > 0 && n > 0)
                errorNotice.message = ['Either the number of lines was not whole, negative or zero (m = ', num2str(m),') or the number of columns was not whole, negative, or zero (n = ', num2str(n), ')!'];
                errorNotice.identifier= 'SLMPixelGroup:invalidSizeOfGroup';
                error(errorNotice);
            elseif ~(overlayPercent > 0 && overlayPercent <= 1)
                errorNotice.message = ['Invalid overlay percent during construction. Value must be between 0 and 1 and a double. Overlay is ', num2str(overlayPercent), ' of type ', class(overlayPercent), '!'];
                errorNotice.identifier= 'SLMPixelGroup:invalidOverlayPercent';
                error(errorNotice);
            elseif ~(nargin >= 3 && nargin <= 4)
                errorNotice.message = ['There were to many arguments during the call of the constructor for SLMPixelGroup (there should be 3 or 4 but there was ', num2str(nargin),')!'];
                errorNotice.identifier= 'SLMPixelGroup:TooManyArgumentsAtCall';
                error(errorNotice);
            end
        end
        
        function setValue(object, positionM, positionN, value)
%             This method changes the value of the of a pixel in the group at
%             a given position.
%                 @object : the group in which the change will occur.
%                 @positionM : the horizontal position in the pixel matrix.
%                 @positionN : the vertical position in the pixel matrix.
%                 @value : the new value for the pixel.

           %Module
           %NOTE: error check on value is done inside the SLMPixel class' setGrayScale method and getPixel.
           object.getPixel(positionM, positionN).setGrayscale(value);
        end
        
        function result = getValue(object, positionM, positionN)
            %             This method gets the value of the of a pixel in the group at
            %             a given position.
            %                 @object : the group in which the pixel's value will be got.
            %                 @positionM : the horizontal position in the pixel matrix.
            %                 @positionN : the vertical position in the pixel matrix.
            %                 @result : the grayscale value in the pixel.
           %Module
           result = object.getPixel(positionM, positionN).getGrayscale();
        end
            
        function randomize(object, varargin)
            %             Randomizes the entire group of pixels to a randomly generated
            %             value.
            %                 @object : the pixel group that is currently being modified.
            %             Randomizes a specified pixel.
            %                 @varargin{1}: the line in which the pixel is found.
            %                 @varargin{2}: the column in which the pixel is found.
            if (isempty(varargin))
            if (~isempty(object.pixelGroup))
                %Declaration and definition of variables
                object.pixelGroup(1,1).randomize; %There should always be atleast 1 pixel.
                randValue = object.pixelGroup(1,1).getGrayscale(); %The new random value.
                for i = 1:object.lines;
                    for j = 1:object.columns;
                        object.pixelGroup(i,j).setGrayscale(randValue);
                    end
                end
            end
            elseif(length(varargin) == 2)
                object.getPixel(varargin{1}, varargin{2}).randomize();
            else
                errorNotice.message = ['Too many arguments were given to the randomize method. There should be 0 or 2 and there was ', num2str(length(varargin)),'!'];
                errorNotice.identifier= 'SLMPixelGroup:NoSuchArgumentCombination';
                error(errorNotice);
            end
        end
       
        function makeGrating(object, gratingType, lengthOfGradient, highestValue)
            %             This function overlays a grating over the pixel group.
            %                 @object : the object to which the grating will be added.
            %                 @value : the type of grating of the group.
            %                 @varargin : when there are 4 more arguments,
            %                 the program assums that the gradient is
            %                 larger than the group. The first argument
            %                 indicates the length of the gradient. The
            %                 second argument indicates the starting
            %                 gradient value.
            
            %Module
            if (object.isNumeric(lengthOfGradient, highestValue) && object.isWhole(lengthOfGradient, highestValue) && highestValue > 0)
               switch(num2str(gratingType))
                    case object.X_GRATING_NAMES
                        object.linearGrating(lengthOfGradient, highestValue, 1);
                    case object.Y_GRATING_NAMES
                        object.linearGrating(lengthOfGradient, highestValue, 0);
                    otherwise
                        errorNotice.message = ['There was no such grating type! The grating type received was : ', num2str(gratingType), ' which should be of type char and was of type ', class(gratingType),'!'];
                        errorNotice.identifier= 'SLMPixelGroup:NoSuchGratingType';
                        error(errorNotice);
               end
            elseif ~(object.isNumeric(lengthOfGradient, highestValue) && object.isWhole(lengthOfGradient, highestValue))
                errorNotice.message = ['The values given should be whole numbers of type double and whole but were: ', 'length of gradient: (', class(lengthOfGradient),') ', num2str(lengthOfGradient),', highest value: (', class(highestValue) ') ', num2str(highestValue), '.'];
                errorNotice.identifier= 'SLMPixelGroup:ValuesMustBeNumeric';
                error(errorNotice);
            else
                errorNotice.message = ['The highest value must be bigger than zero but it was', num2str(highestValue),'.'];
                errorNotice.identifier= 'SLMPixelGroup:NoSuchGratingType';
                error(errorNotice);
            end
        end
        
        function setSelected(object, value, varargin)
            %             This function select and deselect pixels by toggling the
            %             selection.
            %                 @object : the group that will be selected.
            
            %Module.
            if (isempty(varargin))
                for i=1:object.lines
                    for j=1:object.columns
                        object.setPixelSelection(i,j,value);
                    end
                end
            elseif (length(varargin) == 1)
                values=varargin{1};
                sizeValues = size(values);
                if (sizeValues(2) == 2)
                    positionM=varargin{1}(:,1);
                    positionN=varargin{1}(:,2);
                    object.setPixelSelection(positionM,positionN,value);
                else
                    errorNotice.message = ['Values for selection must be an array of must be m by 2 vectors but were ', sizeValues(1),' by ', sizeValues(2), '!'];
                    errorNotice.identifier= 'SLMPixelGroup:SpecifiedValueToGetDoesNotExist';
                    error(errorNotice);
                end
            end
        end
        
        function result = getSelected(object)
            %             Indicates what pixels are selected in the current array of pixels by returning a matrix of the same number of columns and lines as the current array of pixels. A 1 in this array indicates that the pixel is selected.
            %                 @object : the current SLMPixelGroup for which the selected
            %                 pixels a sought.
            %                 @result : the matrix indicating the position of the
            %                 selected pixels
            result = zeros(object.lines, object.columns);
            %Module
            for i=1:object.lines
                for j=1:object.columns
                    result(i,j) = object.getPixel(i,j).getSelected();
                end
            end
        end
        
        function result = transfer(object, object2, positionOfLine, numberOfLines)
            %             Transfers pixel line from one group to another. There are only 4 starting points for the lines that can be transfered: either the TOP, the BOTTOM,  the RIGHT or the LEFT relative to the group giving the pixels to another. 
            %                 @object : the object making the transfer.2
            %                 @object2 : the object receiving the transfer.
            %                 @nameOfLine : either TOP, BOTTOM, RIGHT, LEFT or ALL.
            %                 @numberOfLines : indicates the number of lines to be
            %                 transfered.
            %                 @result : true when the pixel group should be deleted because
            %                 all lines have been transfered.
            
            %Module.
            if (isa(object2, 'SLMPixelGroup') && numberOfLines > 0 && isnumeric(numberOfLines) && object.isWhole(numberOfLines))
                switch(positionOfLine)
                    case 'TOP'
                        if (object2.columns == object2.columns && object.lines >= numberOfLines)
                            object2.pixelGroup = vertcat(object2.pixelGroup(), object.pixelGroup(1:numberOfLines, :));
                            object.pixelGroup = object.pixelGroup(numberOfLines+1:object.lines, :);
                        end
                    case 'BOTTOM'
                        if (object2.columns == object2.columns && object.lines >= numberOfLines)
                            object2.pixelGroup = vertcat(object.pixelGroup(object.lines-(numberOfLines-1):object.lines, :), object2.pixelGroup());
                            object.pixelGroup = object.pixelGroup(1:object.lines-numberOfLines,:);
                        end
                    case 'RIGHT'
                        if (object2.lines == object.lines && object.columns >= numberOfLines)
                            object2.pixelGroup = horzcat(object.pixelGroup(:, object.columns-(numberOfLines-1):object.columns), object2.pixelGroup());
                            object.pixelGroup = object.pixelGroup(:,1:object.columns-numberOfLines);
                        end
                    case 'LEFT'
                        if (object2.lines == object.lines && object.columns >= numberOfLines)
                            object2.pixelGroup = horzcat(object2.pixelGroup(), object.pixelGroup(:, 1:numberOfLines));
                            object.pixelGroup = object.pixelGroup(:,numberOfLines+1:object.columns);
                        end
                    otherwise
                       errorNotice.message = ['Either the following is not TOP, RIGHT, LEFT OR BOTTTOM : ', positionOfLine, '!'];
                       errorNotice.identifier= 'SLMPixelGroup:InvalidParameters';
                       error(errorNotice);
                end
                SLMPixelGroup.refreshSize(object, object2);
                if (object.columns == 0 && object.lines == 0)
                    result =1;
                end
            elseif ~(object.isNumeric(numberOfLines) && object.isWhole(numberOfLines) && numberOfLines > 0 && ((object2.columns == object2.columns && (strcmp(positionOfLine,'TOP') || strcmp(positionOfLine,'BOTTOM'))  || (object2.lines == object.lines)&& (strcmp(positionOfLine,'RIGHT') || strcmp(positionOfLine,'LEFT')))))
               errorNotice.message = ['Either the number of lines for the transfer of the pixel groups was not a double and it was a ', class(numberOfLines), ' (numberOfLines = ', num2str(numberOfLines),', cannot be > object.lines = ', num2str(object.lines) ', and object.columns = ', num2str(object.columns), '!'];
               errorNotice.identifier= 'SLMPixelGroup:InvalidParameters';
               error(errorNotice);
            else
                errorNotice.message = ['The object passed to the additive method is not a SLMPixelGroup but rather a ', class(object2),'!'];
                errorNotice.identifier= 'SLMPixelGroup:InvalidSecondObjectType';
                error(errorNotice);
            end
        end
           
        function result = getOverlayPercent(object)
            %             Returns the amount that this pixel group is overlayed with its other counterparts (pixel groups with the same position as itself.)
            %                 @object : the current object's pointer.
            %                 @result : the value returned.
           result = object.overlayPercent;
        end
        
        function setOverlayPercent(object, overlayPercent)
            %             Sets the amount that this pixel group is overlayed with its
            %             other counterparts (pixel groups with the same position as itself.)
            %                 @object : the current object's pointer.
            %                 @overlayPercent : the new overlay percent for this pixel
            %                 group.
            if (object.isNumeric(overlayPercent) && overlayPercent > 0 && overlayPercent <= 1)
                object.overlayPercent = overlayPercent;
            else
                errorNotice.message = ['Invalid overlay percent during set. Value must be between 0 and 1 and a double. Overlay was ', num2str(overlayPercent), ' of type ', class(overlayPercent), '!'];
                errorNotice.identifier= 'SLMPixelGroup:invalidOverlayPercent';
                error(errorNotice);
            end
        end
        
        function result = getSize(object)
            %This function gets the size of the current group. It returns it
            %             in the form m*n where m is the number of rows and n is the
            %             number of columns.
            %                 @obejct = the object containing the array of pixels for
            %                 which the size is sought.
            
            result = size(object.pixelGroup);
        end
        
        function result = test(object)
        %             %%%%%%%%%%%%%%%%%%%%%%%USE IN TESTING ONLY%%%%%%%%%%%%%%%%%%%%%%%%
        %             Returns an array of integers representing the gray values of
        %             the group.
        %                 @result : The gray values of the group.
        result = zeros(object.lines, object.columns);
        %Module
        for i = 1:object.lines;
            for j = 1:object.columns;
                result(i,j) = object.pixelGroup(i,j).getGrayscale();
            end
        end
        end    
    end
    methods(Access = private)
        function result = isWhole(~,varargin)
            %             Verifies that the property is a whole number.
            %                 @~, ignores the SLMPixelGroup object since it is unused.
            %                 @varargin : Indicates a variable number of arguments. 
            %                     (e.g. varargin{1} is the first argument)
            result = 1;
            if ~isempty(varargin)
                for i = 1:length(varargin)
                   result = result && ~mod(varargin{i},1);
                end
            else
                result =0;
            end
        end
        
        function linearGrating(object, maxVarient, highestValue, flip)
            %             Creates a grating along the x or the y axis.
            %                 @object : The object making the call.
            %                 @maxVarirent : The numbre of pixels with differing values
            %                 in the linear gradient.
            %                 @flip: when true, the grating is made along the length of
            %                 the screen. When false, the grating is made along the
            %                 height of the screen.
            %                 @highestValue : the highest value of the gradient.        

            %(Declaration and definition of variables)
            varientNegative = -1+2*(maxVarient>0);
            maxVarient = maxVarient * varientNegative;
            numberOfDecrements = maxVarient-(maxVarient ~=1)*1;
            constant = (~flip)*object.lines +(flip)*(object.columns);
            varient = (~flip)*object.columns +(flip)*(object.lines);
            lineValue = 0;
            vector = [];
            %Module
            %Make vector that represents the matrix
            for i = 0:numberOfDecrements
                vector = [vector lineValue];
                lineValue = lineValue*~(lineValue>=SLMPixel.getMaximumGrayscale);
                lineValue = lineValue + highestValue/numberOfDecrements;
            end
            %Put the gradient in the array.
            vectorPosition = 1 +(length(vector)-1)*(varientNegative<0);
            for i = 1:varient
                for j = 1:constant
                    object.pixelGroup(i,j).setGrayscale(vector(vectorPosition));
                    if (varientNegative<0)
                        if (vectorPosition == 1)
                            vectorPosition = length(vector);
                        else 
                            vectorPosition = vectorPosition - 1;
                        end
                    else
                        vectorPosition = (vectorPosition)*(vectorPosition ~= length(vector)) + 1;
                    end
                end
            end
        end
        
        function result = isNumeric(~, varargin)
            %             Indicates whether or not the input(s) is of a numerical type.
            %                 @~ignore the input of the object calling the function.
            %                 @varargin : the array of arguments entered.
            result = 1;
            %Module
            if ~isempty(varargin)
                for i = 1:length(varargin)
                    result = result && isnumeric(varargin{i});
                end
            else 
                result =0;
            end
        end
        
        function result = getPixel(object, positionM, positionN)
           %             Gets a pixel from the array of the current object.
            %                 @object : the current SLMPixelGroup.
            %                 @positionM : the column in which the pixel is found.
            %                 @positionN : the line in which the pixel is found.
           %Module
           %NOTE: error check on value is done inside the SLMPixel class' setGrayScale method.
           if (object.isNumeric(positionM, positionN) && object.isWhole(positionM, positionN) && positionM > 0 && positionM <= object.lines && positionN > 0 && positionN <= object.columns)
               result = object.pixelGroup(positionM, positionN);
           elseif ~(object.isNumeric(positionM) && object.isWhole(positionM) && positionM > 0 && positionM <= object.lines)
               errorNotice.message = ['The number of lines in the pixel group was either not a double and it was a ', class(positionM), ' or it is out of bounds (0 < m = ', num2str(positionM),' < ' num2str(object.lines), ')'];
               errorNotice.identifier= 'SLMPixelGroup:SpecifiedValueToGetDoesNotExist';
               error(errorNotice);          
           else
               errorNotice.message = ['Either the number of columns was either not a double and it was a ', class(positionN), ' or it is out of bounds (0 < n = ', num2str(positionN), ' < ', num2str(object.columns),')!'];
               errorNotice.identifier= 'SLMPixelGroup:specifiedValueToGetDoesNotExist';
               error(errorNotice);
           end
        end
        
        function setPixelSelection(object, m, n, value)
%             Select or deselect a pixel or do nothing if it is already selected or deselected.
%                 @object : the SLMPixelGroup in which the pixel will be set
%                 to the specified value.
%                 @m : the line in which the pixel to be toggled is found.
%                 @n : the column in which the pixel to be toggled is found.

            if (length(m) == length(n)  && (value == 1 || value == 0))
                for i=1:length(m)
                    currentPixel = object.getPixel(m(i),n(i));
                    if (currentPixel.getSelected() ~= value)
                        currentPixel.toggleSelection();
                    end
                end
            elseif (length(m) == length(n))
                errorNotice.message = ['Values for selection must be an array of must be m by 2 vectors but were ', length(m),' by ', length(n), '!'];
                errorNotice.identifier= 'SLMPixelGroup:SpecifiedValueToGetDoesNotExist';
                error(errorNotice);
            else  
                errorNotice.message = ['Value can only be set to a 1 or 0 and value was ', value, ' and it needs to be a numerical type but was ', class(value),' !'];
                errorNotice.identifier= 'SLMPixelGroup:SpecifiedValueToGetDoesNotExist';
                error(errorNotice);
            end
        end 
    end
    methods(Static, Access = private)       
        function refreshSize(varargin)
        %    Refresh the values of the number of columns and the number of lines in the group for a certain number of objects.
        %        @varargin : contains the objects to refrest.
            
            %Module
            if (length(varargin) >=1)
                for i = 1:length(varargin)
                    if (~isempty(varargin{i}) && isa(varargin{i}, 'SLMPixelGroup'))
                        objectSize = varargin{i}.getSize();
                        varargin{i}.lines = objectSize(1);
                        varargin{i}.columns = objectSize(2);
                    elseif~(isa(varargin{i}, 'SLMPixelGroup'))
                       errorNotice.message = ['One of the arguments of refreshSize was not an object of type SLMPixelGroup but was rather a ', class(varargin{i}), '!'];
                       errorNotice.identifier= 'SLMPixelGroup:CannotRefreshObjectType';
                       error(errorNotice);
                    end 
                end
            end
        end
    end
end