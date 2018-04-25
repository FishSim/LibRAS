within LibRAS.Sources;

model WaterExchange "Water make-up and let-down."
  extends LibRAS.Interfaces.PartialTwoPort;
//  parameter Real makeupRate (min=0) = 0.1 "Water exchange factor" annotation(Dialog(tab = "General"));
  parameter Modelica.SIunits.Temperature T_makeup = system.T_ambient "Make-up water temperature" annotation(Dialog(tab = "General"));
  replaceable package Medium = Modelica.Media.Interfaces.PartialMedium "Medium model within the source" annotation(choicesAllMatching = true);
  LibRAS.Sources.MassFlowSource_T source(redeclare package Medium = Medium, T = T_makeup, nPorts = 1, use_m_flow_in = true) annotation(Placement(visible = true, transformation(origin = {-8, 30}, extent = {{10, -10}, {-10, 10}}, rotation = 90)));
  LibRAS.Pipes.Tee tee(redeclare package Medium = Medium) annotation(Placement(visible = true, transformation(origin = {-8, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  LibRAS.Sources.MassFlowSource_T drain(redeclare package Medium = Medium, T = T_makeup, nPorts = 1, use_m_flow_in = true) annotation(Placement(visible = true, transformation(origin = {-62, 30}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  LibRAS.Sensors.MassFlowRate massFlowRate1(redeclare package Medium = Medium) annotation(Placement(visible = true, transformation(origin = {44, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Math.Gain gain1(k = -1) annotation(Placement(visible = true, transformation(origin = {-38, 80}, extent = {{6, -6}, {-6, 6}}, rotation = 0)));
  Modelica.Blocks.Interfaces.RealInput makeupRate (min=0, max=1) "Water exchange factor" annotation(
    Placement(visible = true, transformation(origin = {0, 100}, extent = {{12, -12}, {-12, 12}}, rotation = 90), iconTransformation(origin = {0, -120}, extent = {{-20, -20}, {20, 20}}, rotation = 90)));
  Modelica.Blocks.Math.Product product1 annotation(
    Placement(visible = true, transformation(origin = {-54, 54}, extent = {{6, -6}, {-6, 6}}, rotation = 90)));
  Modelica.Blocks.Math.Product product2 annotation(
    Placement(visible = true, transformation(origin = {-16, 54}, extent = {{-6, -6}, {6, 6}}, rotation = -90)));
  Medium.MassFlowRate [Medium.nC_S] m_S_removed (each displayUnit="g/d");
  Medium.MassFlowRate [Medium.nC_X] m_X_removed (each displayUnit="g/d");
  Modelica.Blocks.Interfaces.RealOutput V_flow_exchanged(final quantity = "VolumeFlowRate", final unit = "m3/s") "Volume flow rate of exchanged water" annotation(
    Placement(visible = true, transformation(origin = {0, -100}, extent = {{10, -10}, {-10, 10}}, rotation = 90), iconTransformation(origin = {-1.77636e-15, 119}, extent = {{19, -19}, {-19, 19}}, rotation = -90)));
protected
  Medium.Density d "Density of the passing fluid";

equation
  connect(source.ports[1], tee.port_3) annotation(
    Line(points = {{-8, 20}, {-8, 20}, {-8, 10}, {-8, 10}}, thickness = 0.5));
  connect(massFlowRate1.m_flow, product2.u1) annotation(
    Line(points = {{44, 12}, {44, 12}, {44, 66}, {-12, 66}, {-12, 62}, {-12, 62}}, color = {0, 0, 127}));
  connect(massFlowRate1.m_flow, product1.u2) annotation(
    Line(points = {{44, 12}, {44, 12}, {44, 66}, {-50, 66}, {-50, 62}, {-50, 62}}, color = {0, 0, 127}));
  connect(makeupRate, product2.u2) annotation(
    Line(points = {{0, 100}, {0, 100}, {0, 68}, {-20, 68}, {-20, 62}, {-20, 62}}, color = {0, 0, 127}));
  connect(product2.y, source.m_flow_in) annotation(
    Line(points = {{-16, 48}, {-16, 48}, {-16, 40}, {-16, 40}}, color = {0, 0, 127}));
  connect(makeupRate, gain1.u) annotation(
    Line(points = {{0, 100}, {0, 100}, {0, 80}, {-30, 80}, {-30, 80}, {-30, 80}}, color = {0, 0, 127}));
  connect(gain1.y, product1.u1) annotation(
    Line(points = {{-44, 80}, {-58, 80}, {-58, 62}, {-58, 62}}, color = {0, 0, 127}));
  connect(product1.y, drain.m_flow_in) annotation(
    Line(points = {{-54, 48}, {-54, 48}, {-54, 40}, {-54, 40}}, color = {0, 0, 127}));
  connect(port_a, drain.ports[1]) annotation(
    Line(points = {{-100, 0}, {-62, 0}, {-62, 20}}));
  connect(port_a, tee.port_1) annotation(
    Line(points = {{-100, 0}, {-18, 0}}));
  connect(massFlowRate1.port_a, tee.port_2) annotation(
    Line(points = {{34, 0}, {2, 0}}, color = {0, 127, 255}));
  connect(massFlowRate1.port_b, port_b) annotation(
    Line(points = {{54, 0}, {100, 0}}, color = {0, 127, 255}));
  if port_a.m_flow > 0 then
    m_S_removed = -(inStream(port_a.C_S_outflow)*port_a.m_flow/scalar(Medium.density_phX(port_a.p, port_a.h_outflow, {1})) + port_b.C_S_outflow*port_b.m_flow/scalar(Medium.density_phX(port_b.p, port_b.h_outflow, {1})));
    m_X_removed = -(inStream(port_a.C_X_outflow)*port_a.m_flow/scalar(Medium.density_phX(port_a.p, port_a.h_outflow, {1})) + port_b.C_X_outflow*port_b.m_flow/scalar(Medium.density_phX(port_b.p, port_b.h_outflow, {1})));
  else
    m_S_removed = -(inStream(port_b.C_S_outflow)*port_b.m_flow/scalar(Medium.density_phX(port_b.p, port_b.h_outflow, {1})) + port_a.C_S_outflow*port_a.m_flow/scalar(Medium.density_phX(port_a.p, port_a.h_outflow, {1})));
    m_X_removed = -(inStream(port_b.C_X_outflow)*port_b.m_flow/scalar(Medium.density_phX(port_b.p, port_b.h_outflow, {1})) + port_a.C_X_outflow*port_a.m_flow/scalar(Medium.density_phX(port_a.p, port_a.h_outflow, {1})));
  end if;

  d = Medium.density(Medium.setState_phX(source.ports[1].p, source.ports[1].h_outflow, source.ports[1].Xi_outflow));
  V_flow_exchanged = -source.ports[1].m_flow / d;
  annotation(defaultComponentName = "exchange", uses(Modelica(version = "3.2.1")),
    Icon(graphics = {Rectangle(origin = {-40, -1}, fillPattern = FillPattern.Solid, extent = {{-2, -70}, {2, 70}}), Rectangle(origin = {-33, 62}, rotation = -45, fillPattern = FillPattern.Solid, extent = {{-11, -2}, {11, 2}}), Rectangle(origin = {-47, 62}, rotation = 45, fillPattern = FillPattern.Solid, extent = {{-11, -2}, {11, 2}}), Rectangle(origin = {33, -60}, rotation = -45, fillPattern = FillPattern.Solid, extent = {{-11, -2}, {11, 2}}), Rectangle(origin = {47, -60}, rotation = 45, fillPattern = FillPattern.Solid, extent = {{-11, -2}, {11, 2}}), Rectangle(origin = {40, 3}, fillPattern = FillPattern.Solid, extent = {{-2, -70}, {2, 70}}), Rectangle(origin = {0, -1}, extent = {{-100, 101}, {100, -99}})}));
end WaterExchange;