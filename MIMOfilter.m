function W = MIMOfilter(train, Ztrain)
% MIMO Filter: Use training data to adaptively characterize MIMO channel
%              matrix
% 
% Inputs: 
%        train - training data 
%        Ztrain - recieved training matrix

% Number of tx and rx
nt = length(train(:,1));
nr = length(Ztrain(:,1));

% Loop over each row of the W matrix
W = zeros(nr, nt);
for i=1:nt
    W(:,i) = Ztrain*(Ztrain')\Ztrain*(train(i,:)');
end

end

