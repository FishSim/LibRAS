within LibRAS.Machines;

partial model PartialPump "Base model for centrifugal pumps"
    import SI = Modelica.SIunits;
    import NonSI = Modelica.SIunits.Conversions.NonSIunits;
    import Modelica.Constants;
    import Modelica.Fluid.Machines.BaseClasses.PumpCharacteristics;

  extends LibRAS.Interfaces.PartialTwoPort(
    port_b_exposesState = energyDynamics<>Modelica.Fluid.Types.Dynamics.SteadyState or massDynamics<>Modelica.Fluid.Types.Dynamics.SteadyState,
    port_a(
      p(start=p_a_start),
      m_flow(start = m_flow_start,
             min = if allowFlowReversal and not checkValve then -Constants.inf else 0)),
    port_b(
      p(start=p_b_start),
      m_flow(start = -m_flow_start,
             max = if allowFlowReversal and not checkValve then +Constants.inf else 0)));

  // Initialization
  parameter Medium.AbsolutePressure p_a_start=system.p_start
      "Guess value for inlet pressure"
    annotation(Dialog(tab="Initialization"));
  parameter Medium.AbsolutePressure p_b_start=p_a_start
      "Guess value for outlet pressure"
    annotation(Dialog(tab="Initialization"));
  parameter Medium.MassFlowRate m_flow_start = system.m_flow_start
      "Guess value of m_flow = port_a.m_flow"
    annotation(Dialog(tab = "Initialization"));
  final parameter SI.VolumeFlowRate V_flow_single_init = m_flow_start/rho_nominal/nParallel
      "Used for simplified initialization model";
  final parameter SI.Height delta_head_init = flowCharacteristic(V_flow_single_init)-flowCharacteristic(0)
      "Used for simplified initialization model";

  // Characteristic curves
  parameter Integer nParallel(min=1) = 1 "Number of pumps in parallel"
    annotation(Dialog(group="Characteristics"));
  replaceable function flowCharacteristic =
      PumpCharacteristics.baseFlow
      "Head vs. V_flow characteristic at nominal speed and density"
    annotation(Dialog(group="Characteristics"), choicesAllMatching=true);
  parameter NonSI.AngularVelocity_rpm N_nominal
      "Nominal rotational speed for flow characteristic"
    annotation(Dialog(group="Characteristics"));
  parameter Medium.Density rho_nominal = Medium.density_pTX(Medium.p_default, Medium.T_default, Medium.X_default)
      "Nominal fluid density for characteristic"
    annotation(Dialog(group="Characteristics"));
  parameter Boolean use_powerCharacteristic = false
      "Use powerCharacteristic (vs. efficiencyCharacteristic)"
     annotation(Evaluate=true,Dialog(group="Characteristics"));
  replaceable function powerCharacteristic =
        PumpCharacteristics.quadraticPower (
       V_flow_nominal={0,0,0},W_nominal={0,0,0})
      "Power consumption vs. V_flow at nominal speed and density"
    annotation(Dialog(group="Characteristics", enable = use_powerCharacteristic),
               choicesAllMatching=true);
  replaceable function efficiencyCharacteristic =
    PumpCharacteristics.constantEfficiency(eta_nominal = 0.8) constrainedby
      PumpCharacteristics.baseEfficiency
      "Efficiency vs. V_flow at nominal speed and density"
    annotation(Dialog(group="Characteristics",enable = not use_powerCharacteristic),
               choicesAllMatching=true);

  // Assumptions
  parameter Boolean checkValve=false "= true to prevent reverse flow"
    annotation(Dialog(tab="Assumptions"), Evaluate=true);

  parameter SI.Volume V = 0 "Volume inside the pump"
    annotation(Dialog(tab="Assumptions"),Evaluate=true);

  // Energy and mass balance
  extends LibRAS.Interfaces.PartialLumpedVolume(
      final fluidVolume = V,
      energyDynamics = Modelica.Fluid.Types.Dynamics.SteadyState,
      massDynamics = Modelica.Fluid.Types.Dynamics.SteadyState,
      final p_start = p_b_start);

  // Heat transfer through boundary, e.g., to add a housing
  parameter Boolean use_HeatTransfer = false
      "= true to use a HeatTransfer model, e.g., for a housing"
      annotation (Dialog(tab="Assumptions",group="Heat transfer"));
  replaceable model HeatTransfer =
      Modelica.Fluid.Vessels.BaseClasses.HeatTransfer.IdealHeatTransfer
    constrainedby
      Modelica.Fluid.Vessels.BaseClasses.HeatTransfer.PartialVesselHeatTransfer
      "Wall heat transfer"
      annotation (Dialog(tab="Assumptions",group="Heat transfer",enable=use_HeatTransfer),choicesAllMatching=true);
  HeatTransfer heatTransfer(
    redeclare final package Medium = Medium,
    final n=1,
    surfaceAreas={4*Modelica.Constants.pi*(3/4*V/Modelica.Constants.pi)^(2/3)},
    final states = {medium.state},
    final use_k = use_HeatTransfer)
      annotation (Placement(transformation(
        extent={{-10,-10},{30,30}},
        rotation=180,
        origin={50,-10})));
  Modelica.Thermal.HeatTransfer.Interfaces.HeatPort_a heatPort if use_HeatTransfer
    annotation (Placement(transformation(extent={{30,-70},{50,-50}})));

  // Variables
  final parameter SI.Acceleration g=system.g;
  Medium.Density rho = medium.d;
  SI.Pressure dp_pump = port_b.p - port_a.p "Pressure increase";
  SI.Height head = dp_pump/(rho*g) "Pump head";
  SI.MassFlowRate m_flow = port_a.m_flow "Mass flow rate (total)";
  SI.MassFlowRate m_flow_single = m_flow/nParallel
      "Mass flow rate (single pump)";
  SI.VolumeFlowRate V_flow "Volume flow rate (total)";
  SI.VolumeFlowRate V_flow_single(start = m_flow_start/rho_nominal/nParallel)
      "Volume flow rate (single pump)";
  NonSI.AngularVelocity_rpm N(start = N_nominal) "Shaft rotational speed";
  SI.Power W_single "Power Consumption (single pump)";
  SI.Power W_total = W_single*nParallel "Power Consumption (total)";
  Real eta "Global Efficiency";
  final constant Medium.MassFlowRate unit_m_flow=1 annotation (HideResult=true);
  Real s(start = m_flow_start/unit_m_flow)
      "Curvilinear abscissa for the flow curve in parametric form (either mass flow rate or head)";

  // Diagnostics
  replaceable model Monitoring =
    Modelica.Fluid.Machines.BaseClasses.PumpMonitoring.PumpMonitoringBase
    constrainedby
      Modelica.Fluid.Machines.BaseClasses.PumpMonitoring.PumpMonitoringBase
      "Optional pump monitoring"
      annotation(Dialog(tab="Advanced", group="Diagnostics"), choicesAllMatching=true);
  final parameter Boolean show_NPSHa = false
      "obsolete -- remove modifier and specify Monitoring for NPSH instead"
    annotation(Dialog(tab="Advanced", group="Obsolete"));
  Monitoring monitoring(
          redeclare final package Medium = Medium,
          final state_in = Medium.setState_phX(port_a.p, inStream(port_a.h_outflow), inStream(port_a.Xi_outflow)),
          final state = medium.state) "Monitoring model"
     annotation (Placement(transformation(extent={{-64,-42},{-20,0}})));
  protected
  constant SI.Height unitHead = 1;
  constant SI.MassFlowRate unitMassFlowRate = 1;

equation
  // Flow equations
   V_flow = homotopy(m_flow/rho,
                     m_flow/rho_nominal);
   V_flow_single = V_flow/nParallel;
  if not checkValve then
    // Regular flow characteristics without check valve
    head = homotopy((N/N_nominal)^2*flowCharacteristic(V_flow_single*N_nominal/N),
                     N/N_nominal*(flowCharacteristic(0)+delta_head_init*V_flow_single));
    s = 0;
  else
    // Flow characteristics when check valve is open
    head = homotopy(if s > 0 then (N/N_nominal)^2*flowCharacteristic(V_flow_single*N_nominal/N)
                             else (N/N_nominal)^2*flowCharacteristic(0) - s*unitHead,
                    N/N_nominal*(flowCharacteristic(0)+delta_head_init*V_flow_single));
    V_flow_single = homotopy(if s > 0 then s*unitMassFlowRate/rho else 0,
                             s*unitMassFlowRate/rho_nominal);
  end if;
  // Power consumption
  if use_powerCharacteristic then
    W_single = homotopy((N/N_nominal)^3*(rho/rho_nominal)*powerCharacteristic(V_flow_single*N_nominal/N),
                        N/N_nominal*V_flow_single/V_flow_single_init*powerCharacteristic(V_flow_single_init));
    eta = dp_pump*V_flow_single/W_single;
  else
    eta = homotopy(efficiencyCharacteristic(V_flow_single*(N_nominal/N)),
                   efficiencyCharacteristic(V_flow_single_init));
    W_single = homotopy(dp_pump*V_flow_single/eta,
                        dp_pump*V_flow_single_init/eta);
  end if;

  // Energy balance
  Wb_flow = W_total;
  Qb_flow = heatTransfer.Q_flows[1];
  Hb_flow = port_a.m_flow*actualStream(port_a.h_outflow) +
            port_b.m_flow*actualStream(port_b.h_outflow);

  // Ports
  port_a.h_outflow = medium.h;
  port_b.h_outflow = medium.h;
  port_b.p = medium.p
      "outlet pressure is equal to medium pressure, which includes Wb_flow";

  // Mass balance
  mb_flow = port_a.m_flow + port_b.m_flow;

  mbXi_flow = port_a.m_flow*actualStream(port_a.Xi_outflow) +
              port_b.m_flow*actualStream(port_b.Xi_outflow);
  port_a.Xi_outflow = medium.Xi;
  port_b.Xi_outflow = medium.Xi;

  mbC_flow = port_a.m_flow*actualStream(port_a.C_outflow) +
             port_b.m_flow*actualStream(port_b.C_outflow);
  port_a.C_outflow = C;
  port_b.C_outflow = C;

  mbC_S_flow = port_a.m_flow*actualStream(port_a.C_S_outflow) +
             port_b.m_flow*actualStream(port_b.C_S_outflow);
  port_a.C_S_outflow = C_S;
  port_b.C_S_outflow = C_S;
  mbC_X_flow = port_a.m_flow*actualStream(port_a.C_X_outflow) +
             port_b.m_flow*actualStream(port_b.C_X_outflow);
  port_a.C_X_outflow = C_X;
  port_b.C_X_outflow = C_X;

  connect(heatTransfer.heatPorts[1], heatPort) annotation (Line(
      points={{40,-34},{40,-60}},
      color={127,0,0}));
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=true,  extent={{-100,-100},{100,
              100}}), graphics={
          Rectangle(
            extent={{-100,46},{100,-46}},
            lineColor={0,0,0},
            fillColor={0,127,255},
            fillPattern=FillPattern.HorizontalCylinder),
          Polygon(
            points={{-48,-60},{-72,-100},{72,-100},{48,-60},{-48,-60}},
            lineColor={0,0,255},
            pattern=LinePattern.None,
            fillColor={0,0,0},
            fillPattern=FillPattern.VerticalCylinder),
          Ellipse(
            extent={{-80,80},{80,-80}},
            lineColor={0,0,0},
            fillPattern=FillPattern.Sphere,
            fillColor={0,100,199}),
          Polygon(
            points={{-28,30},{-28,-30},{50,-2},{-28,30}},
            lineColor={0,0,0},
            pattern=LinePattern.None,
            fillPattern=FillPattern.HorizontalCylinder,
            fillColor={255,255,255})}));
end PartialPump;