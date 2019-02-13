within LibRAS.Blocks;

block CEWA
  extends Modelica.Blocks.Interfaces.SISO;
  parameter Real T1 = 86400 "Control input filter time constant";
  parameter Real T2 = 6 * 86400;
  Modelica.Blocks.Interfaces.RealInput v "Connector of Real input signal" annotation(
    Placement(visible = true, transformation(extent = {{-140, -20}, {-100, 20}}, rotation = 0), iconTransformation(origin = {0, -120},extent = {{-20, -20}, {20, 20}}, rotation = 90)));
  Real x;
  Real q;
initial equation
  x = u;
equation
  T1 * der(x) = (q - 1) * x + (1 - q) * u;
  T2 * der(q) = (-q) + v;
  connect(y, x);
end CEWA;