---STEP 1:: DESIGNING AND CREATING THE DBA DATABASE-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

USE [master]
GO

CREATE DATABASE [dba]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'dba', FILENAME = N'D:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\DATA\dba.mdf' , SIZE = 73728KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'dba_log', FILENAME = N'E:\Program Files\Microsoft SQL Server\MSSQL13.SQLEXPRESS\MSSQL\Log\dba_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [dba].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [dba] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [dba] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [dba] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [dba] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [dba] SET ARITHABORT OFF 
GO
ALTER DATABASE [dba] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [dba] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [dba] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [dba] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [dba] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [dba] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [dba] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [dba] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [dba] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [dba] SET  DISABLE_BROKER 
GO
ALTER DATABASE [dba] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [dba] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [dba] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [dba] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [dba] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [dba] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [dba] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [dba] SET RECOVERY FULL 
GO
ALTER DATABASE [dba] SET  MULTI_USER 
GO
ALTER DATABASE [dba] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [dba] SET DB_CHAINING OFF 
GO
ALTER DATABASE [dba] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [dba] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [dba] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [dba] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [dba] SET QUERY_STORE = OFF
GO
ALTER DATABASE [dba] SET  READ_WRITE 
GO










---STEP 2:: CREATING A LINKED SERVER----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
USE [master]
GO

EXEC master.dbo.sp_addlinkedserver @server = N'CDMUAT', @srvproduct=N'CDMUAT', @provider=N'SQLNCLI', @datasrc=N'00172MWCDMUAT2V'
 
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'CDMUAT',@useself=N'False',@locallogin=NULL,@rmtuser=N'BNA',@rmtpassword='########'
GO

EXEC master.dbo.sp_serveroption @server=N'CDMUAT', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'CDMUAT', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'CDMUAT', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'CDMUAT', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'CDMUAT', @optname=N'rpc', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'CDMUAT', @optname=N'rpc out', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'CDMUAT', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'CDMUAT', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'CDMUAT', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'CDMUAT', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'CDMUAT', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'CDMUAT', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'CDMUAT', @optname=N'remote proc CDMUATsaction promotion', @optvalue=N'true'
GO













---STEP 3:: CREATING AUDIT FILE PATH----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE SERVER AUDIT [NetworkAudit] TO FILE(FILEPATH='D:\Audit') WITH (ON_FAILURE=FAIL_OPERATION, QUEUE_DELAY=0);

ALTER SERVER AUDIT [NetworkAudit] WITH (STATE=ON); 

CREATE SERVER AUDIT SPECIFICATION [complianceServerSpec] FOR SERVER AUDIT [NetworkAudit] ADD (SCHEMA_OBJECT_ACCESS_GROUP); 











---STEP 4:: DESIGNING THE AUDIT TABLES IN DBA DATABASE-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---STEP 4A: CREATE THE AUDIT LOGS TABLE--------------- 
USE [DBA]
CREATE TABLE [dbo].[AUDIT_LOGS](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[audit_id] [varchar](24) NULL,
	[name] [varchar](240) NULL,
	[status] [varchar](240) NULL,
	[status_desc] [varchar](240) NULL,
	[status_time] [varchar](240) NULL,
	[event_session_address] [varchar](240) NULL,
	[audit_file_path] [varchar](240) NULL,
	[audit_file_size] [varchar](240) NULL
) ON [PRIMARY]
GO



---STEP 4B: INSERT DATA INTO AUDIT LOGS TABLE---------
USE [DBA]
INSERT INTO [DBA].[dbo].[AUDIT_LOGS]
(   audit_id, name, status, status_desc, status_time, event_session_address, audit_file_path, audit_file_size
	AUDIT_LOGS)
SELECT *
   FROM OPENQUERY([CDMUAT],
'SELECT * FROM sys.dm_server_audit_status')



---STEP 4C: CREATE THE AUDIT LOGS B TABLE-------------
USE [DBA]
CREATE TABLE [dbo].[AUDIT_LOGS_B](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[audit_id] [varchar](24) NULL,
	[name] [varchar](240) NULL,
	[audit_guid] [varchar](240) NULL,
	[create_date] [varchar](240) NULL,
	[modify_date] [varchar](240) NULL,
	[principal_id] [varchar](240) NULL,
	[type] [varchar](240) NULL, [type_desc] [varchar](240) NULL, [on_failure] [varchar](240) NULL, [on_failure_desc] [varchar](240) NULL,
	[is_state_enabled] [varchar](240) NULL, 
	[queue_delay] [varchar](240) NULL, 
	[predicate] [varchar](240) NULL, 
	[max_file_size] [varchar](240) NULL,
	[max_rollover_files] [varchar](240) NULL, 
	[max_files] [varchar](240) NULL, 
	[reserve_disk_space] [varchar](240) NULL, 
	[log_file_path] [varchar](240) NULL, 
	[log_file_name] [varchar](240) NULL, 
	[retention_days] [varchar](240) NULL
) ON [PRIMARY]
GO



---STEP 4D: INSERT DATA INTO AUDIT B LOGS TABLE-------
USE [DBA]
INSERT INTO [DBA].[dbo].[AUDIT_LOGS_B]
(   audit_id, name, audit_guid, create_date, modify_date, principal_id, type, type_desc, on_failure, on_failure_desc, is_state_enabled, queue_delay, predicate, max_file_size, max_rollover_files, max_files, reserve_disk_space, log_file_path, log_file_name, retention_days)
SELECT *
   FROM OPENQUERY([CDMUAT],
'SELECT * FROM sys.server_file_audits')




---STEP 4E: CREATE THE AUDIT LOGS C TABLE-------------
USE [DBA]
CREATE TABLE [dbo].[AUDIT_LOGS_C](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[event_time] [varchar](240) NULL,
	[sequence_number] [varchar](240) NULL,
	[action_id] [varchar](240) NULL,
	[succeeded] [varchar](240) NULL,
	[permission_bitmask] [varchar](240) NULL,
	[is_column_permission] [varchar](240) NULL,
	[session_id] [varchar](240) NULL,
	[server_principal_id] [varchar](240) NULL,
	[database_principal_id] [varchar](240) NULL,
	[target_principal_id] [varchar](240) NULL,
	[object_id] [varchar](240) NULL,
	[class_type] [varchar](240) NULL,
	[session_server_principal_name] [varchar](240) NULL,
	[server_principal_name] [varchar](240) NULL,
	[server_principal_sid] [varchar](240) NULL,
	[database_principal_name] [varchar](240) NULL,
	[target_server_principal_name] [varchar](240) NULL,
	[target_server_principal_sid] [varchar](240) NULL,
	[target_database_principal_name] [varchar](240) NULL,
	[server_instance_name] [varchar](240) NULL,
	[database_name] [varchar](240) NULL,
	[schema_name] [varchar](240) NULL,
	[object_name] [varchar](240) NULL,
	[statement] [varchar](240) NULL,
	[additional_information] [varchar](240) NULL,
	[file_name] [varchar](240) NULL,
	[audit_file_offset] [varchar](240) NULL,
	[user_defined_event_id] [varchar](240) NULL,
	[user_defined_information] [varchar](240) NULL,
	[audit_schema_version] [varchar](240) NULL,
	[sequence_group_id] [varchar](240) NULL,
	[transaction_id] [varchar](240) NULL,
	[client_ip] [varchar](240) NULL,
	[application_name] [varchar](240) NULL,
	[duration_name] [varchar](240) NULL,
	[duration_milliseconds] [varchar](240) NULL,
	[reponse_rows] [varchar](240) NULL,
	[affected_rows] [varchar](240) NULL,
	[connection_id] [varchar](240) NULL,
	[data_sensitivity_information] [varchar](240) NULL,
	[hostname] [varchar](240) NULL
) ON [PRIMARY]
GO




---STEP 4F: INSERT DATA INTO AUDIT C LOGS TABLE-------
USE [DBA]
INSERT INTO [DBA].[dbo].[AUDIT_LOGS_C]
(   event_time, sequence_number, action_id, succeeded, permission_bitmask, is_column_permission,
session_id, server_principal_id, database_principal_id, target_principal_id,
object_id, class_type, session_server_principal_name, server_principal_name, server_principal_sid, database_principal_name,
target_server_principal_name, target_server_principal_sid, target_database_principal_name, 
server_instance_name, database_name, schema_name, object_name, statement, additional_information, file_name, audit_file_offset,
user_defined_event_id, user_defined_information, audit_schema_version, sequence_group_id, transaction_id, client_ip, application_name, duration_name,
duration_milliseconds, reponse_rows, affected_rows, connection_id, data_sensitivity_information, hostname)
SELECT *
   FROM OPENQUERY([CDMUAT],
'SELECT * FROM sys.fn_get_audit_file(''D:\Audit*'', NULL, NULL)
')













---STEP 5:: CREATING A JOB, SCHEDULE AND STORED PROCEDURE---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------
USE [master]
GO
EXECUTE sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
--------------------------------------------------------
USE [master]
exec sp_configure 'xp_cmdshell', 1;
GO
RECONFIGURE;
GO
--------------------------------------------------------
EXEC xp_cmdshell 'copy D:\Audits\*.sqlaudit F:\TEST';
--------------------------------------------------------







------------------------------------------------------------------------------------------------------END OF SCRIPT-------------------------------------------------------------------------------------------------------------------