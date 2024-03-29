function v=JADE(lu,surrogate,popsize,gmax,n)
rand('seed', sum(100 * clock));
% Initialize the main population
popold = repmat(lu(1, :), popsize, 1) + rand(popsize, n) .* (repmat(lu(2, :) - lu(1, :), popsize, 1));

%valParents=srgtsRBFEvaluate(popold, surrogate);
valParents=srgtsKRGEvaluate(popold, surrogate);

c = 1/10;
p = 0.05;
CRm = 0.5;
Fm = 0.5;
Afactor = 1;
archive.NP = Afactor * popsize; % the maximum size of the archive
archive.pop = zeros(0, n); % the solutions stored in te archive
archive.funvalues = zeros(0, 1); % the function value of the archived solutions

%% the values and indices of the best solutions
[valBest, indBest] = sort(valParents, 'ascend');
g=1;
while g < gmax %& min(fit)>error_value(problem)
    
    pop = popold; % the old population becomes the current population
    if g > 1 && ~isempty(goodCR) && sum(goodF) > 0 % If goodF and goodCR are empty, pause the update
        CRm = (1 - c) * CRm + c * mean(goodCR);
        Fm = (1 - c) * Fm + c * sum(goodF .^ 2) / sum(goodF); % Lehmer mean
    end
    
    % Generate CR according to a normal distribution with mean CRm, and std 0.1
    % Generate F according to a cauchy distribution with location parameter Fm, and scale parameter 0.1
    [F, CR] = randFCR(popsize, CRm, 0.1, Fm, 0.1);
    
    r0 = [1 : popsize];
    popAll = [pop; archive.pop];
    [r1, r2] = gnR1R2(popsize, size(popAll, 1), r0);
    
    % Find the p-best solutions
    pNP = max(round(p * popsize), 2); % choose at least two best solutions
    randindex = ceil(rand(1, popsize) * pNP); % select from [1, 2, 3, ..., pNP]
    randindex = max(1, randindex); % to avoid the problem that rand = 0 and thus ceil(rand) = 0
    pbest = pop(indBest(randindex), :);% randomly choose one of the top 100p% solutions
    % == == == == == == == == == == == == == == == Mutation == == == == == == == == == == == == ==
    vi = pop + F(:, ones(1, n)) .* (pbest - pop + pop(r1, :) - popAll(r2, :));
    
    vi = boundConstraint(vi, pop, lu);
    % == == == == = Crossover == == == == =
    mask = rand(popsize, n) > CR(:, ones(1, n)); % mask is used to indicate which elements of ui comes from the parent
    rows = (1 : popsize)'; cols = floor(rand(popsize, 1) * n)+1; % choose one position where the element of ui doesn't come from the parent
    jrand = sub2ind([popsize n], rows, cols); mask(jrand) = false;
    ui = vi; ui(mask) = pop(mask);   

    %RBF
    %valOffspring =  srgtsRBFEvaluate(ui, surrogate);
    %KRG
    valOffspring =  srgtsKRGEvaluate(ui, surrogate);

    % == == == == == == == == == == == == == == == Selection == == == == == == == == == == == == ==
    % I == 1: the parent is better; I == 2: the offspring is better   
    [valParents, I] = min([valParents, valOffspring], [], 2);
    popold = pop;
    archive = updateArchive(archive, popold(I == 2, :), valParents(I == 2));
    popold(I == 2, :) = ui(I == 2, :);
    goodCR = CR(I == 2);
    goodF = F(I == 2);
    [valBest indBest] = sort(valParents, 'ascend');        
    g=g+1;
end    
    v=popold(indBest(1),:);    
end



