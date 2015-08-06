classdef PowerMeter
    %PowerMeter object represents abstractly a 1830-R powermeter,
    %The powermeter class can refresh the values of a powermeter 
    
    properties(Access = private)
        previousValue; %The value that came before the current one.
        currentValue; %The value that was last got from the powermeter.
        filename;
    end
    
    properties (Access = private, Constant)
       PAUSE_BETWEEN_GETTING_VALUES = 0.05; %The length of a pause between optimization values in seconds.  
       GUARANTEED_FILENAME_CHARACTERS = '.txt'; %The name of the directory in which labview prints a value.
       NUMBER_OF_REFRESHES_TO_PERFORM_DURING_CONSTRUCTION = 2; %The number of refreshes that will be performed during the construction of the object.
       MAXIMUM_DIFFERENCE = 500;%Maximum difference allowed betwwen two powerMeter Values.
       POWER_METER_SAMPLE_SIZE = 4; %The number of values that will be averaged out to obtain a more accurate value from the power meter.
    end
    
    methods
        function object = PowerMeter(filename)
           %The constructor of the class.
           %Initializes the values to zero and then performs two refreshs.
           
           %Module
           object.previousValue = 0;
           object.currentValue = 0;
           if (ischar(filename) && ~isempty(strfind(filename, PowerMeter.GUARANTEED_FILENAME_CHARACTERS)))
              object.filename = filename; 
           else
               errorMessage.message = ['The name given for the file is either not a valid name (add .txt?) or was not even a char and it was: (', class(filename), ') ', num2str(filename),'!'];
               errorMessage.identifier = 'PowerMeter:NotAValidLocation';
               error(errorMessage);
           end
           for i = 1:PowerMeter.NUMBER_OF_REFRESHES_TO_PERFORM_DURING_CONSTRUCTION
              object.getCurrentValue()
           end
        end
        
        function result = getCurrentValue(object)
            %Gets the value that is currently found in the specified file
            %name. It returns the powermeter's result in picoW by default.
            %   @object: the current poweremeter object.
            %(Declaration and definition) of variables
            badDifference = 0; %True when the difference in the power meter values is suspiciously different.
            average = 0; %The average value of the power meter that will be returned.
            %Module
            object.previousValue = 0;
            for i=1:PowerMeter.POWER_METER_SAMPLE_SIZE
                while (object.previousValue == object.currentValue || object.currentValue < 0 || object.previousValue < 0 || ~badDifference)
                     pause(PowerMeter.PAUSE_BETWEEN_GETTING_VALUES);
                     object.previousValue = object.currentValue;
                     [string] = textread(object.filename, '%s');
                     if (~isempty(string))
                         object.currentValue = PowerMeter.changeStringToNumericValue(string{1})*10^12;  
                     end
                     %Verify to see if the given power meter value is
                     %suspicious in size.
                     if (object.currentValue-object.previousValue <= PowerMeter.MAXIMUM_DIFFERENCE && object.currentValue-object.previousValue >= -PowerMeter.MAXIMUM_DIFFERENCE)
                         badDifference = 0;
                     else
                         badDifference = 1;
                     end
                end
                if (average == 0)
                    average = object.currentValue;
                else
                    average = average/2 + object.currentValue/2;
                end
            end
            %display(num2str(object.currentValue));             
            result = average;
        end
    end
    
    methods (Access = private, Static)
        function number = changeStringToNumericValue(string) 
           %Transforms a string that represents a number into a numerical
           %value in Matlab.

           %Module
           %status: indicates whether or not the conversion was successful.
           %potentialNumber: indicates the number when the conversion is
           %successful.
           [potentialNumber, status] = str2num(string);
           %Throws an error when the conversion is not successful.
           if (~status)
               errorMessage.message = ['The structure of the string was invalid. Should have been X.XXXXXXE-XX, where X is a number, but was ', num2str(string), '.'];
               errorMessage.identifier = 'PowerMeter:InvalidRegularExpression';
               error(errorMessage);
           else
               number = potentialNumber;
           end
        end
    end
end

