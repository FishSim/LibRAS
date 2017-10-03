within LibRAS.Tanks;
model OpenTank "Tank with inlet/outlet ports and with inlet ports at the top"
  import SI = Modelica.SIunits;
  import Modelica.Constants;
  import Modelica.Fluid.Fittings.BaseClasses.lossConstant_D_zeta;
  import Modelica.Fluid.Utilities.regRoot2;
  import Modelica.Fluid.Vessels.BaseClasses.VesselPortsData;
  SI.Length level(stateSelect = StateSelect.prefer, start = level_start) "Fluid level in the tank";
  //Tank geometry
  parameter SI.Height height "Maximum level of tank before it overflows";
  parameter SI.Area crossArea "Area of tank";
  parameter SI.Volume V0 = 0 "Volume of the liquid when level = 0";
  //Ambient
  parameter Medium.AbsolutePressure p_ambient = system.p_ambient "Tank surface pressure" annotation(Dialog(tab = "Assumptions", group = "Ambient"));
  parameter Medium.Temperature T_ambient = system.T_ambient "Tank surface Temperature" annotation(Dialog(tab = "Assumptions", group = "Ambient"));
  //Initialization
  parameter SI.Height level_start(min = 0) = 0.5 * height "Start value of tank level" annotation(Dialog(tab = "Initialization"));
  //Mass and energy balance
  extends Modelica.Fluid.Interfaces.PartialLumpedVolume(final fluidVolume = V, final initialize_p = false, final p_start = p_ambient);
  //Port definitions
  parameter Integer nTopPorts = 0 "Number of inlet ports above height (>= 1)" annotation(Dialog(connectorSizing = true));
  Interfaces.VesselWasteFluidPorts_a topPorts[nTopPorts](redeclare package Medium = Medium, m_flow(each start = 0, each min = 0)) "Inlet ports over height at top of tank (fluid flows only from the port in to the tank)" annotation(Placement(transformation(extent = {{-20, 0}, {20, 10}}, origin = {0, 100})));
  parameter Integer nPorts = 0 "Number of inlet/outlet ports (on bottom and on the side)" annotation(Dialog(connectorSizing = true));
  parameter Modelica.Fluid.Vessels.BaseClasses.VesselPortsData portsData[nPorts] "Data of inlet/outlet ports at side and bottom of tank";
  Interfaces.VesselWasteFluidPorts_b ports[nPorts](redeclare package Medium = Medium, m_flow(each start = 0)) "inlet/outlet ports at bottom or side of tank (fluid flows in to or out of port; a port might be above the fluid level)" annotation(Placement(transformation(extent = {{-20, 0}, {20, -10}}, origin = {0, -100})));
  // Heat transfer through boundary
  parameter Boolean use_HeatTransfer = false "= true to use the HeatTransfer model" annotation(Dialog(tab = "Assumptions", group = "Heat transfer"));
  replaceable model HeatTransfer = Modelica.Fluid.Vessels.BaseClasses.HeatTransfer.IdealHeatTransfer constrainedby Modelica.Fluid.Vessels.BaseClasses.HeatTransfer.PartialVesselHeatTransfer "Wall heat transfer" annotation(Dialog(tab = "Assumptions", group = "Heat transfer", enable = use_HeatTransfer), choicesAllMatching = true);
  HeatTransfer heatTransfer(redeclare final package Medium = Medium, final n = 1, final states = {medium.state}, surfaceAreas = {crossArea + 2 * sqrt(crossArea * Modelica.Constants.pi) * level}, final use_k = use_HeatTransfer) annotation(Placement(transformation(extent = {{-10, -10}, {30, 30}}, rotation = 90, origin = {-50, -10})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPort if use_HeatTransfer annotation(Placement(transformation(extent = {{-110, -10}, {-90, 10}})));
  // Advanced
  parameter Real hysteresisFactor(min = 0) = 0.1 "Hysteresis for empty pipe = diameter*hysteresisFactor" annotation(Dialog(tab = "Advanced", group = "Port properties"));
  parameter Boolean stiffCharacteristicForEmptyPort = false "=true, if steep pressure loss characteristic for empty pipe port" annotation(Dialog(tab = "Advanced", group = "Port properties"), Evaluate = true);
  parameter Real zetaLarge(min = 0) = 1e5 "Large pressure loss factor if mass flows out of empty pipe port" annotation(Dialog(tab = "Advanced", group = "Port properties", enable = stiffCharacteristicForEmptyPort));
  parameter SI.MassFlowRate m_flow_small(min = 0) = system.m_flow_small "Regularization range at zero mass flow rate" annotation(Dialog(tab = "Advanced", group = "Port properties", enable = stiffCharacteristicForEmptyPort));
  // Tank properties
  SI.Volume V(stateSelect = StateSelect.never) "Actual tank volume";
  Medium.EnthalpyFlowRate H_flow_top[nTopPorts] "Enthalpy flow rates from the top ports in to the tank";
  Medium.EnthalpyFlowRate port_b_H_flow_bottom[nPorts] "Enthalpy flow rates from the bottom ports in to the tank";
  Medium.MassFlowRate mXi_flow_top[nTopPorts, Medium.nXi] "Substance mass flow rates from the top ports into the tank";
  Medium.MassFlowRate port_b_mXi_flow_bottom[nPorts, Medium.nXi] "Substance mass flow rates from the bottom ports into the tank";
  Medium.MassFlowRate mC_flow_top[nTopPorts, Medium.nC] "Trace substance mass flow rates from the top ports into the tank";
  Medium.MassFlowRate port_b_mC_flow_bottom[nPorts, Medium.nC] "Trace substance mass flow rates from the bottom ports into the tank";
protected
  SI.Area bottomArea[nPorts];
  SI.Diameter ports_emptyPipeHysteresis[nPorts];
  SI.Length levelAbovePort[nPorts] "Height of fluid over bottom ports";
  Boolean ports_m_flow_out[nPorts](each start = true, each fixed = true);
  Boolean aboveLevel[nPorts] "= true, if level >= ports[i].height";
  Real zetas_out[nPorts];
  Modelica.Blocks.Interfaces.RealInput portsData_diameter[nPorts] = portsData.diameter if nPorts > 0;
  Modelica.Blocks.Interfaces.RealInput portsData_diameter2[nPorts];
  Modelica.Blocks.Interfaces.RealInput portsData_height[nPorts] = portsData.height if nPorts > 0;
  Modelica.Blocks.Interfaces.RealInput portsData_height2[nPorts];
equation
  assert(level <= height, "Tank starts to overflow (level = height = " + String(level) + ")");
  assert(m >= 0, "Mass in tank is zero");
// Compute constant data
  connect(portsData_diameter, portsData_diameter2);
  connect(portsData_height, portsData_height2);
  for i in 1:nPorts loop
    bottomArea[i] = Constants.pi * (portsData_diameter2[i] / 2) ^ 2;
    ports_emptyPipeHysteresis[i] = portsData_diameter2[i] * hysteresisFactor;
  end for;
// Only one connection allowed to a port to avoid unwanted ideal mixing
/*
for i in 1:nTopPorts loop
assert(cardinality(topPorts[i]) <= 1,"
topPorts[" + String(i) + "] of volume can at most be connected to one component.
If two or more connections are present, ideal mixing takes
place with these connections which is usually not the intention
of the modeller.
");
end for;

for i in 1:nPorts loop
assert(cardinality(ports[i]) <= 1,"
ports[" + String(i) + "] of volume can at most be connected to one component.
If two or more connections are present, ideal mixing takes
place with these connections which is usually not the intention
of the modeller.
");
end for;
*/
// Total quantities
  medium.p = p_ambient;
  V = crossArea * level + V0 "Volume of fluid";
// Mass balances
  mb_flow = sum(topPorts.m_flow) + sum(ports.m_flow);
  for i in 1:Medium.nXi loop
    mbXi_flow[i] = sum(mXi_flow_top[:, i]) + sum(port_b_mXi_flow_bottom[:, i]);
  end for;
  for i in 1:Medium.nC loop
    mbC_flow[i] = sum(mC_flow_top[:, i]) + sum(port_b_mC_flow_bottom[:, i]);
  end for;
// Energy balance
  Hb_flow = sum(H_flow_top) + sum(port_b_H_flow_bottom);
  Qb_flow = heatTransfer.Q_flows[1];
  if Medium.singleState or energyDynamics == Modelica.Fluid.Types.Dynamics.SteadyState then
    Wb_flow = 0 "Mechanical work is neglected, since also neglected in medium model (otherwise unphysical small temperature change, if tank level changes)";
  else
    Wb_flow = -p_ambient * der(V);
  end if;
// Properties at top ports
  for i in 1:nTopPorts loop
// It is assumed that fluid flows only from one of the top ports in to the tank and never vice versa
    H_flow_top[i] = topPorts[i].m_flow * actualStream(topPorts[i].h_outflow);
    mXi_flow_top[i, :] = topPorts[i].m_flow * actualStream(topPorts[i].Xi_outflow);
    mC_flow_top[i, :] = topPorts[i].m_flow * actualStream(topPorts[i].C_outflow);
    topPorts[i].p = p_ambient;
    topPorts[i].h_outflow = h_start;
    topPorts[i].Xi_outflow = X_start[1:Medium.nXi];
    topPorts[i].C_outflow = C_start;
/*
  assert(topPorts[i].m_flow > -1, "Mass flows out of tank via topPorts[" + String(i) + "]\n" +
                                    "This indicates a wrong model");
*/
  end for;
// Properties at bottom ports
  for i in 1:nPorts loop
    port_b_H_flow_bottom[i] = ports[i].m_flow * actualStream(ports[i].h_outflow);
    port_b_mXi_flow_bottom[i, :] = ports[i].m_flow * actualStream(ports[i].Xi_outflow);
    port_b_mC_flow_bottom[i, :] = ports[i].m_flow * actualStream(ports[i].C_outflow);
    aboveLevel[i] = level >= portsData_height2[i] + ports_emptyPipeHysteresis[i] or pre(aboveLevel[i]) and level >= portsData_height2[i] - ports_emptyPipeHysteresis[i];
    levelAbovePort[i] = if aboveLevel[i] then level - portsData_height2[i] else 0;
    ports[i].h_outflow = medium.h;
    ports[i].Xi_outflow = medium.Xi;
    ports[i].C_outflow = C;
    if stiffCharacteristicForEmptyPort then
// If port is above fluid level, use large zeta if fluid flows out of port (= small mass flow rate)
      zetas_out[i] = 1 + (if aboveLevel[i] then 0 else zetaLarge);
      ports[i].p = p_ambient + levelAbovePort[i] * system.g * medium.d + Modelica.Fluid.Utilities.regSquare2(ports[i].m_flow, m_flow_small, lossConstant_D_zeta(portsData_diameter2[i], 0.01) / medium.d, lossConstant_D_zeta(portsData_diameter2[i], zetas_out[i]) / medium.d);
      ports_m_flow_out[i] = false;
    else
// Handling according to Remelhe/Poschlad
      ports_m_flow_out[i] = pre(ports_m_flow_out[i]) and not ports[i].p > p_ambient or ports[i].m_flow < (-1e-6);
      if aboveLevel[i] then
        ports[i].p = p_ambient + levelAbovePort[i] * system.g * medium.d - smooth(2, noEvent(if ports[i].m_flow < 0 then ports[i].m_flow ^ 2 / (2 * medium.d * bottomArea[i] ^ 2) else 0));
      else
        if pre(ports_m_flow_out[i]) then
          ports[i].m_flow = 0;
        else
          ports[i].p = p_ambient;
        end if;
      end if;
      zetas_out[i] = 0;
    end if;
  end for;
initial equation
  for i in 1:nPorts loop
    pre(aboveLevel[i]) = level_start >= portsData_height2[i];
  end for;
  if massDynamics == Modelica.Fluid.Types.Dynamics.FixedInitial then
    level = level_start;
  elseif massDynamics == Modelica.Fluid.Types.Dynamics.SteadyStateInitial then
    der(level) = 0;
  end if;
equation
  connect(heatPort, heatTransfer.heatPorts[1]) annotation(Line(points = {{-100, 0}, {-87, 0}, {-87, 0}, {-74, 0}}, color = {191, 0, 0}));
  annotation(defaultComponentName = "tank", Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}, initialScale = 0.2), graphics = {Rectangle(extent = {{-100, -100}, {100, 100}}, lineColor = {255, 255, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.VerticalCylinder), Rectangle(extent = DynamicSelect({{-100, -100}, {100, 0}}, {{-100, -100}, {100, (-100) + 200 * level / height}}), lineColor = {0, 0, 0}, fillColor = {85, 170, 255}, fillPattern = FillPattern.VerticalCylinder), Text(extent = {{-94, 90}, {95, 60}}, lineColor = {0, 0, 255}, textString = "%name"), Text(extent = {{-95, 41}, {95, 21}}, lineColor = {0, 0, 0}, textString = "level ="), Line(points = {{-100, 100}, {-100, -100}, {100, -100}, {100, 100}}, color = {0, 0, 0}), Text(extent = {{-95, -39}, {95, -59}}, lineColor = {0, 0, 0}, textString = DynamicSelect("%level_start", String(level, minimumLength = 1, significantDigits = 2)))}), Documentation(info = "<html>
<p>
Model of a tank that is open to the environment at the fixed pressure
<code>p_ambient</code>.
The tank is filled with a single or multiple-substance liquid,
assumed to have uniform temperature and mass fractions.
</p>

<p>
At the top of the tank over the maximal fill level <b>height</b>
a vector of FluidPorts, called <b>topPorts</b>, is present.
The assumption is made that fluid flows always in to the tank via these
ports (and never back in to the connector).
</p>

<p>
The vector of connectors <b>ports</b> are fluid ports at the bottom
and side of the tank at a definable height. Fluid can flow either out
of or in to this port. The fluid level of the tank may be below
one of these ports. This case is approximated by introducing a
large pressure flow coefficient so that the mass flow rate
through this port is very small in this case.
</p>

<p>
If the tank starts to over flow (i.e., level > height), an
assertion is triggered.
</p>

<p>
When the diagram layer is open in the plot environment, the
level of the tank is dynamically visualized. Note, the speed
of the diagram animation in Dymola can be set via command
<b>animationSpeed</b>(), e.g., animationSpeed(speed = 10)
</p>
</html>", revisions = "<html>
<ul>
<li><i>Dec. 12, 2008</i> by Ruediger Franke: replace energy and mass balances with
common definition in BaseClasses.PartialLumpedVolume</li>
<li><i>Dec. 8, 2008</i> by Michael Wetter (LBNL):<br>
Implemented trace substances and missing equation for outflow of multi substance media at top port.</li>
<li><i>Jul. 29, 2006</i> by Martin Otter (DLR):<br>
Improved handling of ports that are above the fluid level and
simpler implementation.</li>

<li><i>Jan. 6, 2006</i> by Katja Poschlad, Manuel Remelhe (AST Uni Dortmund),
Martin Otter (DLR):<br>
Implementation based on former tank model but with several improvements
(top, bottom, side ports; correctly treating kinetic energy for outlet
and total dissipation for inlet; ports can be above the fluid level).</li>
</ul>
</html>"));
end OpenTank;
