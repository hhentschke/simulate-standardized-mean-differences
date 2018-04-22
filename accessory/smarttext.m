function th=smarttext(txt,varargin)
% ** function th=smarttext(txt,varargin)
% places text at relative position within axis (default: upper left corner)
% options that can be set:
% varargin{1}       relative x coordinate, default 0.08
% varargin{2}       relative y coordinate, default 0.92
% *** horizontal alignment of text will flip at a thresh of  0.5 ***
% varargin{3} and above: input into text function

% § unclear why clipping had been set to off, disabled July 2016 
% set(gca,'Clipping','off');
x=get(gca,'XLim');
y=get(gca,'YLim');
xd=get(gca,'xdir');

xfac=0.08;
yfac=0.92;

% format options into text func
if nargin>3
  formatOpt=varargin(3:end);
else
  % a 'mock' format option
  formatOpt={'color','k'};
end

% x and y coordinates
if nargin>2
  yfac=varargin{2};
end
if nargin>1
  xfac=varargin{1};
end

% take care of proper adjustment
if xfac<.5
  formatOpt=cat(2,{'horizontalAlignment','left'},formatOpt);
else
  formatOpt=cat(2,{'horizontalAlignment','right'},formatOpt);
end

if strcmpi(xd,'reverse')
  th=text(x(2)-diff(x)*xfac,y(1)+diff(y)*yfac,txt,formatOpt{:});
else
  th=text(x(1)+diff(x)*xfac,y(1)+diff(y)*yfac,txt,formatOpt{:});
end


