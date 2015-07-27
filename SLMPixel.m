classdef SLMPixel < handle
%    This class represents a pixel. The possible values are between 0 and 255. 
%    It contains methods for constructing the pixel, setting the value, gettting the value.
%
%    SLMPixel is a subclass of handle: if you copy its handle, it will not
%    copy the object but rather just a reference towards that object.
    properties (SetAccess = private)
       grayscale; %The value between 0 and 255. 
       selected; %Indicates whether or whether not the pixel is selected.
    end
    properties (Constant, Access = private)
        GRAY_MAX = 255; %Maximum value of a pixel (inclusive).
        GRAY_MIN = 0; %Minimum value of a pixel (inclusive).
    end
    methods 
        function object = SLMPixel(grayscale)
            %
            %    Constructs the object. On construction, the pixel is not selected.
            %        @grayscale : the grayscale value of the new object.
            %        @object : The pixel that has just been constructed.
            %
            if (nargin > 0) %Only runs when there is atleast one argument (i.e. grayscale is given a value.).
                if (object.isNumeric(grayscale) && object.isWhole(grayscale) && object.validatePixelValue(grayscale))
                    object.grayscale = grayscale;
                elseif (~object.isNumeric(grayscale))
                    errorNotice.message = ['Error: cannot create pixel. Grayscale should be a double and is ', class(grayscale), '!'];
                    errorNotice.identifier = 'SLMPixel:InvalidGrayscaleConstructionType';
                    error(errorNotice);
                else 
                    errorNotice.message = ['Error: Grayscales value should be between ', num2str(object.GRAY_MIN), ' and ', num2str(object.GRAY_MAX), ' and its value was ', num2str(grayscale), '.'] ;
                    errorNotice.identifier = 'SLMPixel:InvalidGrayscaleConstructionValue';
                    error(errorNotice);
                end
                object.selected = 0;
            end
        end
        
        function setGrayscale (object, value)
            %    Sets the value of the pixel.
            %        @object : the SLMPixel object.
            %        @value : the new value of the pixel.
           if (object.isNumeric(value) && object.isWhole(value) && object.validatePixelValue(value))
               object.grayscale = value;
           elseif ~(object.isNumeric(value))
                errorNotice.message = ['Error: cannot set value to pixel. Grayscale should be a double and is ', class(value), '!'];
                errorNotice.identifier = 'SLMPixel:InvalidGrayscaleSetType';
                error(errorNotice);
           else 
                errorNotice.message = ['Error: cannot set value to pixel. Grayscale should be a double and is ', class(value), '. Grayscales value should be between ', num2str(object.GRAY_MIN), ' and ', num2str(object.GRAY_MAX), ' and its value was ', num2str(value), '.'] ;
                errorNotice.identifier = 'SLMPixel:InvalidGrayscaleSetValue';
                error(errorNotice);
           end
        end
        
        function result = getGrayscale(object)
            %    Gets the value of the pixel.
            %        @object : the SLMPixel object.
            %        @result : the value of the pixel.
            result = object.grayscale;  
        end
        
        function toggleSelection(object)
             %    Changes the pixel to selected or deselected or vice versa. (Complements value)
             %        @object : the SLMPixel object.
            object.selected = ~object.selected;
        end
        
        function result = getSelected(object)
            %    Gets the value of selected.
            %        @object : the SLMPixel object.
            %        @result : 1 if it is selected.
            result = object.selected;
        end
    end 
    methods (Static) 
        function result = getMaximumGrayscale()
            %    Returns the maximum grayscale value in grayscale pixel value.
            result = SLMPixel.GRAY_MAX;
        end
             
        function result = getMinimumGrayscale()
            %    Returns the minimum grayscale value in grayscale pixel value.
            result = SLMPixel.GRAY_MIN;
        end
    end
    methods (Access = private)
        function result = isWhole(~, number)
            %    Verifies that the property is a whole number.
            %        @~, ignores the SLMPixel object since it is unused.
            %        @number : the number for which the verification will take
            %        place.
            %        @result : either a 1 or zero. 1 means that number is .
            result = ~mod(number,1);
        end  
        
        function result = isNumeric(~, varargin)
            %    Indicates whether or not the input(s) is of a numerical type.
            %        @~ignore the input of the object calling the function.
            %        @varargin : the array of arguments entered.
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
        
        function result = validatePixelValue(object, grayscaleValue)
           %    Verifies that thet pixel value is between the given numbers.
           %        @object : the current SLMPixel object.
           %        @grayscaleValue : the grayScale value to be verified.
           %        @result : either a 1 or zero. 1 means that number is scalar.
           result = grayscaleValue >= object.GRAY_MIN && grayscaleValue <= object.GRAY_MAX;
        end
    end    
end