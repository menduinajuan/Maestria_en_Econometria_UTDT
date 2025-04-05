% Métodos Empíricos en Macroeconomía Estructural - Examen Final
% Juan Menduiña


clear

cd 'G:/Mi unidad/JM/Facultad de Ciencias Económicas (FCE)/Maestría en Econometría/9. Métodos Empíricos en Macroeconomía Estructural/Examen/Datos';
base = readtable('Base.xlsx', 'Sheet', 2);

seed = 12345;
rng(seed);


%*************************************************************************%
                              % EJERCICIO 1 %
%*************************************************************************%


% DEFINICIÓN DE VARIABLES %


var_tfp          = base(:,2);
var_output       = base(:,3);
var_consumption  = base(:,4);
var_hours        = base(:,5);
var_stock_prices = base(:,6);
var_inflation    = base(:,7);
var_confidence   = base(:,8);


% DEFINICIÓN DE ARRAYS %


Y4 = table2array([var_tfp var_consumption var_output var_hours])';
Y7 = table2array([var_tfp var_consumption var_output var_hours var_stock_prices var_inflation var_confidence])';


% CÁLCULO DE NÚMERO ÓPTIMO DE REZAGOS %


results = struct();
lag_max = 10;

datasets       = {Y4, Y7};
datasets_names = {'Y4', 'Y7'};
criterias      = {'AIC', 'SIC', 'HQC'};

for d = 1:length(datasets)

    % Selección del dataset
    Y = datasets{d};
    Y_name = datasets_names{d};

    % Inicialización de criterios de información
    for c=1:length(criterias)
        results.(Y_name).(criterias{c}) = zeros(lag_max,1);
    end

    % Estimación del modelo VAR para distintos rezagos
    for lag=1:lag_max
        VAR = var_ls(Y, lag, lag_max);
        for c = 1:length(criterias)
            results.(Y_name).(criterias{c})(lag) = VAR.(criterias{c});
        end
    end

    % Determinación de número óptimo de rezagos para cada criterio
    for c=1:length(criterias)
        [~, optimalLag] = min(results.(Y_name).(criterias{c}));
        results.(Y_name).(['nlags_' criterias{c}]) = optimalLag;
    end

    % Visualización de resultados
    fprintf('\nCRITERIOS DE INFORMACIÓN PARA %s: \n', Y_name);
    fprintf('Lag     AIC        SIC        HQC   \n');
    fprintf('=================================== \n');
    for lag=1:lag_max
        fprintf('%2d   %8.3f   %8.3f   %8.3f\n', lag, results.(Y_name).AIC(lag), results.(Y_name).SIC(lag), results.(Y_name).HQC(lag));
    end
    for c=1:length(criterias)
        disp(['Número óptimo de rezagos para VAR ', Y_name, ' según ', criterias{c}, ': ', num2str(results.(Y_name).(['nlags_' criterias{c}]))]);
    end

end

clear d c lag lag_max Y Y_name VAR optimalLag;


% ESTIMACIÓN DE MODELOS VAR ESTRUCTURALES CON: %
%   - 4 VARIABLES (tfp, consumption, output, hours) %
%   - 7 VARIABLES (tfp, consumption, output, hours, stock_prices, inflation, confidence) %


for d=1:length(datasets)

    % Selección del dataset
    Y = datasets{d};
    Y_name = datasets_names{d};

    % Estimación del modelo VAR para número óptimo de rezagos según SIC
    %VAR = var_ls(Y, results.(Y_name).nlags_SIC); % Éste debería ser el modelo a estimar.
                                                  % Sin embargo, los resultados no dan muy semejantes al paper.
                                                  % Sí son bastante parecidos si se consideran 3 rezagos (como indica el paper), y no 2 y 1 para Y4 e Y7, respectivamente (como indica SIC).
    VAR = var_ls(Y, 3);                           % Con lo cual, a fines de replicar el paper, se procede a estimar con 3 rezagos.
    results.(Y_name).VAR = VAR;

end

fprintf('\nESTIMACIÓN VAR Y4:\n'), disp(results.Y4.VAR);
fprintf('ESTIMACIÓN VAR Y7:\n'), disp(results.Y7.VAR);

clear d Y Y_name VAR;


% IDENTIFICACIÓN DE SHOCKS (NEWS SHOCK Y SURPRISE TECHNOLOGY SHOCK) EN MODELOS VAR ESTRUCTURALES %


H = 40;

for d=1:length(datasets)

    % Selección del dataset
    Y = datasets{d};
    Y_name = datasets_names{d};

    % Selección de estimación del modelo VAR
    VAR = results.(Y_name).VAR;

    % Descomposición de Cholesky para obtener shocks estructurales
    epsilon = 1e-5;
    k = size(VAR.Omega,1);
    A0_inv = chol(VAR.Omega+epsilon*eye(k),'lower')\eye(k);

    % Cálculo de matriz de respuestas R
    R = calcular_R(VAR, A0_inv, H);

    % Identificación de "news shock" y "surprise technology shock" 
    results.(Y_name).news_shock = calcular_news_shock(R);
    results.(Y_name).surprise_tech_shock = A0_inv(:,1);

end

fprintf('NEWS SHOCK PARA VAR Y4:\n'),                disp(results.Y4.news_shock);
fprintf('SURPRISE TECHNOLOGY SHOCK PARA VAR Y4:\n'), disp(results.Y4.surprise_tech_shock);
fprintf('NEWS SHOCK PARA VAR Y7:\n'),                disp(results.Y7.news_shock);
fprintf('SURPRISE TECHNOLOGY PARA VAR Y7:\n'),       disp(results.Y7.surprise_tech_shock);

clear d Y Y_name VAR epsilon k A0_inv R;


% VERIFICACIÓN DE ORTOGONALIDAD ENTRE "NEWS SHOCK" Y "SURPRISE TECHNOLOGY SHOCK" %


for d = 1:length(datasets_names)

    Y_name = datasets_names{d};
    surprise_tech_shock = results.(Y_name).surprise_tech_shock;
    news_shock = results.(Y_name).news_shock;
    dot_product = dot(surprise_tech_shock,news_shock);
    fprintf('Producto punto entre "surprise technology shock" y "news shock" - VAR %s: %.6f\n', Y_name, dot_product);

    if (abs(dot_product)>1e-5)
        news_shock_ortogonal = news_shock-(dot(surprise_tech_shock,news_shock)/dot(surprise_tech_shock,surprise_tech_shock))*surprise_tech_shock;
        news_shock_ortogonal = news_shock_ortogonal/norm(news_shock_ortogonal);
        dot_product_new = dot(surprise_tech_shock,news_shock_ortogonal);
        fprintf('Nuevo producto punto entre "surprise technology shock" y "news shock" - VAR %s: %.6f\n', Y_name, dot_product_new);
        results.(Y_name).news_shock = news_shock_ortogonal;
    end

end

clear d Y_name surprise_tech_shock news_shock dot_product news_shock_ortogonal dot_product_new;


%*************************************************************************%
                              % EJERCICIO 2 %
%*************************************************************************%


Y4_names = {'TFP', 'Consumption', 'Output', 'Hours', 'Investment'};
Y7_names = {'TFP', 'Consumption', 'Output', 'Hours', 'Investment', 'Stock Prices', 'Inflation', 'Consumer Confidence'};

share_c = 0.7432; % Se computa en el archivo "Base.xlsx" (en la hoja "prepara_base")
H = 40;
reps = 2000;

% FIGURA 1 %



% FIGURA 2 %

[results.Y4.irf_Y4_shock1, results.Y4.irf_lower_Y4_shock1, results.Y4.irf_upper_Y4_shock1] = calcular_irf(results.Y4.VAR, results.Y4.news_shock, share_c, H, reps);
graficar_irf(results.Y4.irf_Y4_shock1, results.Y4.irf_lower_Y4_shock1, results.Y4.irf_upper_Y4_shock1, H, Y4_names);

% FIGURA 3 %

[results.Y4.irf_Y4_shock2, results.Y4.irf_lower_Y4_shock2, results.Y4.irf_upper_Y4_shock2] = calcular_irf(results.Y4.VAR, results.Y4.surprise_tech_shock, share_c, H, reps);
graficar_irf(results.Y4.irf_Y4_shock2, results.Y4.irf_lower_Y4_shock2, results.Y4.irf_upper_Y4_shock2, H, Y4_names);

% FIGURAS 4 y 5 %

[results.Y4.irf_Y7_shock1, results.Y4.irf_lower_Y7_shock1, results.Y4.irf_upper_Y7_shock1] = calcular_irf(results.Y7.VAR, results.Y7.news_shock, share_c, H, reps);
graficar_irf(results.Y4.irf_Y7_shock1, results.Y4.irf_lower_Y7_shock1, results.Y4.irf_upper_Y7_shock1, H, Y7_names);

% FIGURA 6 %

[results.Y4.irf_Y7_shock2, results.Y4.irf_lower_Y7_shock2, results.Y4.irf_upper_Y7_shock2] = calcular_irf(results.Y7.VAR, results.Y7.surprise_tech_shock, share_c, H, reps);
graficar_irf(results.Y4.irf_Y7_shock2, results.Y4.irf_lower_Y7_shock2, results.Y4.irf_upper_Y7_shock2, H, Y7_names);

% FIGURA 7 %




%*************************************************************************%
                               % FUNCIONES %
%*************************************************************************%


% FUNCIÓN "calcular_R" %

function R = calcular_R(VAR, A0_inv, H)

    % Determinación de número de rezagos y variables
    p = VAR.lags;
    k = size(A0_inv,1);

    % Cálculo recursivo de IRF
    Psi = cell(H+1,1);
    Psi{1} = eye(k);
    for h=1:H
        Psi_h = zeros(k);
        for lag=1:min(h,p)
            Psi_h = Psi_h+VAR.coef{lag}*Psi{h-lag+1};
        end
        Psi{h+1} = Psi_h;
    end

    % Construcción de matriz de respuestas R
    R = zeros(H,k);
    for h=1:H
        IRF_h = Psi{h+1}*A0_inv;
        R(h,:) = IRF_h(1,:);
    end

end

% FUNCIÓN "calcular_news_shock" %

function news_shock = calcular_news_shock(R)

    % Construcción la matriz Q (acumula la contribución de cada horizonte)
    Q = R'*R;

    % Restricción de la matriz Q al subespacio de las variables 2 a k
    Q_rest = Q(2:end,2:end);

    % Resolución del problema de autovalores en el espacio reducido
    [V_rest, D_rest] = eig(Q_rest);

    % Selección del autovector asociado al mayor autovalor
    [~, pos] = max(diag(D_rest));
    gamma_rest = V_rest(:,pos);

    % Reconstrucción del news shock con la restricción de impacto nulo en la TFP contemporánea
    news_shock = [0;gamma_rest];

    % Normalización del news shock
    news_shock = news_shock/norm(news_shock);

end

% FUNCIÓN "calcular_irf" %

function [irf, irf_lower, irf_upper] = calcular_irf(VAR, shock, share_c, H, reps)

    % Determinación de número de rezagos, variables y observaciones
    p = VAR.lags;
    k = size(VAR.resid,1);
    T = size(VAR.resid,2);

    % Cálculo recursivo de IRF
    irf = zeros(k+1,H);
    irf(1:k,1) = shock;
    irf(k+1,1) = irf(3,1)-share_c*irf(2,1);
    for h=2:H
        irf(1:k,h) = zeros(k,1);
        for lag=1:min(h-1,p)
            irf(1:k,h) = irf(1:k,h)+VAR.coef{lag}*irf(1:k,h-lag);
        end
        irf(k+1,h) = irf(3,h)-share_c*irf(2,h);
    end

    % Cálculo de intervalos de confianza mediante bootstrap
    irf_sim = zeros(k+1,H,reps);
    for rep=1:reps
        idx = randi(T,[T,1]);
        resid_bootstrap = VAR.resid(:,idx);
        Y_bootstrap = zeros(k,H);
        Y_bootstrap(:,1) = shock;
        for h=2:H
            Y_bootstrap(:,h) = zeros(k,1);
            for lag=1:min(h-1,p)
                Y_bootstrap(:,h) = Y_bootstrap(:,h)+VAR.coef{lag}*Y_bootstrap(:,h-lag);
            end
            Y_bootstrap(:,h) = Y_bootstrap(:,h)+resid_bootstrap(:,randi(T));
        end
        irf_sim(1:k,:,rep) = Y_bootstrap;
        irf_sim(k+1,:,rep) = irf_sim(3,:,rep)-share_c*irf_sim(2,:,rep);
    end
    irf_lower = prctile(irf_sim,5,3);
    irf_upper = prctile(irf_sim,95,3);

    % Reordenamiento de filas para VAR Y7 (para ubicar "investment" en quinto lugar)
    if (k==7)
        % Guardar la fila k+1 antes de sobrescribir
        aux1 = irf(k+1,:);
        aux2 = irf_lower(k+1,:);
        aux3 = irf_upper(k+1,:);
        % Desplazar filas 5 a k una posición hacia abajo
        irf(5+1:k+1,:) = irf(5:k,:);
        irf_lower(5+1:k+1,:) = irf_lower(5:k,:);
        irf_upper(5+1:k+1,:) = irf_upper(5:k,:);
        % Insertar la fila guardada en la posición 5
        irf(5,:) = aux1;
        irf_lower(5,:) = aux2;
        irf_upper(5,:) = aux3;
    end

end

% FUNCIÓN "graficar_irf" %

function graficar_irf(irf, irf_lower, irf_upper, H, names)

    figure;
    k = size(irf,1);
    time = 0:H-1;

    for i=1:k
        nexttile;
        hold on;
        fill([time, fliplr(time)], [irf_lower(i,:), fliplr(irf_upper(i,:))], [0.8 0.8 0.8], 'EdgeColor', 'none');
        plot(time, squeeze(irf(i,:)), 'b', 'LineWidth', 2);
        yline(0, '--k');
        title(names{i}, 'FontSize', 10);
        ylabel('Percent', 'FontSize', 10);
        xlabel('Horizon', 'FontSize', 10);
        xticks(0:5:H);
        hold off;
    end

end


save 'Examen_Final.mat';