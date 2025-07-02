# SQL Permission Master Pro v1.0

🎯 **Professional SQL Server Permissions Management Tool**

A comprehensive, production-ready T-SQL script for managing SQL Server user permissions, database access, and SQL Server Agent configurations across multiple databases with advanced conflict resolution and safety features.

## ✨ Key Features

- **🔐 Dual Authentication Support**: SQL Server and Windows Authentication (users/groups)
- **📊 Six Permission Levels**: From read-only to full sysadmin control
- **🤖 SQL Server Agent Integration**: Granular job management permissions
- **🛡️ Advanced Safety Features**: Preview mode, conflict resolution, comprehensive verification
- **📋 Production Ready**: Extensive error handling, logging, and rollback protection
- **🔄 Repeatable**: Safe to run multiple times, idempotent operations
- **📖 Self-Documenting**: Comprehensive output and verification reporting

## 🎛️ Permission Levels

| Level | Description | Use Cases |
|-------|-------------|-----------|
| **READ_ONLY** | `db_datareader` only | Reports, dashboards, read-only applications |
| **READ_WRITE** | Data access + modification | Standard application users, data entry |
| **READ_WRITE_DDL** | Above + object creation + execute | Developers, application deployment |
| **FULL** | Above + view definitions + advanced permissions | Senior developers, analysts |
| **DB_OWNER** | Complete database control | Database administrators, power users |
| **SYSADMIN** | Full server control ⚠️ | Server administrators only |

## 🤖 SQL Server Agent Levels

| Level | Capabilities | Best For |
|-------|-------------|----------|
| **USER** | Manage own jobs only | Automated applications |
| **READER** | View all jobs + manage own | Monitoring, support teams |
| **OPERATOR** | Full job management | DevOps, database administrators |

## 🚀 Quick Start

### 1. Download and Review
```sql
-- Download SQL-PermissionMaster-Pro.sql
-- Review the configuration section (lines 45-80)
-- Always test in development first!
```

### 2. Basic Configuration
```sql
-- Essential settings to modify:
DECLARE @LoginName NVARCHAR(128) = 'DOMAIN\username'    -- Your user/group
DECLARE @AuthType VARCHAR(10) = 'WINDOWS'               -- 'SQL' or 'WINDOWS' 
DECLARE @PermissionLevel VARCHAR(20) = 'READ_WRITE'     -- See table above
DECLARE @PreviewMode BIT = 1                            -- Start with preview!
```

### 3. Safe Execution Process
```sql
-- Step 1: Preview first (safe)
DECLARE @PreviewMode BIT = 1
-- Run script and review output

-- Step 2: Execute if satisfied
DECLARE @PreviewMode BIT = 0
-- Run script to apply changes
```

## 📋 Common Use Cases

### 🏢 Enterprise Scenarios

#### New Employee Onboarding
```sql
-- Standard developer access
DECLARE @LoginName NVARCHAR(128) = 'CORP\john.smith'
DECLARE @AuthType VARCHAR(10) = 'WINDOWS'
DECLARE @PermissionLevel VARCHAR(20) = 'READ_WRITE_DDL'
DECLARE @GrantSQLAgentAccess BIT = 1
DECLARE @SQLAgentLevel VARCHAR(20) = 'READER'
```

#### Windows Domain Group Setup
```sql
-- Create access for entire team
DECLARE @LoginName NVARCHAR(128) = 'CORP\DatabaseDevelopers'
DECLARE @AuthType VARCHAR(10) = 'WINDOWS'
DECLARE @PermissionLevel VARCHAR(20) = 'FULL'
DECLARE @GrantSQLAgentAccess BIT = 1
DECLARE @SQLAgentLevel VARCHAR(20) = 'OPERATOR'
```

#### Application Service Account
```sql
-- SQL authenticated service account
DECLARE @LoginName NVARCHAR(128) = 'app_service_user'
DECLARE @Password NVARCHAR(128) = 'Complex$erviceP@ssw0rd!'
DECLARE @AuthType VARCHAR(10) = 'SQL'
DECLARE @PermissionLevel VARCHAR(20) = 'READ_WRITE'
DECLARE @GrantSQLAgentAccess BIT = 0
```

#### Read-Only Reporting Access
```sql
-- Business intelligence team
DECLARE @LoginName NVARCHAR(128) = 'CORP\BIAnalysts'
DECLARE @AuthType VARCHAR(10) = 'WINDOWS'
DECLARE @PermissionLevel VARCHAR(20) = 'READ_ONLY'
DECLARE @GrantSQLAgentAccess BIT = 0
DECLARE @IncludeSystemDBs BIT = 0
```

#### Database Administrator Setup
```sql
-- Full administrative access
DECLARE @LoginName NVARCHAR(128) = 'CORP\DatabaseAdmins'
DECLARE @AuthType VARCHAR(10) = 'WINDOWS'
DECLARE @PermissionLevel VARCHAR(20) = 'DB_OWNER'
DECLARE @GrantSQLAgentAccess BIT = 1
DECLARE @SQLAgentLevel VARCHAR(20) = 'OPERATOR'
DECLARE @IncludeSystemDBs BIT = 1
```

## 🛡️ Security Considerations

### ⚠️ Important Safety Notes

1. **Always Preview First**: Use `@PreviewMode = 1` to see what changes will be made
2. **Test in Development**: Never run directly in production without testing
3. **Principle of Least Privilege**: Grant minimal permissions necessary
4. **Audit Regularly**: Review permissions periodically
5. **Backup Security**: Document all permission changes

### 🔒 Security Best Practices

- **Use Windows Authentication** when possible for better security integration
- **Avoid SYSADMIN** unless absolutely necessary
- **Exclude System Databases** unless specifically required
- **Regular Access Reviews**: Periodically audit user permissions
- **Document Changes**: Keep records of permission modifications

## 📋 Prerequisites

### System Requirements
- **SQL Server**: 2012 or later (2016+ recommended)
- **Permissions**: Must run with `sysadmin` privileges
- **PowerShell**: Optional, for advanced automation scenarios

### Authentication Requirements
- **Windows Authentication**: User/group must exist in domain
- **SQL Authentication**: Strong password policy compliance
- **Network**: Appropriate SQL Server connectivity

## 🔧 Advanced Configuration

### Database Scope Options
```sql
-- Include system databases (use carefully!)
DECLARE @IncludeSystemDBs BIT = 1    -- master, model, msdb
DECLARE @IncludeTempDB BIT = 1       -- tempdb (rarely needed)
```

### Conflict Resolution
```sql
-- Handle existing user conflicts
DECLARE @HandleConflicts BIT = 1     -- Auto-resolve conflicts
DECLARE @HandleConflicts BIT = 0     -- Skip conflicted databases
```

### Server-Level Permissions
```sql
-- Additional server permissions
DECLARE @GrantViewServerState BIT = 1    -- Performance monitoring
DECLARE @GrantShowPlan BIT = 1           -- Execution plan access
```

## 📊 Output and Verification

### Execution Summary
The script provides detailed output including:
- **Configuration Summary**: All settings used
- **Step-by-Step Progress**: Real-time execution status
- **Error Reporting**: Detailed error messages and resolution steps
- **Verification Results**: Complete permission verification
- **Connection Details**: Information for testing access

### Sample Output
```
========================================================================
SQL PERMISSION MASTER PRO v1.0 - EXECUTION SUMMARY
========================================================================
Target Login: CORP\DatabaseDevelopers
Authentication: WINDOWS (Domain authentication)
Permission Level: READ_WRITE_DDL
SQL Agent Access: YES (OPERATOR level)
...
STATUS: ALL PERMISSIONS SUCCESSFULLY CONFIGURED!
```

## 🔍 Troubleshooting

### Common Issues and Solutions

#### Authentication Errors
```
ERROR: Login failed for user 'DOMAIN\username'
```
**Solution**: Verify domain connectivity and user/group existence

#### Permission Denied
```
ERROR: User does not have permission to perform this action
```
**Solution**: Ensure running user has `sysadmin` privileges

#### User Conflicts
```
WARNING: Login mapped to different user [old_user] in [database]
```
**Solution**: Enable `@HandleConflicts = 1` or manually resolve conflicts

#### System Database Access
```
ERROR: Cannot access system database
```
**Solution**: Only include system databases when absolutely necessary

### Verification Queries

#### Check User Permissions
```sql
-- Verify user exists and has permissions
USE [YourDatabase]
SELECT 
    dp.name AS UserName,
    r.name AS RoleName,
    'GRANTED' as Status
FROM sys.database_role_members rm
JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id
JOIN sys.database_principals dp ON rm.member_principal_id = dp.principal_id
WHERE dp.name = 'YourUser'
```

#### Check SQL Agent Access
```sql
-- Verify SQL Agent permissions
USE msdb
SELECT 
    IS_MEMBER('SQLAgentUserRole') AS HasUserRole,
    IS_MEMBER('SQLAgentReaderRole') AS HasReaderRole,
    IS_MEMBER('SQLAgentOperatorRole') AS HasOperatorRole
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### 🐛 Report Issues
- Use the GitHub issue tracker
- Include SQL Server version, configuration used, and error messages
- Provide steps to reproduce the problem

### 💡 Feature Requests
- Describe the use case and business value
- Consider security implications
- Provide example configurations

### 🔧 Pull Requests
- Follow the existing code style and documentation patterns
- Include test cases for new features
- Update documentation as needed

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **DevSecOps Community**: For feedback and testing
- **SQL Server Community**: For best practices and security guidelines
- **Contributors**: Everyone who has helped improve this tool

## 📚 Additional Resources

### Microsoft Documentation
- [SQL Server Permissions](https://docs.microsoft.com/en-us/sql/relational-databases/security/permissions-database-engine)
- [SQL Server Agent Security](https://docs.microsoft.com/en-us/sql/ssms/agent/sql-server-agent-security)
- [Database Roles](https://docs.microsoft.com/en-us/sql/relational-databases/security/authentication-access/database-level-roles)

### Best Practices
- [SQL Server Security Best Practices](https://docs.microsoft.com/en-us/sql/relational-databases/security/sql-server-security-best-practices)
- [Principle of Least Privilege](https://docs.microsoft.com/en-us/sql/relational-databases/security/securing-sql-server)

---

**⭐ If this tool helped you, please consider starring the repository!**

**🤝 Questions? Issues? Contributions? We'd love to hear from you!**

---

*SQL Permission Master Pro - Making SQL Server permission management safer, easier, and more reliable.*