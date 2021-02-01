function [ p, idxs] = paretoFront( p )
% Filters a set of points P according to Pareto dominance, i.e., points
% that are dominated (both weakly and strongly) are filtered.
%
% Inputs: 
% - P    : N-by-D matrix, where N is the number of points and D is the 
%          number of elements (objectives) of each point.
%
% Outputs:
% - P    : Pareto-filtered P
% - idxs : indices of the non-dominated solutions
%
% Example:
% p = [1 1 1; 2 0 1; 2 -1 1; 1, 1, 0];
% [f, idxs] = paretoFront(p)
%     f = [1 1 1; 2 0 1]
%     idxs = [1; 2]

[i, dim] = size(p);
idxs = [1 : i]';
while i >= 1
    old_size = size(p,1);
    indices = sum( bsxfun( @ge, p(i,:), p ), 2 ) == dim;
    indices(i) = false;
    p(indices,:) = [];
    idxs(indices) = [];
    i = i - 1 - (old_size - size(p,1)) + sum(indices(i:end));
end    

end

% Copyright (c) 2015, Simone Parisi
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
