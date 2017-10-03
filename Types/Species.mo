within LibRAS.Types;

package Species
  type S = enumeration(I "Soluble inert material", S "Soluble easily biodegradable organics", O "Dissolved oxygen", NO2 "Nitrite", NO3 "Nitrate", NH "Ammonium", ND "Soluble organic nitrogen", Alk "Alkalinity", CO2 "Carbon dioxide", N2 "Nitrogen gas");
  type X = enumeration(I "Particulate inert material", S "Slowly biodegradable organics", BH "Heterotrophic biomass", AOB "Autotrophic AOB biomass", NOB "Autotrophic NOB biomass", p "Particulate decay products", ND "Particulate organic nitrogen");
end Species;
