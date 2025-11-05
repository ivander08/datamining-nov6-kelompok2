% kelompok 2
% Ivander 53522020, Justin Salim 535220017, Jason Chainara Putra 535220045

clear; clc;
rng('default'); % <- biar sama aja hasilnya setiap kali jalan tapi boleh di comment -ivander

data = readmatrix('Data Tugas Resampling.xlsx', 'Range', 'C4'); 
[n, p] = size(data);

% 1. cari estimasi vektor mean + matriks covariance asli 
mean_asli = mean(data);
cov_asli = zeros(p, p);
for x = 1:p 
    for y = 1:p
        mean_x = mean_asli(x);
        mean_y = mean_asli(y);
        jumlah_perkalian = 0;
        for i = 1:n 
            nilai_xi = data(i, x);
            nilai_yi = data(i, y);        
            hasil_perkalian = (nilai_xi - mean_x) * (nilai_yi - mean_y);
            jumlah_perkalian = jumlah_perkalian + hasil_perkalian;
        end
        cov_asli(x, y) = jumlah_perkalian / (n - 1);
    end
end

% 2. cari estimasi vektor mean + matriks covariance bootstrap (100 replikasi)
% pake cara yang dari skripsi jadi pake variabel B
B = 100;
mean_boot_replikasi = zeros(B, p);
cov_boot_replikasi = zeros(p, p, B);

for r = 1:B
    nomor_acak = randi(n, n, 1);      % indeks acak dengan replacement
    sampel_boot = data(nomor_acak, :);
    
    mean_boot_replikasi(r, :) = mean(sampel_boot);
    
    cov_boot = zeros(p, p);
    for x = 1:p
        for y = 1:p
            mean_x = mean_boot_replikasi(r, x);
            mean_y = mean_boot_replikasi(r, y);
            jumlah_perkalian = 0;
            for i = 1:n
                nilai_xi = sampel_boot(i, x);
                nilai_yi = sampel_boot(i, y);
                hasil_perkalian = (nilai_xi - mean_x) * (nilai_yi - mean_y);
                jumlah_perkalian = jumlah_perkalian + hasil_perkalian;
            end
            cov_boot(x, y) = jumlah_perkalian / (n - 1);
        end
    end
    cov_boot_replikasi(:, :, r) = cov_boot;
end

mean_boot = mean(mean_boot_replikasi, 1);
cov_boot = mean(cov_boot_replikasi, 3);

% di skripsi minta hitung standard error tapi sepertinya tidak perlu

% 3. cari estimasi vektor mean + matriks covariance jacknife-del-5
% pake cara yang dari skripsi jadi pake variabel d
d = 5;
n_jack = n - d;

mean_jack_replikasi = zeros(B, p);
cov_jack_replikasi = zeros(p, p, B);

for r = 1:B
    nomor_acak = randperm(n, n_jack); % randperm dia tak diulang -ivander
    sampel_jack = data(nomor_acak, :);
    
    mean_jack_replikasi(r, :) = mean(sampel_jack);
    
    cov_jack_temp = zeros(p, p);
    for x = 1:p
        for y = 1:p
            mean_x = mean_jack_replikasi(r, x);
            mean_y = mean_jack_replikasi(r, y);
            jumlah_perkalian = 0;
            for i = 1:n_jack
                nilai_xi = sampel_jack(i, x);
                nilai_yi = sampel_jack(i, y);
                hasil_perkalian = (nilai_xi - mean_x) * (nilai_yi - mean_y);
                jumlah_perkalian = jumlah_perkalian + hasil_perkalian;
            end
            cov_jack_temp(x, y) = jumlah_perkalian / (n_jack - 1);
        end
    end
    cov_jack_replikasi(:, :, r) = cov_jack_temp;
end

mean_jack = mean(mean_jack_replikasi, 1);
cov_jack = mean(cov_jack_replikasi, 3);

%tampilin hasil
fprintf('\nestimasi vektor mean\n');
fprintf('variabel\tasli\t\tbootstrap\tjackknife-delete-5-%d\n', d);
for j = 1:p
    fprintf('var %d\t\t%.6f\t%.6f\t%.6f\n', j, ...
        mean_asli(j), mean_boot(j), mean_jack(j));
end

fprintf('\nmatriks covariance asli\n');
disp(cov_asli);

fprintf('\nmatriks covariance bootstrap (resampling 100)\n');
disp(cov_boot);

fprintf('\nmatriks covariance jacknife-delete-5\n', d);
disp(cov_jack);
