within LibRAS.Examples;

model Recycle
  extends Modelica.Icons.Example;
  import Modelica.SIunits.Conversions.from_bar;
  replaceable package Medium = LibRAS.Media.WasteWater "Medium in the component";
  parameter Modelica.SIunits.Volume V_system = aerob1.V + aerob2.V + nitri1.V + nitri2.V + nitri3.V + degas1.V + sum(fishTank1.tankVolumes) "System volume";
  parameter Modelica.SIunits.Volume[:] tankSizes = 0.25 * cat(1, {0.125 for i in 1:25}, {0.25 for i in 26:50}, {0.50 for i in 51:75}, {1 for i in 76:100}) annotation(
    HideResult = true);
  parameter Real dailyExchange = 0.10;
  inner LibRAS.System system(T_ambient = 288.15, T_start = 288.15) annotation(
    Placement(visible = true, transformation(extent = {{138, 44}, {158, 64}}, rotation = 0)));
  LibRAS.Machines.ControlledPump pump(redeclare package Medium = Medium, m_flow_nominal = 7.5, p_a_nominal = system.p_ambient, p_b_nominal = system.p_ambient + 0.5e5) annotation(
    Placement(visible = true, transformation(origin = {60, 82}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  LibRAS.Sources.WaterExchange exchange(redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {88, 82}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  LibRAS.Pipes.Tee tee1(redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {120, 82}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  LibRAS.Sources.Boundary_pT boundary1(nPorts = 1, redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {148, 82}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  LibRAS.Pipes.StaticPipe pipe(diameter = 0.2, height_ab = 5, length = 10, redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {30, 82}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  LibRAS.Tanks.CSBR aerob1(redeclare package Medium = Medium, V = 1.75, energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, massDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, nPorts = 2, use_portsData = false) annotation(
    Placement(visible = true, transformation(origin = {90, -56}, extent = {{-10, 10}, {10, -10}}, rotation = 0)));
  LibRAS.Tanks.CSBR aerob2(redeclare package Medium = Medium, V = aerob1.V, energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, massDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, nPorts = 2, use_portsData = false) annotation(
    Placement(visible = true, transformation(origin = {64, -56}, extent = {{-10, 10}, {10, -10}}, rotation = 0)));
  LibRAS.Pipes.IdealParticleFilter filter(filterFactor = 0.9, redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {54, -4}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  LibRAS.Tanks.CSBR nitri1(redeclare package Medium = Medium, C_X_film_start(each displayUnit = "kg/m3") = (1 - system.eps_A) / (1 - system.eps_H) * system.C_X_film_start, V = aerob1.V, energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, massDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, nPorts = 2, nitrifying = true, use_portsData = false, use_m_S_in = true) annotation(
    Placement(visible = true, transformation(origin = {36, -56}, extent = {{-10, 10}, {10, -10}}, rotation = 0)));
  LibRAS.Tanks.CSBR nitri2(redeclare package Medium = Medium, C_X_film_start(each displayUnit = "kg/m3") = (1 - system.eps_A) / (1 - system.eps_H) * system.C_X_film_start, V = aerob1.V, energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, massDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, nPorts = 2, nitrifying = true, use_portsData = false) annotation(
    Placement(visible = true, transformation(origin = {11, -56}, extent = {{-10, 10}, {10, -10}}, rotation = 0)));
  LibRAS.Tanks.CSBR nitri3(redeclare package Medium = Medium, C_X_film_start(each displayUnit = "kg/m3") = (1 - system.eps_A) / (1 - system.eps_H) * system.C_X_film_start, V = aerob1.V, energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, massDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, nPorts = 3, nitrifying = true, use_portsData = false) annotation(
    Placement(visible = true, transformation(origin = {-14, -56}, extent = {{-10, 10}, {10, -10}}, rotation = 0)));
  Modelica.Blocks.Sources.Constant alkSetpoint(k = 2e-3) annotation(
    Placement(visible = true, transformation(origin = {13, -13}, extent = {{5, -5}, {-5, 5}}, rotation = 0)));
  LibRAS.Machines.AdditionController_S alkControl(index = Integer(Types.Species.S.Alk), K = 8 / 86400 * V_system, redeclare package Medium = Medium, u = fill(0, Medium.nC_S)) annotation(
    Placement(visible = true, transformation(origin = {0, -32}, extent = {{-6, -6}, {6, 6}}, rotation = 0)));
  LibRAS.Tanks.FishTank fishTank1(feedingDuration = 86400, feedingTimes = {0}, nPorts = 3, oxygenSetpoint = 9e-3, oxygenControl_Q = pump.m_flow_nominal * 1e-3, nTanks = 100, tankVolumes = tankSizes, fishDensity = 55, fish = Culture.Fish.AtlanticSalmon(), FCR = 0.9, gradingTime = 3, replaceable LibRAS.Culture.simpleCulture culture) annotation(
    Placement(visible = true, transformation(origin = {-50, 40}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  LibRAS.Tanks.CST degas1(redeclare package Medium = Medium, V = 0.7, energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, massDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, nPorts = 3, use_portsData = false) annotation(
    Placement(visible = true, transformation(origin = {90, 6}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  LibRAS.Pipes.Tee tee2(redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {-50, -4}, extent = {{10, 10}, {-10, -10}}, rotation = 90)));
  LibRAS.Machines.ControlledPump recyclePump(redeclare package Medium = Medium, m_flow_nominal = pump.m_flow_nominal * recycleRatio.k, p_a_nominal = system.p_ambient, p_b_nominal = system.p_ambient + 0.5e5, use_m_flow_set = true) annotation(
    Placement(visible = true, transformation(origin = {-36, -46}, extent = {{8, -8}, {-8, 8}}, rotation = 0)));
  LibRAS.Sensors.MassFlowRate massFlowRate1(redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {110, -4}, extent = {{-10, 10}, {10, -10}}, rotation = 0)));
  Modelica.Blocks.Math.Gain recycleRatio(k = 0.3) annotation(
    Placement(visible = true, transformation(origin = {-22, -22}, extent = {{6, -6}, {-6, 6}}, rotation = 0)));
equation
  connect(nitri3.ports[2], recyclePump.port_a) annotation(
    Line(points = {{-16, -46}, {-28, -46}, {-28, -46}, {-28, -46}}, color = {0, 127, 255}));
  connect(nitri3.ports[3], alkControl.port_a) annotation(
    Line(points = {{-16, -46}, {-16, -46}, {-16, -42}, {0, -42}, {0, -38}, {0, -38}}, color = {0, 127, 255}));
  connect(nitri2.ports[2], nitri3.ports[1]) annotation(
    Line(points = {{11, -46}, {-16, -46}}, color = {0, 127, 255}));
  connect(nitri1.ports[2], nitri2.ports[1]) annotation(
    Line(points = {{36, -46}, {9, -46}}, color = {0, 127, 255}));
  connect(alkControl.y, nitri1.m_S_in) annotation(
    Line(points = {{8, -32}, {24, -32}, {24, -72}, {30, -72}, {30, -66}}, color = {0, 0, 127}));
  connect(aerob2.ports[2], nitri1.ports[1]) annotation(
    Line(points = {{64, -46}, {34, -46}}, color = {0, 127, 255}));
  connect(massFlowRate1.port_b, tee1.port_3) annotation(
    Line(points = {{120, -6}, {120, 72}}, color = {0, 127, 255}));
  connect(degas1.ports[3], massFlowRate1.port_a) annotation(
    Line(points = {{90, -4}, {95, -4}, {95, -6}, {100, -6}}, color = {0, 127, 255}));
  connect(massFlowRate1.m_flow, recycleRatio.u) annotation(
    Line(points = {{110, -17}, {110, -22}, {-15, -22}}, color = {0, 0, 127}));
  connect(alkSetpoint.y, alkControl.setpoint) annotation(
    Line(points = {{7.5, -13}, {0, -13}, {0, -24}}, color = {0, 0, 127}));
  connect(recycleRatio.y, recyclePump.m_flow_set) annotation(
    Line(points = {{-29, -22}, {-32, -22}, {-32, -39}}, color = {0, 0, 127}));
  connect(aerob1.ports[2], aerob2.ports[1]) annotation(
    Line(points = {{90, -46}, {66, -46}, {66, -46}, {64, -46}}, color = {0, 127, 255}));
  connect(recyclePump.port_b, tee2.port_2) annotation(
    Line(points = {{-44, -46}, {-50, -46}, {-50, -14}}, color = {0, 127, 255}));
  connect(tee2.port_3, filter.port_a) annotation(
    Line(points = {{-40, -4}, {44, -4}, {44, -4}, {44, -4}}, color = {0, 127, 255}));
  connect(fishTank1.ports[2], tee2.port_1) annotation(
    Line(points = {{-50, 30}, {-50, 6}}, color = {0, 127, 255}));
  connect(filter.port_b, degas1.ports[1]) annotation(
    Line(points = {{64, -4}, {90, -4}}, color = {0, 127, 255}));
  connect(degas1.ports[2], aerob1.ports[1]) annotation(
    Line(points = {{90, -4}, {90, -46}}, color = {0, 127, 255}));
  connect(pipe.port_b, fishTank1.ports[1]) annotation(
    Line(points = {{20, 82}, {-4, 82}, {-4, 26}, {-50, 26}, {-50, 30}}, color = {0, 127, 255}));
  exchange.makeupRate = dailyExchange * V_system * 1000 / 86400 / pump.m_flow_nominal;
  connect(pump.port_b, pipe.port_a) annotation(
    Line(points = {{50, 82}, {40, 82}}, color = {0, 127, 255}));
  connect(exchange.port_b, pump.port_a) annotation(
    Line(points = {{78, 82}, {70, 82}}, color = {0, 127, 255}));
  connect(tee1.port_2, exchange.port_a) annotation(
    Line(points = {{110, 82}, {98, 82}}, color = {0, 127, 255}));
  connect(boundary1.ports[1], tee1.port_1) annotation(
    Line(points = {{138, 82}, {130, 82}}, color = {0, 127, 255}));
  annotation(
    experiment(StopTime = 1.0368e+07, StartTime = 0, Tolerance = 0.0001, Interval = 3600),
    uses(Modelica(version = "3.2.2")),
    Placement(visible = true, transformation(origin = {-56, 58}, extent = {{-14, -14}, {14, 14}}, rotation = 0)),
    Diagram(coordinateSystem(extent = {{-200, -100}, {200, 100}}, initialScale = 0.1)),
    Icon(coordinateSystem(extent = {{-100, -100}, {100, 100}})),
    version = "",
    __OpenModelica_commandLineOptions = "");
end Recycle;