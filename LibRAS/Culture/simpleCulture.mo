within LibRAS.Culture;

model simpleCulture
  extends Culture.PartialCulture(fish=Culture.Fish.AtlanticSalmon(), nTanks=100, tankVolumes=0.25 * cat(1, {0.125 for i in 1:25}, {0.25 for i in 26:50}, {0.50 for i in 51:75}, {1 for i in 76:100}));

  import SI = Modelica.SIunits;
  import Modelica.SIunits.Conversions.from_day;
  import Modelica.SIunits.Conversions.from_hour;
  import Modelica.SIunits.Conversions.from_minute;
  import LibRAS.Types.Species.S;
  import LibRAS.Types.Species.X;
  
  // DESIGN VARIABLES
  parameter Integer           gradingTime (min=0) = 3  "Time between gradings in days";
  parameter SI.Density        fishDensity = 55                   "Maximum fish density in kg/m3";
  parameter SI.Time[:]  feedingTimes = {0}                       "Feeding times in seconds after beginning of each day (00:00) (NOT USED)";
  parameter SI.Time     feedingDuration = 86400                  "Length of feeding period in seconds (NOT USED)";

  // GROWTH AND FEEDING
  parameter Real        FCR = 0.9                   "kg feed/kg fish growth";
  parameter Real        loss = 0.1                  "Food loss factor";
  parameter Real        TGC = fish.TGC/from_day(1);

  parameter Real F_nominal = 1e-6          "Scaling value for feed to ease numerics";

  // CALCULATED PARAMETERS & INITIAL VALUES
  final parameter Real    [nTanks]    n0       = {fishDensity*tankVolumes[nTanks]*(1-fish.mortality)^((i-1)/nTanks-1) / (BW0[nTanks+1])  for i in 1:nTanks}  "Number of stocked fish after grading" annotation(HideResult = false);  // Back-calculation of n(0) from slaughter weight & tank volume
  final parameter SI.Mass [nTanks+1]  BW0      = {(fish.TGC*T*i*gradingTime+(fish.IBW*1000)^(1/3))^3 / 1000 for i in 0:nTanks}                               "Body weight after grading in kg" annotation(HideResult = false); // Using fish.TGC here which is in kg/d!
  // Linear interpolation from small fish to big fish!
  final parameter Real[nTanks] T1       = from_hour({fish.T1[1] + (fish.T1[2]-fish.T1[1]) * (i/(nTanks-1)) for i in 0:nTanks-1}) "Digestion time constant 1 (s)";
  final parameter Real[nTanks] T2       = from_hour({fish.T2[1] + (fish.T2[2]-fish.T2[1]) * (i/(nTanks-1)) for i in 0:nTanks-1}) "Digestion time constant 2 (s)";
  final parameter Real[nTanks] Td       = from_hour({fish.Td[1] + (fish.Td[2]-fish.Td[1]) * (i/(nTanks-1)) for i in 0:nTanks-1}) "Digestion time delay (s)";
  final parameter Real         death_k  = -log(1-fish.mortality)/(nTanks*from_day(gradingTime)) "First order rate constant (1/s) corresponding to fish mortality";

  // STATE & AUX VARIABLES
//  parameter Real [:]   samplePoints = {samplingTime*i for i in 0:integer(gradingTime * 86400 / samplingTime)}  "Time points where calculation is performed";

  SI.Mass [nTanks+1]  BW                              "Fish body mass, kg/fish";
  Real    [nTanks+1]  BWG                             "Fish body mass growth rate, kg/fish/s";
  Real    [nTanks]    n                               "Number of fish (per tank)";
  Real    [nTanks]    F (each start=0.0)              "Added feed mass in kg";
  Real                feedingPulse (start=0.0)        "Feeding pulse is HIGH when fish are being fed.";
  Real    [nTanks]    F_digested (each start=0.0, each fixed=true)     "Digested feed mass in kg";
  Real    [nTanks]    feedSignal (each start=0.0, each fixed=true)     "Digested feed signal. Nonzero means intestine is processing something.";
  Real    [nTanks]    intestineState1 (each start=0.0, each fixed=true) "Internal state of the intestine wrt feedSignal.";
  Real    [nTanks]    intestineState2 (each start=0.0, each fixed=true) "Internal state of the intestine wrt F.";
  Real    [nTanks]    m_fish                          "Total fish mass (per tank) in kg";
  Real    [nTanks]    dm_fish                         "Total fish mass growth (per tank) in kg";
  Real    [nTanks]    delta_m                         "Delta fish mass over two subsequent days";

  output SI.MassFlowRate fishProduction (displayUnit = "kg/d");

  protected
    Real            [nTanks]    F_scaled          (each start=0.0)  "Scaled added feed mass in kg";
    Real            [nTanks]    F_digested_scaled (each start=0.0)  "Scaled digested feed mass in kg";
    Real            [nTanks]    feedSignal_scaled (each start=0.0)  "Scaled digested feed signal";

  algorithm
    // Growth & death
    BW := {((BW0[i]*1000)^(1/3)+TGC*T*(86400*gradingTime))^3 / 1000 for i in 1:nTanks+1};
    BWG := {3*TGC*T*((BW0[i]*1000)^(1/3)+TGC*T*86400*gradingTime)^2 / 1000 for i in 1:nTanks+1};
    n := n0 * exp(-death_k*86400*gradingTime);
    m_fish := BW[1:nTanks] .* n;
    delta_m := (m_fish - (n0 .* BW0[1:nTanks]))/gradingTime;
    dm_fish := (BWG[1:nTanks]-death_k*BW[1:nTanks]) .* n;

    fishProduction := (sum(m_fish) - sum(BW0[1:nTanks] .* n0)) / gradingTime / 86400;

    // Feed Signal
    // Active (high) for feedingDuration s after each feedingTimes event, which triggers ever 24 h.
    // Otherwise inactive (0).
    // Signal area over 24 h is 1/F_nominal.
    feedingPulse := 1/(86400*F_nominal);
    // Feed an amount proportional to how much the fish have grown the past 24 hours.
    F_scaled := {feedingPulse * FCR * delta_m[i] for i in 1:nTanks} "Scaled added feed mass";
    F := F_scaled*F_nominal;
    F_avg := sum(F);

  equation
    Vw = tankVolumes - n0 .* BW0[1:nTanks] / fish.bodyDensity;
    // Intestine calculations
    T1 .* der(intestineState1) = {delay(feedingPulse, Td[i]) for i in 1:nTanks} - intestineState1; // feedingPulse is already scaled
    T1 .* der(intestineState2) = {delay(F_scaled[i], Td[i]) for i in 1:nTanks} - intestineState2;
    T2 .* der(feedSignal_scaled)   = intestineState1 - feedSignal_scaled;
    T2 .* der(F_digested_scaled)   = intestineState2 - F_digested_scaled;
    feedSignal = feedSignal_scaled * F_nominal * 86400;
    F_digested = F_digested_scaled * F_nominal;

    for i in S loop
      // Conditional matrix product: leave out feedSignal for O2 and CO2, because respiration is not coupled to eating
      m_S[i] = waste.S_waste[i, :] * (if i == Types.Species.S.O or i == Types.Species.S.CO2 then {F, F_digested,  dm_fish, m_fish} else {F, F_digested, dm_fish.*feedSignal, m_fish.*feedSignal});
    end for;
    for i in X loop
      m_X[i] = waste.X_waste[i, :] * {F, F_digested, dm_fish.*feedSignal, m_fish.*feedSignal};
    end for;

annotation(experiment(StartTime = 0, StopTime = 2.592e+06, Tolerance = 0.0001, Interval = 3600));

end simpleCulture;