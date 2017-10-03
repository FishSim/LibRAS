within LibRAS.Tanks;
partial model PartialTank "Volume of fixed size, closed to the ambient, with inlet/outlet ports"

  import Modelica.Constants.pi;
  import SI = Modelica.SIunits;

  // Mass and energy balance, ports
//  extends Tanks.PartialLumpedVessel(final fluidVolume = V, vesselArea = pi * (3 / 4 * V) ^ (2 / 3), heatTransfer(surfaceAreas = {4 * pi * (3 / 4 * V / pi) ^ (2 / 3)}));
  replaceable package Medium = LibRAS.Media.WasteWater "Medium in the component";
  parameter SI.Volume V "Volume";
  equation
    Wb_flow = 0;
    for i in 1:nPorts loop
      vessel_ps_static[i] = medium.p;
    end for;
    
    mbC_S_flow = sum_ports_mC_S_flow + m_S_in_internal;
    mbC_X_flow = sum_ports_mC_X_flow + m_X_in_internal;
  
  annotation(defaultComponentName = "volume", Icon(coordinateSystem(preserveAspectRatio = true, extent = {{-100, -100}, {100, 100}}), graphics = {Ellipse(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 0}, fillPattern = FillPattern.Sphere, fillColor = {170, 213, 255}), Text(extent = {{-150, 12}, {150, -18}}, lineColor = {0, 0, 0}, textString = "V=%V")}));
end PartialTank;
