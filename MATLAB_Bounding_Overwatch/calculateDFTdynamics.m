function [E_P, V_P, choice_probs, P_tau] = calculateDFTdynamics(phi1, phi2, tau, epsilon, beta, M, initial_P)
    % Inputs:
    % phi1 - sensitivity parameter
    % phi2 - memory parameter
    % tau - number of preference updating steps
    % epsilon - noise parameter standard deviation (σ_ε)
    % beta - vector of attribute scaling coefficients [β1, β2, ..., βK]
    % M - matrix of attribute values [J alternatives × K attributes]
    % initial_P - initial preference vector [J×1] (optional, default zeros)
    % w - attention weights vector [K×1] (optional, default uniform)
    
    %% Initialization and Validation
   tau = max(1, round(tau));  % ensure tau is integer

    [J, K] = size(M);
    beta = beta(:)'; % Ensure beta is row vector
    
    if nargin < 7 || isempty(initial_P)
        initial_P = zeros(J, 1); % Default zero initial preferences
    end
    
    if nargin < 8 || isempty(w)
        w = ones(K, 1)/K; % Uniform attention weights if not provided
    else
        w = w(:)/sum(w); % Ensure normalization
    end
    
    %% Core DFT Calculations
    
    % 1. Scale attributes by beta coefficients
    M_scaled = M .* beta;
    
    % 2. Create contrast matrix C (J×J)
    C = eye(J) - ones(J)/J;
    
    % 3. Calculate distance matrix D (J×J)
    D = zeros(J);
    for i = 1:J
        for j = 1:J
            D(i,j) = sqrt(sum((M_scaled(i,:) - M_scaled(j,:)).^2));
        end
    end
    
    % 4. Compute feedback matrix S (J×J)
    S = eye(J) - phi2 * exp(-phi1 * (D.^2));
      
    % 5. Calculate mean valence μ (J×1)
    mu = C * M_scaled * w;
    
    % 6. Compute valence covariance Φ (J×J)
    Psi = diag(w) - w*w'; % K×K matrix
    Phi_part = C * M_scaled * (beta' .* Psi); % J×K * K×K = J×K
    Phi = Phi_part * (M_scaled' * C') + (epsilon^2 * eye(J));
    
    %% Preference State Evolution
    [J, ~] = size(M);  % J = number of alternatives (must match initial_P)

    % 7. Expected preference after τ steps (ξ)
    I = eye(J);
    if phi2 == 0 % No memory case
        E_P = tau * mu + initial_P;
        V_P = tau * Phi;
    else
    % Ensure initial_P matches J (pad with zeros if needed)
    if length(initial_P) < J
        initial_P = [initial_P; zeros(J - length(initial_P), 1)];
    end
    
    % Corrected calculation
    E_P = (I - S) \ ((I - S^tau) * mu) + S^tau * initial_P;
    
    % 8. Preference covariance (Ω)
    V_P = zeros(J);
    for r = 0:(tau-1)
        V_P = V_P + (S^r) * Phi * (S')^r;
    end
end
    
    % 9. Simulate full preference state evolution
    P_tau = zeros(J, tau+1);
    P_tau(:,1) = initial_P;
    for step = 1:tau
        % Random attention (one-hot vector)
        att = zeros(K,1);
        att(randsample(K,1,true,w)) = 1;
        
        % Valence vector with noise
        V = C * M_scaled * att + epsilon*randn(J,1);
        
        % Update preference state
        P_tau(:,step+1) = S * P_tau(:,step) + V;
    end
    
    %% Choice Probability Calculation
    
    % 10. Softmax approximation (for J < 5)
    if J <= 4
        % Simple softmax for small J
        scaled_E = (E_P - mean(E_P))/(epsilon + eps);
        choice_probs = exp(scaled_E)/sum(exp(scaled_E));
    else
        % MVN integration for larger J (requires stats toolbox)
        try
            % Add small diagonal noise to ensure positive definiteness
            V_P_stable = V_P + 1e-6 * eye(size(V_P));
            R = chol(V_P); % Cholesky decomposition
            Z = repmat(E_P,1,1e5) + R'*randn(J,1e5);
            [~,maxIdx] = max(Z);
            choice_probs = histcounts(maxIdx,1:J+1)'/1e5;
        catch
            warning('MVN integration failed, using simple softmax');
            choice_probs = softmax(E_P/epsilon);
        end
    end
    
    % Ensure probabilities sum to 1
    choice_probs = choice_probs/sum(choice_probs);
end

function s = softmax(x)
    e = exp(x - max(x));
    s = e/sum(e);
end