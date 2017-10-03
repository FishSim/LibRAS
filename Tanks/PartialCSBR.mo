within LibRAS.Tanks;
partial model PartialCSBR
  extends PartialCST;
  
  import SI = Modelica.SIunits;
  import LibRAS.Types.Species.S;
  import LibRAS.Types.Species.X;

  parameter Medium.ExtraProperty C_S_film_start[Medium.nC_S](quantity=Medium.solublesNames, each unit="kg/m3", each displayUnit="g/m3") = system.C_S_film_start
  "Start value of solubles in film" annotation (Dialog(tab="Initialization", enable=Medium.nC_S > 0), HideResult = true);
  parameter Medium.ExtraProperty C_X_film_start[Medium.nC_X](quantity=Medium.particulatesNames, each unit="kg/m3", each displayUnit="g/m3") = system.C_X_film_start
  "Start value of particulates in film" annotation (Dialog(tab="Initialization", enable=Medium.nC_X > 0), HideResult = true);
  parameter SI.Thickness L_start (displayUnit="mm") = 1.0e-4 "Initial biofilm thickness" annotation(Dialog(tab="General", group="CSBR"), HideResult = true);

  parameter SI.Temp_C T_bio = 15 "Biofilm parameter evaluation temperature" annotation(Dialog(tab="General", group="CSBR"));
  parameter Real carrier_packing(min=0.0) = 0.70 "Biocarrier packing" annotation(Dialog(tab="General", group="CSBR"));
  parameter Real carrier_displacement(min=0.0) = 0.18 "Biocarrier displacement" annotation(Dialog(tab="General", group="CSBR"));
  parameter SI.Area A = V*carrier_packing*system.As "Biocarrier surface" annotation(Dialog(tab="General", group="CSBR"));
  parameter SI.Volume Vw = V*(1-carrier_displacement*carrier_packing) "Available water volume w/o biofilm" annotation(Dialog(tab="General", group="CSBR")); // KAN VARA FEL
  parameter Boolean nitrifying = false "Biofilm is nitrifying" annotation(Evaluate = true, Dialog(tab="General", group="CSBR"), choices(checkBox = true));
  parameter Real K_d (unit="1/(m.s)", displayUnit="1/(m.d)") = if nitrifying then system.K_dA else system.K_dH "Detachment coefficient" annotation(Evaluate = true, Dialog(tab="Advanced", group="CSBR"));
  parameter Real filmPorosity = if nitrifying then system.eps_A  else system.eps_H "Biofilm porosity" annotation(Evaluate = true, Dialog(tab="Advanced", group="CSBR"));

  Medium.ExtraPropertyFlowRate[Medium.nC_S]         J_S (each unit="kg/(m2.s)", each displayUnit="g/(m2.s)") "Dissolved substance diffusion rate";
  Medium.ExtraProperty[Medium.nC_S]                 C_S_film (each unit="kg/m3", each displayUnit="g/m3") "Film dissolved substance concentration";

  Medium.ExtraPropertyFlowRate[Medium.nC_X]         J_X (each unit="kg/(m2.s)", each displayUnit="g/(m2.s)") "Particulate substance diffusion rate";
  Medium.ExtraProperty[Medium.nC_X]                 C_X_film (each unit="kg/m3", each displayUnit="g/m3") "Film particulate substance concentration";

  Real heterotrophDominance (min=0, max=1.0) "Dominance of heterotrophic bacteria. 1 = No autotrophs, 0 = no heterotrophs";

  Types.ProcessData.ProcessMatrix bioparam ( // Pass ALL the parameters!
    _mu_H = system.mu_H,
    _K_S  = system.K_S,
    _K_OH = system.K_OH,
    _K_NO = system.K_NO,
    _b_H  = system.b_H ,
    _mu_A = system.mu_A,
    _mu_AOB=system.mu_AOB,
    _mu_NOB=system.mu_NOB,
    _K_NH = system.K_NH,
    _K_OA = system.K_OA,
    _b_A  = system.b_A,
    _b_AOB= system.b_AOB,
    _b_NOB= system.b_NOB,
    _nu_g = system.nu_g,
    _nu_NO2=system.nu_NO2,
    _nu_NO3=system.nu_NO3,
    _k_a  = system.k_a,
    _k_h  = system.k_h,
    _K_X  = system.K_X,
    _nu_h = system.nu_h,
    _Y_H  = system.Y_H,
    _Y_A  = system.Y_A,
    _Y_AOB= system.Y_AOB,
    _Y_NOB= system.Y_NOB,
    _f_p  = system.f_p,
    _i_XB = system.i_XB,
    _i_XP = system.i_XP,
    _K_Alk= system.K_Alk,
    _K_NHH= system.K_NHH,
    _K_NHI= system.K_NHI,
    T = T_bio
    );

  SI.Thickness L;

  output Real nitrificationRate_AO (unit="kg/(m2.s)", displayUnit="g/(m2.d)") = -(P_film[4])*bioparam.SoluteReactions[S.NH, 4]*L;
  output Real nitrificationRate_NO (unit="kg/(m2.s)", displayUnit="g/(m2.d)") = -(P_film[5])*bioparam.SoluteReactions[S.NO2, 5]*L;
  output Real denitrificationRate (unit="kg/(m2.s)", displayUnit="g/(m2.d)") = -L*sum(P_film[2:3]*bioparam.SoluteReactions[S.NO2:S.NO3, 2:3]);
  output Real[:] R_S (each unit="kg/s", each displayUnit="g/d") = Vf*reactionRate_S + reactionRate_S_film*L*A "Generation/consumption of species";
  output Real[:] R_X (each unit="kg/s", each displayUnit="g/d") = Vf*reactionRate_X + reactionRate_X_film*L*A "Generation/consumption of species";
  output Real[:] r_S_total (each unit="kg/(m3.s)", each displayUnit="g/(m3.d)") = R_S/V "Generation/consumption of species per unit reactor volume";
  output Real[:] r_X_total (each unit="kg/(m3.s)", each displayUnit="g/(m3.d)") = R_X/V "Generation/consumption of species per unit reactor volume";
  output Real[:] r_S_film (each unit="kg/(m2.s)", each displayUnit="g/(m2.d)") = reactionRate_S_film*L "Generation/consumption of species per unit biofilm area";
  output Real[:] r_X_film (each unit="kg/(m2.s)", each displayUnit="g/(m2.d)") = reactionRate_X_film*L "Generation/consumption of species per unit biofilm area";

  output Real[S, 11] R_S_film (each unit="kg/(m2.s)", each displayUnit="g/(m2.d)") = {P_film .* bioparam.SoluteReactions[i, :] for i in S} * L "Generation/consumption of species per unit biofilm area from each process" annotation(HideResult = true);
  //output Real[S, 11] R_S_bulk (each unit="kg/(m3.s)", each displayUnit="g/(m3.d)") = {P_bulk .* bioparam.SoluteReactions[i, :] for i in S} "Generation/consumption of species from each process";

  protected
    Real[11] P_bulk (each unit="kg/s", each displayUnit="g/d") "Process contribution to biomass growth rate in bulk";
    Real[11] P_film (each unit="kg/s", each displayUnit="g/d") "Process contribution to biomass growth rate in film";

    Real[Medium.nC_S] reactionRate_S_film  (each unit="kg/s", each displayUnit="g/d") "Reaction rates (unscaled) of dissolved substances in the film";
    Real[Medium.nC_X] reactionRate_X_film  (each unit="kg/s", each displayUnit="g/d") "Reaction rates (unscaled) of particulate substances in the film";


  equation
    Vf = (Vw-L*A);
    heterotrophDominance = C_X_film[3]/(C_X_film[3]+C_X_film[4]+C_X_film[5]);

    // Mass balances
    if traceDynamics == Modelica.Fluid.Types.Dynamics.SteadyState then // These are probably all wrong
      zeros(Medium.nC_S)  = mbC_S_flow + reactionRate_S;
      der(C_S_film) = zeros(Medium.nC_S);
      zeros(Medium.nC_X)  = mbC_X_flow + reactionRate_X;
      der(C_X_film) = zeros(Medium.nC_X);
      der(L)=0;
    else
      der(mC_S_scaled) = mbC_S_flow./Medium.C_S_nominal + (A*der(L)*C_S)./Medium.C_S_nominal - A*J_S./Medium.C_S_nominal + Vf*reactionRate_S./Medium.C_S_nominal + J_gas./Medium.C_S_nominal;
      der(C_S_film) = 1/L * (J_S/filmPorosity - C_S_film*der(L)) + reactionRate_S_film/filmPorosity;
      der(mC_X_scaled) = mbC_X_flow./Medium.C_X_nominal + (A*der(L)*C_X)./Medium.C_X_nominal - A*J_X./Medium.C_X_nominal + Vf*reactionRate_X./Medium.C_X_nominal;
      der(C_X_film) = 1/L * (J_X - C_X_film*der(L)) + reactionRate_X_film;
      der(L) = 1/(system.rho_x*(1-filmPorosity))*sum((if i<>X.ND then J_X[Integer(i)]+L*reactionRate_X_film[Integer(i)] else 0) for i in X); // Exclude ND as per the report
    end if;

    // Reaction rates and diffusion
    for i in S loop
      reactionRate_S[Integer(i)] = P_bulk * bioparam.SoluteReactions[i, :];
      reactionRate_S_film[Integer(i)] = P_film * bioparam.SoluteReactions[i, :];
      J_S[Integer(i)] = system.K_x*(C_S[Integer(i)] - C_S_film[Integer(i)]);
    end for;

    for i in X loop
      reactionRate_X[Integer(i)] = P_bulk * bioparam.ParticulateReactions[i, :];
      reactionRate_X_film[Integer(i)] = P_film * bioparam.ParticulateReactions[i, :];
      J_X[Integer(i)] = system.K_a*C_X[Integer(i)] - K_d*L^2*C_X_film[Integer(i)];
    end for;

    P_bulk = {
      bioparam.mu_H *          (C_S[2]/(bioparam.K_S + C_S[2])) * (C_S[3]/(bioparam.K_OH + C_S[3]))         * (C_S[6]/(bioparam.K_NHH + C_S[6]))           * C_X[3],
      bioparam.mu_H * bioparam.nu_NO2 * (C_S[2]/(bioparam.K_S + C_S[2])) * (bioparam.K_OH/(bioparam.K_OH + C_S[3])) * (C_S[4]/(bioparam.K_NO + C_S[4])) * (C_S[4]/(C_S[4] + C_S[5] + Modelica.Constants.eps)) * C_X[3] * (C_S[6]/(bioparam.K_NHH + C_S[6])),
      bioparam.mu_H * bioparam.nu_NO3 * (C_S[2]/(bioparam.K_S + C_S[2])) * (bioparam.K_OH/(bioparam.K_OH + C_S[3])) * (C_S[5]/(bioparam.K_NO + C_S[5])) * (C_S[5]/(C_S[4] + C_S[5] + Modelica.Constants.eps)) * C_X[3] * (C_S[6]/(bioparam.K_NHH + C_S[6])),
      bioparam.mu_AOB * (C_S[6]/(bioparam.K_NH + C_S[6])) * (C_S[3]/(bioparam.K_OA + C_S[3])) * (C_S[8]/(bioparam.K_Alk + C_S[8])) * C_X[4],
      bioparam.mu_NOB * (C_S[4]/(bioparam.K_NH + C_S[4])) * (C_S[3]/(bioparam.K_OA + C_S[3])) * (C_S[8]/(bioparam.K_Alk + C_S[8])) * C_X[5] * (bioparam.K_NHI/(C_S[6] + bioparam.K_NHI)),
      bioparam.b_H   * C_X[3],
      bioparam.b_AOB * C_X[4],
      bioparam.b_NOB * C_X[5],
      bioparam.k_a  * C_S[7]  * C_X[3],
      bioparam.k_h  * ((C_X[2]/C_X[3])/(bioparam.K_X + (C_X[2]/C_X[3]))) * ((C_S[3]/(bioparam.K_OH + C_S[3])) + bioparam.nu_h*(bioparam.K_OH/(bioparam.K_OH + C_S[3]))*((C_S[4]+C_S[5])/(bioparam.K_NO + C_S[4] + C_S[5]))) * C_X[3],
      bioparam.k_h  * ((C_X[2]/C_X[3])/(bioparam.K_X + (C_X[2]/C_X[3]))) * ((C_S[3]/(bioparam.K_OH + C_S[3])) + bioparam.nu_h*(bioparam.K_OH/(bioparam.K_OH + C_S[3]))*((C_S[4]+C_S[5])/(bioparam.K_NO + C_S[4] + C_S[5]))) * C_X[3] * C_X[7] / C_X[2]
    };

    P_film = {
      bioparam.mu_H *          (C_S_film[2]/(bioparam.K_S + C_S_film[2])) * (C_S_film[3]/(bioparam.K_OH + C_S_film[3]))         * (C_S_film[6]/(bioparam.K_NHH + C_S_film[6]))           * C_X_film[3],
      bioparam.mu_H * bioparam.nu_NO2 * (C_S_film[2]/(bioparam.K_S + C_S_film[2])) * (bioparam.K_OH/(bioparam.K_OH + C_S_film[3])) * (C_S_film[4]/(bioparam.K_NO + C_S_film[4])) * (C_S_film[4]/(C_S_film[4] + C_S_film[5] + Modelica.Constants.eps)) * C_X_film[3] * (C_S_film[6]/(bioparam.K_NHH + C_S_film[6])),
      bioparam.mu_H * bioparam.nu_NO3 * (C_S_film[2]/(bioparam.K_S + C_S_film[2])) * (bioparam.K_OH/(bioparam.K_OH + C_S_film[3])) * (C_S_film[5]/(bioparam.K_NO + C_S_film[5])) * (C_S_film[5]/(C_S_film[4] + C_S_film[5] + Modelica.Constants.eps)) * C_X_film[3] * (C_S_film[6]/(bioparam.K_NHH + C_S_film[6])),
      bioparam.mu_AOB * (C_S_film[6]/(bioparam.K_NH + C_S_film[6])) * (C_S_film[3]/(bioparam.K_OA + C_S_film[3])) * (C_S_film[8]/(bioparam.K_Alk + C_S_film[8])) * C_X_film[4],
      bioparam.mu_NOB * (C_S_film[4]/(bioparam.K_NH + C_S_film[4])) * (C_S_film[3]/(bioparam.K_OA + C_S_film[3])) * (C_S_film[8]/(bioparam.K_Alk + C_S_film[8])) * C_X_film[5] * (bioparam.K_NHI/(C_S_film[6] + bioparam.K_NHI)),
      bioparam.b_H   * C_X_film[3],
      bioparam.b_AOB * C_X_film[4],
      bioparam.b_NOB * C_X_film[5],
      bioparam.k_a  * C_S_film[7]  * C_X_film[3],
      bioparam.k_h  * ((C_X_film[2]/C_X_film[3])/(bioparam.K_X + (C_X_film[2]/C_X_film[3]))) * ((C_S_film[3]/(bioparam.K_OH + C_S_film[3])) + bioparam.nu_h*(bioparam.K_OH/(bioparam.K_OH + C_S_film[3]))*((C_S_film[4]+C_S_film[5])/(bioparam.K_NO + C_S_film[4] + C_S_film[5]))) * C_X_film[3],
      bioparam.k_h  * ((C_X_film[2]/C_X_film[3])/(bioparam.K_X + (C_X_film[2]/C_X_film[3]))) * ((C_S_film[3]/(bioparam.K_OH + C_S_film[3])) + bioparam.nu_h*(bioparam.K_OH/(bioparam.K_OH + C_S_film[3]))*((C_S_film[4]+C_S_film[5])/(bioparam.K_NO + C_S_film[4] + C_S_film[5]))) * C_X_film[3] * C_X_film[7] / C_X_film[2]
    };

  initial equation
    if traceDynamics == Modelica.Fluid.Types.Dynamics.FixedInitial then
      C_S_film = C_S_film_start[1:Medium.nC_S];
      C_X_film = C_X_film_start[1:Medium.nC_X];
      L=L_start;
    elseif traceDynamics == Modelica.Fluid.Types.Dynamics.SteadyStateInitial then
      der(C_S_film) = zeros(Medium.nC_S);
      der(C_X_film) = zeros(Medium.nC_X);
    end if;

end PartialCSBR;
