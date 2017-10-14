within LibRAS.Sensors;
partial model PartialAbsoluteSensor "Partial component to model a sensor that measures a potential variable"
  replaceable package Medium = Modelica.Media.Interfaces.PartialMedium "Medium in the sensor" annotation(choicesAllMatching = true);
  LibRAS.Interfaces.WasteFluidPort_a port(redeclare package Medium = Medium, m_flow(min = 0)) annotation(Placement(transformation(origin = {0, -100}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
equation
  port.m_flow = 0;
  port.h_outflow = Medium.h_default;
  port.Xi_outflow = Medium.X_default[1:Medium.nXi];
  port.C_outflow = zeros(Medium.nC);
  port.C_S_outflow = zeros(Medium.nC_S);
  port.C_X_outflow = zeros(Medium.nC_X);
  annotation(Documentation(info = "<html>
<p>
Partial component to model an <b>absolute sensor</b>. Can be used for pressure sensor models.
Use for other properties such as temperature or density is discouraged, because the enthalpy at the connector can have different meanings, depending on the connection topology. Use <code>PartialFlowSensor</code> instead.
as signal.
</p>
</html>"));
end PartialAbsoluteSensor;
