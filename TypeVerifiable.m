classdef (Abstract) TypeVerifiable < handle
%   If a class contains calculations, it may need to verify if a series
%   of numbers is whole or not or whether a series of values are numeric.
%   This interface contains basic static methods allowing the following:
%       -Verification as to whether or not a series of values are whole
%       numbers.
%       -Verification as to whether or not a series of values are numbers.
    methods (Access = protected, Static)
       function result = isWhole(varargin)
%       Verifies that the property is a whole number.
%           @varargin: Indicates a variable number of arguments.
%       (e.g. varargin{1} is the first argument)
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
%      Indicates whether or not the input(s) is of a numerical type.
%           @varargin : the array of arguments entered.
%      (e.g. varargin{1} is the first argument)
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