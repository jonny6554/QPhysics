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

classdef SLMRegroupement
   properties
       regroupement; %Contains the regroupement of the SLMPixelArrays.
       groupsM; %Indicates the number of lines.
       groupsN; %Indicates the number of groups.
       width; %Indicates the width of the pixels.
       length; %Indicates the length of the pixels.
   end
   methods 
       function object = SLMRegroupement(groupsM, groupsN, width, length)
           if (isNumeric(groupM, groupN, length, width) && isWhole(groupM, groupN, width, length) && groupsM < width && groupsN < length)
               %Set values of the class.
               object.groupsM = groupsM;
               object.groupsN = groupsN;
               object.width = width;
               object.length = length;
               %Initialize the regroupement.
               if (groupsM < length && groupsN < width)
                   object.regroupement = SLMPixelArrray;
                   divisionM = width/groupsM;
                   divisionN = length/groupsN;
                   m =divisionM;
                   n =divisionN;
                   for i = 1:groupsM
                       for j = 1:groupsN
                           object.regroupement(i,j) = SLMPixelArray(round(m),round(n),i,j);
                           m = divisionM + m;
                           n = divisionN + n;
                       end
                   end
               end
           end
       end
       
       function makeGradientAt(positionM, positonN, type)
       end
       
       function setValueTo
           
       end
   end
   methods (Access = private)
       function getPixel(positionM, positionN)
           %Get the value of a pixel in the regroupement. Returns the
           %combination of groups in the SLMpixel Array.
           
       end
       function setPixel()
          %Set the value of a pixel in the regroupement
          %
       end
   end
end