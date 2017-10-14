within LibRAS.Blocks;
block AddToIndex "Add one scalar input to specified index of other (vector) input"
  extends Modelica.Blocks.Icons.Block;

  parameter Integer n=1 "Dimension of input and output vectors.";
  parameter Integer i=1 "Index to which u2 is added";

  Modelica.Blocks.Interfaces.RealInput u1[n] "Connector of Real input signals vector" annotation (Placement(
        visible = true, transformation(extent = {{-140, 40}, {-100, 80}}, rotation = 0)));
  Modelica.Blocks.Interfaces.RealInput u2 "Connector of Real scalar input signal" annotation (Placement(
        transformation(extent={{-140,-80},{-100,-40}}, rotation=0)));
  Modelica.Blocks.Interfaces.RealOutput y[n] "Connector of Real output signals" annotation (Placement(
        transformation(extent={{100,-10},{120,10}}, rotation=0)));

  Real u2_matrix [n,n];
equation
  u2_matrix = identity(n) * u2;
  y = u1 + u2_matrix[i,:];
  

  annotation (Icon(coordinateSystem(initialScale = 0.1), graphics = {Text(lineColor = {0, 0, 255}, extent = {{-150, 110}, {150, 150}}, textString = "%name", fontName = "DejaVu Sans Mono"), Line(points = {{-100, 60}, {-74, 24}, {-44, 24}}, color = {0, 0, 127}), Line(points = {{-100, -60}, {-74, -28}, {-42, -28}}, color = {0, 0, 127}), Ellipse(lineColor = {0, 0, 127}, extent = {{-50, -50}, {50, 50}}, endAngle = 360), Line(points = {{50, 0}, {100, 0}}, color = {0, 0, 127}), Text(extent = {{-38, -34}, {38, 34}}, textString = "+", fontName = "DejaVu Sans Mono")}), Diagram(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Rectangle(extent = {{-100, -100}, {100, 100}}, lineColor = {0, 0, 127}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Line(points = {{50, 0}, {100, 0}}, color = {0, 0, 255}), Line(points = {{-100, 60}, {-74, 24}, {-44, 24}}, color = {0, 0, 127}), Line(points = {{-100, -60}, {-74, -28}, {-42, -28}}, color = {0, 0, 127}), Ellipse(extent = {{-50, 50}, {50, -50}}, lineColor = {0, 0, 127}), Line(points = {{50, 0}, {100, 0}}, color = {0, 0, 127}), Text(extent = {{-36, 38}, {40, -30}}, lineColor = {0, 0, 0}, textString = "+"), Text(extent = {{-100, 52}, {5, 92}}, lineColor = {0, 0, 0}, textString = "k1"), Text(extent = {{-100, -52}, {5, -92}}, lineColor = {0, 0, 0}, textString = "k2")}));
end AddToIndex;
