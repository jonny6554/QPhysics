%{
    This class contains the regroupement of all the SLMPixelArrays. It
    contains a 2D array of SLMPixelArrays. The class manages the arrays and
    contains a function that allows for the figure display to be refreshed.
    This class can :
        -Construct the subarrays and the class.
        -Select an array or multiple arrays.
        -Save the current state of the figure.
        -Regroup the subarrays.
        -Display the values in the group on the SLMFigure.
        -Create a gradient.
%}

classdef SLMRegroupement < handle
   properties (SetAccess = private)
       regroupement; %Contains the regroupement of the SLMPixelArrays.
       groupsM; %Indicates the number of lines.
       groupsN; %Indicates the number of groups.
       width; %Indicates the width of the pixels.
       length; %Indicates the length of the pixels.
   end
   properties (Access = private, Constant)
       X_GRATING_NAMES = {'x','X','length'}; %Possible grating names. 
       Y_GRATING_NAMES = {'y','Y','width','height'}; %Possible grating names.
       COLOUR_NAMES = {'c', 'C', 'colour', 'Colour'}; %Possible colour names.
   end
   methods 
       function object = SLMRegroupement(groupsM, groupsN, width, length)
           %Constructs the object. 
           %The numbers of lines (length) < number of line groups (groupsM)
           %and the number of columns (width) < number of column groups
           %(groupsN)
           
           %Module
           if (object.isNumeric(groupsM, groupsN, length, width) && object.isWhole(groupsM, groupsN, width, length) && groupsM < width && groupsN < length)
               %Set values of the class.
               SLMPixelArray.empty(0, groupsN)
               object.groupsM = groupsM;
               object.groupsN = groupsN;
               object.width = width;
               object.length = length;
               %Initialize the regroupement.
               if (groupsM < length && groupsN < width)
                   divisionM = fix(width/groupsM); %Division 1
                   divisionN = fix(length/groupsN); %Division 2
                   remainderM =rem(width,groupsM); %Remainder of division 1
                   remainderN =rem(length,groupsN); %Remainder of division 2
                   %Initialize regroupement or pixel arrays.
                   for i = 1:groupsM
                       for j = 1:groupsN
                           object.regroupement(i,j) = SLMPixelArray(1, divisionM, divisionN, i, j);
                           divisionN = divisionN + remainderN*(j == groupsN);
                       end
                       divisionM = divisionM + remainderM*(i == groupsM);
                   end
               elseif ~(object.isNumeric(groupsM, groupsN, length, width) && object.isWhole(groupsM, groupsN, width, length))
                   errorNotice.message = ['The following should all be of a numerical type and whole numbers : number of line groups = ', num2str(groupsM), ' (', class(groupsM),'), number of column groups = ', num2str(groupsN), ' (', class(groupsN),'), number of pixel lines = ', num2str(lines), ' (', class(lines),') and the number of pixel columns = ', num2str(columns), ' (', class(columns),').'];
                   errorNotice.identifier= 'SLMRegroupement:BadInputArgumentTypes';
                   error(errorNotice);
               else
                   errorNotice.message = ['Cannot make more groups than there are pixels. (m = ', num2str(width), ' < number of groups m = ', num2str(groupsM), ' and n = ', num2str(length), ' < number of groups n = ', num2str(groupsN), ').' ];
                   errorNotice.identifier= 'SLMRegroupement:MoreGroupsThanPixels';
                   error(errorNotice);
               end
           end
       end
       
       function command(object, command, m, n, varargin)
       %Runs all possible commands on the arrays.
       %
       %    @varargin : the command name and any other information
       %    needed.
       %    @command : the command to be executed.
       %    @m : the position in lines where the array are found.
       %    @n : the position in columns where the arry are found.
       
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%TODO%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %Run a method that requests missing information so that the program
       %will not crash.
       
           switch(num2str(command))
               case object.X_GRATING_NAMES
                    object.getArray(m, n).makeGrating(1, varargin);
               case object.Y_GRATING_NAMES
                    object.getArray(m, n).makeGrating(0, varargin);
               case object.COLOUR_NAMES
                    object.makeGray(m, n).makeGrating(varargin, 0);
           end
       end
       
       function show()
           %RETURNS ARRAY REPRESENTING NUMERICALLY THE REGROUPEMENT.
       end
   end
   methods (Access = private)
       function result = getArray(positionM, positionN)
           %Get the value of a pixel array in a regroupement.
           %    @positionM: the array's line in the regroupement.
           %    @positionN: the array's column in the regroupement.
           %    @result: the array that was sought.
           
           if (object.isNumeric(positionM, positionN) && object.isWhole(positionM, positionN) && positionM > 0 && positionM <= object.groupsM && positionN > 0 && positionN <= object.groupsN)
               result = object.regroupement(positionM, positionN);
           elseif ~(object.isNumeric(positionM) && object.isWhole(positionM) && positionM > 0 && positionM <= object.groupsM)
               errorNotice.message = ['The number of lines in the pixel regroupment was either not a double and it was a ', class(positionM), ' or it is out of bounds (0 < m = ', num2str(positionM),' < ' num2str(object.groupsM), ')'];
               errorNotice.identifier= 'SLMRegroupement:NoSuchLine';
               error(errorNotice);          
           else
               errorNotice.message = ['Either the number of columns was either not a double and it was a ', class(positionN), ' or it is out of bounds (0 < n = ', num2str(positionN), ' < ', num2str(object.groupsN),')!'];
               errorNotice.identifier= 'SLMRegroupement:NoSuchColumn';
               error(errorNotice);
           end
       end
       
       function setArray(positionM, positionN)
          %Set the value of a pixel in the regroupement
          %
       end
       
       function requestInformation(command, varargin)
           %%%FUNCTION REQUEST'S INPUT FROM USER.
       end
       
       function result = isWhole(~,varargin)
%           Verifies that the property is a whole number.
%                 @~, ignores the SLMPixelGroup object since it is unused.
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
   end
end