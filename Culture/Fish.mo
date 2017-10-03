within LibRAS.Culture;

package Fish
  record FishData
    parameter Real TGC (min=0) "Temperature growth coefficient";
    parameter Modelica.SIunits.MassFlowRate O2rate (min=0) "Respiration rate in kgO2/kg fish/s";
    parameter Modelica.SIunits.MassFlowRate CO2rate (min=0) = O2rate*44/32 "CO2 production rate in gCO2/kg fish/s";
    parameter Real mortality (min=0) "Mortality rate, percent dead per production cycle";
    parameter Real[2] T1 (each unit="h");
    parameter Real[2] T2 (each unit="h");
    parameter Real[2] Td (each unit="h");
    parameter Real IBW (min=0, unit="kg", displayUnit="g");
    
    parameter Real protein (min=0) "Protein weight fraction";
    parameter Real carbohydrate (min=0) "Carbohydrate weight fraction";
    parameter Real fat (min=0) "Fat weight fraction";
    parameter Real ash (min=0) "Ash weight fraction";
    parameter Real water (min=0) "Water weight fraction";  

    parameter Real N = 0.16*protein "Nitrogen";
    parameter Real P = 0.20*ash "Phosphorus";
    parameter Real COD = (0.528*protein+0.4*carbohydrate+0.78*fat)*(32/12)-inert;
    parameter Real inert (min=0) "Inert";
  
    parameter Modelica.SIunits.Density bodyDensity = 1e3 "Fish body density";
  end FishData;

  record RainbowTrout = FishData(
    TGC             = 1.9375e-3,
    O2rate          = 4.051*1e-6/60,
    mortality       = 0.02,
    T1              = {0.1, 3},
    T2              = {0.1, 6},
    Td              = {0.3, 5},
    IBW             = 10e-3,
    protein         = 0.1736,
    carbohydrate    = 0.0024,
    fat             = 0.0196,
    ash             = 0.0244, 
    water           = 0.78,
    inert           = 0.01
  );

  record AtlanticSalmon = FishData(
    TGC             = 2.7e-3, // Thorarensen & Farrell 2011
    O2rate          = 3.59e-8, // Berg et al., 1993
    mortality       = 0.02,
    T1              = {0.1, 3},
    T2              = {0.1, 6},
    Td              = {0.3, 5},
    IBW             = 100e-3,
    protein         = 0.1736,
    carbohydrate    = 0.0024,
    fat             = 0.0196,
    ash             = 0.0244, 
    water           = 0.78,
    inert           = 0.01
  );




end Fish;
