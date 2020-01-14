function [cleanSeg, meanSeg, stimTime] = ArtRemPolynomial(rawData, stimTime,lZero)

    [stimTime,rawSeg] = BuildRawSeg(rawData, stimTime);

nStim = length(stimTime);
dTime = diff(stimTime);
mTime = median(dTime);

cleanSeg = cell(nStim,1);
meanSeg = cell(nStim,1);

beta0 = [27806.88737619045,-0.02775209037254,2731.2772644663446,0.030287482132115,57.71514702269194,-23.22540275116905,-693.3853117459005,0.007146142645412,13.646989326828725,-1.717425270857043];
%betaMat = biuldBeta();

h=waitbar(0,'Artifact removal...');

stop = false;
for j = 1:1
    %disp (num2str(j));
    for i=1:100
        %disp (num2str(i));
        l = find(rawSeg{i}>30000,1,'last');
        %x = [ ones(length(l+1:mTime),1) (exp(l+1:1:mTime).^-1)' ((l+1:1:mTime).^2)' (log(l+1:1:mTime))'];
        if (dTime(i)<mTime)
            x = (l+lZero+1:dTime(i))';
            segLength = dTime(i);        
        else
            x = (l+lZero+1:mTime)';
            segLength = mTime;
        end
        
        try
            beta = nlinfit1(x,rawSeg{i}(l+lZero+1:segLength)', [],beta0);
        catch 
            %disp ([mat2str(betaMat), 'Nan!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'])
            disp ('Nan!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!')
            break;            
        end
        meanSeg{i}(l+lZero+1:segLength) = expRegg2(beta,x);
        meanSeg{i}(1:l+lZero) =rawSeg{i}(1:l+lZero);
        cleanSeg{i}(l+lZero+1:segLength) = rawSeg{i}(l+lZero+1:segLength) - meanSeg{i}(l+lZero+1:segLength);
        cleanSeg{i}(1:l+lZero) = cleanSeg{i}(l+lZero+1);
        %distSeg(j,i) = calculDist( rawSeg{i},meanSeg{i});
        if (rem(i,500)==0)
            waitbar(i/nStim,h);
        end
    end
end
close (h)
%calculProbability(distSeg);


 function [yhat] = expRegg2(beta,x)
     yhat = (beta(1)*exp(beta(2)*x) -beta(3)).*(beta(9)*(sin(pi*beta(8)*x+0.00000001)./(pi*beta(8)*x+0.00000001)))+beta(7);
    
function beta = biuldBeta()

beta = zeros(100,10);
beta(:,1) = 10^4 + (4*10^4-10^4).*rand(100,1);
beta(:,2) = -0.04 + (-0.02+0.04).*rand(100,1);
beta(:,3) = 2000 + (3000-2000).*rand(100,1);
beta(:,4) = 0.03 + (0.05-0.04).*rand(100,1);
beta(:,5) = 45 + (60-45).*rand(100,1);
beta(:,6) = -33 + (-18+33).*rand(100,1);
beta(:,7) = -800 + (-300+800).*rand(100,1);
%beta(:,8) = 10^3 + (10^5-10^3).*rand(100,1);
beta(:,8) = 0.004+ (0.01- 0.004).*rand(100,1);
%beta(:,9) = 0.02 + (0.1-0.02).*rand(100,1);
beta(:,9) = 12 + (15-12).*rand(100,1);
beta(:,10) = -5 + (-1+5).*rand(100,1);


function s = calculDist(vec1,vec2)
    s = sqrt(sum((vec1-vec2).^2));
    sum(abs(vec1-vec2),2)/length(vec1);

function check
    p = find(sum(distSeg>0,2)>=100);
    minVal=min(sum(distSeg(p,:),2))
    find (sum(distSeg(p,:),2)==minVal)    