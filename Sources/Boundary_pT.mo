within LibRAS.Sources;
model Boundary_pT "Boundary with prescribed pressure, temperature, composition and trace substances"
  import Modelica.Media.Interfaces.Choices.IndependentVariables;
  extends Sources.PartialSource;
  parameter Boolean use_p_in = false "Get the pressure from the input connector" annotation(Evaluate = true, HideResult = true, choices(checkBox = true));
  parameter Boolean use_T_in = false "Get the temperature from the input connector" annotation(Evaluate = true, HideResult = true, choices(checkBox = true));
  parameter Boolean use_X_in = false "Get the composition from the input connector" annotation(Evaluate = true, HideResult = true, choices(checkBox = true));
  parameter Boolean use_C_in = false "Get the trace substances from the input connector" annotation(Evaluate = true, HideResult = true, choices(checkBox = true));
  parameter Boolean use_C_S_in = false "Get the trace substances from the input connector" annotation(Evaluate = true, HideResult = true, choices(checkBox = true));
  parameter Boolean use_C_X_in = false "Get the trace substances from the input connector" annotation(Evaluate = true, HideResult = true, choices(checkBox = true));
  parameter Medium.AbsolutePressure p = Medium.p_default "Fixed value of pressure" annotation(Evaluate = true, Dialog(enable = not use_p_in));
  parameter Medium.Temperature T = Medium.T_default "Fixed value of temperature" annotation(Evaluate = true, Dialog(enable = not use_T_in));
  parameter Medium.MassFraction X[Medium.nX] = Medium.X_default "Fixed value of composition" annotation(Evaluate = true, Dialog(enable = not use_X_in and Medium.nXi > 0));
  parameter Medium.ExtraProperty C[Medium.nC](quantity = Medium.extraPropertiesNames) = fill(0, Medium.nC) "Fixed values of trace substances" annotation(Evaluate = true, Dialog(enable = not use_C_in and Medium.nC > 0));
  parameter Medium.ExtraProperty C_S[Medium.nC_S](quantity = Medium.solublesNames) = fill(0, Medium.nC_S) "Fixed values of trace substances" annotation(Evaluate = true, Dialog(enable = not use_C_S_in and Medium.nC_S > 0));
  parameter Medium.ExtraProperty C_X[Medium.nC_X](quantity = Medium.particulatesNames) = fill(0, Medium.nC_X) "Fixed values of trace substances" annotation(Evaluate = true, Dialog(enable = not use_C_S_in and Medium.nC_S > 0));
  Modelica.Blocks.Interfaces.RealInput p_in if use_p_in "Prescribed boundary pressure" annotation(Placement(visible = true, transformation(extent = {{-120, 60}, {-80, 100}}, rotation = 0), iconTransformation(extent = {{-120, 60}, {-80, 100}}, rotation = 0)));
  Modelica.Blocks.Interfaces.RealInput T_in if use_T_in "Prescribed boundary temperature" annotation(Placement(transformation(extent = {{-140, 20}, {-100, 60}})));
  Modelica.Blocks.Interfaces.RealInput X_in[Medium.nX] if use_X_in "Prescribed boundary composition" annotation(Placement(visible = true, transformation(extent = {{-140, -60}, {-100, -20}}, rotation = 0), iconTransformation(extent = {{-140, -60}, {-100, -20}}, rotation = 0)));
  Modelica.Blocks.Interfaces.RealInput C_in[Medium.nC] if use_C_in "Prescribed boundary trace substances" annotation(Placement(visible = true, transformation(extent = {{-120, -100}, {-80, -60}}, rotation = 0), iconTransformation(extent = {{-120, -100}, {-80, -60}}, rotation = 0)));
  Modelica.Blocks.Interfaces.RealInput C_S_in[Medium.nC_S] if use_C_S_in "Prescribed boundary trace substances" annotation(Placement(visible = true, transformation(origin = {-60, 100}, extent = {{-20, -20}, {20, 20}}, rotation = -90), iconTransformation(origin = {-60, 100}, extent = {{-20, -20}, {20, 20}}, rotation = -90)));
  Modelica.Blocks.Interfaces.RealInput C_X_in[Medium.nC_X] if use_C_X_in "Prescribed boundary trace substances" annotation(Placement(visible = true, transformation(origin = {60, 100}, extent = {{-20, -20}, {20, 20}}, rotation = -90), iconTransformation(origin = {60, 100}, extent = {{-20, -20}, {20, 20}}, rotation = -90)));
protected
  Modelica.Blocks.Interfaces.RealInput p_in_internal "Needed to connect to conditional connector";
  Modelica.Blocks.Interfaces.RealInput T_in_internal "Needed to connect to conditional connector";
  Modelica.Blocks.Interfaces.RealInput X_in_internal[Medium.nX] "Needed to connect to conditional connector";
  Modelica.Blocks.Interfaces.RealInput C_in_internal[Medium.nC] "Needed to connect to conditional connector";
  Modelica.Blocks.Interfaces.RealInput C_S_in_internal[Medium.nC_S] "Needed to connect to conditional connector";
  Modelica.Blocks.Interfaces.RealInput C_X_in_internal[Medium.nC_X] "Needed to connect to conditional connector";
equation
  connect(C_in, C_in_internal) annotation(Line);
  connect(p_in, p_in_internal) annotation(Line);
  connect(C_X_in, C_X_in_internal) annotation(Line);
  connect(C_S_in, C_S_in_internal) annotation(Line);
  Modelica.Fluid.Utilities.checkBoundary(Medium.mediumName, Medium.substanceNames, Medium.singleState, true, X_in_internal, "Boundary_pT");
  connect(T_in, T_in_internal);
  connect(X_in, X_in_internal);
  if not use_p_in then
    p_in_internal = p;
  end if;
  if not use_T_in then
    T_in_internal = T;
  end if;
  if not use_X_in then
    X_in_internal = X;
  end if;
  if not use_C_in then
    C_in_internal = C;
  end if;
  if not use_C_S_in then
    C_S_in_internal = C_S;
  end if;
  if not use_C_X_in then
    C_X_in_internal = C_X;
  end if;
  medium.p = p_in_internal;
  if Medium.ThermoStates == IndependentVariables.ph or Medium.ThermoStates == IndependentVariables.phX then
    medium.h = Medium.specificEnthalpy(Medium.setState_pTX(p_in_internal, T_in_internal, X_in_internal));
  else
    medium.T = T_in_internal;
  end if;
  medium.Xi = X_in_internal[1:Medium.nXi];
  ports.C_outflow = fill(C_in_internal, nPorts);
  ports.C_S_outflow = fill(C_S_in_internal, nPorts);
  ports.C_X_outflow = fill(C_X_in_internal, nPorts);
  annotation(defaultComponentName = "boundary", Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics = {Ellipse(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 0}, fillPattern = FillPattern.Sphere, fillColor = {0, 127, 255}), Text(extent = {{-150, 120}, {150, 160}}, textString = "%name", lineColor = {0, 0, 255}), Line(visible = use_p_in, points = {{-100, 80}, {-58, 80}}, color = {0, 0, 255}), Line(visible = use_T_in, points = {{-100, 40}, {-92, 40}}, color = {0, 0, 255}), Line(visible = use_X_in, points = {{-100, -40}, {-92, -40}}, color = {0, 0, 255}), Line(visible = use_C_in, points = {{-100, -80}, {-60, -80}}, color = {0, 0, 255}), Text(visible = use_p_in, extent = {{-152, 134}, {-68, 94}}, lineColor = {0, 0, 0}, textString = "p"), Text(visible = use_X_in, extent = {{-164, 4}, {-62, -36}}, lineColor = {0, 0, 0}, textString = "X"), Text(visible = use_C_in, extent = {{-164, -90}, {-62, -130}}, lineColor = {0, 0, 0}, textString = "C"), Text(visible = use_T_in, extent = {{-162, 34}, {-60, -6}}, lineColor = {0, 0, 0}, textString = "T")}), Documentation(info = "<html>
<p>
Defines prescribed values for boundary conditions:
</p>
<ul>
<li> Prescribed boundary pressure.</li>
<li> Prescribed boundary temperature.</li>
<li> Boundary composition (only for multi-substance or trace-substance flow).</li>
</ul>
<p>If <code>use_p_in</code> is false (default option), the <code>p</code> parameter
is used as boundary pressure, and the <code>p_in</code> input connector is disabled; if <code>use_p_in</code> is true, then the <code>p</code> parameter is ignored, and the value provided by the input connector is used instead.</p>
<p>The same thing goes for the temperature, composition and trace substances.</p>
<p>
Note, that boundary temperature,
mass fractions and trace substances have only an effect if the mass flow
is from the boundary into the port. If mass is flowing from
the port into the boundary, the boundary definitions,
with exception of boundary pressure, do not have an effect.
</p>
</html>"));
end Boundary_pT;