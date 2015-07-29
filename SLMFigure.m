classdef SLMFigure < handle
%    The folowing is the object representing the window containing the
%    images generated by the program. 
%
%    Errors thrown:
%        By constructor: InvalidPositionValues, InvalidLengthValues
    properties (SetAccess = private)
        x; %x coordinate of window
        y; %y coordinate of window
        xlength; %Length of the window on the x axis.
        ylength; %Length of the windnow on the y axis.
        windowNumber; %Unique identifier of the current window.
        window; %The figure of the current object.
    end
    properties (Constant, Access = private)
       ScreenSize = get(0, 'Screensize') 
    end
    methods
        function object = SLMFigure(figNumber, regroupement)
            %Constructor of the figure (Throws InvalidPositionValues and InvalidLengthValues)
            %   @object : the SLMFigure that will be constructed.
            %   @figNumber : the number of the figure that will be
            %   constructed.
            %   @length : the length of the figure to be created.
            %   @width : the width of the figure to be created.
            
            %Module
            %Verifying that the length values entered are valid.
            if (SLMFigure.isNumeric(regroupement.pixLength, regroupement.pixWidth, figNumber) && SLMFigure.isWhole(regroupement.pixLength, regroupement.pixWidth, figNumber))
                object.ylength = regroupement.pixWidth;
                object.xlength = regroupement.pixLength;
                object.windowNumber = figNumber;
            elseif ~(SLMFigure.isNumeric(figNumber) && SLMFigure.isWhole(figNumber)) %Verifying that the figure number entered is valid.
                errorStruct.message = ' figure number of the window entered was not a double value but rather a ' + class(figNumber) +'!';
                errorStruct.identifier = 'SLMFigure:InvalidFigureNumber';
                error(errorStruct);
            else
                errorStruct.message = 'Length of window entered was not a scalar value but rather x length: '+ num2str(length)+' (' + class(length) +') and y length :' + num2str(width) + ' (' + class(width) +')!';
                errorStruct.identifier = 'SLMFigure:InvalidLengthValues';
                error(errorStruct);
            end
            initialCoordinates = [150, object.ScreenSize(4)-(object.xlength+100)];
            object.x = initialCoordinates(1);
            object.y = initialCoordinates(2);
            %Creating the figure
            object.refresh(regroupement);
        end
                
        function close(object)
            %This function closes the window of the object.
            %   @object : the object for which the window will be closed..
              
            %Module
            close(object.windowNumber);
        end
        
        function refresh(object, varargin)
            %This function refreshes the state of the current window.
            %   @object : the window that will be refrehed.
            %   @varargin : when there is 1 input and it is a
            %   SLMRegroupement, the refresh will also display the current
            %   values.
            
            %Module
            initialCoordinates = [150, object.ScreenSize(4)-(object.xlength+100)];
            %Creating the figure
            object.window = figure(object.windowNumber);
            set(object.window,'menubar','none','units','pixels');
            set(object.window,'Position',[initialCoordinates, object.ylength-1,  object.xlength-1]); %Figure appears at initial coordinates
            set(object.window,'Resize','off'); % Disable resizing 
            set(object.window,'BackingStore','off'); %For fast drawing of the figure's contents
            if (~isempty(varargin))
                if (isa(varargin{1}, 'SLMRegroupement')) %Display's the group.
                    varargin{1}.show();
                end
            end
        end
        
        function setX(object, x)
            %Setter for the x value.
            %   @object : the current figure selected on the screen.
            %   @x : the current x position on the screen.

            %Module.
            if (SLMFigure.isNumeric(x) && SLMFigure.isWhole(x) && object.isCurrentlyActive())
                object.x = x;
                vector = [object.x, object.y, object.xlength, object.ylength];
                set(gcf,'Position', vector);
            else
                errorStruct.message = 'Invalid parameters to the function. Either the position was not a double and it was a ' + class(x) + ' (x = '+ num2str(x) + ') or the figure selected is not the figure that you wanted to modify!';
                errorStruct.identifier = 'SLMFigure:InvalidParaeters';
                error(errorStruct);
            end
        end
        
        function setY(object, y)
            %Setter for the x value.
            %   @object : the current figure on the screen.
            %   @y : the current y position on the screen.

            %Module
            if (SLMFigure.isNumeric(y) && SLMFigure.isWhole(y) && object.isCurrentlyActive())
                object.y = y;
                vector = [object.x, object.y, object.xlength, object.ylength];
                set(gcf, 'Position', vector);
            else
                errorStruct.message = 'Invalid parameters to the function. Either the position was not a double and it was a ' + class(y) + ' (y = '+ num2str(y) + ') or the figure selected is not the figure that you wanted to modify!';
                errorStruct.identifier = 'SLMFigure:InvalidParaeters';
                error(errorStruct);
            end
        end
        
        function result = getx(object)
            %Getter for the x value.
            %   @object : the current figure selected on the screen.

            %Module
            result=object.x;
        end
        
        function result = gety(object)
            %Setter for the y value.
            %   @object : the current figure on the screen.
            
            %Modue
            result=object.y;
        end
        
        function result = isCurrentlyActive(object)
           %Returns wether or wether not it is the current active window.
           %    @object : the object containing the window that may be
           %    active.
           %    @result : indicates wheter the object contains the active
           %    window.
           
           %Module
           if (object.window == gcf) 
              result = 1;
           else
              result = 0;
           end
        end
        
        function fitTo(object, regroupement)
            %Fits the window to the current size of the regroupement, if
            %the regroupement is not smaller than the smallest window size
            %possible.
            %   @object : the object containing the window that will be
            %   fitted to the regroupement.
            %   @regroupement : the regroupement to which the window will be set.
            
           % if (object.)
        end
    end
    methods (Access = private, Static)
       function result = isWhole(varargin)
%           Verifies that the property is a whole number.
%                 @varargin: Indicates a variable number of arguments.
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
        
       function result = isNumeric(varargin)
            %             Indicates whether or not the input(s) is of a numerical type.
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
    end
end