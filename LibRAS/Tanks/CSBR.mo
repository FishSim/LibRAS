within LibRAS.Tanks;
model CSBR "Volume of fixed size, closed to the ambient, with inlet/outlet ports"

  import Modelica.Constants.pi;
  import SI = Modelica.SIunits;

  // Mass and energy balance, ports
  extends Tanks.PartialTank;
  extends Tanks.PartialLumpedVessel(final fluidVolume = V, vesselArea = pi * (3 / 4 * V) ^ (2 / 3), heatTransfer(surfaceAreas = {4 * pi * (3 / 4 * V / pi) ^ (2 / 3)}));
  extends Tanks.PartialCSBR;
  equation

end CSBR;
