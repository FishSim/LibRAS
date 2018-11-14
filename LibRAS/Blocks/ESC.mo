within LibRAS.Blocks;

block ESC
extends Modelica.Blocks.Interfaces.SISO;
  parameter Real k = 1 "Integrator Gain";
  parameter Modelica.SIunits.Frequency f = 1 "Perturbation frequency";
  parameter Real a = 1 "Perturbation amplitude";
  parameter Real h = 1 "Washout filter constant";
  parameter Real m = 0 "Base level of output";
  parameter Modelica.SIunits.Time startTime = 1 "Activate when time >= startTime";

  Modelica.Blocks.Sources.Sine sine1(amplitude = a, freqHz = f, startTime = startTime)  annotation(
    Placement(visible = true, transformation(origin = {-58, -36}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Continuous.Integrator integrator1(k = k)  annotation(
    Placement(visible = true, transformation(origin = {8, -30}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Math.Product product1 annotation(
    Placement(visible = true, transformation(origin = {-24, -30}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Continuous.TransferFunction highpass(a = {1, h}, b = {1, 0})  annotation(
    Placement(visible = true, transformation(origin = {-58, 0}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Sources.Constant bias(k = m)  annotation(
    Placement(visible = true, transformation(origin = {8, 2}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
  Modelica.Blocks.Math.Add3 add31 annotation(
    Placement(visible = true, transformation(origin = {40, -30}, extent = {{-10, -10}, {10, 10}}, rotation = 0)));
equation
  connect(bias.y, add31.u1) annotation(
    Line(points = {{20, 2}, {28, 2}, {28, -22}, {28, -22}}, color = {0, 0, 127}));
  connect(integrator1.y, add31.u2) annotation(
    Line(points = {{20, -30}, {28, -30}, {28, -30}, {28, -30}}, color = {0, 0, 127}));
  connect(add31.y, y) annotation(
    Line(points = {{52, -30}, {82, -30}, {82, 0}, {110, 0}, {110, 0}}, color = {0, 0, 127}));
  connect(sine1.y, add31.u3) annotation(
    Line(points = {{-46, -36}, {-46, -46}, {28, -46}, {28, -38}}, color = {0, 0, 127}));
  connect(sine1.y, product1.u2) annotation(
    Line(points = {{-46, -36}, {-38, -36}, {-38, -36}, {-36, -36}}, color = {0, 0, 127}));
  connect(product1.y, integrator1.u) annotation(
    Line(points = {{-12, -30}, {-6, -30}, {-6, -30}, {-4, -30}}, color = {0, 0, 127}));
  connect(highpass.y, product1.u1) annotation(
    Line(points = {{-46, 0}, {-42, 0}, {-42, -24}, {-36, -24}}, color = {0, 0, 127}));
  connect(highpass.u, u) annotation(
    Line(points = {{-70, 0}, {-114, 0}, {-114, 0}, {-120, 0}}, color = {0, 0, 127}));
  annotation(Icon(
      coordinateSystem(preserveAspectRatio=true,
            extent={{-100.0,-100.0},{100.0,100.0}}),
          graphics={
      Line(points={{-80.0,78.0},{-80.0,-90.0}},
          color={192,192,192}),
    Polygon(lineColor={192,192,192},
        fillColor={192,192,192},
        fillPattern=FillPattern.Solid,
        points={{-80.0,90.0},{-88.0,68.0},{-72.0,68.0},{-80.0,90.0}}),
    Line(points={{-90.0,-80.0},{82.0,-80.0}},
        color={192,192,192}),
    Polygon(lineColor={192,192,192},
        fillColor={192,192,192},
        fillPattern=FillPattern.Solid,
        points={{90.0,-80.0},{68.0,-72.0},{68.0,-88.0},{90.0,-80.0}}),
    Line(origin = {-1.939,-1.816},
        points = {{81.939,36.056},{65.362,36.056},{14.39,-26.199},{-29.966,113.485},{-65.374,-61.217},{-78.061,-78.184}},
        color = {0,0,127},
        smooth = Smooth.Bezier),
    Text(lineColor={192,192,192},
        extent={{0.0,-70.0},{60.0,-10.0}},
        textString="ESC")}));
end ESC;
