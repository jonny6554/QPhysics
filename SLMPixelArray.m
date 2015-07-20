classdef SLMPixelArray < handle
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
       function object = SLMPixelArray(numberOfSubGroups, m, n, posM, posN)
%             This is the constructor of the class; it initializes the values
%             of the object.
%                 @object: the object being created.
%                 @numberOfSubGroups: the number of groups to be overlayed.
          %Module.
          if (object.isWhole(numberOfSubGroups, m, n, posM, posN) && numberOfSubGroups > 0 && m > 0 && n > 0 && posM >= 0 && posN >= 0)
             object.positionM = posM;
             object.positionN = posN;
             for i = 1:numberOfSubGroups
                 if (i ==1)
                    object.groupArray =  SLMPixelGroup(m, n, 1/numberOfSubGroups);
                 else
                    object.groupArray = [object.groupArray, SLMPixelGroup(m, n, 1/numberOfSubGroups)];
                 end
             end
          elseif ~(object.isWhole(numberOfSubGroups, m, n, posM, posN))
               errorNotice.message = ['All of the following numbers should be whole but they are not whole: number of sub-groups: ', num2str(numberOfSubGroups),', number of lines: ', num2str(m), ', number of columns: ', num2str(n), ', the line position in the figure: ' num2str(posM), ', the column position in the figure: ', num2str(posN), '!'];
               errorNotice.identifier= 'SLMPixelArray:InvalidParameterTypeForConstruction';
               error(errorNotice);
          else
               errorNotice.message = ['Some of the following number(s) are negative: number of sub-groups: ', num2str(numberOfSubGroups),', number of lines: ', num2str(m), ', number of columns: ', num2str(n), ', the line position in the figure: ' num2str(posM), ', the column position in the figure: ', num2str(posN), '!'];
               errorNotice.identifier= 'SLMPixelArray:NegativeNumbersCannotBePresentDuringConstruction';
               error(errorNotice);
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
          if (object.isWhole(positionM, positionN) && positionM > 0 && positionN > 0)
              object.positionM = positionM;
              object.positionN = positionN;
          elseif (~object.isWhole(positionM, positionN))
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
           if (isnumeric(number) && object.isWhole(number) && number < arrayLength && number > 0)
               if(arrayLength == 1)                 %Single element senario
                  object.groupArray = SLMPixelGroup(size(1), size(2), arrayLength); 
               elseif (number == 1)                 %First element senario
                   object.groupArray = object.groupArray(2:arrayLength);
               elseif(number == arrayLength)        %Last element senario
                   object.groupArray = object.groupArray(1:(number-1));
               else                                 %Middle element senario.
                   object.groupArray = [object.groupArray(1:number-1), object.groupArray(number+1:arrayLength)];
               end
           elseif ~(isnumeric(number) && object.isWhole(number) )
               errorNotice.message = ['Error: the number of the subgroup is not a valid number (number = ',num2str(number), ' of type ', class(number), ')!'];
               errorNotice.identifier= 'SLMPixelArray:NANOrNotAValidNumber';
               error(errorNotice);
           else
               errorNotice.message = 'Error: the number of the subgroup that you whish to remove does not exist within the group!';
               errorNotice.identifier= 'SLMPixelArray:ElementDoesNotExist';
               error(errorNotice);
           end
       end
       
       function result = show(object)
%         Returns an SLMPixelGroup representing the combined result of the sub-groups.
%                 @object: the object containing the array that shall be
%                 combined.
%                 @result: the combined array of the values of the
%                 subgroups. Each subgroups contribution is indicated by the
%                 groups overlay percent.
          %(Declaration and dictionaray) of vairables.
          size = object.groupArray(1).getSize(); %The size of the arrays.
          result = SLMPixelGroup(size(1), size(2), 1, 0); %The combined group.
          %Module
          for i=1:length(object.groupArray)
              currentObject = object.groupArray(i);
              for m = 1:size(1) 
                  for n = 1:size(2)
                      newValue = result.getValue(m,n) + currentObject.getOverlayPercent()*currentObject.getValue(m,n);
                      result.setValue(m, n, newValue); 
                  end
              end
          end
       end
       
       function testCombine(object)
          %%%%%%%%%%%%%%%%%%%%%%%%%%%ONLY FOR TESTING%%%%%%%%%%%%%%%%%%%%%%%%
          %Displays numerical values representing the overlayed combination
          %of the class' values.
          %     @object: the current SLMPixelArray for testing
          
          %Module
          display(object.show.test());
       end
       
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
    end
end