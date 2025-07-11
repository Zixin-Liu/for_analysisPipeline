function [allSubBehavData_Split1, allSubBehavData_Split2] = splitHalf_rand(allSubBehavData)
    % SPLITHALFODDEVEN splits each participant's 240 trials into two sets:
    % Split1: odd trials from first 120 + even trials from second 120
    % Split2: even trials from first 120 + odd trials from second 120
    
    participant_length = 240;
    half_length = 120;
    
    fields = fieldnames(allSubBehavData);
    
    total_length = length(allSubBehavData.(fields{1}));
    M = total_length / participant_length;
    
    if mod(M,1) ~= 0
        error('Length of data vectors is not a multiple of 240. Check your data!');
    end
    
    % Number of trials per split per participant = half_length (120) / 2 (half the trials)
    % So 60 trials from first half (odd or even), 60 from second half (even or odd)
    trials_per_split = half_length / 2; % 60
    
    for f = 1:numel(fields)
        field = fields{f};
        dataVec = allSubBehavData.(field);
        
        split1 = zeros(M * trials_per_split * 2, 1); % 60 + 60 = 120 per participant
        split2 = zeros(M * trials_per_split * 2, 1);
        
        for p = 1:M
            idx_start = (p-1)*participant_length + 1;
            idx_mid = idx_start + half_length - 1;
            idx_end = idx_start + participant_length - 1;
            
            % First 120 trials for participant p
            first_half = dataVec(idx_start : idx_mid);
            % Second 120 trials
            second_half = dataVec(idx_mid+1 : idx_end);
            
            % Odd and even indices relative to each half
            odd_idx_1 = 1:2:half_length;      % odd trials in first 120
            even_idx_1 = 2:2:half_length;     % even trials in first 120
            
            odd_idx_2 = 1:2:half_length;      % odd trials in second 120
            even_idx_2 = 2:2:half_length;     % even trials in second 120
            
            % For Split 1: odd trials from first half + even trials from second half
            split1_first = first_half(odd_idx_1);
            split1_second = second_half(even_idx_2);
            split1_participant = [split1_first; split1_second];
            
            % For Split 2: even trials from first half + odd trials from second half
            split2_first = first_half(even_idx_1);
            split2_second = second_half(odd_idx_2);
            split2_participant = [split2_first; split2_second];
            
            % Place participant’s split data in output vectors
            startIdx_split = (p-1)*trials_per_split*2 + 1;
            endIdx_split = p*trials_per_split*2;
            
            split1(startIdx_split:endIdx_split) = split1_participant;
            split2(startIdx_split:endIdx_split) = split2_participant;
        end
        
        allSubBehavData_Split1.(field) = split1;
        allSubBehavData_Split2.(field) = split2;
    end
end
