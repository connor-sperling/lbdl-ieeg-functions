
function [ in ] = struct_cut( in, field_arr, indices )
%STRUCT_CUT For a structure that has many arrays of the same
% dimensionality, apply a cut to many fields at once without lots of typing
%
% in: Structure

% field_arr: cell array of field names to apply the cut
% indices: indices for the cut, can be a cell array of indices
%
% in: same structure with cut applied
% if the indices are a cell array too, then apply a different cut each time
if iscell(indices)
    for i = 1:length(field_arr)
        % find any dots indicating sub-structures and replace them with ).(
        % add parentheses at the beginning and end
        % ex. turn 'substruct.x.y' into '('substruct').('x').('y')'
        this_field = regexprep([ '(''' char(field_arr{i}) ''')'],'\.',''').(''');
        
        % make the cut
        string_to_evaluate = ['in.' this_field ' = in.' this_field '(cell2mat(indices(i)));'];
        eval(string_to_evaluate);
    end
else % otherwise apply the same cut to each one
    for i = 1:length(field_arr)
        % find any dots indicating sub-structures and replace them with ).(
        % add parentheses at the beginning and end
        % ex. turn 'substruct.x.y' into '('substruct').('x').('y')'
        this_field = regexprep([ '(''' char(field_arr{i}) ''')'],'\.',''').(''');
        
        % make the cut
        string_to_evaluate = ['in.' this_field ' = in.' this_field '(indices);'];
        eval(string_to_evaluate);
    end
end
end
