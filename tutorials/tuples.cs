var pt = (X: 1, Y: 2);

var slope = (double)pt.Y / (double)pt.X;
Console.WriteLine($"A line from the origin to the point {pt} has a slope of {slope}.");

pt.X = pt.X + 5;
Console.WriteLine($"The point is now at {pt}.");

var pt2 = pt with { Y = 10 };
Console.WriteLine($"The point 'pt2' is at {pt2}.");

var subscript = (A: 0, B: 0);
subscript = pt;
Console.WriteLine(subscript);

var namedData = (Name: "Morning observation", Temp: 17, Wind: 4);
var person = (FirstName: "Arshin", LastName: "Khoshroo", Age: 55);
var order = (Product: "guitar picks", style: "triangle", quantity: 500, UnitPrice: 0.10m);
Console.WriteLine(namedData);
Console.WriteLine(person);
Console.WriteLine(order);
Console.WriteLine($"Total price: {order.quantity * order.UnitPrice:C}");
Console.WriteLine($"Customer: {person.FirstName} {person.LastName}, Age {person.Age}.");
Console.WriteLine($"Observation: {namedData.Name}, Temp {namedData.Temp} °C, Wind {namedData.Wind} km/h.");
