function subIDTable = subNumToID(allSubBehavData)
% Generates a table converting Subj_num to ID

subjNum = unique(allSubBehavData.subj_num);
ID = unique(allSubBehavData.ID);
if length(subjNum) == length(ID)
    subIDTable = cat(2, subjNum, ID);
else
    disp("subject number and ID do not match!");
    return
end
end

