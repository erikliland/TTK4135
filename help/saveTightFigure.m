function saveTightFigure(h,outfilename)
% Saves figure H in file outfilename without the white space around it. 
% 
% Usage :
%
%   saveTightFigure('fig_name.eps') 
%       Save current figure
%
%   savsaveTightFigureefig(figure(X) ,'fig_name.pdf') 
%       Save figure X
% 
% The filename extension choose the format.
% Suported formats (same that saveas founction) :
%   ai bmp emf eps fig jpg m pbm pcx pdf pgm png ppm tif
%
% by         :  E Akbas
% updated by :  Flavio "LeviCC" Capitao

if nargin == 0 
    error('Not enough input arguments.')
elseif nargin==1
    outfilename = h;
    h = gcf;
end

%% save state and set next new figures invisibles  
dv.f = get(0, 'DefaultFigureVisible');
dv.a = get(0, 'DefaultAxesVisible');
set(0, 'DefaultFigureVisible', 'off')
set(0, 'DefaultAxesVisible', 'off')

%% copy figure  
h_to_print = figure;
copyobj(get(h,'children'),h_to_print);

%% put old default visible parameters  
set(0, 'DefaultFigureVisible', dv.f)
set(0, 'DefaultAxesVisible', dv.a)

%% find all the axes in the figure
hax = findall(h_to_print, 'type', 'axes');

%% compute the tighest box that includes all axes
tighest_box = [Inf Inf -Inf -Inf]; % left bottom right top
for i=1:length(hax)
    set(hax(i), 'units', 'centimeters');
    
    p = get(hax(i), 'position');
    ti = get(hax(i), 'tightinset');
    
    % get position as left, bottom, right, top
    p = [p(1) p(2) p(1)+p(3) p(2)+p(4)] + ti.*[-1 -1 1 1];
    
    tighest_box(1) = min(tighest_box(1), p(1));
    tighest_box(2) = min(tighest_box(2), p(2));
    tighest_box(3) = max(tighest_box(3), p(3));
    tighest_box(4) = max(tighest_box(4), p(4));
end

%% move all axes to left-bottom
for i=1:length(hax)
    if strcmp(get(hax(i),'tag'),'legend')
        continue
    end
    p = get(hax(i), 'position');
    set(hax(i), 'position', [p(1)-tighest_box(1) p(2)-tighest_box(2) p(3) p(4)]);
end

%% resize figure to fit tightly
set(h_to_print, 'units', 'centimeters');
p = get(h_to_print, 'position');

width = tighest_box(3)-tighest_box(1);
height =  tighest_box(4)-tighest_box(2); 
set(h_to_print, 'position', [p(1) p(2) width height]);

%% set papersize
set(h_to_print,'PaperUnits','centimeters');
set(h_to_print,'PaperSize', [width height]);
set(h_to_print,'PaperPositionMode', 'manual');
set(h_to_print,'PaperPosition',[0 0 width height]);

%% white background  
%set(h_to_print, 'Color', 'w');

%% save it
saveas(h_to_print,outfilename,'epsc');

%% close h_to_print  
close(h_to_print);
