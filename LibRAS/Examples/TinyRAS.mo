within LibRAS.Examples;

model TinyRAS
  extends Modelica.Icons.Example;
  import convert = Modelica.SIunits.Conversions;
  import Modelica.SIunits.Conversions.from_bar;
  type MassFlowRate = Modelica.SIunits.MassFlowRate(displayUnit = "g/d");
  import LibRAS.Types.Species.S;
  import LibRAS.Types.Species.X;
  replaceable package Medium = LibRAS.Media.WasteWater "Medium in the component";
  parameter Modelica.SIunits.Time HRT (displayUnit = "min") = 1200 "Fish tank HRT in seconds";
  parameter Modelica.SIunits.Volume V_system = MBBR1.V + MBBR2.V + sum(fishTank1.tankVolumes) "System volume - used to set controller gains and calculate water exchange";
  parameter Real dailyExchange = 0.100;
  inner LibRAS.System system(T_ambient = 288.15, T_start = 288.15) annotation(
    Placement(visible = true, transformation(extent = {{138, 44}, {158, 64}}, rotation = 0)));
  LibRAS.Machines.ControlledPump pump(redeclare package Medium = Medium, m_flow_nominal = 1000*sum(fishTank1.tankVolumes)/HRT, p_a_nominal = system.p_ambient, p_b_nominal = system.p_ambient + 0.5e5) annotation(
    Placement(visible = true, transformation(origin = {60, 82}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  LibRAS.Sources.WaterExchange exchange(redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {88, 82}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  LibRAS.Pipes.Tee tee1(redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {120, 82}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  LibRAS.Sources.Boundary_pT boundary1(nPorts = 1, redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {148, 82}, extent = {{10, -10}, {-10, 10}}, rotation = 0)));
  LibRAS.Pipes.StaticPipe pipe(diameter = 0.2, height_ab = 5, length = 10, redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {30, 82}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
  LibRAS.Pipes.IdealParticleFilter filter(filterFactor = 0.9, redeclare package Medium = Medium) annotation(
    Placement(visible = true, transformation(origin = {-4, 52}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  LibRAS.Tanks.CSBR MBBR2(redeclare package Medium = Medium, C_X_film_start(each displayUnit = "kg/m3"), V = 20, energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, massDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, nPorts = 3, nitrifying = true, use_m_S_in = true, use_portsData = false) annotation(
    Placement(visible = true, transformation(origin = {118, 36}, extent = {{-10, 10}, {10, -10}}, rotation = 0)));
  Modelica.Blocks.Sources.Constant alkSetpoint(k = 2e-3) annotation(
    Placement(visible = true, transformation(origin = {117, -1}, extent = {{5, -5}, {-5, 5}}, rotation = 0)));
  LibRAS.Tanks.FishTank fishTank1(replaceable LibRAS.Culture.SSCulture_V culture, FCR = 0.9, feedingDuration = 86400, feedingTimes = {0}, fishDensity = 55, gradingTime = 30, nPorts = 2, nTanks = 9, oxygenControl_Q = pump.m_flow_nominal * 1e-3, oxygenSetpoint = 9e-3, tankVolumes = {10 for i in 1:fishTank1.nTanks}) annotation(
    Placement(visible = true, transformation(origin = {-18, 82}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  LibRAS.Machines.AdditionController_S alkControl(redeclare package Medium = Medium, K = 8 / 86400 * V_system, index = Integer(Types.Species.S.Alk), u = fill(0, Medium.nC_S)) annotation(
    Placement(visible = true, transformation(origin = {102, 12}, extent = {{-6, 6}, {6, -6}}, rotation = 0)));
  LibRAS.Tanks.CSBR MBBR1(C_X_film_start(each displayUnit = "kg/m3"), V = 20, energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, massDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, nPorts = 2, nitrifying = true, use_m_S_in = false, use_portsData = false) annotation(
    Placement(visible = true, transformation(origin = {54, 42}, extent = {{-10, 10}, {10, -10}}, rotation = 0)));
equation
  connect(MBBR1.ports[2], MBBR2.ports[1]) annotation(
    Line(points = {{54, 52}, {118, 52}, {118, 46}, {118, 46}}, color = {0, 127, 255}, thickness = 0.5));
  connect(filter.port_b, MBBR1.ports[1]) annotation(
    Line(points = {{6, 52}, {52, 52}, {52, 52}, {54, 52}}));
  connect(tee1.port_3, MBBR2.ports[2]) annotation(
    Line(points = {{120, 72}, {120, 72}, {120, 46}, {118, 46}}, color = {0, 127, 255}));
  connect(MBBR2.ports[3], alkControl.port_a) annotation(
    Line(points = {{120, 46}, {104, 46}, {104, 18}, {104, 18}}, color = {0, 127, 255}, thickness = 0.5));
  connect(alkControl.y, MBBR2.m_S_in) annotation(
    Line(points = {{109.2, 12}, {111.15, 12}, {111.15, 12}, {115.1, 12}, {115.1, 12}, {117, 12}, {117, 19}, {115, 19}, {115, 26}}, color = {0, 0, 127}, thickness = 0.5));
  connect(alkSetpoint.y, alkControl.setpoint) annotation(
    Line(points = {{111.5, -1}, {102, -1}, {102, 5}}, color = {0, 0, 127}));
  connect(fishTank1.ports[2], filter.port_a) annotation(
    Line(points = {{-18, 72}, {-18, 54}, {-14, 54}}, color = {0, 127, 255}));
  connect(pipe.port_b, fishTank1.ports[1]) annotation(
    Line(points = {{20, 82}, {2, 82}, {2, 68}, {-16, 68}, {-16, 72}, {-18, 72}}, color = {0, 127, 255}));
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
    Diagram(coordinateSystem(extent = {{-100, -50}, {200, 100}})),
    Icon(coordinateSystem(extent = {{-100, -50}, {200, 100}})),
    version = "",
    __OpenModelica_commandLineOptions = "");
end TinyRAS;