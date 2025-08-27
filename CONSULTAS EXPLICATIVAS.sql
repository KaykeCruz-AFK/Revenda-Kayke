
CREATE DATABASE db_revenda_kayke;
\c db_revenda_kayke;


CREATE TABLE clientes (
    id_cliente SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    data_cadastro DATE DEFAULT CURRENT_DATE
);


CREATE TABLE fornecedores (
    id_fornecedor SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    cidade VARCHAR(50) NOT NULL
);


CREATE TABLE produtos (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    preco NUMERIC(10,2) NOT NULL CHECK (preco > 0),
    estoque INT DEFAULT 0 CHECK (estoque >= 0),
    id_fornecedor INT NOT NULL REFERENCES fornecedores(id_fornecedor)
);


CREATE TABLE vendas (
    id_venda SERIAL PRIMARY KEY,
    id_cliente INT NOT NULL REFERENCES clientes(id_cliente),
    data_venda TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    valor_total NUMERIC(10,2) NOT NULL CHECK (valor_total >= 0),
    status VARCHAR(20) DEFAULT 'PENDENTE' CHECK (status IN ('PENDENTE','PAGO','CANCELADO'))
);


CREATE TABLE itens_venda (
    id_venda INT NOT NULL REFERENCES vendas(id_venda),
    id_produto INT NOT NULL REFERENCES produtos(id_produto),
    quantidade INT NOT NULL CHECK (quantidade > 0),
    preco_unit NUMERIC(10,2) NOT NULL CHECK (preco_unit > 0),
    PRIMARY KEY (id_venda, id_produto)
);


CREATE TABLE pagamentos (
    id_pagamento SERIAL PRIMARY KEY,
    id_venda INT NOT NULL REFERENCES vendas(id_venda),
    forma_pagamento VARCHAR(30) NOT NULL CHECK (forma_pagamento IN ('PIX','CARTAO','BOLETO','DINHEIRO')),
    valor NUMERIC(10,2) NOT NULL CHECK (valor > 0),
    data_pagamento TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);




CREATE VIEW vw_vendas_detalhes AS
SELECT v.id_venda, c.nome AS cliente, p.nome AS produto,
       iv.quantidade, iv.preco_unit, v.valor_total, v.status
FROM vendas v
JOIN clientes c ON v.id_cliente = c.id_cliente
JOIN itens_venda iv ON v.id_venda = iv.id_venda
JOIN produtos p ON iv.id_produto = p.id_produto;


CREATE VIEW vw_estoque_fornecedores AS
SELECT p.id_produto, p.nome AS produto, p.estoque, p.preco, f.nome AS fornecedor
FROM produtos p
JOIN fornecedores f ON p.id_fornecedor = f.id_fornecedor;



INSERT INTO clientes (nome,email,telefone) VALUES
('Ana Souza','ana@email.com','11999990001'),
('Carlos Lima','carlos@email.com','11999990002'),
('Beatriz Melo','bia@email.com','11999990003'),
('João Silva','joao@email.com','11999990004'),
('Mariana Costa','mari@email.com','11999990005'),
('Pedro Henrique','ph@email.com','11999990006'),
('Luciana Dias','lucy@email.com','11999990007'),
('Fernando Gomes','fer@email.com','11999990008'),
('Rafael Torres','rafa@email.com','11999990009'),
('Julia Martins','julia@email.com','11999990010');


INSERT INTO fornecedores (nome,cnpj,telefone,cidade) VALUES
('Music House','11.111.111/0001-11','1133330001','São Paulo'),
('Guitarras BR','22.222.222/0001-22','1133330002','Rio de Janeiro'),
('Bateria Top','33.333.333/0001-33','1133330003','Belo Horizonte'),
('Teclas Sound','44.444.444/0001-44','1133330004','Curitiba'),
('Violões Pro','55.555.555/0001-55','1133330005','Salvador'),
('Percussão Mix','66.666.666/0001-66','1133330006','Fortaleza'),
('Amplificadores X','77.777.777/0001-77','1133330007','Porto Alegre'),
('Cabos e Cia','88.888.888/0001-88','1133330008','Recife'),
('Som e Luz','99.999.999/0001-99','1133330009','Manaus'),
('Banda Total','00.000.000/0001-00','1133330010','Brasília');


INSERT INTO produtos (nome,preco,estoque,id_fornecedor) VALUES
('Violão Yamaha',1200.00,15,1),
('Guitarra Fender',3500.00,10,2),
('Bateria Pearl',5000.00,5,3),
('Teclado Yamaha',2800.00,7,4),
('Violão Tagima',900.00,20,5),
('Cajon Meinl',700.00,12,6),
('Amplificador Marshall',4200.00,6,7),
('Cabo P10',60.00,50,8),
('Microfone Shure',800.00,25,9),
('Mesa de Som Behringer',2200.00,8,10);


INSERT INTO vendas (id_cliente,valor_total,status) VALUES
(1,2400,'PAGO'),
(2,3500,'PENDENTE'),
(3,800,'PAGO'),
(4,1200,'CANCELADO'),
(5,5000,'PAGO'),
(6,4200,'PAGO'),
(7,60,'PAGO'),
(8,2200,'PENDENTE'),
(9,700,'PAGO'),
(10,900,'PENDENTE');


INSERT INTO itens_venda VALUES
(1,1,2,1200.00),
(2,2,1,3500.00),
(3,9,1,800.00),
(4,1,1,1200.00),
(5,3,1,5000.00),
(6,7,1,4200.00),
(7,8,1,60.00),
(8,10,1,2200.00),
(9,6,1,700.00),
(10,5,1,900.00);

INSERT INTO pagamentos (id_venda,forma_pagamento,valor) VALUES
(1,'PIX',2400),
(2,'CARTAO',3500),
(3,'DINHEIRO',800),
(4,'PIX',1200),
(5,'CARTAO',5000),
(6,'PIX',4200),
(7,'DINHEIRO',60),
(8,'BOLETO',2200),
(9,'PIX',700),
(10,'CARTAO',900);



-- 1. Consulta com filtro usando LIKE
SELECT * FROM clientes
WHERE nome LIKE 'A%';

-- 2. Plano de execução (EXPLAIN)
EXPLAIN SELECT * FROM clientes
WHERE nome LIKE 'A%';

-- 3. Criar índice na coluna "nome" de clientes
CREATE INDEX idx_clientes_nome ON clientes(nome);

-- 4. Reexecutar consulta com EXPLAIN (usando índice agora)
EXPLAIN SELECT * FROM clientes
WHERE nome LIKE 'A%';

-- 5. Alterar coluna VARCHAR para INT (erro esperado)
-- Tentativa: transformar email em inteiro (vai falhar)
ALTER TABLE clientes
ALTER COLUMN email TYPE INT USING email::integer;

-- 6. Alterar coluna INT para VARCHAR
-- Primeiro, transformar telefone (varchar) em INT (pode falhar se houver caracteres não numéricos)
ALTER TABLE clientes
ALTER COLUMN telefone TYPE INT USING telefone::integer;

-- Agora voltar para VARCHAR
ALTER TABLE clientes
ALTER COLUMN telefone TYPE VARCHAR(20);

-- 7. Criar usuário com todas as permissões
CREATE USER kayke WITH PASSWORD '12345';
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO kayke;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO kayke;

-- 8. Criar usuário colega com apenas SELECT
CREATE USER joao WITH PASSWORD '12345';
GRANT SELECT ON clientes TO joao;

-- 9. (Parte prática) refazer itens no usuário joao
-- ATENÇÃO: se logar como "joao" e tentar rodar INSERT/UPDATE/CREATE vai dar erro de permissão.
-- Apenas SELECT vai funcionar.

-- 10. Criar 12 consultas (4 diferentes × 3 tipos de join)

-- Consulta 1: Clientes e Vendas
SELECT c.nome, v.id_venda, v.valor_total
FROM clientes c
INNER JOIN vendas v ON c.id_cliente = v.id_cliente;

SELECT c.nome, v.id_venda, v.valor_total
FROM clientes c
LEFT JOIN vendas v ON c.id_cliente = v.id_cliente;

SELECT c.nome, v.id_venda, v.valor_total
FROM clientes c
RIGHT JOIN vendas v ON c.id_cliente = v.id_cliente;

-- Consulta 2: Produtos e Fornecedores
SELECT p.nome AS produto, f.nome AS fornecedor
FROM produtos p
INNER JOIN fornecedores f ON p.id_fornecedor = f.id_fornecedor;

SELECT p.nome AS produto, f.nome AS fornecedor
FROM produtos p
LEFT JOIN fornecedores f ON p.id_fornecedor = f.id_fornecedor;

SELECT p.nome AS produto, f.nome AS fornecedor
FROM produtos p
RIGHT JOIN fornecedores f ON p.id_fornecedor = f.id_fornecedor;

-- Consulta 3: Vendas e Pagamentos
SELECT v.id_venda, v.valor_total, p.forma_pagamento
FROM vendas v
INNER JOIN pagamentos p ON v.id_venda = p.id_venda;

SELECT v.id_venda, v.valor_total, p.forma_pagamento
FROM vendas v
LEFT JOIN pagamentos p ON v.id_venda = p.id_venda;

SELECT v.id_venda, v.valor_total, p.forma_pagamento
FROM vendas v
RIGHT JOIN pagamentos p ON v.id_venda = p.id_venda;

-- Consulta 4: Itens de Venda (Produtos + Vendas)
SELECT v.id_venda, p.nome, iv.quantidade
FROM itens_venda iv
INNER JOIN vendas v ON iv.id_venda = v.id_venda
INNER JOIN produtos p ON iv.id_produto = p.id_produto;

SELECT v.id_venda, p.nome, iv.quantidade
FROM itens_venda iv
LEFT JOIN vendas v ON iv.id_venda = v.id_venda
LEFT JOIN produtos p ON iv.id_produto = p.id_produto;

SELECT v.id_venda, p.nome, iv.quantidade
FROM itens_venda iv
RIGHT JOIN vendas v ON iv.id_venda = v.id_venda
RIGHT JOIN produtos p ON iv.id_produto = p.id_produto;

-- 11. Atualizar registros com valores NULL
UPDATE clientes SET telefone = NULL WHERE id_cliente IN (1,2,3,4);

-- 12. Reexecutar as consultas de Join
-- (mesmos comandos da seção 10, agora avaliando impacto dos NULLs nos resultados)
