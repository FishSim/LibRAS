within LibRAS.Culture;

package Feed
  record FeedData
    parameter Real FCR (min=0) "Feed conversion ratio";
    
    parameter Real protein (min=0) "Protein weight fraction";
    parameter Real carbohydrate (min=0) "Carbohydrate weight fraction";
    parameter Real fat (min=0) "Fat weight fraction";
    parameter Real ash (min=0) "Ash weight fraction";
    parameter Real water (min=0) "Water weight fraction";  

    parameter Real N = 0.16*protein "Nitrogen";
    parameter Real P = 0.20*ash "Phosphorus";
    parameter Real COD = (0.528*protein+0.4*carbohydrate+0.78*fat)*(32/12)-inert;
    parameter Real inert (min=0) "Inert";
  end FeedData;

  record DefaultFeed = FeedData(
    FCR             = 0.9,
    protein         = 0.44,
    carbohydrate    = 0.14,
    fat             = 0.24,
    ash             = 0.08, 
    water           = 0.10,
    inert           = 0.03
  );
end Feed;
