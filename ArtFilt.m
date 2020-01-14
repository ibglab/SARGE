function outVect = ArtFilt(inVect,samp,HPass,LPass, isNotch, zeroPhase)

nPoles = 4;

if (HPass && LPass)
    Wn=[HPass LPass]/(samp/2);
    [b,a]=butter(nPoles, Wn, 'bandpass');
elseif (HPass)
    Wn=[HPass]/(samp/2);
    [b,a]=butter(nPoles, Wn,'high');
elseif (LPass)
    Wn=[LPass]/(samp/2);
    [b,a]=butter(nPoles, Wn,'low');
end

if (HPass || LPass)
    if (zeroPhase)
        inVect=filtfilt(b,a,inVect);
    else
        inVect=filter(b,a,inVect);
    end
end

if (isNotch)
    wo = 50/(samp/2);  bw = wo/35;
    [bnotch,anotch] = iirnotch(wo,bw);
    if (zeroPhase)
        outVect=filtfilt(bnotch,anotch,inVect);
    else
        outVect=filter(bnotch,anotch,inVect);
    end
        
else
    outVect=inVect;
end