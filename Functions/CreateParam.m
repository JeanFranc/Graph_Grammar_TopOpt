function CreateParam(names, values, folder_path)

% Check the size of variables.
if size(names) == size(values)
    
    % Create the new file. 
    fileName = [folder_path,'\Param.txt'];
    FileID = fopen(fileName,'wt');
    
    fprintf(FileID, '#Variable Files \n');
    
    % Print all names and variables in the proper format for HyperMesh.
    for i=1:length(names)
        fprintf(FileID, "%s \t ""%s"" \n", names{i}, num2str(values{i}));
    end
    
    % Close file.
    fclose(FileID);
    
else
    error('Error in creating parameter file. The name and values cells are not the same size')
end

end

