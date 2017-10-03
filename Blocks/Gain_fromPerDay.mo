within LibRAS.Blocks;

model Gain_fromPerDay "Gain block which converts from unit/day to unit/second through division by a factor 86400"
  extends Blocks.VectorGain(final k=1/(24*3600));
end Gain_fromPerDay;