within LibRAS.Culture;

package Waste
  record WasteData
// Returns data for the production of the modelled compounds.
// The order of the rows in Waste.Prod are given by ASM1, i.e.
//
// S_I,  S_S,    X_I,    X_S,    X_BH,   X_BA,   X_P, 
// S_O,  S_NO,   S_NH,   S_ND,   X_ND,   S_ALK
//
// in units corresponding to ASM1 (see Henze et al., 1987).
// The last three rows added are S_CO2, c_Phosphorus (all kinds)
// and TSS (production not calculated here - set to 0)
//
// Column 1: Food lost in water (per kg feed/day)
// Column 2: Steady state excretion from fish (per kg feed/day)
// Column 3: Correction for fish growth (per kg fish/day)
// Column 4: Correction for respiration (per kg fish)
//-------------------------------------------------------------
//
// Fraction of food not consumed by fish
//   Waste.Loss = 0.1;
//
// Waste production rate matrix (Note TSS production not calculated here)
// Coefficients for COD and N in columns 3 and 4 should agree with column 2!
// The sum of each component (COD,N,P) in columns 1-3 should add up to
// 1.0 times the corresponding content (for example Food.COD)

    Feed.FeedData feed = Feed.DefaultFeed() "FeedData record";
    Fish.FishData fish "FishData record";
  
    parameter Real loss = 0.1 "Feed loss factor";
  
    Real[Types.Species.S, 4] S_waste = {
     //  Food spillage        Excrement           Fish growth          Respiration
        {0.5*feed.inert,      0.5*feed.inert,     -0.5*fish.inert,     0},                // I
        {0.3*feed.COD,        0.30*feed.COD,      -0.30*fish.COD,     -0.30*fish.O2rate}, // S
        {0,                   0,                   0,                 -fish.O2rate},      // O
        {0,                   0,                   0,                  0},                // NO2
        {0,                   0,                   0,                  0},                // NO3
        {0,                   0.7*feed.N,         -0.7*fish.N,         0},                // NH
        {0.5*feed.N,          0.15*feed.N,        -0.15*fish.N,        0},                // ND
        {0,                   0,                   0,                  0},                // Alk
        {0,                   0,                   0,                  fish.CO2rate},     // CO2
        {0,                   0,                   0,                  0}                 // N2
      }*diagonal({loss, 1-loss, 1, 1}) "Waste production of S species";
  
     Real[Types.Species.X, 4] X_waste = {
     //  Food spillage        Excrement           Fish growth          Respiration
        {0.5*feed.inert,      0.5*feed.inert,     -0.5*fish.inert,     0},                // I
        {0.7*feed.COD,        0.30*feed.COD,      -0.30*fish.COD,     -0.30*fish.O2rate}, // S
        {0,                   0.3*feed.COD,       -0.3*fish.COD,      -0.3*fish.O2rate},  // BH???
        {0,                   0,                   0,                  0},                // AOB
        {0,                   0,                   0,                  0},                // NOB
        {0,                   0.1*feed.COD,       -0.1*fish.COD,      -0.1*fish.O2rate},  // p
        {0.5*feed.N,          0.15*feed.N,        -0.15*fish.N,        0}                 // ND
      }*diagonal({loss, 1-loss, 1, 1}) "Waste production of X species";
      
  end WasteData;
end Waste;
