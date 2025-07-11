function [allSubBehavData_Split1, allSubBehavData_Split2] = splitHalf_seq(allSubBehavData)
    % SPLITHALFPARTICIPANTS splits participant data in each field,  each struct
    % has one of each condition in sequence. 
    %
    % Input:
    %   allSubBehavData - struct with 25 fields, each a vector of length M*240
    %                     where M = number of participants
    %
    % Outputs:
    %   allSubBehavData_Split1 - same fields, vectors length M*120 (first half of each participant)
    %   allSubBehavData_Split2 - same fields, vectors length M*120 (second half)
    
    participant_length = 240;
    half_length = 120;
    
    fields = fieldnames(allSubBehavData);
    
    % Calculate number of participants from length of any field
    total_length = length(allSubBehavData.(fields{1}));
    M = total_length / participant_length;
    
    if mod(M,1) ~= 0
        error('Length of data vectors is not a multiple of 240. Check your data!');
    end
    
    for f = 1:numel(fields)
        field = fields{f};
        dataVec = allSubBehavData.(field);
        
        split1 = zeros(M * half_length, 1);
        split2 = zeros(M * half_length, 1);
        
        for p = 1:M
            idx_start = (p-1)*participant_length + 1;
            idx_mid = idx_start + half_length - 1;
            idx_end = idx_start + participant_length - 1;
            
            % First half
            split1((p-1)*half_length + 1 : p*half_length) = dataVec(idx_start : idx_mid);
            % Second half
            split2((p-1)*half_length + 1 : p*half_length) = dataVec(idx_mid + 1 : idx_end);
        end
        
        allSubBehavData_Split1.(field) = split1;
        allSubBehavData_Split2.(field) = split2;
    end
end
