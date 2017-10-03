within LibRAS.Tanks;
model OpenCSBR
  import SI = Modelica.SIunits;
  replaceable package Medium = LibRAS.Media.WasteWater "Medium in the component";

  extends OpenTank;
  extends Tanks.PartialCSBR;
  
  Medium.MassFlowRate[nTopPorts, Medium.nC_S]       mC_S_flow_top "Dissolved substance mass flow rates from the top ports into the tank";
  Medium.MassFlowRate[nPorts, Medium.nC_S]          port_b_mC_S_flow_bottom "Dissolved substance mass flow rates from the bottom ports into the tank";

  equation
    for i in 1:nPorts loop
      port_b_mC_S_flow_bottom[i, :] = ports[i].m_flow * actualStream(ports[i].C_S_outflow);
    end for;

    for i in 1:nTopPorts loop
      // It is assumed that fluid flows only from one of the top ports in to the tank and never vice versa
      mC_S_flow_top[i, :] = topPorts[i].m_flow * actualStream(topPorts[i].C_S_outflow);
      topPorts[i].C_S_outflow = C_S_start;
    end for;

    for i in 1:Medium.nC_S loop
      mbC_S_flow[i] = sum(mC_S_flow_top[:, i]) + sum(port_b_mC_S_flow_bottom[:, i]);
    end for;
end OpenCSBR;
