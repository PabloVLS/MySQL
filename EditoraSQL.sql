 create database livraria;
 use livraria;
 
 
 create table editora(
 cod_editora int auto_increment primary key,
 descricao varchar(45) not null,
 endereco varchar(45) not null
 );
 alter table editora change column descricao nome varchar(45) not null;
 
 create table livro(
cod_livro int auto_increment primary key,
isbn varchar(45) not null,
titulo varchar(45) not null,
autor varchar(45) not null,
num_edicao int,
preco float not null,
editora_cod_editora int not null,
foreign key (editora_cod_editora) references editora(cod_editora)
 );
 alter table livro change column isbn isbn varchar(45) unique not null;
 alter table livro modify column preco float default 10;
 alter table livro drop num_edicao;
 
 
 
 create table autor(
cod_autor int auto_increment primary key,
nome varchar(45) not null,
sexo char(1),
data_nascimento date
);
alter table autor change column sexo sexo varchar(1);

create table livro_autor(
cod_livro_fk int,
cod_autor_fk int,
foreign key (cod_livro_fk) references livro(cod_livro),
foreign key (cod_autor_fk) references autor(cod_autor)

);