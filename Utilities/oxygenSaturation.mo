within LibRAS.Utilities;

function oxygenSaturation
  import to_degC = Modelica.SIunits.Conversions.to_degC;
  input Modelica.SIunits.Temperature T;
  output Modelica.SIunits.MassConcentration C_O2_sat;
  algorithm
    C_O2_sat := ((14.53 - 0.411 * to_degC(T) + 9.6e-3 * to_degC(T) ^ 2 - 1.2e-4 * to_degC(T) ^ 3) / 1000);
end oxygenSaturation;