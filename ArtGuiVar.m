function s = ArtGuiVar(v)

lv = length(v);
maxlv = 0;
for i=1:lv
    if (length(v{i})>maxlv)
        maxlv = length(v{i});
    end
end
str = zeros(lv,maxlv);

for i=1:lv
    str(i,1:length(v{i})) = v{i};
end

s = char(str);