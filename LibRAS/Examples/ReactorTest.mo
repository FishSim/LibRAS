within LibRAS.Examples;

model ReactorTest
  extends Modelica.Icons.Example;
  import Modelica.SIunits.Conversions.from_bar;
  type MassFlowRate = Modelica.SIunits.MassFlowRate(displayUnit = "g/d");
  import LibRAS.Types.Species.S;
  import LibRAS.Types.Species.X;
  
  parameter Modelica.SIunits.Volume V_aerob = 5.0 "Treatment tank volume";
  parameter Real C_NH = 5.0;
  replaceable package Medium = LibRAS.Media.WasteWater "Medium in the component";
  inner LibRAS.System system(T_ambient = Modelica.SIunits.Conversions.from_degC(20)) annotation(
    Placement(visible = true, transformation(extent = {{138, 44}, {158, 64}}, rotation = 0)));
  LibRAS.Machines.ControlledPump pump(redeclare package Medium = Medium, m_flow_nominal = 10, p_a_nominal = system.p_ambient, p_b_nominal = system.p_ambient + 0.5e5) annotation(
    Placement(visible = true, transformation(origin = {60, 82}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  LibRAS.Sources.WaterExchange exchange(redeclare package Medium = Medium, source.C_S = {0.1, 0.1, 8, 0.01, 10, C_NH, 0.1, 2, 0.1, 0.1}*1e-3, source.C_X = {0.1, 0.1, 0.1, 0.01, 0.01, 1, 0.1}*1e-3) annotation(
    Placement(visible = true, transformation(origin = {88, 82}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  LibRAS.Pipes.Tee tee1(redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {120, 82}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  LibRAS.Sources.Boundary_pT boundary1(nPorts = 1, redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {148, 82}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  LibRAS.Pipes.StaticPipe pipe(diameter = 0.2, height_ab = 5, length = 10, redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {30, 82}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  LibRAS.Tanks.CSBR aerob1(KLa = 500 / 86400, energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, massDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, use_portsData = false, redeclare package Medium = Medium, V = V_aerob, nPorts = 2) annotation(
    Placement(visible = true, transformation(origin = {50, 20}, extent = {{-10, 10}, {10, -10}}, rotation = 0)));
  LibRAS.Tanks.CST bufferTank(redeclare package Medium = Medium, V = 1, energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, massDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, nPorts = 3, use_portsData = false) annotation(
    Placement(visible = true, transformation(origin = {20, 40}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
equation
  connect(bufferTank.ports[2], aerob1.ports[1]) annotation(
    Line(points = {{20, 30}, {48, 30}, {48, 30}, {50, 30}}, color = {0, 127, 255}, thickness = 0.5));
  connect(aerob1.ports[2], tee1.port_3) annotation(
    Line(points = {{50, 30}, {120, 30}, {120, 72}}, color = {0, 127, 255}, thickness = 0.5));
  connect(pipe.port_b, bufferTank.ports[1]) annotation(
    Line(points = {{20, 82}, {0, 82}, {0, 30}, {20, 30}, {20, 30}}, color = {0, 127, 255}));
  exchange.makeupRate = 1;
  connect(pump.port_b, pipe.port_a) annotation(
    Line(points = {{50, 82}, {40, 82}}, color = {0, 127, 255}));
  connect(exchange.port_b, pump.port_a) annotation(
    Line(points = {{78, 82}, {70, 82}}, color = {0, 127, 255}));
  connect(tee1.port_2, exchange.port_a) annotation(
    Line(points = {{110, 82}, {98, 82}}, color = {0, 127, 255}));
  connect(boundary1.ports[1], tee1.port_1) annotation(
    Line(points = {{138, 82}, {130, 82}}, color = {0, 127, 255}));
  annotation(
    experiment(StopTime = 86400, StartTime = 0, Tolerance = 0.0001, Interval = 3600),
    uses(Modelica(version = "3.2.2")),
    Placement(visible = true, transformation(origin = {-56, 58}, extent = {{-14, -14}, {14, 14}}, rotation = 0)),
    Diagram(coordinateSystem(extent = {{-200, -100}, {200, 100}}, initialScale = 0.1)),
    Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}})),
    version = "",
    __OpenModelica_commandLineOptions = "");
end ReactorTest;
