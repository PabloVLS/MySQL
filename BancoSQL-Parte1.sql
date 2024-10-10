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

create table telefone_cliente(
	cpf_cliente varchar(45) not null,
    telefone varchar(20) not null,
    primary key(telefone,cpf_cliente),
    foreign key (cpf_cliente) references cliente(cpf)

);





