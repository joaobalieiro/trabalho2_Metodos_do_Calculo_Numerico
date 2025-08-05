% Carregar dados
try
    dados = readtable('precos.xlsx'); 
catch
    disp('Erro ao ler o arquivo de dados.')
    return
end

% Remover a coluna de datas
dados(:,1) = [];

% Calcular retornos
try
    retornos = diff(log(dados{:,:}));
catch
    disp('Erro ao calcular os retornos.')
    return
end

% Calcular matriz de covariância
matriz_cov = cov(retornos);

% Iniciar o cronômetro para a Decomposição de Cholesky
tic

% Decomposição de Cholesky
try
    L = chol(matriz_cov, 'lower');
catch
    disp('Erro na decomposição de Cholesky.')
    return
end

% Parar o cronômetro e imprimir o tempo da Decomposição de Cholesky
tempo_cholesky = toc;
disp(['Tempo da Decomposição de Cholesky: ', num2str(tempo_cholesky), ' segundos'])

% Calcular a variância do portfólio
variancia = sum(diag(L))^2;

% Calcular o desvio padrão (risco) do portfólio
risco = sqrt(variancia);

% Imprimir o risco do portfólio
disp(['O risco do portfólio é: ', num2str(risco)])

% Criar um gráfico de barras do risco de cada ativo
risco_ativos = diag(L);
figure, bar(risco_ativos, 'FaceColor', [0 .5 .5], 'EdgeColor', [.9 .9 .9], 'LineWidth',1.5)
title('Risco de cada ativo', 'FontSize', 14)
xlabel('Ativos', 'FontSize', 12)
ylabel('Risco (Desvio Padrão dos Retornos)', 'FontSize', 12)
set(gca, 'XTickLabel', dados.Properties.VariableNames, 'XTick',1:numel(dados.Properties.VariableNames))
saveas(gcf,'risco_ativos.png')

% Gerar imagens das matrizes
figure, imagesc(matriz_cov), colorbar, title('Matriz de Covariância')
saveas(gcf,'matriz_cov.png')

figure, imagesc(L), colorbar, title('Matriz L da Decomposição de Cholesky')
saveas(gcf,'matriz_L.png')

% Criar um gráfico dos retornos de cada ativo
figure, plot(retornos)
title('Retornos de cada ativo ao longo do tempo', 'FontSize', 14)
xlabel('Tempo (dias)', 'FontSize', 12)
ylabel('Retornos (log do preço de fechamento)', 'FontSize', 12)
legend(dados.Properties.VariableNames, 'Location', 'best')
saveas(gcf,'retornos.png')

% Classificar os ativos com base no risco inverso
[risco_ativos_ordenado, indices] = sort(risco_ativos, 'ascend');
ativos_ordenados = dados.Properties.VariableNames;
ativos_ordenados = ativos_ordenados(indices);

% Criar um gráfico de barras dos ativos ordenados
figure, bar(risco_ativos_ordenado, 'FaceColor', [0 .5 .5], 'EdgeColor', [.9 .9 .9], 'LineWidth',1.5)
title('Ativos ordenados por risco', 'FontSize', 14)
xlabel('Ativos', 'FontSize', 12)
ylabel('Risco (Desvio Padrão dos Retornos)', 'FontSize', 12)
set(gca, 'XTickLabel', ativos_ordenados, 'XTick',1:numel(ativos_ordenados))
saveas(gcf,'ativos_ordenados.png')

% Definir a proporção de dados a serem usados para treinamento
proporcao_treinamento = 0.6;

% Determinar o número de observações de treinamento
num_treinamento = round(proporcao_treinamento * height(dados));

% Dividir os dados em conjuntos de treinamento e teste
dados_treinamento = dados(1:num_treinamento, :);
dados_teste = dados(num_treinamento+1:end, :);

% Calcular retornos para os conjuntos de treinamento e teste
retornos_treinamento = diff(log(dados_treinamento{:,:}));
retornos_teste = diff(log(dados_teste{:,:}));

% Calcular matriz de covariância com os dados de treinamento
matriz_cov_treinamento = cov(retornos_treinamento);

% Decomposição de Cholesky com os dados de treinamento
L_treinamento = chol(matriz_cov_treinamento, 'lower');

% Calcular a variância do portfólio com os dados de treinamento
variancia_treinamento = sum(diag(L_treinamento))^2;

% Calcular o desvio padrão (risco) do portfólio com os dados de treinamento
risco_treinamento = sqrt(variancia_treinamento);

% Imprimir o risco do portfólio com os dados de treinamento
disp(['O risco do portfólio com os dados de treinamento é: ', num2str(risco_treinamento)])

% Calcular matriz de covariância com os dados de teste
matriz_cov_teste = cov(retornos_teste);

% Decomposição de Cholesky com os dados de teste
L_teste = chol(matriz_cov_teste, 'lower');

% Calcular a variância do portfólio com os dados de teste
variancia_teste = sum(diag(L_teste))^2;

% Calcular o desvio padrão (risco) do portfólio com os dados de teste
risco_teste = sqrt(variancia_teste);

% Imprimir o risco do portfólio com os dados de teste
disp(['O risco do portfólio com os dados de teste é: ', num2str(risco_teste)])

% Criar um gráfico de barras do risco de cada ativo para os dados de treinamento
risco_ativos_treinamento = diag(L_treinamento);
figure, bar(risco_ativos_treinamento, 'FaceColor', [0 .5 .5], 'EdgeColor', [.9 .9 .9], 'LineWidth',1.5)
title('Risco de cada ativo (dados de treinamento)', 'FontSize', 14)
xlabel('Ativos', 'FontSize', 12)
ylabel('Risco (Desvio Padrão dos Retornos)', 'FontSize', 12)
set(gca, 'XTickLabel', dados.Properties.VariableNames, 'XTick',1:numel(dados.Properties.VariableNames))
saveas(gcf,'risco_ativos_treinamento.png')

% Gerar imagens das matrizes para os dados de treinamento
figure, imagesc(matriz_cov_treinamento), colorbar, title('Matriz de Covariância (dados de treinamento)')
saveas(gcf,'matriz_cov_treinamento.png')

figure, imagesc(L_treinamento), colorbar, title('Matriz L da Decomposição de Cholesky (dados de treinamento)')
saveas(gcf,'matriz_L_treinamento.png')

% Criar um gráfico de barras do risco de cada ativo para os dados de teste
risco_ativos_teste = diag(L_teste);
figure, bar(risco_ativos_teste, 'FaceColor', [0 .5 .5], 'EdgeColor', [.9 .9 .9], 'LineWidth',1.5)
title('Risco de cada ativo (dados de teste)', 'FontSize', 14)
xlabel('Ativos', 'FontSize', 12)
ylabel('Risco (Desvio Padrão dos Retornos)', 'FontSize', 12)
set(gca, 'XTickLabel', dados.Properties.VariableNames, 'XTick',1:numel(dados.Properties.VariableNames))
saveas(gcf,'risco_ativos_teste.png')

% Gerar imagens das matrizes para os dados de teste
figure, imagesc(matriz_cov_teste), colorbar, title('Matriz de Covariância (dados de teste)')
saveas(gcf,'matriz_cov_teste.png')

figure, imagesc(L_teste), colorbar, title('Matriz L da Decomposição de Cholesky (dados de teste)')
saveas(gcf,'matriz_L_teste.png')

% Classificar os ativos com base no risco inverso - treinamento 
risco_treinamento_l = diag(L_treinamento)
[risco_ativos_ordenado_treinamento, indices] = sort(risco_treinamento_l, 'ascend');
ativos_ordenados_treinamento = dados.Properties.VariableNames;
ativos_ordenados_treinamento = ativos_ordenados_treinamento(indices);

% Criar um gráfico de barras dos ativos ordenados - treinamento
figure, bar(risco_ativos_ordenado_treinamento, 'FaceColor', [0 .5 .5], 'EdgeColor', [.9 .9 .9], 'LineWidth',1.5)
title('Ativos ordenados por risco - Treinamento', 'FontSize', 14)
xlabel('Ativos', 'FontSize', 12)
ylabel('Risco (Desvio Padrão dos Retornos)', 'FontSize', 12)
set(gca, 'XTickLabel', ativos_ordenados_treinamento, 'XTick',1:numel(ativos_ordenados_treinamento))
saveas(gcf,'ativos_ordenados_treinamento.png')

% Classificar os ativos com base no risco inverso - teste 
risco_teste_l = diag(L_teste)
[risco_ativos_ordenado_teste, indices] = sort(risco_teste_l, 'ascend');
ativos_ordenados_teste = dados.Properties.VariableNames;
ativos_ordenados_teste = ativos_ordenados_teste(indices);

% Criar um gráfico de barras dos ativos ordenados - teste
figure, bar(risco_ativos_ordenado_teste, 'FaceColor', [0 .5 .5], 'EdgeColor', [.9 .9 .9], 'LineWidth',1.5)
title('Ativos ordenados por risco - Teste', 'FontSize', 14)
xlabel('Ativos', 'FontSize', 12)
ylabel('Risco (Desvio Padrão dos Retornos)', 'FontSize', 12)
set(gca, 'XTickLabel', ativos_ordenados_teste, 'XTick',1:numel(ativos_ordenados_teste))
saveas(gcf,'ativos_ordenados_treinamento.png')
