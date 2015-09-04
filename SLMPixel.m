classdef SLMPixel < TypeVerifiable
%    This class represents a pixel. The possible values are between 0 and 255. 
%    It contains methods for constructing the pixel, setting the value, gettting the value.
%
%    SLMPixel is a subclass of handle: if you copy its handle, it will not
%    copy the object but rather just a reference towards that object.
    properties (SetAccess = private)
        grayscale_; %The value between the minimum and maximum. 
        dimension_; %The dimension of this pixel.
        position_; %The position of this pixel.
    end
    properties (Dependent)
        grayscale; %This value is used for getting and setting. It depends on it's equivalent private property.
        dimension;  %This is value is used for getting and setting. It depends on it's equivalent private property.
        position;  %This is value is used for getting and setting. It depends on it's equivalent private property.
    end
    properties (Constant, Access = private)
        GRAY_MAX = 255; %Maximum value of a pixel (inclusive).
        GRAY_MIN = 0; %Minimum value of a pixel (inclusive).
    end
    methods 
        function object = SLMPixel(grayscale, m, n, x, y)
            %
            %    Constructs the object. On construction, the pixel is not selected.
            %        @grayscale : the grayscale value of the new object.
            %        @m : the line in which the pixel is found.
            %        @n : the column in which the pixel is found.
            %        @x : the length in pixels of the pixel.
            %        @y : the width in pixels of the pixel.
            %        @object : The pixel that has just been constructed.
            %
            if (nargin > 0) %Only runs when there is atleast one argument (i.e. grayscale is given a value.).
                if (SLMPixel.isNumeric(grayscale) && SLMPixel.isWhole(grayscale) && SLMPixel.validatePixelValue(grayscale))
                    object.grayscale_ = grayscale;
                    object.position_ = [m,n];
                    object.dimension_ = [x,y];
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
        
        function set.grayscale(object, value)
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
        
        function set.position(object, position)
            %Sets the position of the current pixel.
            %   object: the current pixel's value.
            %   position: the new position of the pixel.
            
            if (length(object.position_) == length(position) && object.isNumeric(position(1), position(2)) && object.isWhole(position(1), position(2)))
               object.position_ = position; 
            else
                errorNotice.message = ['Incorrect data format: Should be of dimension two and was ', num2str(length(dimension(position))), ' and should be of type double and was ', class(position), ' and should contain only whole numbers and had ', num2str(position),'.'] ;
                errorNotice.identifier = 'SLMPixel:InvalidPositionValue';
                error(errorNotice);
            end
        end
        
        function set.dimension(object, dimension)
            %Sets the dimension of the current pixel.
            %   object: the current pixel for which the dimension will be
            %   changed.
            %   dimension : the current pixel's dimension in the figure
               
            if (length(object.dimension_) == length(dimension) && object.isNumeric(dimension(1), dimension(2)) && object.isWhole(dimension(1), dimension(2)))
               object.dimension_ = dimension; 
            else
                errorNotice.message = ['Incorrect data format: Should be of dimension two and was ', num2str(length(dimension(dimension))), ' and should be of type double and was ', class(dimension), ' and should contain only whole numbers and had ', num2str(dimension),'.'] ;
                errorNotice.identifier = 'SLMPixel:InvalidPositionValue';
                error(errorNotice);
            end
        end
        
        function result = get.position(object)
           %Gets thet position of this object. (Returns vector with two numbers.)
           %    @object : the pixel for which the position is sought.
           
           result = object.position_;
        end
        
        function result = get.dimension(object)
           %Gets thet dimension of this object. (Returns vector with two numbers.)
           %    @object : the pixel for which the dimension is sought.
           
           result = object.dimension_;
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