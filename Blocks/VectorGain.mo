within LibRAS.Blocks;
  block VectorGain "Output the product of a gain value with the input signal"
    parameter Real k(start = 1, unit = "1") "Gain value multiplied with input signal";
    parameter Integer n=1 "Dimension of input and output vectors.";
  public
    Modelica.Blocks.Interfaces.RealInput u[n] "Input signal connector" annotation(Placement(transformation(extent = {{-140, -20}, {-100, 20}}, rotation = 0)));
    Modelica.Blocks.Interfaces.RealOutput y[n] "Output signal connector" annotation(Placement(transformation(extent = {{100, -10}, {120, 10}}, rotation = 0)));
  equation
    y = k * u;
    annotation(Documentation(info = "<html>
<p>
This block computes output <i>y</i> as
<i>product</i> of gain <i>k</i> with the
input <i>u</i>:
</p>
<pre>
    y = k * u;
</pre>

</html>"), Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Polygon(points = {{-100, -100}, {-100, 100}, {100, 0}, {-100, -100}}, lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-150, -140}, {150, -100}}, lineColor = {0, 0, 0}, textString = "k=%k"), Text(extent = {{-150, 140}, {150, 100}}, textString = "%name", lineColor = {0, 0, 255})}), Diagram(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Polygon(points = {{-100, -100}, {-100, 100}, {100, 0}, {-100, -100}}, lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-76, 38}, {0, -34}}, textString = "k", lineColor = {0, 0, 255})}));
  end VectorGain;
