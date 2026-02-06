# Install MySQL.Data NuGet package if not already installed
# dotnet add package MySql.Data

[Reflection.Assembly]::LoadFrom("/root/.nuget/packages/mysql.data/9.6.0/lib/net10.0/MySql.Data.dll") | Out-Null

$server = "127.0.0.1"
$username = "root"
$password = "rootChibaba"
$database = "ArioDB"

$connectionString = "Server=$server;Uid=$username;Pwd=$password;Database=$database"

try {
    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString)
    $connection.Open()
    Write-Host "Successfully connected to MySQL server"
    
    # Example: Execute a query
    $command = $connection.CreateCommand()
    $command.CommandText = "SELECT VERSION();"
    $result = $command.ExecuteScalar()
    Write-Host "MySQL Version: $result"
    
    $connection.Close()
} catch {
    Write-Host "Connection failed: $_"
}

try {
    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString)
    $connection.Open()
    Write-Host "Successfully connected to MySQL server"
    
    # Create a test table
    $command = $connection.CreateCommand()
    $command.CommandText = @"
    CREATE TABLE IF NOT EXISTS TestTable (
        Id INT AUTO_INCREMENT PRIMARY KEY,
        Name VARCHAR(100),
        Email VARCHAR(100),
        Age INT
    )
"@
    $command.ExecuteNonQuery()
    Write-Host "Test table created successfully"
    
    # Describe the table
    $command.CommandText = "DESCRIBE TestTable"
    $reader = $command.ExecuteReader()
    Write-Host "`nTable Structure:"
    while ($reader.Read()) {
        Write-Host "$($reader['Field']) - $($reader['Type'])"
    }
    $reader.Close()
    
    # Insert test data
    $command.CommandText = @"
    INSERT INTO TestTable (Name, Email, Age) VALUES 
    ('John Doe', 'john@example.com', 28),
    ('Jane Smith', 'jane@example.com', 32),
    ('Bob Johnson', 'bob@example.com', 25)
"@
    $command.ExecuteNonQuery()
    Write-Host "`nTest data inserted successfully"
    
    # Select and display all records
    $command.CommandText = "SELECT * FROM TestTable"
    $reader = $command.ExecuteReader()
    Write-Host "`nTable Data:"
    while ($reader.Read()) {
        Write-Host "ID: $($reader['Id']), Name: $($reader['Name']), Email: $($reader['Email']), Age: $($reader['Age'])"
    }
    $reader.Close()
    
    $connection.Close()
} catch {
    Write-Host "Error: $_"
}
