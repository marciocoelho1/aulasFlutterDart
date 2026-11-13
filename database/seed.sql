
-- Dados de exemplo do api_epi (funcionários, EPIs, treinamentos e empréstimos).
-- Uso: mysql -u root epi_db < database/seed.sql
-- Requer o schema já criado pelo Hibernate (ddl-auto=update).
-- Senha dos usuários de exemplo: 1234.
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

/*!40000 ALTER TABLE `emprestimo` DISABLE KEYS */;
INSERT  IGNORE INTO `emprestimo` (`id`, `data_devolucao`, `data_emprestimo`, `status`, `epi_id`, `funcionario_id`, `observacao`) VALUES (1,NULL,'2026-11-06','SOLICITADO',1,2,'Capacete atual está trincado');
INSERT  IGNORE INTO `emprestimo` (`id`, `data_devolucao`, `data_emprestimo`, `status`, `epi_id`, `funcionario_id`, `observacao`) VALUES (2,NULL,'2026-11-06','SOLICITADO',2,1,'teste');
INSERT  IGNORE INTO `emprestimo` (`id`, `data_devolucao`, `data_emprestimo`, `status`, `epi_id`, `funcionario_id`, `observacao`) VALUES (3,NULL,'2026-11-06','SOLICITADO',1,3,'rwrsdfgsdfg');
/*!40000 ALTER TABLE `emprestimo` ENABLE KEYS */;

/*!40000 ALTER TABLE `epi` DISABLE KEYS */;
INSERT  IGNORE INTO `epi` (`id`, `ca`, `categoria`, `imagem_url`, `nome`, `quantidade_disponivel`, `validade_ca`) VALUES (1,'40101','Proteção da Cabeça','/imagens/capacete.jpg','Capacete de segurança classe B',10,'2028-03-15');
INSERT  IGNORE INTO `epi` (`id`, `ca`, `categoria`, `imagem_url`, `nome`, `quantidade_disponivel`, `validade_ca`) VALUES (2,'40102','Proteção Auditiva','/imagens/plug.jpg','Protetor auricular tipo plug',25,'2027-11-30');
INSERT  IGNORE INTO `epi` (`id`, `ca`, `categoria`, `imagem_url`, `nome`, `quantidade_disponivel`, `validade_ca`) VALUES (3,'40103','Proteção Auditiva','/imagens/concha.jpg','Protetor auricular tipo concha',0,'2027-08-20');
INSERT  IGNORE INTO `epi` (`id`, `ca`, `categoria`, `imagem_url`, `nome`, `quantidade_disponivel`, `validade_ca`) VALUES (4,'40104','Proteção Respiratória','/imagens/pff2.jpg','Máscara PFF2',30,'2028-01-10');
INSERT  IGNORE INTO `epi` (`id`, `ca`, `categoria`, `imagem_url`, `nome`, `quantidade_disponivel`, `validade_ca`) VALUES (5,'40105','Proteção das Mãos','/imagens/luva.jpg','Luva nitrílica',20,'2027-05-05');
INSERT  IGNORE INTO `epi` (`id`, `ca`, `categoria`, `imagem_url`, `nome`, `quantidade_disponivel`, `validade_ca`) VALUES (6,'40106','Proteção dos Olhos e Face','/imagens/oculos.jpg','Óculos de proteção incolor',12,'2025-06-30');
INSERT  IGNORE INTO `epi` (`id`, `ca`, `categoria`, `imagem_url`, `nome`, `quantidade_disponivel`, `validade_ca`) VALUES (7,'40107','Proteção Contra Quedas','/imagens/cinto.jpg','Cinto de segurança tipo paraquedista',4,'2028-09-01');
INSERT  IGNORE INTO `epi` (`id`, `ca`, `categoria`, `imagem_url`, `nome`, `quantidade_disponivel`, `validade_ca`) VALUES (8,'40108','Proteção dos Pés','/imagens/botina.jpg','Botina de segurança',8,'2027-12-12');
/*!40000 ALTER TABLE `epi` ENABLE KEYS */;

/*!40000 ALTER TABLE `funcionario` DISABLE KEYS */;
INSERT  IGNORE INTO `funcionario` (`id`, `matricula`, `nome`, `senha`, `setor`, `perfil`) VALUES (1,'1001','Ana Souza','1234','Manutenção','ADMIN');
INSERT  IGNORE INTO `funcionario` (`id`, `matricula`, `nome`, `senha`, `setor`, `perfil`) VALUES (2,'1002','Bruno Lima','1234','Almoxarifado','FUNCIONARIO');
INSERT  IGNORE INTO `funcionario` (`id`, `matricula`, `nome`, `senha`, `setor`, `perfil`) VALUES (3,'1003','Carla Mendes','1234','Produção','FUNCIONARIO');
/*!40000 ALTER TABLE `funcionario` ENABLE KEYS */;

/*!40000 ALTER TABLE `treinamento` DISABLE KEYS */;
INSERT  IGNORE INTO `treinamento` (`id`, `arquivo_url`, `descricao`, `titulo`, `validade_meses`) VALUES (1,'/arquivos/nr35.pdf','Análise de risco, uso do cinto de segurança tipo paraquedista e pontos de ancoragem.','NR-35 - Trabalho em Altura',NULL);
INSERT  IGNORE INTO `treinamento` (`id`, `arquivo_url`, `descricao`, `titulo`, `validade_meses`) VALUES (2,'/arquivos/nr06.pdf','Responsabilidades da empresa e do trabalhador, Certificado de Aprovação (CA), guarda e conservação do EPI.','NR-06 - Equipamento de Proteção Individual',NULL);
INSERT  IGNORE INTO `treinamento` (`id`, `arquivo_url`, `descricao`, `titulo`, `validade_meses`) VALUES (3,'/arquivos/dds.pdf','Como conduzir a conversa rápida de segurança no início do turno e registrar a participação.','DDS - Diálogo Diário de Segurança',NULL);
INSERT  IGNORE INTO `treinamento` (`id`, `arquivo_url`, `descricao`, `titulo`, `validade_meses`) VALUES (4,'/arquivos/uso-epis.pdf','Colocação, ajuste, higienização e inspeção dos EPIs usados na empresa.','Uso correto de EPIs',NULL);
/*!40000 ALTER TABLE `treinamento` ENABLE KEYS */;

/*!40000 ALTER TABLE `treinamento_realizado` DISABLE KEYS */;
INSERT  IGNORE INTO `treinamento_realizado` (`id`, `data_conclusao`, `funcionario_id`, `treinamento_id`) VALUES (1,'2026-11-09',3,1);
INSERT  IGNORE INTO `treinamento_realizado` (`id`, `data_conclusao`, `funcionario_id`, `treinamento_id`) VALUES (2,'2026-11-09',2,3);
/*!40000 ALTER TABLE `treinamento_realizado` ENABLE KEYS */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

