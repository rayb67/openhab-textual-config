// Manchmal gibt es folgende Zahl aus der PV : 5.605193857299268e-45
// Das fuert bei einer Berechnung zu folgender Fehlermeldung
// Incoming payload '5.605193857299268e-45' not supported by type 'NumberValue'
// Daher muss das "e-45" abgeschnitten werden.
(function(inputData) {
  const front = inputData.split('e').slice(0)[0]
  return front
})(input);
