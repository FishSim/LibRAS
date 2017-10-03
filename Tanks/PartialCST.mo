within LibRAS.Tanks;
  partial model PartialCST "Reactionless stirred tank with optional input of species and bubbling of air"
    import SI = Modelica.SIunits;
    import LibRAS.Types.Species.S;
    import LibRAS.Types.Species.X;
    import to_degC = Modelica.SIunits.Conversions.to_degC;
    replaceable package Medium = LibRAS.Media.WasteWater "Medium in the component";
    parameter Medium.ExtraProperty C_S_start[Medium.nC_S](quantity = Medium.solublesNames, each unit = "kg/m3", each displayUnit = "g/m3") = system.C_S_start "Start value of solubles" annotation(Dialog(tab = "Initialization", enable = Medium.nC_S > 0));
    parameter Medium.ExtraProperty C_X_start[Medium.nC_X](quantity = Medium.particulatesNames, each unit = "kg/m3", each displayUnit = "g/m3") = system.C_X_start "Start value of particulates" annotation(Dialog(tab = "Initialization", enable = Medium.nC_X > 0));
    parameter Real KLa(unit = "1/s") = 500 / (24 * 3600) "Gas exchange rate" annotation(Dialog(tab = "General", group = "CSBR"));
    parameter Real KLa_ratio(min=0) = 0.9 "KLa_CO2/KLa_O2 ratio" annotation(Dialog(tab = "General", group = "CSBR"));
  
    SI.Mass[Medium.nC_S] mC_S (each min=-1e-5) "Masses of dissolved substances in the fluid";
    Real[Medium.nC_S] C_S(each unit = "kg/m3", each displayUnit = "g/m3", each min = -1e-5) "Dissolved substance mixture content";
    Medium.ExtraPropertyFlowRate[Medium.nC_S] mbC_S_flow(each unit = "kg/s", each displayUnit = "g/s") "Dissolved substance mass flows across boundaries";
    Medium.ExtraPropertyFlowRate[nPorts, Medium.nC_S] ports_mC_S_flow(each unit = "kg/s", each displayUnit = "g/s") annotation(HideResult = true);
    Medium.ExtraPropertyFlowRate[Medium.nC_S] sum_ports_mC_S_flow(each unit = "kg/s", each displayUnit = "g/d") "Dissolved substance mass flows through ports" annotation(HideResult = true);
    Medium.ExtraPropertyFlowRate[Medium.nC_S] J_gas(each unit = "kg/s", each displayUnit = "g/s") "Gas diffusion rate";
    SI.Mass[Medium.nC_X] mC_X (each min=-1e-5) "Masses of particulate substances in the fluid";
    Real[Medium.nC_X] C_X(each unit = "kg/m3", each displayUnit = "g/m3", each min=-1e-5) "Particulate substance mixture content";
    Medium.ExtraPropertyFlowRate[Medium.nC_X] mbC_X_flow(each unit = "kg/s", each displayUnit = "g/s") "Particulate substance mass flows across boundaries";
    Medium.ExtraPropertyFlowRate[nPorts, Medium.nC_X] ports_mC_X_flow(each unit = "kg/s", each displayUnit = "g/s") annotation(HideResult = true);
    Medium.ExtraPropertyFlowRate[Medium.nC_X] sum_ports_mC_X_flow(each unit = "kg/s", each displayUnit = "g/s") "Particulate substance mass flows through ports" annotation(HideResult = true);

    output Medium.ExtraProperty C_S_sat_O2(each unit = "kg/m3", each displayUnit = "g/m3") = (14.53 - 0.411 * to_degC(medium.T) + 9.6e-3 * to_degC(medium.T) ^ 2 - 1.2e-4 * to_degC(medium.T) ^ 3) / 1000;

    SI.Volume Vf;
  
    parameter Boolean use_KLa_in = false "Get KLa from the input connector" annotation(Evaluate = true, HideResult = true, choices(checkBox = true));    
    parameter Boolean use_m_S_in = false "Get added S from the input connector" annotation(Evaluate = true, HideResult = true, choices(checkBox = true));
    parameter Boolean use_m_X_in = false "Get added X from the input connector" annotation(Evaluate = true, HideResult = true, choices(checkBox = true));

    Modelica.Blocks.Interfaces.RealInput KLa_in if use_KLa_in "Prescribed oxygenation rate" annotation(Placement(visible = true,transformation(origin = {-60, 100}, extent = {{-20, -20}, {20, 20}}, rotation = -90), iconTransformation(origin = {100, 0},extent = {{-20, -20}, {20, 20}}, rotation = 180)));
    Modelica.Blocks.Interfaces.RealInput m_S_in[Medium.nC_S] if use_m_S_in "Addition rate of soluble species (kg/s)" annotation(Placement(visible = true, transformation(origin = {40, 100}, extent = {{-20, -20}, {20, 20}}, rotation = -90), iconTransformation(origin = {-40, 100}, extent = {{-20, -20}, {20, 20}}, rotation = -90)));
    Modelica.Blocks.Interfaces.RealInput m_X_in[Medium.nC_X] if use_m_S_in "Addition rate of particulate species (kg/s)"annotation(Placement(visible = true, transformation(origin = {80, 100}, extent = {{-20, -20}, {20, 20}}, rotation = -90), iconTransformation(origin = {40, 100}, extent = {{-20, -20}, {20, 20}}, rotation = -90)));
    
protected
    Modelica.Blocks.Interfaces.RealInput KLa_in_internal "Needed to connect to conditional connector";
    Modelica.Blocks.Interfaces.RealInput m_S_in_internal[Medium.nC_S];
    Modelica.Blocks.Interfaces.RealInput m_X_in_internal[Medium.nC_X];
    Real[Medium.nC_S] mC_S_scaled(each min = -1e-5) "Scaled masses of dissolved substances in the fluid";
    Real[Medium.nC_S] reactionRate_S "Reaction rates (unscaled) of dissolved substances in the fluid";
    Real[Medium.nC_X] mC_X_scaled(each min = -1e-5) "Scaled masses of particulate substances in the fluid";
    Real[Medium.nC_X] reactionRate_X "Reaction rates (unscaled) of particulate substances in the fluid";

  equation
    mC_S = (m/medium.d)*C_S*Vf/V;
    mC_S_scaled = mC_S ./ Medium.C_S_nominal;
    mC_X = (m/medium.d)*C_X*Vf/V;
    mC_X_scaled = mC_X ./ Medium.C_X_nominal;
    for i in 1:nPorts loop
      ports[i].C_S_outflow = C_S;
      ports_mC_S_flow[i, :] = ports[i].m_flow / portInDensities[i] * actualStream(ports[i].C_S_outflow) "Dissolved substance mass flow";
      ports[i].C_X_outflow = C_X;
      ports_mC_X_flow[i, :] = ports[i].m_flow / portInDensities[i] * actualStream(ports[i].C_X_outflow) "Particulate mass flow";
    end for;
    for i in 1:Medium.nC_S loop
      sum_ports_mC_S_flow[i] = sum(ports_mC_S_flow[:, i]);
    end for;
    for i in 1:Medium.nC_X loop
      sum_ports_mC_X_flow[i] = sum(ports_mC_X_flow[:, i]);
    end for;
    for i in S loop
      if i == S.O then
        J_gas[Integer(i)] = Vf * KLa_in_internal * ((14.53 - 0.411 * to_degC(medium.T) + 9.6e-3 * to_degC(medium.T) ^ 2 - 1.2e-4 * to_degC(medium.T) ^ 3) / 1000 - C_S[Integer(i)]);
      elseif i == S.CO2 then
        J_gas[Integer(i)] = Vf * KLa_in_internal * KLa_ratio * (44*Modelica.SIunits.Conversions.to_bar(system.pCO2)*(75.14-2.605*to_degC(medium.T)+0.038*to_degC(medium.T)^2) / 1000 - C_S[Integer(i)]); // Remember the ugly /1000 here
      else
        J_gas[Integer(i)] = 0;
      end if;
    end for;
    // Mass balances
    if traceDynamics == Modelica.Fluid.Types.Dynamics.SteadyState then
      // These are probably all wrong
      zeros(Medium.nC_S) = mbC_S_flow + reactionRate_S;
      zeros(Medium.nC_X) = mbC_X_flow + reactionRate_X;
    end if;
    
    connect(KLa_in, KLa_in_internal);
    if not use_KLa_in then
      KLa_in_internal = KLa;
    end if;
    connect(m_S_in, m_S_in_internal);
    if not use_m_S_in then
      m_S_in_internal = fill(0, Medium.nC_S);
    end if;
    connect(m_X_in, m_X_in_internal);
    if not use_m_X_in then
      m_X_in_internal = fill(0, Medium.nC_X);
    end if;
  
  initial equation
    if traceDynamics == Modelica.Fluid.Types.Dynamics.FixedInitial then
      mC_S_scaled = m / medium.d * C_S_start[1:Medium.nC_S] * (Vf/V) ./ Medium.C_S_nominal;
      mC_X_scaled = m / medium.d * C_X_start[1:Medium.nC_X] * (Vf/V) ./ Medium.C_X_nominal;
    elseif traceDynamics == Modelica.Fluid.Types.Dynamics.SteadyStateInitial then
      der(mC_S_scaled) = zeros(Medium.nC_S);
      der(mC_X_scaled) = zeros(Medium.nC_X);
    end if;
  end PartialCST;
