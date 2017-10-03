within LibRAS.Types;

package ProcessData
  record ProcessMatrix "ASM conversion matrix"
    parameter Real[2] _mu_H;
    parameter Real[2] _K_S;
    parameter Real[2] _K_OH;
    parameter Real[2] _K_NO;
    parameter Real[2] _b_H;
    parameter Real[2] _mu_A;
    parameter Real[2] _mu_AOB;
    parameter Real[2] _mu_NOB;
    parameter Real[2] _K_NH;
    parameter Real[2] _K_OA;
    parameter Real[2] _b_A;
    parameter Real[2] _b_AOB;
    parameter Real[2] _b_NOB;
    parameter Real[2] _nu_g;
    parameter Real[2] _nu_NO2;
    parameter Real[2] _nu_NO3;
    parameter Real[2] _k_a;
    parameter Real[2] _k_h;
    parameter Real[2] _K_X;
    parameter Real[2] _nu_h;
    parameter Real[2] _Y_H;
    parameter Real[2] _Y_A;
    parameter Real[2] _Y_AOB;
    parameter Real[2] _Y_NOB;
    parameter Real[2] _f_p;
    parameter Real[2] _i_XB;
    parameter Real[2] _i_XP;
    parameter Real[2] _K_Alk;
    parameter Real[2] _K_NHH;
    parameter Real[2] _K_NHI;
    constant Modelica.SIunits.Conversions.NonSIunits.Temperature_degC T0[2] = {10.0, 20.0};
    parameter Modelica.SIunits.Conversions.NonSIunits.Temperature_degC T = 15 "Operating temperature";

    // Correlate biofilm parameters to temperature. Adapt units from "standard ASM" to SI.
    parameter Real mu_H  = _mu_H [2]*((_mu_H [2]/_mu_H [1])^0.1)^(T-T0[2]) /(24*3600);
    parameter Real K_S   = _K_S  [2]*((_K_S  [2]/_K_S  [1])^0.1)^(T-T0[2]) * 1e-3;
    parameter Real K_OH  = _K_OH [2]*((_K_OH [2]/_K_OH [1])^0.1)^(T-T0[2]) * 1e-3;
    parameter Real K_NO  = _K_NO [2]*((_K_NO [2]/_K_NO [1])^0.1)^(T-T0[2]) * 1e-3;
    parameter Real b_H   = _b_H  [2]*((_b_H  [2]/_b_H  [1])^0.1)^(T-T0[2]) /(24*3600);
    parameter Real mu_A  = _mu_A [2]*((_mu_A [2]/_mu_A [1])^0.1)^(T-T0[2]) /(24*3600);
    parameter Real mu_AOB= _mu_AOB[2]*((_mu_AOB[2]/_mu_AOB[1])^0.1)^(T-T0[2]) /(24*3600);
    parameter Real mu_NOB= _mu_NOB[2]*((_mu_NOB[2]/_mu_NOB[1])^0.1)^(T-T0[2]) /(24*3600);
    parameter Real K_NH  = _K_NH [2]*((_K_NH [2]/_K_NH [1])^0.1)^(T-T0[2]) * 1e-3;
    parameter Real K_OA  = _K_OA [2]*((_K_OA [2]/_K_OA [1])^0.1)^(T-T0[2]) * 1e-3;
    parameter Real b_A   = _b_A  [2]*((_b_A  [2]/_b_A  [1])^0.1)^(T-T0[2]) /(24*3600);
    parameter Real b_AOB = _b_AOB[2]*((_b_AOB[2]/_b_AOB[1])^0.1)^(T-T0[2]) /(24*3600);
    parameter Real b_NOB = _b_NOB[2]*((_b_NOB[2]/_b_NOB[1])^0.1)^(T-T0[2]) /(24*3600);
    parameter Real nu_g  = _nu_g [2]*((_nu_g [2]/_nu_g [1])^0.1)^(T-T0[2]);
    parameter Real nu_NO2= _nu_NO2[2]*((_nu_NO2[2]/_nu_NO2[1])^0.1)^(T-T0[2]);
    parameter Real nu_NO3= _nu_NO3[2]*((_nu_NO3[2]/_nu_NO3[1])^0.1)^(T-T0[2]);
    parameter Real k_a   = _k_a  [2]*((_k_a  [2]/_k_a  [1])^0.1)^(T-T0[2]) /(24*3600) * 1000;
    parameter Real k_h   = _k_h  [2]*((_k_h  [2]/_k_h  [1])^0.1)^(T-T0[2]) /(24*3600);
    parameter Real K_X   = _K_X  [2]*((_K_X  [2]/_K_X  [1])^0.1)^(T-T0[2]);
    parameter Real nu_h  = _nu_h [2]*((_nu_h [2]/_nu_h [1])^0.1)^(T-T0[2]);
    parameter Real Y_H   = _Y_H  [2]*((_Y_H  [2]/_Y_H  [1])^0.1)^(T-T0[2]);
    parameter Real Y_A   = _Y_A  [2]*((_Y_A  [2]/_Y_A  [1])^0.1)^(T-T0[2]);
    parameter Real Y_AOB = _Y_AOB[2]*((_Y_AOB[2]/_Y_AOB[1])^0.1)^(T-T0[2]);
    parameter Real Y_NOB = _Y_NOB[2]*((_Y_NOB[2]/_Y_NOB[1])^0.1)^(T-T0[2]);
    parameter Real f_p   = _f_p  [2]*((_f_p  [2]/_f_p  [1])^0.1)^(T-T0[2]);
    parameter Real i_XB  = _i_XB [2]*((_i_XB [2]/_i_XB [1])^0.1)^(T-T0[2]);
    parameter Real i_XP  = _i_XP [2]*((_i_XP [2]/_i_XP [1])^0.1)^(T-T0[2]);
    parameter Real K_Alk = _K_Alk[2]*((_K_Alk[2]/_K_Alk[1])^0.1)^(T-T0[2]) * 1e-3;
    parameter Real K_NHH = _K_NHH[2]*((_K_NHH[2]/_K_NHH[1])^0.1)^(T-T0[2]) * 1e-3; // Heterotrophs ammonia monod constant
    parameter Real K_NHI = _K_NHI[2]*((_K_NHI[2]/_K_NHI[1])^0.1)^(T-T0[2]) * 1e-3;
 
   /* R
      1   Aerobic growth of heterotrophs
      2   Anoxic growth of heterotrophs on NO2
      3   Anoxic growth of heterotrophs on NO3
      4   Aerobic growth of AOB
      5   Aerobic growth of NOB
      6   Decay of heterotrophs
      7   Decay of AOB
      8   Decay of NOB
      9   Ammonification of SND
      10  Hydrolysis of XS
      11  Hydrolysis of XND
  */
  
    parameter Real SoluteReactions[Species.S, :] = { // Make sure we keep the order defined in Types.Species.S
      //             r1                          DN-NO2                           DN-NO3                   N-AOB                 N-NOB              r6              r7               r8      r9  r10  r11
      {               0,                              0,                               0,                      0,                    0,              0,              0,               0,      0,   0,   0}, // I
      {          -1/Y_H,                         -1/Y_H,                          -1/Y_H,                      0,                    0,              0,              0,               0,      0,   1,   0}, // S
      {       1-(1/Y_H),                              0,                               0,     (Y_AOB-3.43)/Y_AOB,   (Y_NOB-1.14)/Y_NOB,              0,              0,               0,      0,   0,   0}, // O
      {               0,            -(1-Y_H)/(1.72*Y_H),                               0,                1/Y_AOB,             -1/Y_NOB,              0,              0,               0,      0,   0,   0}, // NO2
      {               0,                              0,             -(1-Y_H)/(2.86*Y_H),                      0,              1/Y_NOB,              0,              0,               0,      0,   0,   0}, // NO3
      {           -i_XB,                          -i_XB,                           -i_XB,        -i_XB - 1/Y_AOB,                -i_XB,              0,              0,               0,      1,   0,   0}, // NH
      {               0,                              0,                               0,                      0,                    0,              0,              0,               0,     -1,   0,   1}, // ND
      {        -i_XB/14,  (1-Y_H)/(14*1.72*Y_H)-i_XB/14,   (1-Y_H)/(14*2.86*Y_H)-i_XB/14,   -i_XB/14-1/(7*Y_AOB),             -i_XB/14,              0,              0,               0,   1/14,   0,   0}, // Alk
      {               0,                              0,                               0,                      0,                    0,              0,              0,               0,      0,   0,   0}, // CO2
      {               0,             (1-Y_H)/(1.72*Y_H),              (1-Y_H)/(2.86*Y_H),                      0,                    0,              0,              0,               0,      0,   0,   0}  // N2
    };
  
    parameter Real ParticulateReactions[Species.X, :] = { // Make sure we keep the order defined in Types.Species.X
      //             r1                          DN-NO2                           DN-NO3                   N-AOB                 N-NOB              r6              r7               r8      r9 r10   r11
      {               0,                              0,                               0,                      0,                    0,              0,              0,               0,      0,   0,   0}, // I
      {               0,                              0,                               0,                      0,                    0,          1-f_p,          1-f_p,           1-f_p,      0,  -1,   0}, // S
      {               1,                              1,                               1,                      0,                    0,             -1,              0,               0,      0,   0,   0}, // BH
      {               0,                              0,                               0,                      1,                    0,              0,             -1,               0,      0,   0,   0}, // AOB
      {               0,                              0,                               0,                      0,                    1,              0,              0,              -1,      0,   0,   0}, // NOB
      {               0,                              0,                               0,                      0,                    0,            f_p,            f_p,             f_p,      0,   0,   0}, // p
      {               0,                              0,                               0,                      0,                    0,  i_XB-f_p*i_XP,  i_XB-f_p*i_XP,   i_XB-f_p*i_XP,      0,   0,  -1}  // ND
    };
  
  end ProcessMatrix;
end ProcessData;
