-- Criação do usuário e banco
CREATE USER IF NOT EXISTS 'monitora'@'%' IDENTIFIED BY 'monitora@1234';
GRANT SELECT, INSERT, UPDATE, DELETE ON monitora.* TO 'monitora'@'%';
FLUSH PRIVILEGES;

CREATE USER IF NOT EXISTS 'adminmonitora'@'%' IDENTIFIED BY 'admin1234!';
GRANT ALL PRIVILEGES ON *.* TO 'adminmonitora'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS monitora;
USE monitora;

-- -----------------------------------------------------
-- Tabela endereco
-- -----------------------------------------------------
CREATE TABLE endereco (
  idEndereco INT NOT NULL AUTO_INCREMENT,
  latitude VARCHAR(240),
  longitude VARCHAR(240),	
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
  senha VARCHAR(255) NOT NULL,
  cnpj VARCHAR(20) NOT NULL UNIQUE,
  ativo TINYINT(1),
  aprovada TINYINT(1),
  data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fotoDePerfil VARCHAR(255) DEFAULT 'fotoPerfil.svg',
  PRIMARY KEY (idEmpresa)
);

-- -----------------------------------------------------
-- Tabela cargos
-- -----------------------------------------------------
CREATE TABLE cargos (
  idCargo INT NOT NULL AUTO_INCREMENT,
  nome_cargo VARCHAR(45) NOT NULL,
  FkEmpresa INT NOT NULL,
  CONSTRAINT fk_cargo_empresa FOREIGN KEY (FkEmpresa) REFERENCES empresas(idEmpresa),
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
  senha VARCHAR(255) NOT NULL,
  telefone CHAR(11) NOT NULL UNIQUE,
  fotoUser VARCHAR(255) DEFAULT 'fotoPerfil.svg',
  data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
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
  nome VARCHAR(45) NOT NULL UNIQUE,
  data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FkEmpresa INT NOT NULL,
  FkEndereco INT UNIQUE NOT NULL,
  PRIMARY KEY (idDataCenter),
  CONSTRAINT fk_datacenter_empresa FOREIGN KEY (FkEmpresa) REFERENCES empresas(idEmpresa),
  CONSTRAINT fk_datacenter_endereco FOREIGN KEY (FkEndereco) REFERENCES endereco(idEndereco) ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Tabela servidores
-- -----------------------------------------------------
CREATE TABLE servidores (
  idServidor VARCHAR(70) NOT NULL UNIQUE,
  nome VARCHAR(100) NOT NULL,
  data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
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
-- Tabela parametros críticos
-- -----------------------------------------------------
CREATE TABLE parametros_critico (
  id INT NOT NULL AUTO_INCREMENT,
  limite DECIMAL(5, 3) NOT NULL,
  PRIMARY KEY (id)
);

-- -----------------------------------------------------
-- Tabela parametros atenção
-- -----------------------------------------------------
CREATE TABLE parametros_atencao (
  id INT NOT NULL AUTO_INCREMENT,
  limite DECIMAL(5, 3) NOT NULL,
  PRIMARY KEY (id)
);
-- -----------------------------------------------------
-- Tabela unidade_medida
-- -----------------------------------------------------
CREATE TABLE unidade_medida (
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
  servidores_idServidor VARCHAR(100) NOT NULL,
  unidade_medida_id INT NOT NULL,
  parametros_critico_id INT NOT NULL,
  parametros_atencao_id INT NOT NULL,
  PRIMARY KEY (idComponente),
  CONSTRAINT fk_comp_nome FOREIGN KEY (nome_componente_id) REFERENCES nome_componente(id) ON DELETE CASCADE,
  CONSTRAINT fk_comp_servidor FOREIGN KEY (servidores_idServidor) REFERENCES servidores(idServidor) ON DELETE CASCADE,
  CONSTRAINT fk_comp_unidade_medida FOREIGN KEY (unidade_medida_id) REFERENCES unidade_medida(id) ON DELETE CASCADE,
  CONSTRAINT fk_comp_parametros_criticos FOREIGN KEY (parametros_critico_id) REFERENCES parametros_critico(id) ON DELETE CASCADE,
  CONSTRAINT fk_comp_parametros_atencao FOREIGN KEY (parametros_atencao_id) REFERENCES parametros_atencao(id) ON DELETE CASCADE
);

-- -----------------------------------------------------
-- Tabela permissoes_has_cargos
-- -----------------------------------------------------
CREATE TABLE permissoes_has_cargos (
  permissoes_idPermissao INT NOT NULL,
  cargos_idCargo INT NOT NULL,
  PRIMARY KEY (permissoes_idPermissao, cargos_idCargo),
  CONSTRAINT fk_phc_permissao FOREIGN KEY (permissoes_idPermissao) REFERENCES permissoes(idPermissao) ON DELETE CASCADE,
  CONSTRAINT fk_phc_cargo FOREIGN KEY (cargos_idCargo) REFERENCES cargos(idCargo) ON DELETE CASCADE
);

INSERT INTO monitora.permissoes (nomePermissao) VALUES
	("CadastrarFuncionario"), -- Cadastrar novos funcionarios
    ("EditarCargoFuncionario"), -- Editar o cargo de cada usuario
    ("RemoverFuncionario"), -- Remover o cadastro dos funcionarios
    ("EditarPerfil"), -- Editar as proprias informações
    ("AdicionarServidor"), -- Adicionar novos servidores
    ("EditarServidor"), -- Editar servidores
    ("ExcluirServidor"), -- Excluir servidores
    ("AdicionarDataCenter"), -- Adicionar novos Data Centers
    ("EditarDataCenter"), -- Editar Data Centers
    ("ExcluirDataCenter"), -- Excluir Data Centers
    ("AdicionarCargos"), -- Adicionar novos cargos
    ("ModificarCargos"), -- Modificar os cargos existentes
    ("DeletarCargos"); -- Deletar cargos

-- TRIGGER PARA CRIAR OS CARGOS PADRÕES AO CADASTRAR UMA NOVA EMPRESA
DELIMITER $$

CREATE TRIGGER cargosPadroes
AFTER INSERT ON empresas
FOR EACH ROW
BEGIN

	-- Criando variaveis para automação funcionar da maneira correta
	DECLARE adminId INT;
    DECLARE usuarioId INT;
	
    INSERT INTO cargos (nome_cargo, FkEmpresa) VALUES ('ADMINISTRADOR', NEW.idEmpresa);
	SET adminId = LAST_INSERT_ID();

    INSERT INTO cargos (nome_cargo, FkEmpresa) VALUES ('Usuario', NEW.idEmpresa);
    SET usuarioId = LAST_INSERT_ID();
	
    INSERT INTO cargos (nome_cargo, FkEmpresa) VALUES ('Desativado', NEW.idEmpresa);
    
    INSERT INTO monitora.permissoes_has_cargos (cargos_idCargo, permissoes_idPermissao) VALUES
		(adminId, 1),
		(adminId, 2),
		(adminId, 3),
		(adminId, 4),
		(adminId, 5),
		(adminId,6),
		(usuarioId, 7);
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER medidasPadroes
AFTER INSERT ON servidores
FOR EACH ROW
BEGIN
    DECLARE idCPU INT DEFAULT 0;
    DECLARE idRAM INT DEFAULT 0;
    DECLARE idDISCO INT DEFAULT 0;
    DECLARE idREDE INT DEFAULT 0;
    DECLARE idPorcentagem INT DEFAULT 0;
    DECLARE idMs INT DEFAULT 0;
    DECLARE idParamCriticoCPU INT;
    DECLARE idParamCriticoRAM INT;
    DECLARE idParamCriticoDISCO INT;
    DECLARE idParamCriticoREDEms INT;
    DECLARE idParamCriticoREDEpercent INT;
    DECLARE idParamAtencaoCPU INT;
    DECLARE idParamAtencaoRAM INT;
    DECLARE idParamAtencaoDISCO INT;
    DECLARE idParamAtencaoREDEms INT;
    DECLARE idParamAtencaoREDEpercent INT;
    
    SELECT id INTO idCPU FROM nome_componente WHERE componente = 'CPU';
    SELECT id INTO idRAM FROM nome_componente WHERE componente = 'RAM';
    SELECT id INTO idDISCO FROM nome_componente WHERE componente = 'Disco';
    SELECT id INTO idREDE FROM nome_componente WHERE componente = 'Rede';

    SELECT id INTO idPorcentagem FROM unidade_medida WHERE unidade_de_medida = '%';
    SELECT id INTO idMs FROM unidade_medida WHERE unidade_de_medida = 'ms';

    -- Insere parâmetros críticos padrões
	INSERT INTO parametros_critico (limite) VALUES (90);
    SET idParamCriticoCPU = LAST_INSERT_ID();

    INSERT INTO parametros_critico (limite) VALUES (85);
    SET idParamCriticoRAM = LAST_INSERT_ID();

    INSERT INTO parametros_critico (limite) VALUES (95);
    SET idParamCriticoDISCO = LAST_INSERT_ID();

    INSERT INTO parametros_critico (limite) VALUES (0.05);
    SET idParamCriticoREDEms = LAST_INSERT_ID();
	
    INSERT INTO parametros_critico (limite) VALUES (90);
    SET idParamCriticoREDEpercent = LAST_INSERT_ID();
    
    -- Insere parâmetros de atenção padrões    
    INSERT INTO parametros_atencao (limite) VALUES (80);
    SET idParamAtencaoCPU = LAST_INSERT_ID();

    INSERT INTO parametros_atencao (limite) VALUES (75);
    SET idParamAtencaoRAM = LAST_INSERT_ID();

    INSERT INTO parametros_atencao (limite) VALUES (85);
    SET idParamAtencaoDISCO = LAST_INSERT_ID();

    INSERT INTO parametros_atencao (limite) VALUES (0.04);
    SET idParamAtencaoREDEms = LAST_INSERT_ID();
	
    INSERT INTO parametros_atencao (limite) VALUES (80);
    SET idParamAtencaoREDEpercent = LAST_INSERT_ID();
    
    -- Relaciona os componentes monitorados ao novo servidor
    INSERT INTO componentes_monitorados (nome_componente_id, servidores_idServidor, unidade_medida_id, parametros_critico_id, parametros_atencao_id)
    VALUES
        (idCPU, NEW.idServidor, idPorcentagem, idParamCriticoCPU, idParamAtencaoCPU),
        (idRAM, NEW.idServidor, idPorcentagem, idParamCriticoRAM, idParamAtencaoRAM),
        (idDISCO, NEW.idServidor, idPorcentagem, idParamCriticoDISCO, idParamAtencaoDISCO),
		(idREDE, NEW.idServidor, idPorcentagem, idParamCriticoREDEpercent, idParamAtencaoREDEpercent),
        (idREDE, NEW.idServidor, idMs, idParamCriticoREDEms, idParamAtencaoREDEms);
END$$

DELIMITER ;

-- Criacao de Admins para teste e configurações:
INSERT INTO monitora.empresas(nome, senha, cnpj, ativo, aprovada) VALUES
('admin', SHA2('@Admin123', 512), 12345678901234, 1, 1);

INSERT INTO monitora.usuarios(nome, sobrenome, email, senha, telefone, FkCargo, FkEmpresa) VALUES
('leonardo', 'borges', 'leonardo@gmail.com', SHA2('@Admin123', 512), 11912345671, 1, 1),
('gustavo', 'anthony', 'gustavo@gmail.com', SHA2('@Admin123', 512), 11912345672, 1, 1),
('ally', 'awada', 'ally@gmail.com', SHA2('@Admin123', 512), 11912345673, 1, 1),
('pedro', 'borges', 'pedro@gmail.com', SHA2('@Admin123', 512), 11912345674, 1, 1),
('maria', 'eduarda', 'maria@gmail.com', SHA2('@Admin123', 512), 11912345675, 1, 1);


-- INSERTS COMPONENTES GERAIS:
INSERT INTO nome_componente (componente) VALUES
('CPU'),
('RAM'),
('Disco'),
('Rede');
INSERT INTO unidade_medida (unidade_de_medida) VALUES
('%'),
('ms');

INSERT INTO monitora.endereco(pais, estado, cidade, bairro, rua, numero, complemento) VALUES
('Brasil', 'SP', 'São Paulo', 'República', 'Av. São João', 677, 'Sem complemento');
INSERT INTO monitora.datacenters(nome, FkEmpresa, FkEndereco) VALUES
('DataCenter - Teste', 1, 1);
INSERT INTO monitora.servidores(idServidor, nome, FkDataCenter) VALUES
('abcde', 'Servidor - Teste', 1);


-- Select tabelas para teste
select * from monitora.endereco;
select * from monitora.usuarios;
select * from monitora.empresas;
select * from monitora.datacenters;
select * from monitora.servidores;
select * from monitora.cargos;
select * from monitora.permissoes;
select * from monitora.permissoes_has_cargos;
select * from monitora.nome_componente;
select * from monitora.unidade_medida;
select * from monitora.parametros_critico;
select * from monitora.parametros_atencao;
select * from monitora.componentes_monitorados;
