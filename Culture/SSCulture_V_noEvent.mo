within LibRAS.Culture;

model SSCulture_V_noEvent
  extends Culture.PartialCulture;
  
  import SI = Modelica.SIunits;
  import Modelica.SIunits.Conversions.from_day;
  import Modelica.SIunits.Conversions.from_hour;
  import Modelica.SIunits.Conversions.from_minute;
  import LibRAS.Types.Species.S;
  import LibRAS.Types.Species.X;
  
  // DESIGN VARIABLES
  parameter Integer           gradingTime (unit="d", min=0) = 30  "Time between gradings in days";
  parameter SI.Density        fishDensity = 70                    "Maximum fish density in kg/m3";
  parameter Real              samplingTime (quantity="time", unit="s", min = 0) = 3600 "Sampling time for fish calculation";
  parameter Boolean fastCalculation = false "If true, assume constant number of fish";

  // GROWTH AND FEEDING
  parameter SI.Time[:]  feedingTimes = from_hour({6, 18}) "Feeding times in seconds after beginning of each day (00:00)";
  parameter SI.Time     feedingDuration = from_minute(15) "Length of feeding period in seconds";
  parameter Real        FCR = 1.1                   "kg feed/kg fish growth";
  parameter Real        loss = 0.1                  "Food loss factor";
  parameter Real        TGC = fish.TGC/from_day(1);

  parameter Real F_nominal = 1e-6          "Scaling value for feed to ease numerics";

  // CALCULATED PARAMETERS & INITIAL VALUES
  final parameter Real    [nTanks]    n0       = {fishDensity*tankVolumes[nTanks]*(1-fish.mortality)^((i-1)/nTanks-1) / (BW0[nTanks+1])  for i in 1:nTanks}  "Number of stocked fish after grading" annotation(HideResult = true);  // Back-calculation of n(0) from slaughter weight & tank volume
  final parameter SI.Mass [nTanks+1]  BW0      = {(fish.TGC*T*i*gradingTime+(fish.IBW*1000)^(1/3))^3 / 1000 for i in 0:nTanks}                               "Body weight after grading in kg" annotation(HideResult = true); // Using fish.TGC here which is in kg/d!
  final parameter SI.Mass [nTanks]    delta_m0 = {fishDensity*tankVolumes[nTanks]*(1-fish.mortality)^((i-1)/nTanks-1) * (BW0[i] - (((BW0[i]*1000)^(1/3)+TGC*T*(-86400))^3 / 1000))/BW0[nTanks+1] for i in 1:nTanks} annotation(HideResult = true);
  // Linear interpolation from small fish to big fish!
  final parameter Real[nTanks] T1       = from_hour({fish.T1[1] + (fish.T1[2]-fish.T1[1]) * (i/(nTanks-1)) for i in 0:nTanks-1}) "Digestion time constant 1 (s)";
  final parameter Real[nTanks] T2       = from_hour({fish.T2[1] + (fish.T2[2]-fish.T2[1]) * (i/(nTanks-1)) for i in 0:nTanks-1}) "Digestion time constant 2 (s)";
  final parameter Real[nTanks] Td       = from_hour({fish.Td[1] + (fish.Td[2]-fish.Td[1]) * (i/(nTanks-1)) for i in 0:nTanks-1}) "Digestion time delay (s)";
  final parameter Real         death_k  = -log(1-fish.mortality)/(nTanks*from_day(gradingTime)) "First order rate constant (1/s) corresponding to fish mortality";

  // STATE & AUX VARIABLES
  parameter Real [:]   samplePoints = {samplingTime*i for i in 0:integer(gradingTime * 86400 / samplingTime)}  "Time points where calculation is performed";
  //parameter SI.Mass [nTanks+1, :]  _BW = {((BW0[i]*1000)^(1/3).+TGC*T*(samplePoints)).^3 / 1000 for i in 1:nTanks+1}                "Fish body mass, kg/fish" annotation(HideResult = true);
  //parameter Real    [:, nTanks+1]  _BWG               "Fish body mass growth rate, kg/fish/s";
  //parameter Real    [:, nTanks  ]  _n                 "Number of fish (per tank)";

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

  SI.Time timeSinceLastGrading (start=0)              "Time since last grading";  

  // Sampled variables
  //Clock clk = Clock(86400);
  //SI.Mass [nTanks]                sampled_m (start = {fishDensity*tankVolumes[nTanks] *BW0[i]/BW0[i+1] * (1-fish.mortality)^((i-1)/nTanks-1) for i in 1:nTanks}) "Sampled fish mass" annotation(HideResult = true);
  //SI.Time lastGrading (start=0)              "Time since last grading";  

  protected
    Real            [nTanks]    F_scaled          (each start=0.0)  "Scaled added feed mass in kg";
    Real            [nTanks]    F_digested_scaled (each start=0.0)  "Scaled digested feed mass in kg";
    Real            [nTanks]    feedSignal_scaled (each start=0.0)  "Scaled digested feed signal";

  initial equation
    n = n0;

  equation
    Vw = tankVolumes - n0 .* BW0[1:nTanks] / fish.bodyDensity;
    timeSinceLastGrading = mod(time, 86400*gradingTime);

    // ONCE PER DAY STARTING AT t=0
    /*when shiftSample(clk, 1, 86400) then
      sampled_m = sample(m_fish);
      //delta_m = sampled_m-previous(sampled_m);
    end when;*/

    // Once per grading period starting at t=0
    /*when Clock(86400*gradingTime) then
      lastGrading = sample(time);
    end when;*/

    // After each grading, reinit the number of fish in each tank to starting value. Keep this expression matched with the initial equation section!
    if fastCalculation then
      der(n) = fill(0, nTanks);
    else
      when sample(gradingTime*86400, gradingTime*86400) then // from_day doesn't work here
        reinit(n, n0);
      end when;
      der(n) = -death_k*n;
    end if;

    // Growth & death
    BW = {((BW0[i]*1000)^(1/3)+TGC*T*(timeSinceLastGrading))^3 / 1000 for i in 1:nTanks+1};
    BWG = {3*TGC*T*((BW0[i]*1000)^(1/3)+TGC*T*(timeSinceLastGrading))^2 / 1000 for i in 1:nTanks+1};
    m_fish = BW[1:nTanks] .* n;
    delta_m = m_fish - {n[i] * ((BW0[i]*1000)^(1/3)+TGC*T*(timeSinceLastGrading - 86400))^3 / 1000 for i in 1:nTanks};
    dm_fish = (BWG[1:nTanks]-death_k*BW[1:nTanks]) .* n;

    // Feed Signal
    // Active (high) for feedingDuration s after each feedingTimes event, which triggers ever 24 h.
    // Otherwise inactive (0).
    // Signal area over 24 h is 1/F_nominal.
    feedingPulse = if ( sum({if (mod(time, 86400) > T) and (mod(time, 86400) < T + feedingDuration) then 1 else 0 for T in feedingTimes}) > 0 ) then 1/(feedingDuration*size(feedingTimes, 1)*F_nominal) else 0;
    // Feed an amount proportional to how much the fish have grown the past 24 hours.
    F_scaled = {feedingPulse * FCR * (if timeSinceLastGrading > 0 then delta_m[i] else delta_m0[i]) for i in 1:nTanks} "Scaled added feed mass";
    F = F_scaled*F_nominal;

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

  annotation(experiment(StartTime = 0, StopTime = 2592000, Tolerance = 0.0001, Interval = 180), defaultComponentName = "ssculture_V");
end SSCulture_V_noEvent;