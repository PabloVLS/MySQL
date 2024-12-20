CREATE DATABASE IF NOT EXISTS bd_empresa;
USE bd_empresa;

CREATE TABLE departamento (
    id_depto    Integer    NOT NULL auto_increment PRIMARY KEY,
    nome_depto   VARCHAR(30)   NOT NULL,
    id_gerente  Integer      NOT NULL,
    CONSTRAINT uk_nome UNIQUE (nome_depto)
);

CREATE TABLE funcionario (
    id_func     Integer     NOT NULL PRIMARY KEY auto_increment,
    nome_func    VARCHAR(30)  NOT NULL,
    endereco    VARCHAR(50)  NOT NULL,
    data_nasc    DATE          NOT NULL,
    sexo        CHAR(1)       NOT NULL,
    salario     NUMERIC(8,2)   NOT NULL,
    id_superv   Integer         NULL,
    id_depto    Integer     NOT NULL,
    CONSTRAINT ck_sexo CHECK (sexo='M' or sexo='F')
);

CREATE TABLE projeto (
    id_proj       Integer     NOT NULL PRIMARY KEY auto_increment,
    nome_proj      VARCHAR(30)  NOT NULL,
    localizacao   VARCHAR(30)      NULL,
    id_depto      Integer     NOT NULL,
    CONSTRAINT uk_nome_proj UNIQUE (nome_proj)
);

CREATE TABLE dependente (
    id_dep       Integer     NOT NULL,
    id_func      Integer     NOT NULL,
    nome_dep      VARCHAR(30)  NOT NULL,
    data_nasc     DATE          NOT NULL,
    sexo         CHAR(1)       NOT NULL,
    parentesco   CHAR(15)          NULL,
    CONSTRAINT pk_depend PRIMARY KEY (id_dep, id_func),
    CONSTRAINT ck_sexo_dep CHECK (sexo='M' or sexo='F')
);

CREATE TABLE trabalha (
    id_func    Integer    NOT NULL,
    id_proj    Integer     NOT NULL,
    num_horas   NUMERIC(6,1)       NULL,
    CONSTRAINT pk_trab PRIMARY KEY (id_func,id_proj)
);

INSERT INTO funcionario
VALUES (1,'Joao Silva','R. Guaicui, 175', str_to_date('01/02/1955',"%d/%m/%Y"),'M',500,2,1);
INSERT INTO funcionario
VALUES (2,'Frank Santos','R. Gentios, 22',str_to_date('02/02/1966',"%d/%m/%Y"),'M',1000,8,1);
INSERT INTO funcionario
VALUES (3,'Alice Pereira','R. Curitiba, 11',str_to_date('15/05/1970',"%d/%m/%Y"),'F',700,4,3);
INSERT INTO funcionario
VALUES (4,'Junia Mendes','R. Espirito Santos, 123',str_to_date('06/07/1976',"%d/%m/%Y"),'F',1200,8,3);
INSERT INTO funcionario
VALUES (5,'Jose Tavares','R. Irai, 153',str_to_date('07/10/1975',"%d/%m/%Y"),'M',1500,2,1);
INSERT INTO funcionario
VALUES (6,'Luciana Santos','R. Irai, 175',str_to_date('07/10/1960',"%d/%m/%Y"),'F',600,2,1);
INSERT INTO funcionario
VALUES (7,'Maria Ramos','R. C. Linhares, 10',str_to_date('01/11/1965',"%d/%m/%Y"),'F',1000,4,3);
INSERT INTO funcionario
VALUES (8,'Jaime Mendes','R. Bahia, 111',str_to_date('25/11/1960',"%d/%m/%Y"),'M',2000,NULL,2);

INSERT INTO departamento
VALUES (1,'Pesquisa',2);
INSERT INTO departamento
VALUES (2,'Administracao',8);
INSERT INTO departamento
VALUES (3,'Construcao',4);

INSERT INTO dependente
VALUES (1,2,'Luciana',str_to_date('05/11/1990',"%d/%m/%Y"),'F','Filha');
INSERT INTO dependente
VALUES (2,2,'Paulo',str_to_date('11/11/1992',"%d/%m/%Y"),'M','Filho');
INSERT INTO dependente
VALUES (3,2,'Sandra',str_to_date('05/12/1996',"%d/%m/%Y"),'F','Filha');
INSERT INTO dependente
VALUES (4,4,'Mike',str_to_date('05/11/1997',"%d/%m/%Y"),'M','Filho');
INSERT INTO dependente
VALUES (5,1,'Max',str_to_date('11/05/1979',"%d/%m/%Y"),'M','Filho');
INSERT INTO dependente
VALUES (6,1,'Rita',str_to_date('07/11/1985',"%d/%m/%Y"),'F','Filha');
INSERT INTO dependente
VALUES (7,1,'Bety',str_to_date('15/12/1960',"%d/%m/%Y"),'F','Esposa');

INSERT INTO projeto
VALUES (1,'ProdX','Savassi',1);
INSERT INTO projeto
VALUES (2,'ProdY','Luxemburgo',1);
INSERT INTO projeto
VALUES (3,'ProdZ','Centro',1);
INSERT INTO projeto
VALUES (10,'Computacao','C. Nova',3);
INSERT INTO projeto
VALUES (20,'Organizacao','Luxemburgo',2);
INSERT INTO projeto
VALUES (30,'N. Beneficios','C. Nova',1);

INSERT INTO trabalha
VALUES (1,1,32.5);
INSERT INTO trabalha
VALUES (1,2,7.5);
INSERT INTO trabalha
VALUES (5,3,40.0);
INSERT INTO trabalha
VALUES (6,1,20.0);
INSERT INTO trabalha
VALUES (6,2,20.0);
INSERT INTO trabalha
VALUES (2,2,10.0);
INSERT INTO trabalha
VALUES (2,3,10.0);
INSERT INTO trabalha
VALUES (2,10,10.0);
INSERT INTO trabalha
VALUES (2,20,10.0);
INSERT INTO trabalha
VALUES (3,30,30.0);
INSERT INTO trabalha
VALUES (3,10,10.0);
INSERT INTO trabalha
VALUES (7,10,35.0);
INSERT INTO trabalha
VALUES (7,30,5.0);
INSERT INTO trabalha
VALUES (4,20,15.0);
INSERT INTO trabalha
VALUES (8,20,NULL);

ALTER TABLE funcionario
ADD CONSTRAINT fk_func_depto FOREIGN KEY (id_depto) REFERENCES departamento (id_depto);

ALTER TABLE funcionario
ADD CONSTRAINT fk_func_superv FOREIGN KEY (id_superv) REFERENCES funcionario (id_func);

ALTER TABLE departamento
ADD CONSTRAINT fk_depto_func FOREIGN KEY (id_gerente) REFERENCES funcionario (id_func);

ALTER TABLE projeto
ADD CONSTRAINT fk_proj_depto FOREIGN KEY (id_depto) REFERENCES departamento (id_depto);

ALTER TABLE dependente
ADD CONSTRAINT fk_dep_func FOREIGN KEY (id_func) REFERENCES funcionario (id_func) ON DELETE CASCADE;

ALTER TABLE trabalha
ADD CONSTRAINT fk_trab_func FOREIGN KEY (id_func) REFERENCES funcionario (id_func) ON DELETE CASCADE;

ALTER TABLE trabalha
ADD CONSTRAINT fk_trab_proj FOREIGN KEY (id_proj) REFERENCES projeto (id_proj) ON DELETE CASCADE;

/*1 Dado uma taxa e um identificador do funcionário, crie um procedure que aplique a taxa
informada no salário do funcionário*/

DELIMITER //
create procedure taxaSalario(taxa double, codigo_func int)
begin
	update funcionario set salario = salario*taxa where id_func = codigo_func;
end//
DELIMITER ;
call taxaSalario(5,1);



/*2 Crie uma tabela chamada hora_extra. Essa tabela deverá ter o identificador do funcionário e
campo para guardar quantas horas foram excedidas de um funcionário na jornada semanal.
Crie uma trigger que, ao ser adicionado um registro na tabela “trabalha” no banco, ela chamará
uma procedure que calcula a soma do número de horas trabalhadas em todos os projetos de um
funcionário. Caso a carga horária seja maior que 40, a trigger insere o valor excedente na tabela
de hora_extra. */

create table hora_extra(
	identificador integer not null,
    horas_execidadas float,
    foreign key (identificador) references funcionario(id_func)
);

drop table hora_extra;

DELIMITER //
create trigger calculo_horas
after insert on trabalha
	for each row
	begin
		declare total_horas int default 0;
end//
DELIMITER ;


DELIMITER//
	create procedure calculo_horas_extras(in id_func int, out total_horas int)
    begin
    select sum(num_hora) from trabalha;
    
end//
DELIMITER ;



/*Exercicios Adm*/
/* Crie um usuário my_user1;*/
CREATE USER 'my_user1'@'localhost' IDENTIFIED BY 'senha';

/*Crie um usuário my_admin;*/

CREATE USER 'my_admin'@'localhost' IDENTIFIED BY 'senha1';

/*. Crie/use dois bancos de dados bd1 e db2 
quaisquer. Pode ser bancos de outros exercícios. Crie
algumas tabelas aleatoriamente.*/
/*Conceda acesso total para o usuário my_admin ao banco bd1.*/
GRANT ALL PRIVILEGES ON bd_empresa.* TO 'my_admin'@'localhost';

/*Conceda apenas select, insert, delete e update para o usuário my_user no bd1.*/
GRANT SELECT, INSERT, DELETE, UPDATE ON bd_empresa.* TO 'my_user1'@'localhost';

/*Visualize as permissões dadas aos usuários.*/
SHOW GRANTS FOR 'my_admin'@'localhost';
SHOW GRANTS FOR 'my_user1'@'localhost';

/*Retire todas as permissões do usuário my_user.*/
REVOKE ALL PRIVILEGES ON bd_empresa.* FROM 'my_user1'@'localhost';/*ta falando que ta com erro mas ta certo*/

/*Crie uma nova conexão com o usuário my_user1 e use o comando show tables;*/
GRANT ALL PRIVILEGES ON bd_empresa.* TO 'my_user1'@'localhost';


/*Tente fazer uma operação de update usando o usuário my_user*/
/*foi usado em outra conexão*/
use bd_empresa;
update projeto
set nome_proj = 'projetinho' where id_proj =3;

/*Crie um papel chamado papelAdmin e outro papelDev*/
CREATE ROLE papelAdmin;
CREATE ROLE papelDev;

/*Conceda ao papel papelAdmin todos os privilégios e para papelDev apenas as operações select,
insert, update e delete. */
GRANT ALL PRIVILEGES ON bd_empresa.* TO papelAdmin;
GRANT SELECT, INSERT, DELETE, UPDATE ON bd_empresa.* TO papelDev;

/*Crie dois usuários e atribuía a cada um, um dos papéis criados. Faça teste com os dois usuários
criados.*/

GRANT papelAdmin TO 'my_admin'@'localhost';
set default role papelAdmin to 'my_admin'@'localhost';
SHOW GRANTS FOR 'my_admin'@'localhost';

CREATE USER 'tst'@'localhost' IDENTIFIED BY 'senha1';
GRANT papelDev TO 'tst'@'localhost';
SHOW GRANTS FOR 'tst'@'localhost';

FLUSH PRIVILEGES;
