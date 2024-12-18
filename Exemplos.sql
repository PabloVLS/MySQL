Pergunta 1: Como criar uma procedure que insere um registro em uma tabela?
Resposta:
DELIMITER //
CREATE PROCEDURE InserirProduto(
    IN nomeProduto VARCHAR(50),
    IN precoProduto DECIMAL(10,2)
)
BEGIN
    INSERT INTO produtos (nome, preco) VALUES (nomeProduto, precoProduto);
END;
//
DELIMITER ;

Pergunta 2: Como chamar uma procedure criada?
CALL InserirProduto('Notebook', 2999.99);


Pergunta 3: Como criar um trigger que registra alterações em uma tabela de log quando um registro é inserido em outra tabela?
CREATE TRIGGER after_inserir_produto
AFTER INSERT ON produtos
FOR EACH ROW
BEGIN
    INSERT INTO log_produtos (acao, produto_id, data_hora)
    VALUES ('INSERT', NEW.id, NOW());
END;



Pergunta 4: Como criar um trigger para evitar que um preço seja atualizado para um valor menor que 0?
CREATE TRIGGER before_atualizar_preco
BEFORE UPDATE ON produtos
FOR EACH ROW
BEGIN
    IF NEW.preco < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Preço não pode ser negativo.';
    END IF;
END;


Pergunta 5: Como criar uma view que exibe apenas os produtos com preço maior que R$ 100,00?
CREATE VIEW produtos_caros AS
SELECT * FROM produtos WHERE preco > 100.00;

Pergunta 6: Como consultar dados de uma view criada?
Resposta:
SELECT * FROM produtos_caros;


Pergunta 7: Como criar uma procedure para atualizar o preço de um produto com base em um percentual de aumento?
DELIMITER //
CREATE PROCEDURE AtualizarPreco(
    IN produtoId INT,
    IN percentual DECIMAL(5,2)
)
BEGIN
    UPDATE produtos
    SET preco = preco + (preco * (percentual / 100))
    WHERE id = produtoId;
END;
//
DELIMITER ;


Pergunta 8: Como criar uma view que mostra o total de produtos em cada categoria?
CREATE VIEW total_por_categoria AS
SELECT categoria, COUNT(*) AS total
FROM produtos
GROUP BY categoria;



Pergunta 1: Temos uma tabela de produtos e outra de estoque. Existe uma view chamada estoque_baixo que lista produtos com quantidade menor que 10 no estoque.
Criamos um trigger para verificar o estoque após cada inserção na tabela de pedidos. Se o estoque do produto cair abaixo de 10, registra-se na tabela alertas.
CREATE VIEW estoque_baixo AS
SELECT p.id AS produto_id, p.nome, e.quantidade
FROM produtos p
JOIN estoque e ON p.id = e.produto_id
WHERE e.quantidade < 10;


CREATE TRIGGER after_inserir_pedido
AFTER INSERT ON pedidos
FOR EACH ROW
BEGIN
    -- Atualizar o estoque
    UPDATE estoque
    SET quantidade = quantidade - NEW.quantidade
    WHERE produto_id = NEW.produto_id;

    -- Verificar a view 'estoque_baixo' e registrar alerta
    IF (SELECT COUNT(*) FROM estoque_baixo WHERE produto_id = NEW.produto_id) > 0 THEN
        INSERT INTO alertas (produto_id, mensagem, data_hora)
        VALUES (NEW.produto_id, 'Estoque abaixo de 10 unidades.', NOW());
    END IF;
END;



Há uma tabela vendas e uma tabela lucros. Existe uma view chamada lucro_diario que mostra o lucro total por dia.
    Criamos um trigger que, ao inserir uma nova venda, verifica a view e atualiza a tabela de lucros com base nela.CREATE TRIGGER after_update_preco
CREATE VIEW lucro_diario AS
SELECT data_venda, SUM(valor_venda - custo) AS lucro
FROM vendas
GROUP BY data_venda;

CREATE TRIGGER after_inserir_venda
AFTER INSERT ON vendas
FOR EACH ROW
BEGIN
    -- Consultar lucro diário da nova data inserida
    DECLARE lucro_total DECIMAL(10, 2);
    SELECT lucro INTO lucro_total FROM lucro_diario WHERE data_venda = NEW.data_venda;

    -- Atualizar a tabela de lucros
    INSERT INTO lucros (data, total_lucro) 
    VALUES (NEW.data_venda, lucro_total)
    ON DUPLICATE KEY UPDATE total_lucro = lucro_total;
END;


Há uma tabela produtos e uma tabela auditoria. Existe uma view chamada produtos_caros, que exibe produtos com preços acima de R$ 500,00. 
    O objetivo é registrar na tabela auditoria sempre que um produto caro for atualizado.CREATE TRIGGER after_delete_produto
CREATE VIEW produtos_caros AS
SELECT id, nome, preco FROM produtos WHERE preco > 500.00;

CREATE TRIGGER after_update_produtos
AFTER UPDATE ON produtos
FOR EACH ROW
BEGIN
    -- Verificar se o produto atualizado está na view 'produtos_caros'
    IF (SELECT COUNT(*) FROM produtos_caros WHERE id = NEW.id) > 0 THEN
        INSERT INTO auditoria (produto_id, acao, data_hora)
        VALUES (NEW.id, 'Atualização de produto caro', NOW());
    END IF;
END;



Existe uma tabela categorias e outra tabela produtos. A view total_produtos_por_categoria exibe o total de produtos por categoria.
Criamos um trigger para atualizar automaticamente os totais na tabela de categorias sempre que um produto for adicionado.CREATE TRIGGER after_update_produto_audit
CREATE VIEW total_produtos_por_categoria AS
SELECT c.id AS categoria_id, c.nome AS categoria_nome, COUNT(p.id) AS total_produtos
FROM categorias c
LEFT JOIN produtos p ON c.id = p.categoria_id
GROUP BY c.id, c.nome;

CREATE TRIGGER after_inserir_produto
AFTER INSERT ON produtos
FOR EACH ROW
BEGIN
    -- Consultar o total de produtos atual na view
    DECLARE total INT;
    SELECT total_produtos INTO total 
    FROM total_produtos_por_categoria 
    WHERE categoria_id = NEW.categoria_id;

    -- Atualizar a tabela de categorias
    UPDATE categorias
    SET total_produtos = total
    WHERE id = NEW.categoria_id;
END;


Pergunta 5: Como criar um trigger que calcula automaticamente um desconto com base em tabelas relacionadas (categorias e promocoes) e atualiza os preços na tabela produtos?
CREATE VIEW categorias_com_promocoes AS
SELECT 
    c.id AS categoria_id,
    c.nome AS categoria_nome,
    p.percentual AS desconto,
    p.ativa AS promocao_ativa
FROM 
    categorias c
LEFT JOIN 
    promocoes p ON c.id = p.categoria_id
WHERE 
    p.ativa = 1;

    
CREATE TRIGGER before_update_preco_produto
BEFORE UPDATE ON produtos
FOR EACH ROW
BEGIN
    DECLARE desconto DECIMAL(5,2);

    -- Consultar desconto na view 'categorias_com_promocoes'
    SELECT desconto 
    INTO desconto
    FROM categorias_com_promocoes
    WHERE categoria_id = NEW.categoria_id;

    -- Aplicar desconto ao preço novo, se houver
    IF desconto IS NOT NULL THEN
        SET NEW.preco = NEW.preco - (NEW.preco * (desconto / 100));
    END IF;

    -- Garantir que o preço não seja negativo
    IF NEW.preco < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O preço não pode ser negativo após aplicar desconto.';
    END IF;
END;







