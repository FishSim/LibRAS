within LibRAS.Blocks;
  block VectorAdd "Output the sum of the two inputs"
    extends Modelica.Blocks.Interfaces.MI2MO;
    parameter Real k1 = +1 "Gain of upper input";
    parameter Real k2 = +1 "Gain of lower input";
  equation
    y = k1 * u1 + k2 * u2;
    annotation(Documentation(info = "<html>
<p>
This blocks computes output <b>y</b> as <i>sum</i> of the
two input signals <b>u1</b> and <b>u2</b>:
</p>
<pre>
    <b>y</b> = k1*<b>u1</b> + k2*<b>u2</b>;
</pre>
<p>
Example:
</p>
<pre>
     parameter:   k1= +2, k2= -3

  results in the following equations:

     y = 2 * u1 - 3 * u2
</pre>

</html>"), Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}, initialScale = 0.1), graphics = {Text(lineColor = {0, 0, 255}, extent = {{-150, 110}, {150, 150}}, textString = "%name"), Line(points = {{-100, 60}, {-74, 24}, {-44, 24}}, color = {0, 0, 127}), Line(points = {{-100, -60}, {-74, -28}, {-42, -28}}, color = {0, 0, 127}), Ellipse(lineColor = {0, 0, 127}, extent = {{-50, -50}, {50, 50}}), Line(points = {{50, 0}, {100, 0}}, color = {0, 0, 127}), Text(extent = {{-38, -34}, {38, 34}}, textString = "+"), Text(extent = {{-100, 52}, {5, 92}}, textString = "%k1"), Text(extent = {{-100, -92}, {5, -52}}, textString = "%k2")}), Diagram(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(extent = {{-100, -100}, {100, 100}}, lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Line(points = {{50, 0}, {100, 0}}, color = {0, 0, 255}), Line(points = {{-100, 60}, {-74, 24}, {-44, 24}}, color = {0, 0, 127}), Line(points = {{-100, -60}, {-74, -28}, {-42, -28}}, color = {0, 0, 127}), Ellipse(extent = {{-50, 50}, {50, -50}}, lineColor = {0, 0, 127}), Line(points = {{50, 0}, {100, 0}}, color = {0, 0, 127}), Text(extent = {{-36, 38}, {40, -30}}, lineColor = {0, 0, 0}, textString = "+"), Text(extent = {{-100, 52}, {5, 92}}, lineColor = {0, 0, 0}, textString = "k1"), Text(extent = {{-100, -52}, {5, -92}}, lineColor = {0, 0, 0}, textString = "k2")}));
  end VectorAdd;
