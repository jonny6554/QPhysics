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
       pixWidth; %Indicates the width of the pixels.
       pixLength; %Indicates the length of the pixels.
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
               object.regroupement = SLMPixelArray;
               object.regroupement(groupsM, groupsN) = SLMPixelArray;
               object.groupsM = groupsM;
               object.groupsN = groupsN;
               object.pixWidth = width;
               object.pixLength = length;
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
       
       %Modificataions to necessary variables.
           m = SLMRegroupement.str2Num(m);
           n = SLMRegroupement.str2Num(n);
           if (~isempty(varargin))
              for i = 1:length(varargin)
                 varargin{i} = SLMRegroupement.str2Num(varargin{i});
              end
           end
       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%TODO%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       %Run a method that requests missing information so that the program
       %will not crash.
           
           %Module
               switch(num2str(command))
                   case object.X_GRATING_NAMES
                       object.getArray(m, n).makeGrating(1, varargin);
                   case object.Y_GRATING_NAMES
                       object.getArray(m, n).makeGrating(0, varargin);
                   case object.COLOUR_NAMES
                       if(length(varargin) == 2)
                       object.getArray(m, n).makeGray(varargin);
                       end
               end
           
       end
       
       function result = show(object)
           %Returns an array that represents the current state of the
           %objects in the regroupement.
           %    @object : the regroupement for which a numerical
           %    representation is sought.
           
           %(Declaration and definition) of variables.
           %Module.
           result = zeros(object.pixWidth, object.pixLength);
           previousM = 0;
           previousN = 0;
           for i = 1:object.groupsM
               for j = 1:object.groupsN
                   currentObject = object.getArray(i,j);
                   arrayToBeTreated = currentObject.numericize();
                   currentSize = size(arrayToBeTreated);
                   for k = 1:currentSize(1)
                       for l = 1:currentSize(2)
                           result((previousM)*(i-1) + k, (previousN)*(j-1) + l) = arrayToBeTreated(k,l);
                       end
                   end
                   previousN = previousN + currentSize(2);
               end
               previousN = 0;
               previousM = previousM + currentSize(1);
           end
       end
   end
   methods (Access = private)
       function result = getArray(object, positionM, positionN)
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
       
       function resetArray(object, positionM, positionN)
          %Resets the value of a pixel array inside the regroupement to its default.
          %     @object : the object in which the array to be reset is
          %     found.
          %     @positionM : the line in which the array to be reset is
          %     found.
          %     @postionN : the column in which the array to be reset is
          %     found.
          
          %(Declaration and definition) of variables.
          selectedObject = object.getArray(positionM, positionN); %The array that will be reset.
          %Module
          for i = 1:selectedObject.getNumberOfGroups() 
              selectedObject.removeSubgroup(i);
          end
       end
       
       function requestInformation(command, varargin)
           %%%FUNCTION REQUEST'S INPUT FROM USER.
       end
       
       function makeGrating(object, gratingNumber, varargin)
           %Creates a grating on the
           
           %Module
           if(length(varargin) == 2)
               object.getArray(m, n).makeGrating(gratingNumber, varargin{1}, varargin{2});
           elseif(length(varargin) == 3)
               object.getArray(m, n).makeGrating(gratingNumber, varargin{1}, varargin{2}, varargin{3});
           end
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
   methods (Access = private, Static)
       function result = str2Num(string)
           %When it is given a char containing a number and a number only, it returns that
           %number. Otherwise it returns that char.
           %    @string : the string of characters that may contain a number.
           
           value = []; %Value is by default empty. Contains the result.
           %Module
           if (ischar(string))
               value = str2double(string);
           end
           if (isempty(value))
               value = string;
           end
           result = value;
       end
   end
end