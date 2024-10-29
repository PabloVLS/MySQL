CREATE DATABASE universidade;
USE universidade;

CREATE TABLE aluno (
  id_aluno INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  cpf VARCHAR(14) NOT NULL,
  data_nascimento DATE NOT NULL,
  sexo CHAR(1) NOT NULL,
  PRIMARY KEY (id_aluno)
);

CREATE TABLE curso (
  id_curso INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  carga_horaria INT NOT NULL,
  PRIMARY KEY (id_curso)
);

CREATE TABLE matricula (
  id_matricula INT NOT NULL AUTO_INCREMENT,
  id_aluno INT NOT NULL,
  id_curso INT NOT NULL,
  data_inicio DATE NOT NULL,
  data_fim DATE,
  PRIMARY KEY (id_matricula),
  FOREIGN KEY (id_aluno) REFERENCES aluno (id_aluno),
  FOREIGN KEY (id_curso) REFERENCES curso (id_curso)
);


CREATE TABLE disciplina (
  id_disciplina INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  carga_horaria INT NOT NULL,
  PRIMARY KEY (id_disciplina)
);


CREATE TABLE matricula_disciplina (
  id_matricula_disciplina INT NOT NULL AUTO_INCREMENT,
  id_matricula INT NOT NULL,
  id_disciplina INT NOT NULL,
  nota DECIMAL(4,2) NOT NULL,
  PRIMARY KEY (id_matricula_disciplina),
  FOREIGN KEY (id_matricula) REFERENCES matricula (id_matricula),
  FOREIGN KEY (id_disciplina) REFERENCES disciplina (id_disciplina)
);


INSERT INTO aluno (nome, cpf, data_nascimento, sexo)
VALUES
('João da Silva', '123.456.789-00', '1990-01-01', 'M'),
('Maria da Costa', '987.654.321-00', '1991-02-02', 'F'),
('Pedro dos Santos', '098.765.432-10', '1992-03-03', 'M');


INSERT INTO curso (nome, carga_horaria)
VALUES
('Ciência da Computação', 2400),
('Engenharia de Software', 2800),
('Administração', 2200);


INSERT INTO matricula (id_aluno, id_curso, data_inicio, data_fim)
VALUES
(1, 1, '2023-08-01', NULL),
(2, 2, '2023-08-01', NULL),
(3, 3, '2023-08-01', NULL);


INSERT INTO disciplina (nome, carga_horaria)
VALUES
('Algoritmos e Estruturas de Dados', 60),
('Programação Orientada a Objetos', 60),
('Bancos de Dados', 60);


INSERT INTO matricula_disciplina (id_matricula, id_disciplina, nota)
VALUES
(1, 1, 8.0),
(2, 1, 9.0),
(3, 1, 7.5),
(1, 2, 6.0),
(2, 2, 4.0),
(3, 2, 7.5),
(1, 3, 7.0),
(2, 3, 2.0),
(3, 3, 10);


/*1*/
select nome,cpf,data_nascimento from aluno;

/*2*/
select nome,cpf,sexo from aluno where data_nascimento > 1990;

/*3*/
select nome from curso order by carga_horaria desc limit 1;

/*4*/
INSERT INTO disciplina (nome, carga_horaria) values ('Poo', 15);
select * from disciplina;

ALTER TABLE matricula_disciplina DROP FOREIGN KEY matricula_disciplina_ibfk_2;
      ALTER TABLE matricula_disciplina
	     ADD CONSTRAINT matricula_disciplina_ibfk_2 FOREIGN KEY (id_disciplina) 
         REFERENCES disciplina(id_disciplina) ON DELETE CASCADE;
         
         delete from disciplina where carga_horaria < 20;
         
/*5*/
select id_aluno from matricula
join matricula_disciplina ON matricula.id_matricula=matricula_disciplina.id_matricula
join disciplina ON disciplina.id_disciplina=matricula_disciplina.id_disciplina
where nome = 'Programação Orientada a Objetos' order by nota asc limit 1;

/*6*/
select id_aluno from matricula
join curso ON matricula.id_curso=curso.id_curso
where carga_horaria > 2400;

/*7*/
select aluno.nome, curso.nome , carga_horaria from aluno
join matricula ON aluno.id_aluno = matricula.id_aluno
join curso ON matricula.id_curso=curso.id_curso;

/*8*/
update curso
   set carga_horaria = 300
   where nome = "Administração";
