function [handle] = plotIQ(re,im)

    % Plot IQ samples
    handle = figure();
    plot(re,im,...
        'LineStyle','none',...
        'Marker','.',...
        'MarkerSize',8, 'linewidth',10);
    xlabel('In-Phase Component')
    ylabel('Quadrature Component')

end

