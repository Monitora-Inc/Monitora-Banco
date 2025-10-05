-- Criação do usuário e banco
CREATE USER 'Monitora'@'localhost' IDENTIFIED BY 'monitora@1234';
GRANT SELECT, INSERT, UPDATE, DELETE ON Monitora.* TO 'Monitora'@'localhost';
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS Monitora;
USE Monitora;

-- Endereços
CREATE TABLE IF NOT EXISTS Endereco (
  idEndereco INT AUTO_INCREMENT PRIMARY KEY,
  pais VARCHAR(60),
  estado VARCHAR(60),
  cidade VARCHAR(60),
  bairro VARCHAR(60),
  rua VARCHAR(60),
  numero INT,
  complemento VARCHAR(45)
);

-- Empresas
CREATE TABLE IF NOT EXISTS Empresas(
  idEmpresa INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  cnpj VARCHAR(20) UNIQUE,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  aprovada TINYINT(1) NOT NULL DEFAULT 0,
  data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
  fkEndereco INT,
  CONSTRAINT fk_Empresa_Endereco FOREIGN KEY (fkEndereco) REFERENCES Endereco (idEndereco)
);

-- Data Centers
CREATE TABLE IF NOT EXISTS DataCenters(
  idDataCenter INT AUTO_INCREMENT PRIMARY KEY,
  data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
  fkEmpresa INT NOT NULL,
  fkEndereco INT NOT NULL,
  CONSTRAINT fk_DataCenter_Empresa FOREIGN KEY (fkEmpresa) REFERENCES Empresas (idEmpresa),
  CONSTRAINT fk_DataCenter_Endereco FOREIGN KEY (fkEndereco) REFERENCES Endereco (idEndereco)
);

-- Servidores
CREATE TABLE IF NOT EXISTS Servidores (
  idServidor INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
  fkEndereco INT,
  fkDataCenter INT NOT NULL,
  CONSTRAINT fk_Servidor_Endereco FOREIGN KEY (fkEndereco) REFERENCES Endereco (idEndereco),
  CONSTRAINT fk_Servidor_DataCenter FOREIGN KEY (fkDataCenter) REFERENCES DataCenters (idDataCenter)
);

-- Permissões
CREATE TABLE IF NOT EXISTS Permissoes (
  idPermissao INT AUTO_INCREMENT PRIMARY KEY,
  root TINYINT(1) NOT NULL DEFAULT 0,
  admin TINYINT(1) NOT NULL DEFAULT 0
);

-- Cargos
CREATE TABLE IF NOT EXISTS Cargos (
  idCargo INT AUTO_INCREMENT PRIMARY KEY,
  nome_cargo VARCHAR(45) NOT NULL,
  nivel_acesso INT NOT NULL,
  CONSTRAINT fk_Cargo_Permissao FOREIGN KEY (nivel_acesso) REFERENCES Permissoes (idPermissao)
);

-- Unidades de Medida
CREATE TABLE IF NOT EXISTS Unidade_de_Medidas (
  idMedida INT AUTO_INCREMENT PRIMARY KEY,
  nomeMedida VARCHAR(45) NOT NULL
);

-- Componentes Monitorados
CREATE TABLE IF NOT EXISTS Componentes_Monitorados (
  idComponente INT AUTO_INCREMENT PRIMARY KEY,
  nome_componente VARCHAR(45) NOT NULL,
  alerta TINYINT(1) NOT NULL DEFAULT 0,
  fkMedida INT NOT NULL,
  CONSTRAINT fk_Componente_Medida FOREIGN KEY (fkMedida) REFERENCES Unidade_de_Medidas (idMedida)
);

-- Parâmetros
CREATE TABLE IF NOT EXISTS Parametros (
  idParametro INT AUTO_INCREMENT PRIMARY KEY,
  fkServidor INT NOT NULL,
  fkComponente INT NOT NULL,
  CONSTRAINT fk_Parametro_Servidor FOREIGN KEY (fkServidor) REFERENCES Servidores (idServidor),
  CONSTRAINT fk_Parametro_Componente FOREIGN KEY (fkComponente) REFERENCES Componentes_Monitorados (idComponente)
);

-- Usuários
CREATE TABLE IF NOT EXISTS Usuarios (
  idUsuario INT AUTO_INCREMENT PRIMARY KEY,
  nome VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  senha VARCHAR(255) NOT NULL,
  ativo TINYINT(1) NOT NULL DEFAULT 1,
  data_cadastro DATETIME DEFAULT CURRENT_TIMESTAMP,
  fkCargo INT NOT NULL,
  fkEmpresa INT NOT NULL,
  CONSTRAINT fk_Usuario_Cargo FOREIGN KEY (fkCargo) REFERENCES Cargos (idCargo),
  CONSTRAINT fk_Usuario_Empresa FOREIGN KEY (fkEmpresa) REFERENCES Empresas (idEmpresa)
);