# Install MySQL.Data NuGet package if not already installed
# dotnet add package MySql.Data

[Reflection.Assembly]::LoadFrom("/root/.nuget/packages/mysql.data/9.6.0/lib/net10.0/MySql.Data.dll") | Out-Null

# Load credentials from environment variables with fallback defaults
$server = $env:MYSQL_SERVER ?? "127.0.0.1"
$username = $env:MYSQL_USER ?? "root"
$password = $env:MYSQL_PASSWORD ?? "rootChibaba"
$database = $env:MYSQL_DATABASE ?? "ArioDB"

$connectionString = "Server=$server;Uid=$username;Pwd=$password;Database=$database;Connection Timeout=10;"

# Helper function to execute queries and return results
function Invoke-MySQLQuery {
    param(
        [Parameter(Mandatory = $true)] [MySql.Data.MySqlClient.MySqlConnection]$Connection,
        [Parameter(Mandatory = $true)] [string]$Query,
        [hashtable]$Parameters = @{}
    )
    
    $command = $Connection.CreateCommand()
    $command.CommandText = $Query
    
    # Add parameterized query support
    foreach ($param in $Parameters.GetEnumerator()) {
        $command.Parameters.AddWithValue("@$($param.Key)", $param.Value) | Out-Null
    }
    
    return $command
}

# Helper function to display results in formatted table
function Display-QueryResults {
    param(
        [Parameter(Mandatory = $true)] [MySql.Data.MySqlClient.MySqlDataReader]$Reader,
        [string[]]$Columns
    )
    
    $results = @()
    while ($Reader.Read()) {
        $row = @{}
        if ($Columns.Count -eq 0) {
            # Auto-detect columns if not specified
            for ($i = 0; $i -lt $Reader.FieldCount; $i++) {
                $row[$Reader.GetName($i)] = $Reader[$i]
            }
        } else {
            foreach ($col in $Columns) {
                $row[$col] = $Reader[$col]
            }
        }
        $results += $row
    }
    
    if ($results.Count -gt 0) {
        $results | Format-Table -AutoSize
    } else {
        Write-Host "(No results)"
    }
}

# Helper function for safe command disposal
function Close-MySQLCommand {
    param([MySql.Data.MySqlClient.MySqlCommand]$Command)
    if ($Command -ne $null) {
        $Command.Dispose()
    }
}

try {
    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString)
    $connection.Open()
    Write-Host "✓ Successfully connected to MySQL server`n" -ForegroundColor Green
    
    # Show all databases
    Write-Host "Available Databases:" -ForegroundColor Cyan
    $command = Invoke-MySQLQuery -Connection $connection -Query "SHOW DATABASES"
    $reader = $command.ExecuteReader()
    while ($reader.Read()) {
        Write-Host "  - $($reader[0])"
    }
    $reader.Close()
    Close-MySQLCommand $command

    # Show all tables in the current database
    Write-Host "`nTables in '$database' database:" -ForegroundColor Cyan
    $command = Invoke-MySQLQuery -Connection $connection -Query "SHOW TABLES"
    $reader = $command.ExecuteReader()
    if ($reader.HasRows) {
        while ($reader.Read()) {
            Write-Host "  - $($reader[0])"
        }
    } else {
        Write-Host "  (No tables found)"
    }
    $reader.Close()
    Close-MySQLCommand $command

    # Drop existing version of TestTable if it exists 
    Write-Host "`nRecreating TestTable..." -ForegroundColor Yellow
    $command = Invoke-MySQLQuery -Connection $connection -Query "DROP TABLE IF EXISTS TestTable"
    $command.ExecuteNonQuery() | Out-Null
    Close-MySQLCommand $command
    
    # Create a test table
    $createTableSql = @"
    CREATE TABLE IF NOT EXISTS TestTable (
        Id INT AUTO_INCREMENT PRIMARY KEY,
        Name VARCHAR(100) NOT NULL,
        Email VARCHAR(100),
        Age INT,
        CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
"@
    $command = Invoke-MySQLQuery -Connection $connection -Query $createTableSql
    $command.ExecuteNonQuery() | Out-Null
    Write-Host "✓ Test table created successfully" -ForegroundColor Green
    Close-MySQLCommand $command
    
    # Describe the table
    Write-Host "`nTable Structure:" -ForegroundColor Cyan
    $command = Invoke-MySQLQuery -Connection $connection -Query "DESCRIBE TestTable"
    $reader = $command.ExecuteReader()
    while ($reader.Read()) {
        Write-Host "  $($reader['Field']) - $($reader['Type']) $($reader['Null']) $($reader['Key'])"
    }
    $reader.Close()
    Close-MySQLCommand $command
    
    # Insert test data using parameterized queries (prevents SQL injection)
    Write-Host "`nInserting test data..." -ForegroundColor Yellow
    $testData = @(
        @{Name = 'John Doe'; Email = 'john@example.com'; Age = 28},
        @{Name = 'Jane Smith'; Email = 'jane@example.com'; Age = 32},
        @{Name = 'Bob Johnson'; Email = 'bob@example.com'; Age = 25}
    )
    
    foreach ($data in $testData) {
        $command = Invoke-MySQLQuery -Connection $connection `
            -Query "INSERT INTO TestTable (Name, Email, Age) VALUES (@name, @email, @age)" `
            -Parameters @{
                name = $data.Name
                email = $data.Email
                age = $data.Age
            }
        $command.ExecuteNonQuery() | Out-Null
        Close-MySQLCommand $command
    }
    Write-Host "✓ Test data inserted successfully ($($testData.Count) rows)" -ForegroundColor Green
    
    # Select and display all records
    Write-Host "`nTable Data:" -ForegroundColor Cyan
    $command = Invoke-MySQLQuery -Connection $connection -Query "SELECT * FROM TestTable"
    $reader = $command.ExecuteReader()
    
    $records = @()
    while ($reader.Read()) {
        $records += [PSCustomObject]@{
            ID = $reader['Id']
            Name = $reader['Name']
            Email = $reader['Email']
            Age = $reader['Age']
            CreatedAt = $reader['CreatedAt']
        }
    }
    $reader.Close()
    Close-MySQLCommand $command
    
    # Display in formatted table
    if ($records.Count -gt 0) {
        $records | Format-Table -AutoSize
    }
    
} catch {
    Write-Host "✗ Error: $_" -ForegroundColor Red
    Write-Host "StackTrace: $($_.Exception.StackTrace)" -ForegroundColor Red
} finally {
    if ($connection -ne $null) {
        $connection.Close()
        $connection.Dispose()
    }
}
