function compareLLH(varargin)
    % Number of inputs
    nInputs = nargin;
    
    if nInputs == 0
        error('No input structs provided.');
    end

    % Initialize storage
    llh_values = zeros(1, nInputs);
    input_names = cell(1, nInputs);

    % Loop over inputs
    for i = 1:nInputs
        s = varargin{i};
        if ~isstruct(s) || ~isfield(s, 'llh')
            error('Input %d is not a struct with field ".llh".', i);
        end
        llh_values(i) = sum(s.llh);
        
        % Get variable name if possible
        input_names{i} = inputname(i);
        if isempty(input_names{i})
            input_names{i} = sprintf('input%d', i);
        end
    end

    % Sort and rank
    [sorted_llh, sort_idx] = sort(llh_values, 'ascend');
    sorted_names = input_names(sort_idx);

    % Display results
    fprintf('\n--- LLH Comparison (Low to High) ---\n');
    fprintf('%-10s | %-10s\n', 'Name', 'LLH');
    fprintf('----------------------------\n');
    for i = 1:nInputs
        fprintf('%-10s | %-10.4f\n', sorted_names{i}, sorted_llh(i));
    end
end
