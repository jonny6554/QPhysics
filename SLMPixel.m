classdef SLMPixel < TypeVerifiable
%    This class represents a pixel. The possible values are between 0 and 255. 
%    It contains methods for constructing the pixel, setting the value, gettting the value.
%
%    SLMPixel is a subclass of handle: if you copy its handle, it will not
%    copy the object but rather just a reference towards that object.
    properties (SetAccess = private)
        grayscale_; %The value between the minimum and maximum. 
    end
    properties (Dependent)
        grayscale %This value is used for getting and setting. It depends on it's equivalent private property.
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
                if (SLMPixel.isNumeric(grayscale) && SLMPixel.isWhole(grayscale) && SLMPixel.validatePixelValue(grayscale))
                    object.grayscale_ = grayscale;
                elseif (~SLMPixel.isNumeric(grayscale))
                    errorNotice.message = ['Error: cannot create pixel. Grayscale should be a double and is ', class(grayscale), '!'];
                    errorNotice.identifier = 'SLMPixel:InvalidGrayscaleConstructionType';
                    error(errorNotice);
                else 
                    errorNotice.message = ['Error: Grayscales value should be between ', num2str(object.GRAY_MIN), ' and ', num2str(object.GRAY_MAX), ' and its value was ', num2str(grayscale), '.'] ;
                    errorNotice.identifier = 'SLMPixel:InvalidGrayscaleConstructionValue';
                    error(errorNotice);
                end
            end
        end
        
        function set.grayscale (object, value)
            %    Sets the value of the pixel.
            %        @object : the SLMPixel object.
            %        @value : the new value of the pixel.
           if (SLMPixel.isNumeric(value) && SLMPixel.isWhole(value) && SLMPixel.validatePixelValue(value))
               object.grayscale_ = value;
           elseif ~(SLMPixel.isNumeric(value))
                errorNotice.message = ['Error: cannot set value to pixel. Grayscale should be a double and is ', class(value), '!'];
                errorNotice.identifier = 'SLMPixel:InvalidGrayscaleSetType';
                error(errorNotice);
           else 
                errorNotice.message = ['Error: cannot set value to pixel. Grayscale should be a double and is ', class(value), '. Grayscales value should be between ', num2str(object.GRAY_MIN), ' and ', num2str(object.GRAY_MAX), ' and its value was ', num2str(value), '.'] ;
                errorNotice.identifier = 'SLMPixel:InvalidGrayscaleSetValue';
                error(errorNotice);
           end
        end
        
        function result = get.grayscale(object)
            %    Gets the value of the pixel.
            %        @object : the SLMPixel object.
            %        @result : the value of the pixel.
            result = object.grayscale_;  
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
    methods (Access = private, Static)       
        function result = validatePixelValue(grayscaleValue)
           %    Verifies that thet pixel value is between the given numbers.
           %        @object : the current SLMPixel object.
           %        @grayscaleValue : the grayScale value to be verified.
           %        @result : either a 1 or zero. 1 means that number is scalar.
           result = grayscaleValue >= SLMPixel.GRAY_MIN && grayscaleValue <= SLMPixel.GRAY_MAX;
        end
    end    
end