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



Pergunta 1: Como criar um trigger que atualiza o estoque em uma tabela estoque ao inserir um pedido em uma tabela pedidos?
CREATE TRIGGER after_inserir_pedido
AFTER INSERT ON pedidos
FOR EACH ROW
BEGIN
    UPDATE estoque e
    JOIN produtos p ON e.produto_id = p.id
    SET e.quantidade = e.quantidade - NEW.quantidade
    WHERE p.id = NEW.produto_id;

    -- Validações para evitar estoque negativo
    IF (SELECT quantidade FROM estoque WHERE produto_id = NEW.produto_id) < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estoque insuficiente para este produto.';
    END IF;
END;


Pergunta 2: Como criar um trigger que registra alterações de preço em uma tabela de histórico (historico_precos) e utiliza dados de uma view produtos_caros para verificar se o preço continua acima de um certo limite?
CREATE TRIGGER after_update_preco
AFTER UPDATE ON produtos
FOR EACH ROW
BEGIN
    -- Registrar no histórico
    INSERT INTO historico_precos (produto_id, preco_antigo, preco_novo, data_alteracao)
    VALUES (OLD.id, OLD.preco, NEW.preco, NOW());

    -- Validações com base na view
    IF (SELECT COUNT(*) FROM produtos_caros WHERE id = NEW.id) = 0 AND NEW.preco > 100.00 THEN
        INSERT INTO log_alertas (produto_id, mensagem, data_hora)
        VALUES (NEW.id, 'Produto voltou a ser caro.', NOW());
    END IF;
END;


Pergunta 3: Como criar um trigger que sincroniza informações entre duas tabelas, garantindo que exclusões ou alterações em produtos reflitam na tabela produtos_arquivados?
CREATE TRIGGER after_delete_produto
AFTER DELETE ON produtos
FOR EACH ROW
BEGIN
    -- Arquivar o produto deletado
    INSERT INTO produtos_arquivados (produto_id, nome, preco, data_exclusao)
    VALUES (OLD.id, OLD.nome, OLD.preco, NOW());
END;

CREATE TRIGGER after_update_produto
AFTER UPDATE ON produtos
FOR EACH ROW
BEGIN
    -- Sincronizar produto arquivado com as novas informações
    UPDATE produtos_arquivados
    SET nome = NEW.nome, preco = NEW.preco
    WHERE produto_id = NEW.id;
END;


Pergunta 4: Como criar um trigger que registra em uma tabela auditoria as alterações feitas por um usuário em produtos caros (baseado na view produtos_caros), usando informações de uma tabela usuarios?
CREATE TRIGGER after_update_produto_audit
AFTER UPDATE ON produtos
FOR EACH ROW
BEGIN
    -- Verificar se o produto é caro
    IF (SELECT COUNT(*) FROM produtos_caros WHERE id = NEW.id) > 0 THEN
        INSERT INTO auditoria (usuario_id, produto_id, acao, data_hora)
        SELECT u.id, NEW.id, 'Alterou produto caro', NOW()
        FROM usuarios u
        WHERE u.id = NEW.usuario_modificador; -- Supõe um campo 'usuario_modificador' na tabela produtos
    END IF;
END;

Pergunta 5: Como criar um trigger que calcula automaticamente um desconto com base em tabelas relacionadas (categorias e promocoes) e atualiza os preços na tabela produtos?
CREATE TRIGGER before_update_preco_produto
BEFORE UPDATE ON produtos
FOR EACH ROW
BEGIN
    DECLARE desconto DECIMAL(5,2);

    -- Calcular desconto com base na categoria e promoção
    SELECT p.percentual
    INTO desconto
    FROM promocoes p
    JOIN categorias c ON p.categoria_id = c.id
    WHERE c.id = NEW.categoria_id AND p.ativa = 1;

    -- Aplicar desconto ao preço novo, se houver
    IF desconto IS NOT NULL THEN
        SET NEW.preco = NEW.preco - (NEW.preco * (desconto / 100));
    END IF;

    -- Garantir que o preço não seja negativo
    IF NEW.preco < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'O preço não pode ser negativo após aplicar desconto.';
    END IF;
END;






