within LibRAS.Machines;

model AdditionController_S
  extends Modelica.Blocks.Icons.Block;
  outer LibRAS.System system "System wide properties";
  replaceable package Medium = Modelica.Media.Interfaces.PartialMedium "Medium in the component" annotation(
    choicesAllMatching = true);
  parameter Integer index annotation(
    Evaluate = true,
    Dialog(tab = "General", group = "Basic"));
  // Oxygen control
  parameter Real K "Proportional gain of PI controller" annotation(
    Evaluate = true,
    Dialog(tab = "General", group = "Controller"));
  parameter Real Ti = 21000 "Integral time for PI controller" annotation(
    Evaluate = true,
    Dialog(tab = "General", group = "Controller"));
  parameter Real max_u = Modelica.Constants.inf "Output upper bound" annotation(
    Evaluate = true,
    Dialog(tab = "General", group = "Controller"));
  parameter Real min_u = Modelica.Constants.eps "Output lower bound" annotation(
    Evaluate = true,
    Dialog(tab = "General", group = "Controller"));
  LibRAS.Sensors.SoluteSensor sensor(substanceIndex = index, redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {6, 2}, extent = {{6, 6}, {-6, -6}}, rotation = 90)));
  Modelica.Blocks.Interfaces.RealInput setpoint annotation(
    Placement(visible = true, transformation(origin = {36, -18}, extent = {{-8, -8}, {8, 8}}, rotation = 180), iconTransformation(origin = {0, 120}, extent = {{-20, -20}, {20, 20}}, rotation = -90)));
  Modelica.Blocks.Continuous.LimPID PID(Ti(displayUnit = "s") = Ti, controllerType = Modelica.Blocks.Types.SimpleController.PI, k = K, yMax = max_u, yMin = min_u) annotation(
    Placement(visible = true, transformation(origin = {6, -18}, extent = {{6, 6}, {-6, -6}}, rotation = 0)));
  LibRAS.Interfaces.WasteFluidPort_a port_a(redeclare package Medium = Medium) "Fluid port for sensing solute concentration" annotation(
    Placement(visible = true, transformation(origin = {-22, 2}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {0, -100}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Interfaces.RealInput u[Medium.nC_S] "Connector of Real input signals vector" annotation(
    Placement(visible = true, transformation(origin = {-19, -31}, extent = {{-5, -5}, {5, 5}}, rotation = 180), iconTransformation(extent = {{-140, -20}, {-100, 20}}, rotation = 0)));
  Modelica.Blocks.Interfaces.RealOutput y[Medium.nC_S] "Connector of Real output signals" annotation(
    Placement(visible = true, transformation(origin = {-70, -20}, extent = {{-10, -10}, {10, 10}}, rotation = 180), iconTransformation(origin = {120, 0}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
equation
  connect(port_a, sensor.port) annotation(
    Line(points = {{-22, 2}, {0, 2}, {0, 2}, {0, 2}}));
  connect(setpoint, PID.u_s) annotation(
    Line(points = {{36, -18}, {14, -18}}, color = {0, 0, 127}));
  connect(sensor.C, PID.u_m) annotation(
    Line(points = {{6, -4}, {6, -4}, {6, -10}, {6, -10}}, color = {0, 0, 127}));
  for i in 1:Medium.nC_S loop
    y[i] = u[i] + (if i == index then PID.y else 0);
  end for;
  annotation(
    Icon(coordinateSystem(initialScale = 0.1), graphics = {Line(points = {{-80, 78}, {-80, -90}}, color = {192, 192, 192}), Polygon(lineColor = {192, 192, 192}, fillColor = {192, 192, 192}, fillPattern = FillPattern.Solid, points = {{-80, 90}, {-88, 68}, {-72, 68}, {-80, 90}}), Line(points = {{-90, -80}, {82, -80}}, color = {192, 192, 192}), Polygon(lineColor = {192, 192, 192}, fillColor = {192, 192, 192}, fillPattern = FillPattern.Solid, points = {{90, -80}, {68, -72}, {68, -88}, {90, -80}}), Line(origin = {-1.939, -1.816}, points = {{81.939, 36.056}, {65.362, 36.056}, {14.39, -26.199}, {-29.966, 113.485}, {-65.374, -61.217}, {-78.061, -78.184}}, color = {0, 0, 127}, smooth = Smooth.Bezier)}));
end AdditionController_S;