within LibRAS.Media;
package WasteWater
  extends Modelica.Media.Water.ConstantPropertyLiquidWater(
    mediumName="WasteWater"
  );

  constant String solublesNames[:]={String(i) for i in Types.Species.S}
    "Names of the soluble species. Auto-generates from the list in Types";
  final constant Integer nC_S=size(solublesNames, 1) annotation (Evaluate=true);
  constant Real C_S_nominal[nC_S](min=fill(-1e-6, nC_S)) = 1.0e-3*
    ones(nC_S) "Default for the nominal values for the solubles";

  constant String particulatesNames[:]={String(i) for i in Types.Species.X}
    "Names of the particulate species. Auto-generates from the list in Types";
  final constant Integer nC_X=size(particulatesNames, 1) annotation (Evaluate=true);
  constant Real C_X_nominal[nC_X](min=fill(-1e-6, nC_X)) = 1.0e-3*
    ones(nC_X) "Default for the nominal values for the particulates";
end WasteWater;
