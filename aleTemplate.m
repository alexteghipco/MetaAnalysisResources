function aleTemplate(inPoints,numSubs,textFileName,spaceType)
%This script will generate a text file compatible with gingerALE for
%meta-analysis of a list of foci. Your list of foci should be placed in the
%inPoints variable wherein rows should correspond to individual foci, and
%the first three columns correspond to the x, y, and z dimensions of each
%foci. A fourth column should give a number to each coordinate based on the
%experiment or paper that it came from. This is to keep track of which
%references correspond to which coordinates. Furthermore, this will be used
%to find the number of subjects associated with each reference (i.e.
%experiment/paper). numSubs should contain this information. Each row of
%numSubs should correspond to a unique reference. The reference number
%should be in the first column and should match what you have given in
%inPoints, and the number of subjects within that reference (to associate
%with its foci) should go in the second column. spaceType can either be
%'tal' or 'mni', and textFileName is the output textfile name. This
%textfile will be writted to your working directory.

% alex.teghipco@uci.edu

%start writting out
fileID = fopen([textFileName '.txt'],'w');
header = '// Reference=';
switch spaceType
    case 'mni'
        header = [header 'MNI'];
    case 'tal'
        header = [header 'Talairach'];
end
fprintf(fileID,header);
%loop over each unique reference
uniqueRefs = unique(inPoints(:,4),'rows');

for i = 1:size(uniqueRefs,1)
    fprintf(fileID,['\n// Ref. # ' num2str(i) ]);
    sub = numSubs(find(numSubs(:,1) == uniqueRefs(i)),2);
    fprintf(fileID,['\n// Subjects=' num2str(sub) ]);
    uniqueSubset = inPoints(find(inPoints(:,4) == uniqueRefs(i)),1:3);
    for j = 1:size(uniqueSubset,1)
        if j == size(uniqueSubset,1)
            fprintf(fileID,['\n' num2str(uniqueSubset(j,1)) '\t' num2str(uniqueSubset(j,2)) '\t' num2str(uniqueSubset(j,3)) '\n']);
        else
            fprintf(fileID,['\n' num2str(uniqueSubset(j,1)) '\t' num2str(uniqueSubset(j,2)) '\t' num2str(uniqueSubset(j,3))]);
        end
    end
end
fclose(fileID);
    
    
    
