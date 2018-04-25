within LibRAS.Utilities;

function logisticInterpolation
  input Real lower;
  input Real upper;
  input Real x;
  input Real k;
  input Real x0;
  output Real y;
  protected
    Real logistic;
  algorithm
    logistic := exp(-k*(x-x0));
    y := (upper + lower*logistic) / (1 + logistic);
end logisticInterpolation;