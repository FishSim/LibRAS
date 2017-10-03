within LibRAS.Sensors;
model SoluteSensor
  extends LibRAS.Sensors.PartialAbsoluteSensor;
  extends Modelica.Icons.RotationalSensor;
  parameter String substanceName = "O" "Name of sensed substance (Not used)";
  parameter Integer substanceIndex = Integer(LibRAS.Types.Species.S.O) "Species to sense";

Modelica.Blocks.Interfaces.RealOutput C (quantity="MassConcentration", unit="kg/m3", displayUnit="g/m3") "Trace substance in port medium"
  annotation (Placement(transformation(extent={{100,-10},{120,10}})));

  protected
    parameter Integer ind(fixed=false) "Index of species in vector of auxiliary substances";
    Medium.ExtraProperty CVec[Medium.nC_S](quantity=Medium.solublesNames) "Trace substances vector, needed because indexed argument for the operator inStream is not supported";

  initial algorithm
    ind:= -1;
    for i in 1:Medium.nC_S loop
      if ( Modelica.Utilities.Strings.isEqual(Medium.solublesNames[i], substanceName)) then
        ind := i;
      end if;
    end for;
    assert(ind > 0, "Substance S.'" + substanceName + "' is not present in medium '"
        + Medium.mediumName + "'.\n"
        + "Check sensor parameter and medium model.");
  equation
    CVec = inStream(port.C_S_outflow);
    C = CVec[substanceIndex];
  annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{100,100}}), graphics={
      Line(points={{0,-70},{0,-100}}, color={0,0,127}),
      Text(
        extent={{-150,80},{150,120}},
        textString="%name",
        lineColor={0,0,255}),
      Text(
        extent={{160,-30},{60,-60}},
        lineColor={0,0,0},
        textString="C"),
      Line(points={{70,0},{100,0}}, color={0,0,127})}));
end SoluteSensor;
