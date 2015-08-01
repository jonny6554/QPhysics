classdef SLMRegroupement < TypeVerifiable
%    This class contains the regroupement of all the SLMPixelArrays. It
%    contains a 2D array of SLMPixelArrays. The class manages the arrays and
%    contains a function that allows for the figure display to be refreshed.
%    This class can :
%        -Construct the subarrays and the class.
%        -Select an array or multiple arrays.
%        -Save the current state of the figure.
%        -Regroup the subarrays.
%        -Display the values in the group on the SLMFigure.
%        -Create a gradient.
   properties (SetAccess = private)
       regroupement; %Contains the regroupement of the SLMPixelArrays.
       groupsM; %Indicates the number of lines.
       groupsN; %Indicates the number of groups.
       pixWidth; %Indicates the width of the pixels.
       pixLength; %Indicates the length of the pixels.
       currentState; %Matrix representing the current numerical values.
   end
   properties (Access = private, Constant)
       %For exectution of commands
       X_GRATING_NAMES = {'x','X','length'}; %Possible grating names. 
       Y_GRATING_NAMES = {'y','Y','width','height'}; %Possible grating names.
       COLOUR_NAMES = {'c', 'C', 'colour', 'Colour'}; %Possible colour names.
       %For the execution of optimization algorithms.
       LINEAR_OPTIMIZATION_RATE = 10; %The number of pixels that the optimization algorithm jumps over per iteration.
       PAUSE_BETWEEN_OPTIMIZAITON_VALUES = 0.2; %The length of a pause between optimization values in seconds. 
   end
   methods 
       function object = SLMRegroupement(groupsM, groupsN, width, length)
           %Constructs the object. 
           %The numbers of lines (length) < number of line groups (groupsM)
           %and the number of columns (width) < number of column groups
           %(groupsN)
           
           %Module
           if (SLMRegroupement.isNumeric(groupsM, groupsN, length, width) && SLMRegroupement.isWhole(groupsM, groupsN, width, length) && groupsM < width && groupsN < length)
               %Set values of the class.
               object.regroupement = SLMPixelArray;
               object.regroupement(groupsM, groupsN) = SLMPixelArray;
               object.groupsM = groupsM;
               object.groupsN = groupsN;
               object.pixWidth = width;
               object.pixLength = length;
               %Initialize the regroupement.
               if (groupsM <= length && groupsN <= width)
                   divisionM = fix(width/groupsM); %Division 1
                   divisionN = fix(length/groupsN); %Division 2
                   remainderM =rem(width,groupsM); %Remainder of division 1
                   remainderN =rem(length,groupsN); %Remainder of division 2
                   %Initialize regroupement or pixel arrays.
                   for i = 1:groupsM
                      divisionM = divisionM + remainderM*(i == groupsM);
                       for j = 1:groupsN
                           divisionN = divisionN + remainderN*(j == groupsN);
                           object.regroupement(i,j) = SLMPixelArray(1, divisionM, divisionN, i, j); 
                           divisionN = divisionN - remainderN*(j == groupsN);
                       end
                       divisionM = divisionM - remainderM*(i == groupsM);
                   end
                   object.currentState = zeros(width, length); %Since values are initialized at zero.
               elseif ~(SLMRegroupement.isNumeric(groupsM, groupsN, length, width) && SLMRegroupement.isWhole(groupsM, groupsN, width, length))
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
                       object.numericize(m,n);
                   case object.Y_GRATING_NAMES
                       object.getArray(m, n).makeGrating(0, varargin);
                       object.numericize(m,n);
                   case object.COLOUR_NAMES
                       if(length(varargin) == 2)
                            object.getArray(m, n).makeGray(varargin{1}, varargin{2});
                            object.numericize(m,n);
                       end
                       
               end
           
       end
       
       function numericize(object, m, n)
           %Returns an array that represents the current state of the
           %objects in the regroupement.
           %    @object : the regroupement for which a numerical
           %    representation is sought.
           
           %(Declaration and definition) of variables.
           distanceM = 0;
           distanceN = 0;
           %Module.
           currentObject = object.getArray(m,n); %Throws errors.
           arrayToBeTreated = currentObject.numericize();
           currentSize = size(arrayToBeTreated);
           if (m ~= 1)
               for i=1:(m-1)
                   currentObject = object.getArray(i,1);
                   distanceM = distanceM + currentObject.getWidth();
               end
           end
           if (n ~= 1)
               for i = 1:(n-1)
                   currentObject = object.getArray(1,i);
                   distanceN = distanceN + currentObject.getLength();
               end
           end
           for k = 1:currentSize(1)
               for l = 1:currentSize(2)
                   object.currentState(distanceM+k, distanceN+l) = arrayToBeTreated(k,l);
               end
           end
       end
       
       function show(object)
           %Dispays, on the current grafical figure, a representation of
           %the image.
           %    @object : the regroupement for which a graphical
           %    representation is sought.
           
           %(Declaration and definition) of variables.
           %Module.
           val = object.currentState();
           imagesc(val);
 %         image(object.numericize());pause(.001)
           colormap(gray(SLMPixel.getMaximumGrayscale())); %Sets colormap to gray values.
           set(gca, 'CLim', [SLMPixel.getMinimumGrayscale(), SLMPixel.getMaximumGrayscale()]); %Makes the colormap limits minimum 0 and the maximum 1. (otherwise -1 and 1)
           axis off;
           set(gca,'units','pixels','position',[0 0 object.pixWidth object.pixLength]); %Bottom left corner is 0,0
   %      axis off
      
         %imshow(object.numericize);
       end
       
       function result = getPixLength(object)
          %Returns the length in pixels of the regroupement.
           %    @object : the object for which the length is sought.
           
           %Module
           result = object.pixLength;
       end
       
       function result = getPixWidth(object)
           %Returns the width in pixels of the regroupement.
           %    @object : the object for which the width is sought.
           
           %Module
           result = object.pixWidth;
       end
           
       function optimizeLinearly(object)
       %This function linearly optimizes the values of the subarrays based off of the output of a powermeter. It begins the optimization at the top left corner of the window, then proceeds column by column. When it reaches the last column, if there is another line, the algorithm goes to the first column of that line, if not, the optimization is done.
       %@object : the regroupement for which optimization is sought.
       
           %(Declaration and definition) of variables
           currentValue = 0;    %The current value of the array being optimized.
           exit = 0;    %Exits the while loop when true.
           previousBestPowermeterValue = SLMRegroupement.getPowerMeterValue;%The highest powermeter value achieved.
           %Module
           for i = 1:object.groupsM
               for j = 1:object.groupsN
                   while(currentValue <= SLMPixel.getMaximumGrayscale() )
                       %Display the current value
                       object.displayResult(i, j, currentValue);
                       %Pause and check to see if the powermeter value is better.
                       pause(SLMRegroupement.PAUSE_BETWEEN_OPTIMIZAITON_VALUES);
                       display(['The current value is ', num2str(currentValue), ' for m = ', num2str(i), ' and n = ', num2str(j), '.'] );
                       newPowermeterValue = SLMRegroupement.getPowerMeterValue;
                       if (newPowermeterValue > previousBestPowermeterValue)
                          bestValue = currentValue; 
                          previousBestPowermeterValue = newPowermeterValue;
                       end
                       %Set the new current Value of the group and exit
                       %loop if the current value is the maximum possible.
                       currentValue = currentValue + SLMRegroupement.LINEAR_OPTIMIZATION_RATE;
                       if (currentValue > SLMPixel.getMaximumGrayscale() && ~exit)
                           exit = 1;
                           currentValue = SLMPixel.getMaximumGrayscale();
                       end
                   end
                   object.displayResult(i, j, bestValue);
                   currentValue = 0;
                   bestValue = 0;
                   exit = 0;
               end
           end
       end
       
       function optimizeRandomly(object, variationRate, numberOfGroupsToRandomize, waitingIterations)
          %The function randomly optimizes a certain number of groups on each loop iteration and increments their values based on a given varaiation rate, modulo the maxium pixel value. 
          %     @object : the regroupement that will be optimized.
          %     @variationRate : the rate at which the values in the group
          %     will change (modulo of this value with the maximum pixel value
          %     added with the current value of the randomly selected pixel)
          %     @numberOfGroupsToRandomize : the number of groups that will
          %     be randomized at every loop iteration.
          %     @waitingIterations: the maximum (inclusive) number of iterations that the
          %     program will wait for a better regroupement to be
          %     generated.
          
          if(SLMRegroupement.isNumeric(variationRate, numberOfGroupsToRandomize, waitingIterations) && SLMRegroupement.isWhole(variationRate, numberOfGroupsToRandomize, waitingIterations) && variationRate > 0 && numberOfGroupsToRandomize > 0&& waitingIterations >= 0)
              %(Declaration and definition) of variables
              numberOfIterations = 0;
              previousValues = zeros(numberOfIterations, 3);
              bestPowerMeterValue = 0;
              %Module
              while (numberOfIterations <= waitingIterations)
                  previousState = object.currentState; %State of regroupement before randomization.
                  for i = 1:numberOfGroupsToRandomize
                      randomM = randi(object.groupsM);
                      randomN = randi(object.groupsN);
                      %Array to which the random generation will be applied.
                      currentArray = object.getArray(randomM, randomN);
                      %Save previous values.
                      previousValues(i,1) =  currentArray.getValue(1,1,1); %There should always be atleast one groups and pixel.
                      previousValues(i,2) = randomM;
                      previousValues(i,3) = randomN;
                      %Generate new value and set.
                      newValue = mod(previousValues(i)+variationRate, SLMPixel.getMaximumGrayscale); 
                      object.getArray(randomM, randomN).makeGray(newValue, 1);
                      object.numericize(randomM, randomN);
                  end
                  object.show();
                  pause(SLMRegroupement.PAUSE_BETWEEN_OPTIMIZAITON_VALUES);
                  currentPowerMeterValue = SLMRegroupement.getPowerMeterValue();
                  if (currentPowerMeterValue > bestPowerMeterValue)
                      bestPowerMeterValue = currentPowerMeterValue;
                  else %Undo previous sets and redisplay the previous values.
                      for i = 1:numberOfGroupsToRandomize
                           %Array to which the random generation will be applied.
                           currentArray = object.getArray(previousValues(i,2), previousValues(i,3));
                           currentArray.makeGray(previousValues(i,3), 1);
                      end
                      object.currentState = previousState;
                      object.show();
                  end
              end
          else
              errorNotice.message = ['All of the following parameters must be a double, positive (or zero in the case of the last one) and whole numbers, but atleast one of these conditions was not forfilled: variation rate: ', num2str(variationRate),' (' , class(variationRate), ') number of groups to randomize: ',num2str(numberOfGroupsToRandomize),' (', class(numberOfGroupsToRandomize),') and waiting iterations: ', num2str(waitingIterations), '(', class(waitingIterations),').' ];
              errorNotice.identifier= 'SLMRegroupement:InvalidOptimizationParameters';
              error(errorNotice);
          end
       end
   end
   methods (Access = private)
       function displayResult(object, m, n, value)
           %Sets a value to one of the arrays in the regroupement.
           %    @m : the row in which the array is found.
           %    @n : the column in which the array is found.
           %    @value : the value that is set to the array.
           
               object.getArray(m, n).makeGray(value, 1);
               object.numericize(m, n);
               object.show();
        end
       
       function result = getArray(object, positionM, positionN)
           %Get the value of a pixel array in a regroupement.
           %    @positionM: the array's line in the regroupement.
           %    @positionN: the array's column in the regroupement.
           %    @result: the array that was sought.
           
           if (SLMRegroupement.isNumeric(positionM, positionN) && SLMRegroupement.isWhole(positionM, positionN) && positionM > 0 && positionM <= object.groupsM && positionN > 0 && positionN <= object.groupsN)
               result = object.regroupement(positionM, positionN);
           elseif ~(SLMRegroupement.isNumeric(positionM) && SLMRegroupement.isWhole(positionM) && positionM > 0 && positionM <= object.groupsM)
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
       
      function result = numericizeRegroupement(object)
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
       
      function result = getPowerMeterValue(~)
          %Gets the current value of the powermeter.
          %     @~: means that no inputs will be accepted.
          
          %Module
          %Gets the current power meter's value from labview.
          result = rand();
      end
   end
end