within LibRAS.Tanks;
partial model PartialLumpedVessel
"Lumped volume with a vector of fluid ports and replaceable heat transfer model"
extends Modelica.Fluid.Interfaces.PartialLumpedVolume;
  import SI = Modelica.SIunits;
// Port definitions
parameter Integer nPorts=0 "Number of ports"
annotation(Evaluate=true, Dialog(connectorSizing=true, tab="General",group="Ports"));
Interfaces.VesselWasteFluidPorts_b ports[nPorts](redeclare each package Medium = Medium)
"Fluid inlets and outlets"
annotation (Placement(transformation(extent={{-40,-10},{40,10}},
  origin={0,-100})));

// Port properties
parameter Boolean use_portsData=true
"= false to neglect pressure loss and kinetic energy"
annotation(Evaluate=true, Dialog(tab="General",group="Ports"));
parameter Modelica.Fluid.Vessels.BaseClasses.VesselPortsData[if use_portsData then nPorts else 0]
portsData "Data of inlet/outlet ports"
annotation(Dialog(tab="General",group="Ports",enable= use_portsData));

parameter Medium.MassFlowRate m_flow_nominal = if system.use_eps_Re then system.m_flow_nominal else 1e2*system.m_flow_small
"Nominal value for mass flow rates in ports"
annotation(Dialog(tab="Advanced", group="Port properties"));
parameter SI.MassFlowRate m_flow_small(min=0) = if system.use_eps_Re then system.eps_m_flow*m_flow_nominal else system.m_flow_small
"Regularization range at zero mass flow rate"
annotation(Dialog(tab="Advanced", group="Port properties"));
parameter Boolean use_Re = system.use_eps_Re
"= true, if turbulent region is defined by Re, otherwise by m_flow_small"
annotation(Dialog(tab="Advanced", group="Port properties"), Evaluate=true);

Medium.EnthalpyFlowRate ports_H_flow[nPorts];
Medium.MassFlowRate ports_mXi_flow[nPorts,Medium.nXi];
Medium.MassFlowRate[Medium.nXi] sum_ports_mXi_flow
"Substance mass flows through ports";
Medium.ExtraPropertyFlowRate ports_mC_flow[nPorts,Medium.nC];
Medium.ExtraPropertyFlowRate[Medium.nC] sum_ports_mC_flow
"Trace substance mass flows through ports";


// Heat transfer through boundary
parameter Boolean use_HeatTransfer = false
"= true to use the HeatTransfer model"
  annotation (Dialog(tab="Assumptions", group="Heat transfer"));
replaceable model HeatTransfer =
  Modelica.Fluid.Vessels.BaseClasses.HeatTransfer.IdealHeatTransfer
constrainedby
Modelica.Fluid.Vessels.BaseClasses.HeatTransfer.PartialVesselHeatTransfer
"Wall heat transfer"
  annotation (Dialog(tab="Assumptions", group="Heat transfer",enable=use_HeatTransfer),choicesAllMatching=true);
HeatTransfer heatTransfer(
redeclare final package Medium = Medium,
final n=1,
final states = {medium.state},
final use_k = use_HeatTransfer)
  annotation (Placement(transformation(
    extent={{-10,-10},{30,30}},
    rotation=90,
    origin={-50,-10})));
Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPort if use_HeatTransfer
annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));

// Conservation of kinetic energy
Medium.Density[nPorts] portInDensities
"densities of the fluid at the device boundary";
SI.Velocity[nPorts] portVelocities
"velocities of fluid flow at device boundary";
SI.EnergyFlowRate[nPorts] ports_E_flow
"flow of kinetic and potential energy at device boundary";

// Note: should use fluidLevel_start - portsData.height
Real[nPorts] s(each start = fluidLevel_max)
"curve parameters for port flows vs. port pressures; for further details see, Modelica Tutorial: Ideal switching devices";
Real[nPorts] ports_penetration
"penetration of port with fluid, depending on fluid level and port diameter";

// treatment of pressure losses at ports
SI.Area[nPorts] portAreas = {Modelica.Constants.pi/4*portsData_diameter[i]^2 for i in 1:nPorts};
Medium.AbsolutePressure[nPorts] vessel_ps_static
"static pressures inside the vessel at the height of the corresponding ports, zero flow velocity";

// determination of turbulent region
constant SI.ReynoldsNumber Re_turbulent = 100 "cf. suddenExpansion";
SI.MassFlowRate[nPorts] m_flow_turbulent;

protected
input SI.Height fluidLevel = 0
"level of fluid in the vessel for treating heights of ports";
parameter SI.Height fluidLevel_max = 1
"maximum level of fluid in the vessel";
parameter SI.Area vesselArea = Modelica.Constants.inf
"Area of the vessel used to relate to cross flow area of ports";

// Treatment of use_portsData=false to neglect portsData and to not require its specification either in this case.
// Remove portsData conditionally if use_portsData=false. Simplify their use in model equations by always
// providing portsData_diameter and portsData_height, independent of the use_portsData setting.
// Note: this moreover serves as work-around if a tool does not support a zero sized portsData record.
Modelica.Blocks.Interfaces.RealInput[nPorts]
portsData_diameter_internal = portsData.diameter if use_portsData and nPorts > 0;
Modelica.Blocks.Interfaces.RealInput[nPorts] portsData_height_internal = portsData.height if use_portsData and nPorts > 0;
Modelica.Blocks.Interfaces.RealInput[nPorts] portsData_zeta_in_internal = portsData.zeta_in if use_portsData and nPorts > 0;
Modelica.Blocks.Interfaces.RealInput[nPorts] portsData_zeta_out_internal = portsData.zeta_out if use_portsData and nPorts > 0;
Modelica.Blocks.Interfaces.RealInput[nPorts] portsData_diameter;
Modelica.Blocks.Interfaces.RealInput[nPorts] portsData_height;
Modelica.Blocks.Interfaces.RealInput[nPorts] portsData_zeta_in;
Modelica.Blocks.Interfaces.RealInput[nPorts] portsData_zeta_out;
Modelica.Blocks.Interfaces.BooleanInput[nPorts] regularFlow(each start=true);
Modelica.Blocks.Interfaces.BooleanInput[nPorts] inFlow(each start=false);

equation
mb_flow = sum(ports.m_flow);
mbXi_flow = sum_ports_mXi_flow;
mbC_flow  = sum_ports_mC_flow;
Hb_flow = sum(ports_H_flow) + sum(ports_E_flow);
Qb_flow = heatTransfer.Q_flows[1];

// Only one connection allowed to a port to avoid unwanted ideal mixing
for i in 1:nPorts loop
assert(cardinality(ports[i]) <= 1,"
each ports[i] of volume can at most be connected to one component.
If two or more connections are present, ideal mixing takes
place with these connections, which is usually not the intention
of the modeller. Increase nPorts to add an additional port.
");
end for;
// Check for correct solution
assert(fluidLevel <= fluidLevel_max, "Vessel is overflowing (fluidLevel > fluidLevel_max = " + String(fluidLevel) + ")");
assert(fluidLevel > -1e-6*fluidLevel_max, "Fluid level (= " + String(fluidLevel) + ") is below zero meaning that the solution failed.");

// Boundary conditions

// treatment of conditional portsData
connect(portsData_diameter, portsData_diameter_internal);
connect(portsData_height, portsData_height_internal);
connect(portsData_zeta_in, portsData_zeta_in_internal);
connect(portsData_zeta_out, portsData_zeta_out_internal);
if not use_portsData then
portsData_diameter = zeros(nPorts);
portsData_height = zeros(nPorts);
portsData_zeta_in = zeros(nPorts);
portsData_zeta_out = zeros(nPorts);
end if;

// actual definition of port variables
for i in 1:nPorts loop
portInDensities[i] = Medium.density(Medium.setState_phX(vessel_ps_static[i], inStream(ports[i].h_outflow), inStream(ports[i].Xi_outflow)));
if use_portsData then
  // dp = 0.5*zeta*d*v*|v|
  // Note: assume vessel_ps_static for portVelocities to avoid algebraic loops for ports.p
  portVelocities[i] = smooth(0, ports[i].m_flow/portAreas[i]/Medium.density(Medium.setState_phX(vessel_ps_static[i], actualStream(ports[i].h_outflow), actualStream(ports[i].Xi_outflow))));
  // Note: the penetration should not go too close to zero as this would prevent a vessel from running empty
  ports_penetration[i] = Utilities.regStep(fluidLevel - portsData_height[i] - 0.1*portsData_diameter[i], 1, 1e-3, 0.1*portsData_diameter[i]);
  m_flow_turbulent[i]=if not use_Re then m_flow_small else
    max(m_flow_small, (Modelica.Constants.pi/8)*portsData_diameter[i]
                        *(Medium.dynamicViscosity(Medium.setState_phX(vessel_ps_static[i], inStream(ports[i].h_outflow), inStream(ports[i].Xi_outflow)))
                          + Medium.dynamicViscosity(medium.state))*Re_turbulent);
else
  // an infinite port diameter is assumed
  portVelocities[i] = 0;
  ports_penetration[i] = 1;
  m_flow_turbulent[i] = Modelica.Constants.inf;
end if;

// fluid flow through ports
regularFlow[i] = fluidLevel >= portsData_height[i];
inFlow[i]      = not regularFlow[i] and (s[i] > 0 or portsData_height[i] >= fluidLevel_max);
if regularFlow[i] then
  // regular operation: fluidLevel is above ports[i]
  // Note: >= covers default values of zero as well
  if use_portsData then
    /* Without regularization
        ports[i].p = vessel_ps_static[i] + 0.5*ports[i].m_flow^2/portAreas[i]^2
                    * noEvent(if ports[i].m_flow>0 then zeta_in[i]/portInDensities[i] else -zeta_out[i]/medium.d);
    */

    ports[i].p = homotopy(vessel_ps_static[i] + (0.5/portAreas[i]^2*Utilities.regSquare2(ports[i].m_flow, m_flow_turbulent[i],
                                  (portsData_zeta_in[i] - 1 + portAreas[i]^2/vesselArea^2)/portInDensities[i]*ports_penetration[i],
                                  (portsData_zeta_out[i] + 1 - portAreas[i]^2/vesselArea^2)/medium.d/ports_penetration[i])),
                          vessel_ps_static[i]);
    /*
      // alternative formulation m_flow=f(dp); not allowing the ideal portsData_zeta_in[i]=1 though
      ports[i].m_flow = smooth(2, portAreas[i]*Utilities.regRoot2(ports[i].p - vessel_ps_static[i], dp_small,
                              2*portInDensities[i]/portsData_zeta_in[i],
                              2*medium.d/portsData_zeta_out[i]));
    */
  else
    ports[i].p = vessel_ps_static[i];
  end if;
  s[i] = fluidLevel - portsData_height[i];

elseif inFlow[i] then
  // ports[i] is above fluidLevel and has inflow
  ports[i].p = vessel_ps_static[i];
  s[i] = ports[i].m_flow;

else
  // ports[i] is above fluidLevel, preventing outflow
  ports[i].m_flow = 0;
  s[i] = (ports[i].p - vessel_ps_static[i])/Medium.p_default*(portsData_height[i] - fluidLevel);
end if;

ports[i].h_outflow  = medium.h;
ports[i].Xi_outflow = medium.Xi;
ports[i].C_outflow  = C;

ports_H_flow[i] = ports[i].m_flow * actualStream(ports[i].h_outflow)
"Enthalpy flow";
ports_E_flow[i] = ports[i].m_flow*(0.5*portVelocities[i]*portVelocities[i] + system.g*portsData_height[i])
"Flow of kinetic and potential energy";
ports_mXi_flow[i,:] = ports[i].m_flow * actualStream(ports[i].Xi_outflow)
"Component mass flow";
ports_mC_flow[i,:]  = ports[i].m_flow * actualStream(ports[i].C_outflow)
"Trace substance mass flow";
end for;

for i in 1:Medium.nXi loop
sum_ports_mXi_flow[i] = sum(ports_mXi_flow[:,i]);
end for;

for i in 1:Medium.nC loop
sum_ports_mC_flow[i]  = sum(ports_mC_flow[:,i]);
end for;

connect(heatPort, heatTransfer.heatPorts[1]) annotation (Line(
  points={{-100,0},{-87,0},{-87,0},{-74,0}},
  color={191,0,0}));
annotation (
Documentation(info="<html>
<p>
This base class extends PartialLumpedVolume with a vector of fluid ports and a replaceable wall HeatTransfer model.
</p>
<p>
The following modeling assumption are made:
<ul>
<li>homogeneous medium, i.e., phase separation is not taken into account,</li>
<li>no kinetic energy in the fluid, i.e., kinetic energy dissipates into the internal energy,</li>
<li>pressure loss definitions at vessel ports assume incompressible fluid,</li>
<li>outflow of ambient media is prevented at each port assuming check valve behavior.
If <code> fluidlevel &lt; portsData_height[i] </code>and &nbsp; <code> ports[i].p &lt; vessel_ps_static[i]</code> mass flow at the port is set to 0.</li>
</ul>
<p>
Each port has a (hydraulic) diameter and a height above the bottom of the vessel, which can be configured using the &nbsp;<b><code>portsData</code></b> record.
Alternatively the impact of port geometries can be neglected with <code>use_portsData=false</code>. This might be useful for early
design studies. Note that this means to assume an infinite port diameter at the bottom of the vessel.
Pressure drops and heights of the ports as well as kinetic and potential energy fluid entering or leaving the vessel are neglected then.
</p>
<p>
The following variables need to be defined by an extending model:
</p>
<ul>
<li><code>input fluidVolume</code>, the volume of the fluid in the vessel,</li>
<li><code>vessel_ps_static[nPorts]</code>, the static pressures inside the vessel at the height of the corresponding ports, at zero flow velocity, and</li>
<li><code>Wb_flow</code>, work term of the energy balance, e.g., p*der(V) if the volume is not constant or stirrer power.</li>
</ul>
<p>
An extending model should define:
</p>
<ul>
<li><code>parameter vesselArea</code> (default: Modelica.Constants.inf m2), the area of the vessel, to be related to cross flow areas of the ports for the consideration of dynamic pressure effects.</li>
</ul>
<p>
Optionally the fluid level may vary in the vessel, which effects the flow through the ports at configurable <code>portsData_height[nPorts]</code>.
This is why an extending model with varying fluid level needs to define:
</p>
<ul>
<li><code>input fluidLevel (default: 0m)</code>, the level the fluid in the vessel, and</li>
<li><code>parameter fluidLevel_max (default: 1m)</code>, the maximum level that must not be exceeded. Ports at or above fluidLevel_max can only receive inflow.</li>
</ul>
<p>
An extending model should not access the <code>portsData</code> record defined in the configuration dialog,
as an access to <code>portsData</code> may fail for <code>use_portsData=false</code> or <code>nPorts=0</code>.
</p>
<p>
Instead the predefined variables
</p>
<ul>
<li><code>portsData_diameter[nPorts]</code>,</li>
<li><code>portsData_height[nPorts]</code>,</li>
<li><code>portsData_zeta_in[nPorts]</code>, and</li>
<li><code>portsData_zeta_out[nPorts]</code></li>
</ul>
<p>
should be used if these values are needed.
</p>
</html>",       revisions="<html>
<ul>
<li><i>Jan. 2009</i> by R&uuml;diger Franke: extended with
<ul><li>portsData record and threat configurable port heights,</li>
<li>consideration of kinetic and potential energy of fluid entering or leaving in energy balance</li>
</ul>
</li>
<li><i>Dec. 2008</i> by R&uuml;diger Franke: derived from OpenTank, in order to make general use of configurable port diameters</li>
</ul>
</html>"),Icon(coordinateSystem(preserveAspectRatio=true,  extent={{-100,-100},
      {100,100}}), graphics={Text(
    extent={{-150,110},{150,150}},
    textString="%name",
    lineColor={0,0,255})}));
end PartialLumpedVessel;
