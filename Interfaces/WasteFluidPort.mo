within LibRAS.Interfaces;
connector WasteFluidPort
  extends Modelica.Fluid.Interfaces.FluidPort;
  stream Medium.ExtraProperty C_S_outflow[Medium.nC_S]
    "Properties c_i/m close to the connection point if m_flow < 0";
  stream Medium.ExtraProperty C_X_outflow[Medium.nC_X]
    "Properties c_i/m close to the connection point if m_flow < 0";
end WasteFluidPort;
