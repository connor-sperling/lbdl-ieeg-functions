function scatter_clusters(cscat, cnums, clr)

    k = 1;
    figure
    hold on
    for i = 1:length(cnums)
        n = cnums(i);
        s = cscat(:,k:k+n-1);
        h = scatter(s(1,:),s(2,:), 500,clr(i,:), '.'); 
        text(mean(s(1,:)), mean(s(2,:)), sprintf('C %i', i), 'color', h.CData)
        ms = [mean(s(1,:)); mean(s(2,:))];
        ns = s-ms;
        a = angle(ns(1,:)+1i*ns(2,:));
        [~,idx]  = sort(a,'descend');
        cs = [s(:,idx) s(:,idx(1))];
        curve = fnplt(cscvn(cs));
        plot(curve(1,:),curve(2,:),'color',h.CData);
        
    %     ctemp = [cs(:,end-1) cs];
    %     dcs = diff(ctemp,1,2);
        k = k+n;
    end

end