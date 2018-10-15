within LibRAS.Culture;

partial model PartialCulture
  import SI = Modelica.SIunits;
  import Modelica.SIunits.Conversions.from_day;
  import Modelica.SIunits.Conversions.from_hour;
  import Modelica.SIunits.Conversions.from_minute;
  import LibRAS.Types.Species.S;
  import LibRAS.Types.Species.X;

  // FEED AND FISH DATA
  parameter Feed.FeedData feed    = Feed.DefaultFeed() "FeedData record" annotation(choicesAllMatching=true);
  parameter Fish.FishData fish    = Fish.RainbowTrout()"FishData record" annotation(choicesAllMatching=true);
  parameter Waste.WasteData waste = Waste.WasteData(fish=fish, feed=feed, loss=loss) "WasteData record" annotation(choicesAllMatching=true);

  // DESIGN VARIABLES
  parameter Integer           nTanks = 9;
  parameter SI.Volume[nTanks] tankVolumes = fill(1, nTanks)       "Vector of fish basin volumes";

  // GROWTH AND FEEDING
  parameter SI.Temp_C   T = 15                      "Farming temperature";

  // OUTPUTS
  output SI.Volume[nTanks] Vw "Tank water volume (tank volume - fish displacement) in m3";
  Modelica.Blocks.Interfaces.RealOutput[size(m_S_tot, 1)] m_S_output (each unit="kg/s", each displayUnit="g/d") "Connector for soluble species output signal" annotation(Placement(visible = true, transformation(extent = {{-100, 20}, {-60, 60}}, rotation = 0), iconTransformation(extent = {{100, 20}, {140, 60}}, rotation = 0)));
  Modelica.Blocks.Interfaces.RealOutput[size(m_X_tot, 1)] m_X_output (each unit="kg/s", each displayUnit="g/d") "Connector for soluble species output signal" annotation(Placement(visible = true, transformation(extent = {{-100, -60}, {-60, -20}}, rotation = 0), iconTransformation(extent = {{100, -60}, {140, -20}}, rotation = 0)));


  protected
    SI.MassFlowRate [S, nTanks] m_S                                 "Produced waste, soluble species";
    SI.MassFlowRate [X, nTanks] m_X                                 "Produced waste, particulate species";
    SI.MassFlowRate [S]         m_S_tot                             "Sum of produced soluble waste";
    SI.MassFlowRate [X]         m_X_tot                             "Sum of produced particulate waste";

  equation

    for i in S loop
      m_S_tot[i] = sum(m_S[i, :]);
      connect(m_S_tot[i], m_S_output[Integer(i)]);
    end for;
    for i in X loop
      m_X_tot[i] = sum(m_X[i]);
      connect(m_X_tot[i], m_X_output[Integer(i)]);
    end for;

  annotation(experiment(StartTime = 0, StopTime = 2592000, Tolerance = 0.0001, Interval = 180), defaultComponentName = "ssculture_V");
end PartialCulture;