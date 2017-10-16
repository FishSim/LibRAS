within LibRAS.Machines;

model ControlledPump
  "Centrifugal pump with ideally controlled mass flow rate"
  import SI = Modelica.SIunits;
  import Modelica.SIunits.Conversions.NonSIunits.AngularVelocity_rpm;
  extends LibRAS.Machines.PartialPump(
    N_nominal=1500,
    N(start=N_nominal),
    redeclare replaceable function flowCharacteristic =
        Modelica.Fluid.Machines.BaseClasses.PumpCharacteristics.quadraticFlow
        ( V_flow_nominal={0, V_flow_op, 1.5*V_flow_op},
          head_nominal={2*head_op, head_op, 0}));

  // nominal values
  parameter Medium.AbsolutePressure p_a_nominal
    "Nominal inlet pressure for predefined pump characteristics";
  parameter Medium.AbsolutePressure p_b_nominal
    "Nominal outlet pressure, fixed if not control_m_flow and not use_p_set";
  parameter Medium.MassFlowRate m_flow_nominal
    "Nominal mass flow rate, fixed if control_m_flow and not use_m_flow_set";

  // what to control
  parameter Boolean control_m_flow = true
    "= false to control outlet pressure port_b.p instead of m_flow"
    annotation(Evaluate = true);
  parameter Boolean use_m_flow_set = false
    "= true to use input signal m_flow_set instead of m_flow_nominal"
    annotation (Dialog(enable = control_m_flow));
  parameter Boolean use_p_set = false
    "= true to use input signal p_set instead of p_b_nominal"
    annotation (Dialog(enable = not control_m_flow));

  // exemplary characteristics
  final parameter SI.VolumeFlowRate V_flow_op = m_flow_nominal/rho_nominal
    "operational volume flow rate according to nominal values";
  final parameter SI.Height head_op = (p_b_nominal-p_a_nominal)/(rho_nominal*g)
    "operational pump head according to nominal values";

  Modelica.Blocks.Interfaces.RealInput m_flow_set if use_m_flow_set
    "Prescribed mass flow rate"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={-50,82})));
  Modelica.Blocks.Interfaces.RealInput p_set if use_p_set
    "Prescribed outlet pressure"
    annotation (Placement(transformation(
        extent={{-20,-20},{20,20}},
        rotation=-90,
        origin={50,82})));

protected
  Modelica.Blocks.Interfaces.RealInput m_flow_set_internal
    "Needed to connect to conditional connector";
  Modelica.Blocks.Interfaces.RealInput p_set_internal
    "Needed to connect to conditional connector";
equation
  // Ideal control
  if control_m_flow then
    m_flow = m_flow_set_internal;
  else
    dp_pump = p_set_internal - port_a.p;
  end if;

  // Internal connector value when use_m_flow_set = false
  if not use_m_flow_set then
    m_flow_set_internal = m_flow_nominal;
  end if;
  if not use_p_set then
    p_set_internal = p_b_nominal;
  end if;
  connect(m_flow_set, m_flow_set_internal);
  connect(p_set, p_set_internal);

  annotation (defaultComponentName="pump",
    Icon(coordinateSystem(preserveAspectRatio=true,  extent={{-100,-100},{100,
            100}}), graphics={Text(
          visible=use_p_set,
          extent={{82,108},{176,92}},
          textString="p_set"), Text(
          visible=use_m_flow_set,
          extent={{-20,108},{170,92}},
          textString="m_flow_set")}));
end ControlledPump;
