within LibRAS.Blocks;

partial block SISO2
  "1 Single Input / 2 Single Output continuous control block"
  extends Modelica.Blocks.Icons.Block;

  Modelica.Blocks.Interfaces.RealInput u "Connector of Real input signal" annotation (Placement(
        transformation(extent={{-140,-20},{-100,20}})));
  Modelica.Blocks.Interfaces.RealOutput y1 "Connector of Real output signal" annotation (Placement(
        transformation(extent={{100,40},{140,80}})));
  Modelica.Blocks.Interfaces.RealOutput y2 "Connector of Real output signal" annotation (Placement(
        transformation(extent={{100,-80},{140,-40}})));
end SISO2;