close all



L = 60;

N = 5; % Number of Ribs.

Ls = L / N;

x = linspace(0,L,N+2);

for i = 1:N
   C(i) = Ls*i - Ls/2;
end

figure(1)
clf
plot(x,[0,C,L],'-ok')