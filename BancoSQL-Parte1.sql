create database Banco;
use Banco;


create table banco(
	codigo int primary key auto_increment,
    nome varchar(45)
);



create table agencia(
	numero_agencia int auto_increment,
    cod_banco int unique not null,
    endereco varchar(100),
    primary key(numero_agencia,cod_banco),
    foreign key (cod_banco) references banco(codigo)
);
-- ta com erro
-- UPDATE conta SET num_agencia = 6342 WHERE num_conta= 562;
-- UPDATE agencia SET numero_agencia = 6342 WHERE numero_agencia = 562;


create table conta(
	num_conta varchar(7) primary key not null,
    saldo float not null,
    tipo_conta int not null,
    num_agencia int not null,
    foreign key (num_agencia) references agencia(numero_agencia)
);


create table historico(
	cpf varchar(14) not null,
    num_conta varchar(7) not null,
    data_inicio date,
    primary key (cpf,num_conta),
    foreign key (cpf) references cliente(cpf),
    foreign key (num_conta) references conta(num_conta)
);

create table cliente(
	cpf varchar(14) primary key not null,
    nome varchar(45) not null,
    endereco varchar(100),
    sexo char(1)
);
alter table cliente add email varchar(60);
select cpf, endereco from cliente where nome like 'c%';
update cliente set email = 'caetanolima@gmail.com.' where cpf = '666.777.888-99';

create table telefone_cliente(
	cpf_cliente varchar(45) not null,
    telefone varchar(20) not null,
    primary key(telefone,cpf_cliente),
    foreign key (cpf_cliente) references cliente(cpf)

);






insert into banco(nome) values ('Banco do Brasil');
insert into banco(codigo,nome) values (4,'CEF');
insert into banco(nome) values ('Inter');



insert into agencia(numero_agencia,endereco,cod_banco) values ('0562','Rua Joaquim Teixeira Alves, 1555','4');
insert into agencia(numero_agencia,endereco,cod_banco) values ('3153','Av. Marcelino Pires, 1960','1');



insert into cliente(cpf,nome,sexo,endereco) values ('111.222.333-44','Jennifer B Souza','F','Rua Cuiabá, 1050');
insert into cliente(cpf,nome,sexo,endereco) values ('666.777.888-99','Caetano K Lima','M','Rua Ivinhema, 879');
insert into cliente(cpf,nome,sexo,endereco) values ('555.444.777-33','Silvia Macedo','F','Rua Estados Unidos, 735');



insert into conta(num_conta, saldo, tipo_conta, num_agencia) values ('86340-2', 763.05, 2 , 3153);
insert into conta(num_conta, saldo, tipo_conta, num_agencia) values ('23584-7', 3879.12, 1 , 0562);



insert into historico(cpf, num_conta, data_inicio) values ('111.222.333-44','23584-7','1997-12-17');
insert into historico(cpf, num_conta, data_inicio) values ('666.777.888-99','23584-7','1997-12-17');
insert into historico(cpf, num_conta, data_inicio) values ('555.444.777-33','86340-2','2010-11-29');



insert into telefone_cliente(cpf_cliente,telefone) values('111.222.333-44','(67)3422-7788');
insert into telefone_cliente(cpf_cliente,telefone) values('666.777.888-99','(67)3423-9900');
insert into telefone_cliente(cpf_cliente,telefone) values('666.777.888-99','(67)8121-8833');






