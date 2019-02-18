within LibRAS;
  model System
    extends Modelica.Fluid.System;
    import U = LibRAS.Units;
    import Modelica.Constants.eps;

    parameter Modelica.SIunits.PartialPressure pCO2 = 320 "Atmospheric CO2 partial pressure" annotation(Dialog(tab="General", group="Environment"));

    parameter U.GrowthRate[2] mu_H = {3.00, 6.00} "Heterotrophs - Growth constant"    annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] K_S  = {10.0, 10.0} "Heterotrophs - Organic substrate"  annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] K_OH = {0.20, 0.20} "Heterotrophs - Dissolved oxygen"   annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] K_NO = {0.50, 0.50} "Heterotrophs - Nitrate"            annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] b_H  = {0.20, 0.40} "Heterotrophs - Mortality rate"     annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] mu_A = {0.29, 0.76} "Autotrophs - Growth constant"      annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] mu_AOB={0.29, 0.76} "AOB - Growth constant"             annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] mu_NOB={0.58, 1.04} "NOB - Growth constant"             annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] K_NH = {1.00, 1.00} "Autotrophs - Ammonia"              annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] K_OA = {0.50, 0.50} "Autotrophs - Dissolved oxygen"     annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] b_A  = {0.05, 0.15} "Autotrophs - Mortality rate"       annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] b_AOB= {0.05, 0.15} "AOB - Mortality rate"              annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)")); // Guessed
    parameter Real[2] b_NOB= {0.05, 0.15} "NOB - Mortality rate"              annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)")); // Guessed
    parameter Real[2] nu_g = {1.00, 1.00} "Correction factor for anoxic growth" annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] nu_NO2={0.80, 0.80} "Anoxic growth nitrite correction"  annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] nu_NO3={0.80, 0.80} "Anoxic growth nitrate correction"  annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] k_a  = {0.05, 0.05} "Ammonification rate"               annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] k_h  = {2.00, 3.00} "Hydrolysis rate"                   annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] K_X  = {0.30, 0.10} "Heterotrophs - Hydrolysis"         annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] nu_h = {1.30, 1.30} "Correction factor for hydrolysis"  annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] Y_H  = {0.67, 0.67} "Heterotrophs - Yield factor"       annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] Y_A  = {0.24, 0.24} "Autotrophs - Yield factor"         annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] Y_AOB= {0.21, 0.21} "AOB - Yield factor"                annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] Y_NOB= {0.03, 0.03} "NOB - Yield factor"                annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] f_p  = {0.08, 0.08} "Biomass particulate content"       annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] i_XB = {0.08, 0.08} "Biomass nitrogen (S) content"      annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] i_XP = {0.06, 0.06} "Biomass nitrogen (X) content"      annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));
    parameter Real[2] K_Alk= {0.10, 0.10} "Autotrophs - Alkalinity"           annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)"));

    parameter Real[2] K_NHH = {0.01, 0.01} "Heterotrophs - Ammonia"           annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)")); // This is the 0.01 found in the report
    parameter Real[2] K_NHI = {5.00, 5.00} "Ammonia inhibition of NOB growth" annotation(Dialog(tab="Biofilm", group="Growth and conversion (at 10 and 20 degC)")); // Iacopozzi et al 2007

    parameter Real D_Test (unit="m^2/s")     = 1e-4/(24*3600) "Diffusion coefficient for oxygen" annotation(Dialog(tab="Biofilm", group="Physical"));

/*
T = [t.^0 t t.^2 t.^3]';

DO2 = [682 29.8 -0.0343 0.0160] * T * 1e-7;
DNH = [730 12.8 0.606 -0.00533] * T * 1e-7;
DAlk= [450 7.16 0.446 -0.00533] * T * 1e-7;
DNO2= [610 12.8 0.606 -0.00533] * T * 1e-7;
DNO3= [610 12.8 0.606 -0.00533] * T * 1e-7;
DBOD= [830 0 0 0] * T * 1e-7;
*/

    parameter Real K_x (unit="m/s")     = 2.0 /(24*3600)    "Solute transport coefficient"      annotation(Dialog(tab="Biofilm", group="Physical"));
    parameter Real K_a (unit="m/s")     = 10  /(24*3600)    "Attachment coefficent"             annotation(Dialog(tab="Biofilm", group="Physical"));
    parameter Real K_dA (unit="1/(m.s)") = 30e3 /(24*3600)   "Detachment coefficient in nitrifying biofilm"    annotation(Dialog(tab="Biofilm", group="Physical"));
    parameter Real K_dH (unit="1/(m.s)") = 100e3 /(24*3600)   "Detachment coefficient in heterotrophic biofilm" annotation(Dialog(tab="Biofilm", group="Physical"));
    parameter Real rho_x (unit="kg/m3") = 50     "Biofilm thinness"                  annotation(Dialog(tab="Biofilm", group="Physical"));
    parameter Real eps_A   = 0.5    "Porosity in nitrifying biofilm"    annotation(Dialog(tab="Biofilm", group="Physical"));
    parameter Real eps_H   = 0.8    "Porosity in heterotrophic biofilm" annotation(Dialog(tab="Biofilm", group="Physical"));
    parameter Real As      = 500    "Carrier specific surface"          annotation(Dialog(tab="Biofilm", group="Physical"));

    parameter Real C_S_start[10](each unit = "kg/m3", each displayUnit = "g/m3")      = {eps, eps, eps, eps, eps, eps, 2e-3, eps, eps, eps} "Start value of bulk S in CSBRs"          annotation(Dialog(tab="Initialization", group="Concentrations"));
    parameter Real C_S_film_start[10](each unit = "kg/m3", each displayUnit = "g/m3") = {eps, eps, eps, eps, eps, eps, 2e-3, eps, eps, eps} "Start value of film S in CSBRs"          annotation(Dialog(tab="Initialization", group="Concentrations"));
    parameter Real C_X_start[7](each unit = "kg/m3", each displayUnit = "g/m3")      = {eps, 1e-3, 1e-3, eps, eps, eps, eps} "Start value of bulk X in CSBRs"          annotation(Dialog(tab="Initialization", group="Concentrations"));
    parameter Real C_X_film_start[7](each unit = "kg/m3", each displayUnit = "g/m3") = {3.0, 0.5, 5.0, 0.5, 0.5, 1.0, 0.1} "Start value of film X in CSBRs"    annotation(Dialog(tab="Initialization", group="Concentrations"));
    parameter Real C_X_film_start_nitri[7](each unit = "kg/m3", each displayUnit = "g/m3") = (1 - eps_A) / (1 - eps_H) * C_X_film_start "Start value of film X in nitrifying CSBRs"    annotation(Dialog(tab="Initialization", group="Concentrations"));

  end System;
