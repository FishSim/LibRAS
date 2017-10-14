within LibRAS.Examples;

model Bypass
  extends Modelica.Icons.Example;
  import Modelica.SIunits.Conversions.from_bar;
  type MassFlowRate = Modelica.SIunits.MassFlowRate(displayUnit = "g/d");
  import LibRAS.Types.Species.S;
  import LibRAS.Types.Species.X;
  replaceable package Medium = LibRAS.Media.WasteWater "Medium in the component";
  parameter Modelica.SIunits.Volume V_system = aerob1.V + aerob2.V + nitri1.V + nitri2.V + nitri3.V + degas1.V + sum(fishTank1.tankVolumes) "System volume - used to set controller gains";
  parameter Modelica.SIunits.Volume[:] tankSizes = 0.25 * cat(1, {0.125 for i in 1:25}, {0.25 for i in 26:50}, {0.50 for i in 51:75}, {1 for i in 76:100}) annotation(
    HideResult = true);
  parameter Real dailyExchange = 0.100;
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
  LibRAS.Tanks.CSBR aerob1(redeclare package Medium = Medium, KLa = 500 / 86400, V = 1.75, energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, massDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, nPorts = 2, use_portsData = false) annotation(
    Placement(visible = true, transformation(origin = {10, -40}, extent = {{-10, 10}, {10, -10}}, rotation = 0)));
  LibRAS.Tanks.CSBR aerob2(redeclare package Medium = Medium, KLa = 500 / 86400, V = aerob1.V, energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, massDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, nPorts = 2, use_portsData = false) annotation(
    Placement(visible = true, transformation(origin = {40, -40}, extent = {{-10, 10}, {10, -10}}, rotation = 0)));
  LibRAS.Pipes.IdealParticleFilter filter(filterFactor = 0.9, redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {-18, 12}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  LibRAS.Tanks.CSBR nitri1(redeclare package Medium = Medium, C_X_film_start(displayUnit = "kg/m3"), V = aerob1.V, energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, massDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, nPorts = 2, nitrifying = true, use_m_S_in = true, use_portsData = false) annotation(
    Placement(visible = true, transformation(origin = {70, -40}, extent = {{-10, 10}, {10, -10}}, rotation = 0)));
  LibRAS.Tanks.CSBR nitri2(redeclare package Medium = Medium, C_X_film_start(displayUnit = "kg/m3"), V = aerob1.V, energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, massDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, nPorts = 2, nitrifying = true, use_portsData = false) annotation(
    Placement(visible = true, transformation(origin = {95, -40}, extent = {{-10, 10}, {10, -10}}, rotation = 0)));
  LibRAS.Tanks.CSBR nitri3(redeclare package Medium = Medium, C_X_film_start(displayUnit = "kg/m3"), V = aerob1.V, energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, massDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, nPorts = 3, nitrifying = true, use_portsData = false) annotation(
    Placement(visible = true, transformation(origin = {120, -40}, extent = {{-10, 10}, {10, -10}}, rotation = 0)));
  Modelica.Blocks.Sources.Constant alkSetpoint(k = 2e-3) annotation(
    Placement(visible = true, transformation(origin = {155, -79}, extent = {{5, -5}, {-5, 5}}, rotation = 0)));
  LibRAS.Tanks.FishTank fishTank1(replaceable LibRAS.Culture.simpleCulture culture, FCR = 0.9, feedingDuration = 86400, feedingTimes = {0}, fishDensity = 55, gradingTime = 3, nPorts = 2, nTanks = 100, oxygenControl_Q = pump.m_flow_nominal * 1e-3, oxygenSetpoint = 9e-3, tankVolumes = tankSizes) annotation(
    Placement(visible = true, transformation(origin = {-18, 40}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  LibRAS.Machines.AdditionController_S alkControl(redeclare package Medium = Medium, K = 8 / 86400 * V_system, index = Integer(Types.Species.S.Alk), u = fill(0, Medium.nC_S)) annotation(
    Placement(visible = true, transformation(origin = {136, -64}, extent = {{6, 6}, {-6, -6}}, rotation = 0)));
  LibRAS.Tanks.CST degas1(redeclare package Medium = Medium, V = 0.7, energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, massDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, nPorts = 3, use_portsData = false) annotation(
    Placement(visible = true, transformation(origin = {104, 20}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  LibRAS.Machines.ControlledPump pump1(redeclare package Medium = Medium, m_flow_nominal = 4, p_a_nominal = system.p_ambient, p_b_nominal = system.p_ambient + 0.5e5) annotation(
    Placement(visible = true, transformation(origin = {37, -9}, extent = {{-9, -9}, {9, 9}}, rotation = 0)));
equation
  connect(pump1.port_a, filter.port_b) annotation(
    Line(points = {{28, -11}, {-18, -11}, {-18, 2}}, color = {0, 127, 255}));
  connect(pump1.port_b, degas1.ports[3]) annotation(
    Line(points = {{46, -11}, {102, -11}, {102, 10}, {104, 10}}, color = {0, 127, 255}));
  connect(filter.port_b, aerob1.ports[1]) annotation(
    Line(points = {{-18, 2}, {-18, 2}, {-18, -30}, {10, -30}, {10, -30}}, color = {0, 127, 255}));
  connect(fishTank1.ports[2], filter.port_a) annotation(
    Line(points = {{-18, 30}, {-18, 22}}, color = {0, 127, 255}));
  connect(degas1.ports[2], tee1.port_3) annotation(
    Line(points = {{104, 10}, {120, 10}, {120, 72}}));
  connect(nitri3.ports[2], degas1.ports[1]) annotation(
    Line(points = {{120, -30}, {120, -10}, {104, -10}, {104, 10}}, color = {0, 127, 255}));
  connect(nitri2.ports[2], nitri3.ports[1]) annotation(
    Line(points = {{96, -30}, {118, -30}, {118, -30}, {120, -30}}, color = {0, 127, 255}));
  connect(nitri1.ports[2], nitri2.ports[1]) annotation(
    Line(points = {{70, -30}, {92, -30}, {92, -30}, {96, -30}}, color = {0, 127, 255}));
  connect(alkControl.y, nitri1.m_S_in) annotation(
    Line(points = {{129, -64}, {66, -64}, {66, -50}}, color = {0, 0, 127}));
  connect(aerob2.ports[2], nitri1.ports[1]) annotation(
    Line(points = {{40, -30}, {70, -30}}, color = {0, 127, 255}));
  connect(aerob1.ports[2], aerob2.ports[1]) annotation(
    Line(points = {{10, -30}, {40, -30}}, color = {0, 127, 255}));
  connect(pipe.port_b, fishTank1.ports[1]) annotation(
    Line(points = {{20, 82}, {-4, 82}, {-4, 26}, {-18, 26}, {-18, 30}}, color = {0, 127, 255}));
  exchange.makeupRate = dailyExchange * V_system * 1000 / 86400 / pump.m_flow_nominal;
  connect(nitri3.ports[3], alkControl.port_a) annotation(
    Line(points = {{120, -30}, {122, -30}, {122, -24}, {136, -24}, {136, -58}}, color = {0, 127, 255}));
  connect(alkSetpoint.y, alkControl.setpoint) annotation(
    Line(points = {{149.5, -79}, {136, -79}, {136, -71}}, color = {0, 0, 127}));
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
end Bypass;