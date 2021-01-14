function [R, T] = Reangularity(MAT)

n = size(MAT,2);

R = 1;

T = zeros(n);

for i = 1:n-1
    for j = i+1:n
        
        col1 = MAT(:,i);
        col2 = MAT(:,j);
        
        CkiCkj  = abs(sum(col1.*col2));
        Cki2    = sum(col1.^2);
        Ckj2    = sum(col2.^2);
        
        InternalTerm = sqrt(abs(1- CkiCkj.^2 / Cki2 / Ckj2));
        R = R * InternalTerm;
        
        if isnan(InternalTerm)
           disp('TEST') 
        end
        
        T(i,j) = InternalTerm;
%         T(j,i) = InternalTerm;
        
    end
end

% T(T==0) = NaN;

end

