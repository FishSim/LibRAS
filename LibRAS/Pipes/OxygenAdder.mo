within LibRAS.Pipes;

model OxygenAdder "Addition of oxygen to (small) stirred volume"
  extends LibRAS.Interfaces.PartialTwoPort;
  parameter Modelica.SIunits.Volume V = 1e-3 "Internal volume" annotation(Dialog(tab = "General"));
  replaceable package Medium = Modelica.Media.Interfaces.PartialMedium "Medium model within the device" annotation(choicesAllMatching = true);
  Tanks.CST cst(V=V, KLa = 0, nPorts = 2, use_portsData = false, redeclare package Medium = Medium, use_m_S_in = true)  annotation(Placement(visible = true, transformation(origin = {0, 10}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Interfaces.RealInput O2_in (quantity="MassFlowRate", unit="kg/s", displayUnit="g/s") annotation(Placement(visible = true, transformation(origin = {-5, 63}, extent = {{-11, -11}, {11, 11}}, rotation = -90), iconTransformation(origin = {0, 102}, extent = {{-20, -20}, {20, 20}}, rotation = -90)));
  Modelica.Blocks.Sources.Constant const(k = 0)  annotation(Placement(visible = true, transformation(origin = {-76, 46}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Routing.Replicator replicator1(nout = Medium.nC_S-1)  annotation(Placement(visible = true, transformation(origin = {-42, 46}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  parameter Integer ind = Integer(Types.Species.S.O);
equation
  connect(const.y, replicator1.u) annotation(Line(points = {{-64, 46}, {-54, 46}, {-54, 46}, {-54, 46}}, color = {0, 0, 127}));
  connect(O2_in, cst.m_S_in[ind]) annotation(Line(points = {{-4, 64}, {-4, 64}, {-4, 20}, {-4, 20}}, color = {0, 0, 127}));
  for i in 1:ind-1 loop
    connect(replicator1.y[i], cst.m_S_in[i]) annotation(Line(points = {{-30, 46}, {-4, 46}, {-4, 20}, {-4, 20}}, color = {0, 0, 127}));
  end for;
  for i in ind+1:Medium.nC_S loop
    connect(replicator1.y[i-1], cst.m_S_in[i]) annotation(Line(points = {{-30, 46}, {-4, 46}, {-4, 20}, {-4, 20}}, color = {0, 0, 127}));
  end for;
  connect(port_a, cst.ports[1]);
  connect(port_b, cst.ports[2]);
  annotation(defaultComponentName = "O2addition", uses(Modelica(version = "3.2.1")), Icon(coordinateSystem(
      initialScale = 0.1), graphics={Rectangle(fillColor = {0, 127, 255}, fillPattern = FillPattern.HorizontalCylinder, extent = {{-100, 44}, {100, -44}}), Text(lineColor = {0, 0, 255}, extent = {{-150, -89}, {150, -129}}, textString = "%name", fontName = "DejaVu Sans Mono"), Rectangle(fillColor = {85, 170, 127}, fillPattern = FillPattern.VerticalCylinder, extent = {{-44, 100}, {44, 44}})}));
end OxygenAdder;