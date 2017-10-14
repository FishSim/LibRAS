within LibRAS.Sensors;
partial model PartialFlowSensor "Partial component to model sensors that measure flow properties"
  extends LibRAS.Interfaces.PartialTwoPort;
  parameter Medium.MassFlowRate m_flow_nominal = system.m_flow_nominal "Nominal value of m_flow = port_a.m_flow" annotation(Dialog(tab = "Advanced"));
  parameter Medium.MassFlowRate m_flow_small(min = 0) = if system.use_eps_Re then system.eps_m_flow * m_flow_nominal else system.m_flow_small "Regularization for bi-directional flow in the region |m_flow| < m_flow_small (m_flow_small > 0 required)" annotation(Dialog(tab = "Advanced"));
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
  port_a.C_X_outflow = inStream(port_b.C_X_outflow);
  port_b.C_X_outflow = inStream(port_a.C_X_outflow);
  annotation(Documentation(info = "<html>
<p>
Partial component to model a <b>sensor</b> that measures any intensive properties
of a flow, e.g., to get temperature or density in the flow
between fluid connectors.<br>
The model includes zero-volume balance equations. Sensor models inheriting from
this partial class should add a medium instance to calculate the measured property.
</p>
</html>"));
end PartialFlowSensor;
