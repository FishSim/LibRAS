within LibRAS.Pipes;
partial model PartialStraightPipe "Base class for straight pipe models"
  extends LibRAS.Interfaces.PartialTwoPort;
  import SI = Modelica.SIunits;
  // Geometry
  // Note: define nParallel as Real to support inverse calculations
  parameter Real nParallel(min = 1) = 1 "Number of identical parallel pipes" annotation(Dialog(group = "Geometry"));
  parameter SI.Length length "Length" annotation(Dialog(tab = "General", group = "Geometry"));
  parameter Boolean isCircular = true "= true if cross sectional area is circular" annotation(Evaluate, Dialog(tab = "General", group = "Geometry"));
  parameter SI.Diameter diameter "Diameter of circular pipe" annotation(Dialog(group = "Geometry", enable = isCircular));
  parameter SI.Area crossArea = Modelica.Constants.pi * diameter * diameter / 4 "Inner cross section area" annotation(Dialog(tab = "General", group = "Geometry", enable = not isCircular));
  parameter SI.Length perimeter = Modelica.Constants.pi * diameter "Inner perimeter" annotation(Dialog(tab = "General", group = "Geometry", enable = not isCircular));
  parameter SI.Height roughness = 2.5e-5 "Average height of surface asperities (default: smooth steel pipe)" annotation(Dialog(group = "Geometry"));
  final parameter SI.Volume V = crossArea * length * nParallel "volume size";
  // Static head
  parameter SI.Length height_ab = 0 "Height(port_b) - Height(port_a)" annotation(Dialog(group = "Static head"));
  // Pressure loss
  replaceable model FlowModel = Modelica.Fluid.Pipes.BaseClasses.FlowModels.DetailedPipeFlow constrainedby Modelica.Fluid.Pipes.BaseClasses.FlowModels.PartialStaggeredFlowModel "Wall friction, gravity, momentum flow" annotation(Dialog(group = "Pressure loss"), choicesAllMatching = true);
equation
  assert(length >= height_ab, "Parameter length must be greater or equal height_ab.");
  annotation(defaultComponentName = "pipe", Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(extent = {{-100, 40}, {100, -40}}, fillPattern = FillPattern.Solid, fillColor = {95, 95, 95}, pattern = LinePattern.None), Rectangle(extent = {{-100, 44}, {100, -44}}, lineColor = {0, 0, 0}, fillPattern = FillPattern.HorizontalCylinder, fillColor = {0, 127, 255})}), Documentation(info = "<html>
<p>
Base class for one dimensional flow models. It specializes a PartialTwoPort with a parameter interface and icon graphics.
</p>
</html>"));
end PartialStraightPipe;
