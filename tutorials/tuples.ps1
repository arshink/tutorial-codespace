# Array - ordered collection
$fruits = @("Apple", "Banana", "Orange")
$numbers = @(1, 2, 3, 4, 5)
$empty = @()

# Hashtable - key-value pairs
$person = @{
    Name = "John"
    Age = 30
    City = "Seattle"
}

# Access hashtable values
Write-Host $person.Name
Write-Host $person["Age"]

# Class - record-like type (PS 5.0+)
class Employee {
    [string]$Name
    [int]$Id
    [string]$Department
    
    # Constructor
    Employee([string]$name, [int]$id, [string]$dept) {
        $this.Name = $name
        $this.Id = $id
        $this.Department = $dept
    }
}

# Create instances
$emp1 = [Employee]::new("Alice", 101, "Engineering")
$emp2 = [Employee]::new("Bob", 102, "Sales")

# Access properties
Write-Host $emp1.Name
Write-Host $emp2.Department

# Array of custom objects
$employees = @($emp1, $emp2)
$employees | ForEach-Object { Write-Host "$($_.Name) - $($_.Department)" }