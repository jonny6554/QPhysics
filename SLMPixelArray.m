classdef SLMPixelArray < TypeVerifiable
%     This class conatains many SLMPixelGroups (it is an array of them). It
%     allows for layering of the gray values in the pixel groups, so that
%     many different types of gradients (or any other combination of
%     pixels) can be overlayed. There is always atleast one element in an
%     SLM Pixel Array.
%         -Construct an array of groups.
%         -Can get and change the position in the figure.
%         -Has a size and many subgroups of the same size.
%         -Add subgroup to Array.
%         -Remove a subgroup from the array.
%         -Can calculate a current array of pixels representing the overlayed
%         combination of the groups.
% 
%     SLMPixelArray is a subclass of handle: if you copy its handle, it will not
%     copy the object but rather just a reference towards that object.
    properties (SetAccess = private)
       positionM; %Position in the SLMRegroupement.
       positionN; %Position in the SLMRegroupement.
       groupArray; %The array of the SLMPixelGroups.
    end
    methods
       function object = SLMPixelArray(numberOfSubgroups, sizeM, sizeN, posM, posN)
%             This is the constructor of the class; it initializes the values
%             of the object.
%                 @object: the object being created.
%                 @numberOfSubGroups: the number of groups to be overlayed.

          %Module.
          if (nargin~=0)
              if (SLMPixelArray.isWhole(numberOfSubgroups, sizeM, sizeN, posM, posN) && numberOfSubgroups > 0 && sizeM > 0 && sizeN > 0 && posM >= 0 && posN >= 0)

                 object.groupArray = SLMPixelGroup.empty(0, numberOfSubgroups);
                 object.positionM = posM;
                 object.positionN = posN; 
                 for i = 1:numberOfSubgroups
                     if (i ==1)
                        object.groupArray =  SLMPixelGroup(sizeM, sizeN, 1/numberOfSubgroups);
                     else
                        object.groupArray = [object.groupArray, SLMPixelGroup(sizeM, sizeN, 1/numberOfSubgroups)];
                     end
                 end

              elseif ~(SLMPixelArray.isWhole(numberOfSubgroups, sizeM, sizeN, posM, posN))
                   errorNotice.message = ['All of the following numbers should be whole but they are not whole: number of sub-groups: ', num2str(numberOfSubgroups),', number of lines: ', num2str(sizeM), ', number of columns: ', num2str(sizeN), ', the line position in the figure: ' num2str(posM), ', the column position in the figure: ', num2str(posN), '!'];
                   errorNotice.identifier= 'SLMPixelArray:InvalidParameterTypeForConstruction';
                   error(errorNotice);
              else
                   errorNotice.message = ['Some of the following number(s) are negative: number of sub-groups: ', num2str(numberOfSubgroups),', number of lines: ', num2str(sizeM), ', number of columns: ', num2str(sizeN), ', the line position in the figure: ' num2str(posM), ', the column position in the figure: ', num2str(posN), '!'];
                   errorNotice.identifier= 'SLMPixelArray:NegativeNumbersCannotBePresentDuringConstruction';
                   error(errorNotice);
              end
          end
       end
       
       function result = getPosition(object)
%          Returns the position of the current array in the SLMRegroupement.
%                 @object: the SLMPixelArray for which the position is
%                 sought.

           %Module.
           result = [object.positionM, object.positionN];
       end
       
       function setPosition(object, positionM, positionN)
%             Changes the position of the values in the SLMRegroupement.
%                 @object: the SLMPixelArray making the call.
%                 @positionM: the position in the line of the SLMRegroupement.
%                 @positionN: the new position in the column of the SLMRegroupement.
          %Module.
          if (SLMPixelArray.isWhole(positionM, positionN) && positionM > 0 && positionN > 0)
              object.positionM = positionM;
              object.positionN = positionN;
          elseif (~SLMPixelArray.isWhole(positionM, positionN))
               errorNotice.message = ['All of the following numbers should be whole but they are not whole: the line position in the figure: ' num2str(positionM), ', the column position in the figure: ', num2str(positionN), '!'];
               errorNotice.identifier= 'SLMPixelArray:PositionCannotBeSetToRealNumber';
               error(errorNotice);
          else
               errorNotice.message = ['Some of the following number(s) are negative: the line position in the figure: ' num2str(positionM), ', the column position in the figure: ', num2str(positionN), '!'];
               errorNotice.identifier= 'SLMPixelArray:NegativeNumbersCannotBePresentDuringConstruction';
               error(errorNotice);
          end
       end
       
       function addSubgroup(object)
%             Adds a subgroup to the ending of the array. The program forces the overlays to be equal.
%                 @object: the current object to which the subgroup is being added.       
           numberOfSubgroups = length(object.groupArray);
           for i=1:numberOfSubgroups
               object.groupArray(i).setOverlayPercent(1/(numberOfSubgroups+1))
           end
           size = object.groupArray(1).getSize();
           object.groupArray = [object.groupArray, SLMPixelGroup(size(1), size(2), 1/(numberOfSubgroups+1))];
       end
       
       function removeSubgroup(object, number)
%          Remove a subgroup from the SLMPixelArray.
%             @object: the SLMPixelArray from which the subgroup will be
%             removed.
%             @number: the number of the object to be removed.
           %Declaration and definition of variable
           size = object.groupArray(1).getSize(); %The number of pixel lines and columns.
           arrayLength = length(object.groupArray); %The current number of subgroups.
           %Module
           if (isnumeric(number) && SLMPixelArray.isWhole(number) && number < arrayLength && number > 0)
               if(arrayLength == 1)                 %Single element senario
                  object.groupArray = SLMPixelGroup(size(1), size(2), arrayLength); 
               elseif (number == 1)                 %First element senario
                   object.groupArray = object.groupArray(2:arrayLength);
               elseif(number == arrayLength)        %Last element senario
                   object.groupArray = object.groupArray(1:(number-1));
               else                                 %Middle element senario.
                   object.groupArray = [object.groupArray(1:number-1), object.groupArray(number+1:arrayLength)];
               end
           elseif ~(isnumeric(number) && SLMPixelArray.isWhole(number) )
               errorNotice.message = ['Error: the number of the subgroup is not a valid number (number = ',num2str(number), ' of type ', class(number), ')!'];
               errorNotice.identifier= 'SLMPixelArray:NANOrNotAValidNumber';
               error(errorNotice);
           else
               errorNotice.message = 'Error: the number of the subgroup that you whish to remove does not exist within the group!';
               errorNotice.identifier= 'SLMPixelArray:ElementDoesNotExist';
               error(errorNotice);
           end
       end
              
       function makeGrating(object, type, info)
           %Makes a gradient pixel group at the given location in the pixel array.
           %    @object: the current pixel group array in which a gradient
           %    pixel group shall be created. 
           %    @number : the location where the pixel group will be created.  
           %    @info : When there is 2 arguments, the first indicates 
           %    the group position and the second indicates the length of 
           %    the gradient. When there is a 3rd argument, it indicates 
           %    the maximum value that the gradient is projected towards. 

           %Module
           if (length(info) == 2)
               object.getGroup(cell2mat(info(1))).makeGrating(type, cell2mat(info(2)));
           elseif (length(info) == 3)
               object.getGroup(cell2mat(info(1))).makeGrating(type, cell2mat(info(2)), cell2mat(info(3)));
           end
       end
       
       function makeGray(object, varargin)
          %Sets the gray value to a particular value.
          %     @object : the pixel array in which the group array that will be set to a particular value is found.
          %     @info : the first value in the array is the group that will
          %     be sets' location in the group pixel array and the second
          %     is the grayscale value that the group will be set to.
          if (length(varargin) == 2)
                object.getGroup(varargin{2}).setTo(varargin{1});
          end
       end
       
       function changeOverlayPercent(object, number, overlayPercent)
           %Changes the overlay percent at a particular location.
           %    @object: the pixel array in which the group of pixels' overlay 
           %    percent to be changed will be found.
           %    @number: the location of the group in the pixel array for
           %    which the overlay percent will be changed
           %    @overlayPercent : the new overlay percent.
           
           %Module
           object.groupArray(number).setOverlayPercent(overlayPercent);
       end
       
       function result = getNumberOfGroups(object)
          %Returns the number of groups inside the array of pixel groups.
          %     @objet : The object for which the number of pixel groups is sought.
           
          result = length(object.groupArray);
       end
       
       function result = numericize(object)
          %Displays numerical values representing the overlayed combination
          %of the class' values.
          %     @object: the current SLMPixelArray for testing
          
          %Module
          result = object.combine.numericize();
       end
       
       function result = getLength(object)
           %Gives the length of the current groups in the array.
           %    @object : the current array in which the groups are found
           
           %(Declaration and definition) of variables.
           size = object.getGroup(1).getSize();
           %Module
           result = size(2);               
       end
       
       function result = getWidth(object)
           %Gives the width of the current groups in the array.
           %    @object : the current array in which the groups are found
          
           %(Declaration and definition) of variables.
           size = object.getGroup(1).getSize();
           %Module
           result = size(1);               
       end
       
       function result = getValue(object, groupNumber, pixelM, pixelN)
           %Returns the value of a pixel in the group.
           %    object : the current array in which there is group in which there is a pixel for which the value is sought..
           %    groupNumber : the number of the group in which the value of
           %    the sought pixel is found.
           %    pixelM : the row of the pixel.
           %    pixelN : the column of the pixel.
           %    result : the value of the pixel in the group
           
           result = object.getGroup(groupNumber).getPixelGrayscale(pixelM, pixelN);
       end
       
       %Methods to assist during testing:
       function testSubgroups(object)
       %%%%%%%%%%%%%%%%% FOR TESTING PURPOSES ONLY %%%%%%%%%%%%%%%%%%%%%%%%%
       %This class displays all of the subgroups in the array in the order
       %that they appear.
       %    @object : the current SLMPixelArray for testing.
       
       %Module
            for i = 1:length(object.groupArray)
               display(['GroupArray number ', num2str(i), ': '])
               display(object.groupArray(i).test);
            end
       end
    end
    methods (Access = private)
       function result = combine(object)
%         Returns an SLMPixelGroup representing the combined result of the sub-groups.
%                 @object: the object containing the array that shall be
%                 combined.
%                 @result: the combined array of the values of the
%                 subgroups. Each subgroups contribution is indicated by the
%                 groups overlay percent.
          %(Declaration and dictionaray) of vairables.
          size = object.groupArray(1).getSize(); %The size of the arrays.
          result = SLMPixelGroup(size(1), size(2), 1, 0); %The combined group.
          totalOverlayPercent = 0; %Algorithm will not add any of the groups that come after this value reaches 1.
          %Module
          if (length(object.groupArray) ~= 1)
              for i=1:length(object.groupArray)
                  currentObject = object.groupArray(i);
                  totalOverlayPercent = totalOverlayPercent + currentObject.getOverlayPercent();
                  if (totalOverlayPercent > 1)
                     difference = totalOverlayPercent-1;
                     currentOverlayPercent = currentObject.getOverlayPercent()-difference;
                  else
                     currentOverlayPercent = currentObject.getOverlayPercent();
                  end
                  for m = 1:size(1) 
                      for n = 1:size(2)
                          newValue = result.getPixelGrayscale(m,n) + currentOverlayPercent*currentObject.getPixelGrayscale(m,n);
                          result.setPixelGrayscale(m, n, newValue); 
                      end
                  end
                  if (totalOverlayPercent >= 1)
                     break; 
                  end
              end
          else
              result = object.groupArray(1);
          end
        end
        
       function result = getGroup(object, number)
           %Gets a group from the group array.
           %    @number: the groups position in the array of groups.
           
            if (SLMPixelArray.isNumeric(number) && SLMPixelArray.isWhole(number) && number > 0 && number <= length(object.groupArray))
               result = object.groupArray(number);
           elseif ~(SLMPixelArray.isNumeric(number) && SLMPixelArray.isWhole(number))
               errorNotice.message = ['The numerical location of the group to which the gradient will be applied should be a double and whole but it was', class(number),'(numerical location = ' , num2str(number),').'];
               errorNotice.identifier= 'SLMPixelArray:InvalidIdentifierType.';
               error(errorNotice);
           else
               errorNotice.message = ['The numerical location must be between 0 (exclusively) and ', num2str(length(object.groupArray)),' (inclusively) but was ', num2str(number),'.'];
               errorNotice.identifier= 'SLMPixelArray:NoSuchElementInArray';
               error(errorNotice);
           end
        end
    end
end