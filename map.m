function cood = map(data_matrix,lat,lon)
[m,n] = size(data_matrix);
acc = 1;
for i = 1:m
    for j = 1:n
        if isnan(data_matrix(i,j)) && (lon(i)  > 250 && lon(i) < 400)
                % Atlantic Ocean
            if (i>1&& i<length(data_matrix(:,1))&&...
                    ((isnan(data_matrix(i-1,j)) && ~isnan(data_matrix(i+1,j)))...
                    || (~isnan(data_matrix(i-1,j)) && isnan(data_matrix(i+1,j)))))...
                    || (i == 1 && ~isnan(data_matrix(i+1,j)))...
                    || (i == length(data_matrix(:,1))&& ~isnan(data_matrix(i-1,j)))
                cood(:,acc) = [lon(i);lat(j)];
                acc = acc + 1;
            end
        end     
    end
end
end