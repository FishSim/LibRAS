within LibRAS.Sensors;
model StateSensor
  extends LibRAS.Sensors.PartialFlowSensor;
  extends Modelica.Icons.RotationalSensor;
  import LibRAS.Types.Species.S;
  import LibRAS.Types.Species.X;
  //  Modelica.Blocks.Interfaces.RealOutput states[31] "States at port";
  parameter Integer stateNumber_S[S] = {1, 2, 8, 9, 10, 11, 13, 14};
  parameter Integer stateNumber_S_film[S] = {16, 17, 23, 24, 25, 26, 28, 29};
  parameter Integer stateNumber_X[X] = {3, 4, 5, 6, 7, 12};
  parameter Integer stateNumber_X_film[X] = {18, 19, 20, 21, 22, 27};
  parameter Integer stateNumber_L = 31;
  parameter Integer blankStates[:] = {15, 30};

  Modelica.Blocks.Interfaces.RealOutput C_S[Medium.nC_S] annotation(Placement(visible = true, transformation(origin = {-86, 54}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {-32, 102}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  Modelica.Blocks.Interfaces.RealOutput C_X[Medium.nC_X] annotation(Placement(visible = true, transformation(origin = {-76, 64}, extent = {{-10, -10}, {10, 10}}, rotation = 0), iconTransformation(origin = {32, 102}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
equation
  C_S = if port_a.m_flow > 0 then inStream(port_a.C_S_outflow) else inStream(port_b.C_S_outflow);
  C_X = if port_a.m_flow > 0 then inStream(port_a.C_X_outflow) else inStream(port_b.C_X_outflow);
/*    for i in S loop
    states[stateNumber_S[i]] = C_S[Integer(i)];
    states[stateNumber_S_film[i]] = C_S_film[Integer(i)];
  end for;
  for i in X loop
    states[stateNumber_X[i]] = C_X[Integer(i)];
    states[stateNumber_X_film[i]] = C_X_film[Integer(i)];
  end for;
  states[stateNumber_L] = 0;
  for i in 4 loop
    states[blankStates[i]] = 0;
  end for;*/
  annotation(Icon(coordinateSystem(preserveAspectRatio = false, initialScale = 0.1), graphics = {Line(points = {{70, 0}, {100, 0}}, color = {0, 128, 255}), Text(extent = {{162, 120}, {2, 90}}, textString = "states", fontName = "DejaVu Sans Mono"), Line(points = {{-100, 0}, {-70, 0}}, color = {0, 128, 255}), Line(origin = {-32, -8}, points = {{0, 100}, {0, 70}}, color = {0, 0, 127}), Line(origin = {32, -8}, points = {{0, 100}, {0, 70}}, color = {0, 0, 127})}), uses(Modelica(version = "3.2.1")));
end StateSensor;
