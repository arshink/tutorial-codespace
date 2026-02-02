# Install MySQL.Data NuGet package if not already installed
# dotnet add package MySql.Data

[Reflection.Assembly]::LoadFrom("C:\path\to\MySql.Data.dll") | Out-Null

$server = "10.10.100.74"
$username = "alaki"
$password = "dolaki"
$database = "your_database_name"

$connectionString = "Server=$server;Uid=$username;Pwd=$password;Database=$database"

try {
    $connection = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString)
    $connection.Open()
    Write-Host "Successfully connected to MySQL server"
    
    # Example: Execute a query
    $command = $connection.CreateCommand()
    $command.CommandText = "SELECT VERSION()"
    $result = $command.ExecuteScalar()
    Write-Host "MySQL Version: $result"
    
    $connection.Close()
} catch {
    Write-Host "Connection failed: $_"
}