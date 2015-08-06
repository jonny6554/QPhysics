classdef SLMPixelGroup < TypeVerifiable
%     This class is an SLMPixelGroupement. It allows the user to apply an action to multiple pixels, or one pixel, at a time. 
%     It is possible to :
%         -Construct the SLMPixelGroup. 
%         -Change and get the location in the SLMpixelGroup.
%         -Change and get the value of a pixel.
%         -Randomize the values of all the pixels in the group to one
%         specific value.
%         -Add gratings to the group.
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
       DEFAULT_INITIAL_PIXEL_VALUE = SLMPixel.getMinimumGrayscale(); 
    end
    methods 
        function object = SLMPixelGroup(m, n, overlayPercent, varargin)
%             The constructor of the class. When the pixel group is first
%             initialized, it is assumed that the pixels are black. 
%                 @object : the new SLMPixelGroup object created.
%                 @m : the number of lines of the pixel array.
%                 @n : the number of columns of the pixel array.
%                 @overlayPercent : the overlay percent of the group.
%                 @varargin : if there is 1 more argument, it indicates the
%                 initial value of all the pixels.
            %(Declaration and definition) of variables
            initialPixelGrayscale = object.DEFAULT_INITIAL_PIXEL_VALUE;
            %Module
            %No need to treat error on varargin because the constructor of
            %SLMPixel does it.
            if (SLMPixelGroup.isNumeric(m,n,overlayPercent) && SLMPixelGroup.isWhole(m,n) && m > 0 && n > 0 && overlayPercent > 0 && overlayPercent <= 1 && nargin >= 3 && nargin <= 4)
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
            elseif(~SLMPixelGroup.isNumeric(m,n,overlayPercent) || nargin == 4 && ~SLMPixelGroup.isNumeric(varargin{1}))
                errorNotice.message = ['One of the folowing values is not numeric: m : ', class(m),', n : ', class(n), ', overlay percent : ', class(overlayPercent)];
                errorNotice.identifier= 'SLMPixelGroup:NAN';
                if (length(varargin) == 1)
                    errorNotice.message = [errorNotice.message, ' or initial grayscale : ', class(varargin{1})]; 
                end
                errorNotice.message = [errorNotice.message, '!'];
                error(errorNotice);
            elseif ~(SLMPixelGroup.isWhole(m,n) && m > 0 && n > 0)
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
       
        function makeGrating(object, gratingType, lengthOfGradient, varargin)
            %             This function overlays a grating over the pixel group. Changing the values of the lengthOfGradient and varargin together controls the rate of change of the values of the gradient. Slope = highestValue/lengthOfGradient.
            %                 @object : the object to which the grating will be added.
            %                 @gratingType : the type of graritng.
            %                 @lengthOfGradient : indicates the length of the gradient.            
            %                 @varargin : when there is 1 more arguments,
            %                 The maximum value that the gradient is
            %                 projected towards may be changed.
            highestValue = SLMPixel.getMaximumGrayscale(); %The value that the gradient will tends towards as it approaches the maximum value of a pixel.
            %Module
            if (nargin == 4 && ~isempty(varargin) && SLMPixelGroup.isNumeric(varargin{1}) && SLMPixelGroup.isWhole(varargin{1}))
                highestValue = varargin{1};
            elseif (nargin == 4 && isempty(varargin)) 
                errorNotice.message = ['The gradient maximum should be numeric of type double but it was a ', class(varargin{1}),' (maximum value of grating = ', num2str(varargin{1}),').'];
                errorNotice.identifier= 'SLMPixelGroup:InvalidGradientMaximum';
                error(errorNotice);
            end
            if (SLMPixelGroup.isNumeric(lengthOfGradient, highestValue) && SLMPixelGroup.isWhole(lengthOfGradient, highestValue) && highestValue > 0)
               switch(num2str(gratingType))
                    case '1'
                        object.linearGrating(lengthOfGradient, highestValue, 1);
                    case '0'
                        object.linearGrating(lengthOfGradient, highestValue, 0);
                    otherwise
                        errorNotice.message = ['There was no such grating type! The grating type received was : ', num2str(gratingType), ' which should be of type double and was of type ', class(gratingType),'!'];
                        errorNotice.identifier= 'SLMPixelGroup:NoSuchGratingType';
                        error(errorNotice);
               end
            elseif ~(SLMPixelGroup.isNumeric(lengthOfGradient, highestValue) && SLMPixelGroup.isWhole(lengthOfGradient, highestValue))
                errorNotice.message = ['The values given should be whole numbers of type double and whole but were: ', 'length of gradient: (', class(lengthOfGradient),') ', num2str(lengthOfGradient),', highest value: (', class(highestValue) ') ', num2str(highestValue), '.'];
                errorNotice.identifier= 'SLMPixelGroup:ValuesMustBeNumeric';
                error(errorNotice);
            else
                errorNotice.message = ['The highest value must be bigger than zero but it was ', num2str(highestValue),'.'];
                errorNotice.identifier= 'SLMPixelGroup:NoSuchGratingType';
                error(errorNotice);
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
            if (isa(object2, 'SLMPixelGroup') && numberOfLines > 0 && isnumeric(numberOfLines) && SLMPixelGroup.isWhole(numberOfLines))
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
            elseif ~(SLMPixelGroup.isNumeric(numberOfLines) && SLMPixelGroup.isWhole(numberOfLines) && numberOfLines > 0 && ((object2.columns == object2.columns && (strcmp(positionOfLine,'TOP') || strcmp(positionOfLine,'BOTTOM'))  || (object2.lines == object.lines)&& (strcmp(positionOfLine,'RIGHT') || strcmp(positionOfLine,'LEFT')))))
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
            if (SLMPixelGroup.isNumeric(overlayPercent) && overlayPercent > 0 && overlayPercent <= 1)
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
        
        function result = numericize(object)
        %             Returns an array of integers representing the gray values of
        %             the group.
        %                 @object : the object for which a numrical representation is sought.            
        %                 @result : The gray values of the group.
        
        result = zeros(object.lines, object.columns);
        %Module
        for i = 1:object.lines;
            for j = 1:object.columns;
                result(i,j) = grayscale(object.pixelGroup(i,j));
            end
        end
        end  
        
        function setTo(object, value)
            %Set all of the values in the group to a particular value.
            %   @object : the object for which the pixels will be set to a
            %   value.
            %   @value : the value that the pixel will be set to.
            
            %All of the error checking is done inside the SLMPixel class.
            for i = 1:object.lines;
                for j = 1:object.columns;
                    grayscale(object.pixelGroup(i,j), value);
                end
            end
        end
    end
    methods(Access = private)
        function linearGrating(object, maxVarient, highestValue, flip)
            %             Creates a grating along the x or the y axis.
            %                 @object : The object making the call.
            %                 @maxVarirent : The numbre of pixels with differing values
            %                 in the linear gradient.
            %                 @highestValue : the highest value of the gradient.
            %                 @flip: when true, the grating is made along the length of
            %                 the screen. When false, the grating is made along the
            %                 height of the screen.        

            %(Declaration and definition of variables)
            varientNegative = -1+2*(maxVarient>=0);
            maxVarient = maxVarient * varientNegative;
            numberOfDecrements = maxVarient-(maxVarient ~= 1 && maxVarient ~= 0)*1;
            lineValue = 0;
            vectorPosition = [];
            vector = zeros(1,numberOfDecrements+1);
            function modifyVectorPosition(pos, constant)
                %Subfunction used to modify the value of the
                %vectorPosition. It changes depending on the gradient flip.
                if (varientNegative<0)
                    if (isempty(vectorPosition) || vectorPosition == 1 || pos == constant)
                        if (length(vector) <= constant)
                            vectorPosition = length(vector);
                        else 
                            vectorPosition = constant;
                        end
                    else 
                        vectorPosition = vectorPosition - 1;
                    end
                else
                    if (isempty(vectorPosition))
                        vectorPosition = 1;
                    else
                        vectorPosition = (vectorPosition)*(vectorPosition ~= length(vector) && pos ~= constant) + 1;
                    end
                end
            end
            %Module
            %Make vector that represents the matrix
            if (maxVarient ~= 0 && maxVarient ~= 1 && object.lines ~= 1 && object.columns ~=1)
                for i = 0:numberOfDecrements
                    vector(i+1) = lineValue;
                    lineValue = lineValue*~(lineValue>=SLMPixel.getMaximumGrayscale);
                    lineValue = lineValue + highestValue/numberOfDecrements;
                end
            elseif (object.lines == 1 || object.columns ==1)
                lineValue = lineValue + highestValue/numberOfDecrements;
                vector = lineValue;
            elseif (maxVarient == 1)
                vector = SLMPixel.getMinimumGrayscale();
            else
                vector = SLMPixel.getMaximumGrayscale();
            end
            %Put the gradient in the array.
            modifyVectorPosition(1,(flip)*object.columns + ~(flip)*object.lines);
            for i = 1:object.lines
                for j = 1:object.columns
                    grayscale(object.pixelGroup(i,j), round(vector(vectorPosition)));
                    if (flip)
                        modifyVectorPosition(j,object.columns);
                    end
                end
                if ~(flip)
                    modifyVectorPosition(i,object.lines);
                end
            end
        end
        
        function result = getPixel(object, positionM, positionN)
           %             Gets a pixel from the array of the current object.
            %                 @object : the current SLMPixelGroup.
            %                 @positionM : the column in which the pixel is found.
            %                 @positionN : the line in which the pixel is found.
           %Module
           %NOTE: error check on value is done inside the SLMPixel class' set.grayscale method.
           if (SLMPixelGroup.isNumeric(positionM, positionN) && SLMPixelGroup.isWhole(positionM, positionN) && positionM > 0 && positionM <= object.lines && positionN > 0 && positionN <= object.columns)
               result = object.pixelGroup(positionM, positionN);
           elseif ~(SLMPixelGroup.isNumeric(positionM) && SLMPixelGroup.isWhole(positionM) && positionM > 0 && positionM <= object.lines)
               errorNotice.message = ['The number of lines in the pixel group was either not a double and it was a ', class(positionM), ' or it is out of bounds (0 < m = ', num2str(positionM),' < ' num2str(object.lines), ')'];
               errorNotice.identifier= 'SLMPixelGroup:SpecifiedValueToGetDoesNotExist';
               error(errorNotice);          
           else
               errorNotice.message = ['Either the number of columns was either not a double and it was a ', class(positionN), ' or it is out of bounds (0 < n = ', num2str(positionN), ' < ', num2str(object.columns),')!'];
               errorNotice.identifier= 'SLMPixelGroup:specifiedValueToGetDoesNotExist';
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