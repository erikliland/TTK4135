t = 0:100;

y1 = sin(0.1*t);
y2 = 1.1*sin(0.11*t-0.13);

z1 = exp(-(0.1*(t-50)).^2);
z2 = exp(-(0.08*(t-50)).^2);

f1 = figure(1);
clf(f1);

sp(1) = subplot(2,1,1);
hold('on');
plot(t,y1,'LineWidth',1);
plot(t,y2,'--r','LineWidth',2);
hold('off');
box('on');
ylim([-1.2, 1.2]);
set(sp(1), 'YTick', -1.2:0.4:1.2);
set(sp(1), 'XTickLabel', '');

sp(2) = subplot(2,1,2);
hold('on');
plot(t,z1,'LineWidth',1);
plot(t,z2,'--r','LineWidth',2);
hold('off');
box('on');
ylim([-0.2, 1.2]);
set(sp(2), 'YTick', -0.2:0.2:1.2);

% Figure paper dimensions (not exact):
w = 12; % w cm wide
h =  8; % h cm tall

% Set the dimensions of the figure
set(f1, 'units','centimeters');
pos = get(gcf, 'position');
set(gcf, 'position', [pos(1), pos(2), w, h]);

% Add some text
h_text(1) = ylabel(sp(1), '$\lambda(t)$');
h_text(2) = ylabel(sp(2), '$f^2(t)$');
h_text(3) = xlabel(sp(2), '$t$/s');
h_text(4) = legend(sp(2), '$q = 1.0$', '$q = 0.1$', 'Location', 'NE');
h_text(5) = title(sp(1), 'Comparison of functions');

set(h_text, 'Interpreter', 'Latex');

% Go to the figure windon, click 'File', then 'Save As...', 
% choose 'EPS file' in 'save as type:'. For some reason, this works better
% than saving the figure as EPS using the print or saveas commands, at 
% least in some cases.
