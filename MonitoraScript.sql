-- Criação do usuário e banco
CREATE USER IF NOT EXISTS 'monitora'@'localhost' IDENTIFIED BY 'monitora@1234';
CREATE DATABASE IF NOT EXISTS monitora;
GRANT SELECT, INSERT, UPDATE, DELETE ON monitora.* TO 'monitora'@'localhost';
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS monitora;
USE monitora;

-- -----------------------------------------------------
-- Tabela endereco
-- -----------------------------------------------------
CREATE TABLE endereco (
  idEndereco INT NOT NULL AUTO_INCREMENT,
  pais VARCHAR(60),
  estado VARCHAR(60),
  cidade VARCHAR(60),
  bairro VARCHAR(60),
  rua VARCHAR(60),
  numero INT,
  complemento VARCHAR(45),
  PRIMARY KEY (idEndereco)
);

-- -----------------------------------------------------
-- Tabela empresas
-- -----------------------------------------------------
CREATE TABLE empresas (
  idEmpresa INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL UNIQUE,
  senha VARCHAR(45) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  cnpj VARCHAR(20) NOT NULL UNIQUE,
  ativo TINYINT(1),
  aprovada TINYINT(1),
  data_cadastro DATETIME,
  fotoDePerfil VARCHAR(100) UNIQUE,
  PRIMARY KEY (idEmpresa)
);

-- -----------------------------------------------------
-- Tabela cargos
-- -----------------------------------------------------
CREATE TABLE cargos (
  idCargo INT NOT NULL AUTO_INCREMENT,
  nome_cargo VARCHAR(45) NOT NULL UNIQUE,
  PRIMARY KEY (idCargo)
);

-- -----------------------------------------------------
-- Tabela usuarios
-- -----------------------------------------------------
CREATE TABLE usuarios (
  idUsuario INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  sobrenome VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  senha VARCHAR(20) NOT NULL,
  fotoUser VARCHAR(100) UNIQUE,
  telefone CHAR(11) UNIQUE,
  data_cadastro DATETIME,
  FkCargo INT NOT NULL,
  FkEmpresa INT NOT NULL,
  PRIMARY KEY (idUsuario),
  CONSTRAINT fk_usuarios_cargo FOREIGN KEY (FkCargo) REFERENCES cargos(idCargo),
  CONSTRAINT fk_usuarios_empresa FOREIGN KEY (FkEmpresa) REFERENCES empresas(idEmpresa)
);

-- -----------------------------------------------------
-- Tabela datacenters
-- -----------------------------------------------------
CREATE TABLE datacenters (
  idDataCenter INT NOT NULL AUTO_INCREMENT,
  data_cadastro DATETIME,
  FkEmpresa INT NOT NULL,
  FkEndereco INT NOT NULL,
  PRIMARY KEY (idDataCenter),
  CONSTRAINT fk_datacenter_empresa FOREIGN KEY (FkEmpresa) REFERENCES empresas(idEmpresa),
  CONSTRAINT fk_datacenter_endereco FOREIGN KEY (FkEndereco) REFERENCES endereco(idEndereco)
);

-- -----------------------------------------------------
-- Tabela servidores
-- -----------------------------------------------------
CREATE TABLE servidores (
  idServidor INT NOT NULL AUTO_INCREMENT,
  nome VARCHAR(100) NOT NULL,
  data_cadastro DATETIME,
  FkDataCenter INT NOT NULL,
  PRIMARY KEY (idServidor),
  CONSTRAINT fk_servidor_datacenter FOREIGN KEY (FkDataCenter) REFERENCES datacenters(idDataCenter)
);

-- -----------------------------------------------------
-- Tabela nome_componente
-- -----------------------------------------------------
CREATE TABLE nome_componente (
  id INT NOT NULL AUTO_INCREMENT,
  componente VARCHAR(45) NOT NULL UNIQUE,
  PRIMARY KEY (id)
);

-- -----------------------------------------------------
-- Tabela parametros
-- -----------------------------------------------------
CREATE TABLE parametros (
  id INT NOT NULL AUTO_INCREMENT,
  limite INT NOT NULL,
  PRIMARY KEY (id)
);
-- -----------------------------------------------------
-- Tabela medida
-- -----------------------------------------------------
CREATE TABLE medida (
  id INT NOT NULL AUTO_INCREMENT,
  unidade_de_medida VARCHAR(5) NOT NULL,
  PRIMARY KEY (id)
);

-- -----------------------------------------------------
-- Tabela Permissoes
-- -----------------------------------------------------
CREATE TABLE permissoes (
  idPermissao INT NOT NULL AUTO_INCREMENT,
  nomePermissao VARCHAR(45) NOT NULL UNIQUE,
  PRIMARY KEY (idPermissao)
);

-- -----------------------------------------------------
-- Tabela componentes_monitorados
-- -----------------------------------------------------
CREATE TABLE componentes_monitorados (
  idComponente INT NOT NULL AUTO_INCREMENT,
  nome_componente_id INT NOT NULL,
  servidores_idServidor INT NOT NULL,
  medida_id INT NOT NULL,
  parametros_id INT NOT NULL,
  PRIMARY KEY (idComponente),
  CONSTRAINT fk_comp_nome FOREIGN KEY (nome_componente_id) REFERENCES nome_componente(id),
  CONSTRAINT fk_comp_servidor FOREIGN KEY (servidores_idServidor) REFERENCES servidores(idServidor),
  CONSTRAINT fk_comp_medida FOREIGN KEY (medida_id) REFERENCES medida(id),
  CONSTRAINT fk_comp_parametros FOREIGN KEY (parametros_id) REFERENCES parametros(id)
);

-- -----------------------------------------------------
-- Tabela permissoes_has_cargos
-- -----------------------------------------------------
CREATE TABLE permissoes_has_cargos (
  id INT AUTO_INCREMENT,
  permissoes_idPermissao INT NOT NULL,
  cargos_idCargo INT NOT NULL,
  PRIMARY KEY (id, permissoes_idPermissao, cargos_idCargo),
  CONSTRAINT fk_phc_permissao FOREIGN KEY (permissoes_idPermissao) REFERENCES permissoes(idPermissao),
  CONSTRAINT fk_phc_cargo FOREIGN KEY (cargos_idCargo) REFERENCES cargos(idCargo)
);
