function luv = xyz2luv(xyz, whitepoint)
% Convert CIE XYZ values to CIELUV values
%
% Syntax:
%   luv = xyz2luv(xyz, whitepoint)
%
% Description:
%    The whitepoint is a 3-vector indicating the XYZ of a white object or
%    patch in the scene. 
%
% Inputs:
%    xyz        - Can be in XW or RGB format.
%    whitepoint - a 3-vector of the xyz values of the white point.
%
% Outputs:
%    LUV        - Returned in identical format as the input matrix xyz.
%                 (Formats are RGB or XW)
%
% References:
%    Formulae are taken from Hunt's book,page 116. I liked the irony that
%    116 is prominent in the formula and that is the page number in Hunt.
%    Also, see Wyszecki and Stiles book.
%

% History:
%    xx/xx/03       Copyright ImagEval Consultants, LLC.
%    11/01/17  jnm  Comments & formatting
%    11/02/17  dhb  Force error if white point not specified, but provide
%                   old default value, which should make it easy to fix any
%                   calling code that breaks.
%    11/17/17  jnm  Formatting
%

% Examples:
%{
   whitepoint = [95.05 100 108.88];
   xyz = [77 88 25; whitepoint]
   xyz2luv(xyz, whitepoint)
%}

if notDefined('xyz'), error('XYZ values required.'); end
if notDefined('whitepoint')
    error('White point required. Old default was [95.05 100 108.88].');
end
if (numel(whitepoint) ~= 3 ),  error('whitepoint must be 3x1 vector'); end

if ndims(xyz) == 3
    iFormat = 'RGB';
    [r, c, ~] = size(xyz);
    xyz = RGB2XWFormat(xyz);
else
    iFormat = 'XW';
end

luv = zeros(size(xyz));

luv(:, 1) = Y2Lstar(xyz(:, 2), whitepoint(2));
[u, v] = xyz2uv(xyz);
[un, vn] = xyz2uv(whitepoint);

luv(:, 2) = 13 * luv(:,1) .* (u - un);
luv(:, 3) = 13 * luv(:,1) .* (v - vn);

% return CIELUV in the appropriate format.
% Currently it is a XW format.  If the input had three dimensions then we
% need to change it to that format.
if strcmp(iFormat, 'RGB'), luv = XW2RGBFormat(luv, r, c); end

end