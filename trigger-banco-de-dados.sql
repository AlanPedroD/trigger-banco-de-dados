-- Tabela de produtos
CREATE TABLE produtos (
    id_produto SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    quantidade INT NOT NULL,
    preco DECIMAL(10, 2) NOT NULL
);

-- Tabela de logs de estoque
CREATE TABLE log_estoque (
    id_log SERIAL PRIMARY KEY,
    id_produto INT NOT NULL,
    acao VARCHAR(20) NOT NULL,
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_produto) REFERENCES produtos (id_produto)
);

CREATE OR REPLACE FUNCTION registrar_log_estoque()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO log_estoque (id_produto, acao, data_hora)
        VALUES (NEW.id_produto, 'INSERT', CURRENT_TIMESTAMP);
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO log_estoque (id_produto, acao, data_hora)
        VALUES (NEW.id_produto, 'UPDATE', CURRENT_TIMESTAMP);
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO log_estoque (id_produto, acao, data_hora)
        VALUES (OLD.id_produto, 'DELETE', CURRENT_TIMESTAMP);
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_estoque
AFTER INSERT OR UPDATE OR DELETE ON produtos
FOR EACH ROW EXECUTE FUNCTION registrar_log_estoque();

UPDATE produtos
SET quantidade = 15
WHERE id_produto = 1;

DELETE FROM produtos
WHERE id_produto = 1;

SELECT * FROM log_estoque;
