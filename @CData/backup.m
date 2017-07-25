function backup(obj)
for iI = 1:numel(obj)
    obj(iI).OldCenter = mean(obj(iI).Window);
    obj(iI).OldWidth  = obj(iI).Window(2) - obj(iI).Window(1);
end