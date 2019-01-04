function NLL = mymodelHeuristicUncertainty(pars, data)
beta1      = exp(pars(1));
allk       = exp([pars(2) pars(4);  
                  pars(3) pars(5)]); 
alphaPrior =  pars(6); %0.56;
betaPrior  =  pars(7); %0.84; 

NLL = 0;
m   = 2;
T = 25;

moneyvec  = [0 1];
socialvec = [0 1];

for moneyidx = 1:length(moneyvec)
    money = moneyvec(moneyidx);
    
    for socialidx = 1:length(socialvec)
        social = socialvec(socialidx);
        
        k = allk(moneyidx, socialidx);
        DeltaQ = computeUncertainty(T, m, k, alphaPrior, betaPrior);
        
        trialidx   = find(data.money == money & data.social == social & data.red + data.green < T);
        
        thistime   = data.red(trialidx) + data.green(trialidx) + 1;
        thischoice = data.choice(trialidx);
        
        linearidx           = sub2ind(size(DeltaQ), data.green(trialidx) + 1, thistime);
        DeltaQ_vectorized   = DeltaQ(:);
        
        % Log likelihood
        prediction = 1./(1+exp(- thischoice .* (beta1 * DeltaQ_vectorized(linearidx))));
        NLL = NLL - sum(log(prediction));
    end
end

