function color = hex2rgb(hex)
color = sscanf(hex(2:end),'%2x%2x%2x',[1 3])/255;
end