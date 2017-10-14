within LibRAS.Tanks;
model CST "Ideally stirred spherical volume with inlet/outlet ports and addition of species. Any reactions are neglected."

  import Modelica.Constants.pi;
  import SI = Modelica.SIunits;
  import LibRAS.Types.Species.S;
  import LibRAS.Types.Species.X;
  // Mass and energy balance, ports
  extends Tanks.PartialTank;
  extends Tanks.PartialLumpedVessel(fluidVolume = V, vesselArea = pi * (3 / 4 * V) ^ (2 / 3), heatTransfer(surfaceAreas = {4 * pi * (3 / 4 * V / pi) ^ (2 / 3)}));
  extends Tanks.PartialCST;
  equation
    Vf = fluidVolume; // There might be fish in here, but there are at least no carriers or biofilm
    // Mass balances
    if traceDynamics <> Modelica.Fluid.Types.Dynamics.SteadyState then
      der(mC_S_scaled) = mbC_S_flow./Medium.C_S_nominal + Vf*reactionRate_S./Medium.C_S_nominal + J_gas./Medium.C_S_nominal;
      der(mC_X_scaled) = mbC_X_flow./Medium.C_X_nominal + Vf*reactionRate_X./Medium.C_X_nominal;
    end if;

    // Reaction rates
    for i in S loop
      reactionRate_S[Integer(i)] = 0;
    end for;
    for i in X loop
      reactionRate_X[Integer(i)] = 0;
    end for;


end CST;
