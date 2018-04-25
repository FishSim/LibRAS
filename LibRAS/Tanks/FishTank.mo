within LibRAS.Tanks;

model FishTank
  replaceable package Medium = LibRAS.Media.WasteWater "Medium in the component";
  import SI = Modelica.SIunits;
  import LibRAS.Types.Species.S;
  import LibRAS.Culture.*;
  import Modelica.SIunits.Conversions.from_day;
  import Modelica.SIunits.Conversions.from_hour;
  import Modelica.SIunits.Conversions.from_minute;
  // DESIGN VARIABLES
  //  parameter SI.Volume V = 9 "Fish tank volume" annotation(Evaluate=true, Dialog(tab="General", group="Design"));
  parameter Integer nTanks = 9 annotation(
    Dialog(tab = "General", group = "Design"));
  parameter SI.Volume[nTanks] tankVolumes = fill(1, nTanks) "Vector of fish basin volumes" annotation(
    Dialog(tab = "General", group = "Design"),
    HideResult = true);
  // FEED AND FISH DATA
  parameter Feed.FeedData feed = Feed.DefaultFeed() "FeedData record" annotation(
    choicesAllMatching = true,
    Dialog(tab = "General", group = "Culture"));
  parameter Fish.FishData fish = Fish.RainbowTrout() "FishData record" annotation(
    choicesAllMatching = true,
    Dialog(tab = "General", group = "Culture"));
  //  parameter Waste.WasteData waste = Waste.WasteData(fish=fish, feed=feed, loss=loss) "WasteData record" annotation(choicesAllMatching=true, Dialog(tab="General", group="Culture"));
  parameter Integer gradingTime(unit = "d", min = 0) = 30 "Time between gradings in days" annotation(
    Dialog(tab = "General", group = "Culture"));
  parameter SI.Density fishDensity(displayUnit = "kg/m3") = 70 "Maximum fish density in kg/m3" annotation(
    Dialog(tab = "General", group = "Culture"));
  // GROWTH AND FEEDING
  parameter SI.Temp_C T = 15 "Farming temperature" annotation(
    Dialog(tab = "General", group = "Culture"));
  parameter SI.Time[:] feedingTimes = from_hour({6, 18}) "Feeding times in seconds after beginning of each day (00:00)" annotation(
    Dialog(tab = "General", group = "Culture"));
  parameter SI.Time feedingDuration = from_minute(15) "Length of feeding period in seconds" annotation(
    Dialog(tab = "General", group = "Culture"));
  parameter Real FCR = 1.1 "kg feed/kg fish growth" annotation(
    Dialog(tab = "General", group = "Culture"));
  parameter Real loss = 0.1 "Food loss factor" annotation(
    Dialog(tab = "General", group = "Culture"));
  // Oxygen control
  parameter Real oxygenControl_Q "Throughflow setpoint for controller tuning" annotation(
    Evaluate = true,
    Dialog(tab = "General", group = "Oxygen control"));
  parameter Real oxygenControl_K = 10 * 0.1 * oxygenControl_Q / ((Utilities.oxygenSaturation(SI.Conversions.from_degC(T)) - 8e-3) * sum(tankVolumes)) "Proportional gain of oxygen PI controller" annotation(
    Evaluate = true,
    Dialog(tab = "General", group = "Oxygen control"));
  parameter Real oxygenControl_Ti = oxygenControl_K * sum(tankVolumes) ^ 2 * (Utilities.oxygenSaturation(SI.Conversions.from_degC(T)) - 8e-3) / oxygenControl_Q ^ 2 "Integral time for oyxgen PI controller" annotation(
    Evaluate = true,
    Dialog(tab = "General", group = "Oxygen control"));
  parameter Real oxygenControl_maxKLa = 0.20 "Maximum KLa value in 1/s" annotation(
    Evaluate = true,
    Dialog(tab = "General", group = "Oxygen control"));
  parameter Real oxygenControl_minKLa = 0 "Minimum KLa value in 1/s" annotation(
    Evaluate = true,
    Dialog(tab = "General", group = "Oxygen control"));
  outer LibRAS.System system annotation(
    Placement(visible = true, transformation(extent = {{20, 60}, {40, 80}}, rotation = 0)));
  parameter Integer nPorts = 0 "Number of ports" annotation(
    Evaluate = true,
    Dialog(connectorSizing = true, tab = "General", group = "Ports"));
  LibRAS.Interfaces.VesselWasteFluidPorts_b ports[nPorts](redeclare each package Medium = Medium) "Fluid inlets and outlets" annotation(
    Placement(visible = true, transformation(origin = {48, 42}, extent = {{-40, -10}, {40, 10}}, rotation = -90), iconTransformation(extent = {{-40, -110}, {40, -90}}, rotation = 0)));
  LibRAS.Tanks.CST fishtank(redeclare package Medium = Medium, V = sum(tankVolumes), fluidVolume = sum(culture.Vw), energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState, massDynamics = Modelica.Fluid.Types.Dynamics.FixedInitial, nPorts = nPorts, use_KLa_in = true, use_m_S_in = true, use_m_X_in = true, use_portsData = false, use_HeatTransfer = true) annotation(
    Placement(visible = true, transformation(origin = {0, 44}, extent = {{-10, 10}, {10, -10}}, rotation = -90)));
  Modelica.Blocks.Continuous.LimPID oxygenPI(Ti(displayUnit = "s") = oxygenControl_Ti, controllerType = Modelica.Blocks.Types.SimpleController.PI, k = oxygenControl_K, limitsAtInit = false, yMax = oxygenControl_maxKLa, yMin = oxygenControl_minKLa) annotation(
    Placement(visible = true, transformation(origin = {-24, 20}, extent = {{-6, -6}, {6, 6}}, rotation = 0)));
  Modelica.Blocks.Interfaces.RealInput oxygenSetpoint annotation(
    Placement(visible = true, transformation(origin = {-100, 20}, extent = {{-8, -8}, {8, 8}}, rotation = 0), iconTransformation(origin = {-120, 0}, extent = {{-20, -20}, {20, 20}}, rotation = 0)));
  replaceable LibRAS.Culture.SSCulture_V culture(nTanks = nTanks, tankVolumes = tankVolumes, fish = fish, feed = feed, gradingTime = gradingTime, fishDensity = fishDensity, feedingTimes = feedingTimes, feedingDuration = feedingDuration, T = T, FCR = FCR, loss = loss) annotation(
    Placement(visible = true, transformation(origin = {-50, 44}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  output SI.Mass mFish "Total mass of fish";
  output SI.Mass meanBW "Mean fish body weight";
  output SI.Density avgDensity = mFish/sum(tankVolumes);
  Modelica.Thermal.HeatTransfer.Sources.FixedTemperature fixedTemperature1(T = SI.Conversions.from_degC(T)) annotation(
    Placement(visible = true, transformation(origin = {-20, 80}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));

equation
  connect(fixedTemperature1.port, fishtank.heatPort) annotation(
    Line(points = {{-10, 80}, {0, 80}, {0, 54}, {0, 54}}, color = {191, 0, 0}));
  mFish = sum(culture.m_fish);
  meanBW = mFish / sum(culture.n);
  connect(fishtank.ports, ports) annotation(
    Line(points = {{10, 44}, {48, 44}, {48, 42}}, color = {0, 127, 255}));
  connect(oxygenSetpoint, oxygenPI.u_s) annotation(
    Line(points = {{-100, 20}, {-32, 20}}, color = {0, 0, 127}));
  connect(oxygenPI.y, fishtank.KLa_in) annotation(
    Line(points = {{-18, 20}, {0, 20}, {0, 34}, {0, 34}}, color = {0, 0, 127}));
  connect(fishtank.C_S[Integer(S.O)], oxygenPI.u_m);
  connect(culture.m_X_output, fishtank.m_X_in) annotation(
    Line(points = {{-38, 40}, {-10, 40}, {-10, 40}, {-10, 40}}, color = {0, 0, 127}));
  connect(culture.m_S_output, fishtank.m_S_in) annotation(
    Line(points = {{-38, 48}, {-12, 48}, {-12, 48}, {-10, 48}}, color = {0, 0, 127}));
  annotation(
    Icon(coordinateSystem(initialScale = 0.2), graphics = {Rectangle(lineColor = {255, 255, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.VerticalCylinder, extent = {{-100, -100}, {100, 100}}), Rectangle(fillColor = {85, 170, 255}, fillPattern = FillPattern.VerticalCylinder, extent = {{-100, -100}, {100, 0}}), Text(lineColor = {0, 0, 255}, extent = {{-94, 90}, {95, 60}}, textString = "%name"), Line(points = {{-100, 100}, {-100, -100}, {100, -100}, {100, 100}})}),
    experiment(StartTime = 0, StopTime = 2.592e+06, Tolerance = 0.0001, Interval = 3600));
end FishTank;