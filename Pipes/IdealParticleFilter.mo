within LibRAS.Pipes;
model IdealParticleFilter "Particle filter without pressure drop"
  extends LibRAS.Interfaces.PartialTwoPort;
  parameter Real filterFactor(min = 0.0) = 0.9 "Particulates removal factor" annotation(Dialog(tab = "General"));
  parameter Real TSS_ratio (unit="1", min=0) = 0.75 "gTSS/gCOD" annotation(Dialog(tab = "General"));
  parameter Medium.MassFlowRate m_flow_nominal = system.m_flow_nominal "Nominal value of m_flow = port_a.m_flow" annotation(Dialog(tab = "Advanced"));
  parameter Medium.MassFlowRate m_flow_small(min = 0) = if system.use_eps_Re then system.eps_m_flow * m_flow_nominal else system.m_flow_small "Regularization for bi-directional flow in the region |m_flow| < m_flow_small (m_flow_small > 0 required)" annotation(Dialog(tab = "Advanced"));
  Modelica.Blocks.Interfaces.RealOutput TSS (unit="kg/s", displayUnit="kg/d") annotation(
    Placement(visible = true, transformation(origin = {-32, -74}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {0, -54}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
  Medium.MassFlowRate [Medium.nC_X] m_X_removed (each displayUnit="g/d");
equation
// mass balance
  0 = port_a.m_flow + port_b.m_flow;
// momentum equation (no pressure loss)
  port_a.p = port_b.p;
// isenthalpic state transformation (no storage and no loss of energy)
  port_a.h_outflow = inStream(port_b.h_outflow);
  port_b.h_outflow = inStream(port_a.h_outflow);
  port_a.Xi_outflow = inStream(port_b.Xi_outflow);
  port_b.Xi_outflow = inStream(port_a.Xi_outflow);
  port_a.C_outflow = inStream(port_b.C_outflow);
  port_b.C_outflow = inStream(port_a.C_outflow);
  port_a.C_S_outflow = inStream(port_b.C_S_outflow);
  port_b.C_S_outflow = inStream(port_a.C_S_outflow);
  port_a.C_X_outflow = inStream(port_b.C_X_outflow) * (1 - filterFactor);
  port_b.C_X_outflow = inStream(port_a.C_X_outflow) * (1 - filterFactor);

  if port_a.m_flow > 0 then
    m_X_removed = -inStream(port_a.C_X_outflow)*port_a.m_flow/scalar(Medium.density_phX(port_a.p, port_a.h_outflow, {1}))*filterFactor;
    TSS = sum((if i == Integer(Types.Species.X.ND) then 0 else m_X_removed[i]) for i in 1:Medium.nC_X)*TSS_ratio;
  else
    m_X_removed = -inStream(port_b.C_X_outflow)*port_b.m_flow/scalar(Medium.density_phX(port_b.p, port_b.h_outflow, {1}))*filterFactor;
    TSS = sum((if i == Integer(Types.Species.X.ND) then 0 else m_X_removed[i]) for i in 1:Medium.nC_X)*TSS_ratio;
  end if;
  annotation(defaultComponentName = "filter", Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(extent = {{-100, 40}, {100, -40}}, fillPattern = FillPattern.Solid, fillColor = {95, 95, 95}, pattern = LinePattern.None), Rectangle(extent = {{-100, 44}, {100, -44}}, lineColor = {0, 0, 0}, fillPattern = FillPattern.HorizontalCylinder, fillColor = {0, 127, 255})}));
end IdealParticleFilter;