// SPDX-License-Identifier: MIT

/// (0, _r0)
///      |\
///      | -\
///      |   \
///      |    -\
///      |      -\
///      |        \
///      |         -\
///      |           \
///      |            -\
///      |              -\
///      |                \
///      |                 -\
///      |                   \
///      |                    -\
///      |                      -\
///      |                        \
///      |                         -\
///      |                          ***----\
///      |                     (_s1, _r1)   ----\
///      |                                       ----\
///      |                                            ----\
///      |                                                 ----\ (_s2, _r2)
///      |                                                             ***--------------------------------------------------------------\
///      |
///      |
///      |
///      |
///      +---------------------------------------------------------------------------------------------------------------------------------
/// (0,0)                                                                                                                            (100, _r2)

// 
pragma solidity 0.8.9;



interface ICurveSlave {
  function valueAt(int256 x_value) external view returns (int256);
}// 
pragma solidity 0.8.9;





/// described by variables _r0, _r1, and _r2, along with _s1 and _s2
/// graph of function appears below code
// solhint-disable-next-line contract-name-camelcase
contract ThreeLines0_100 is ICurveSlave {
  int256 public _r0;
  int256 public _r1;
  int256 public _r2;
  int256 public _s1;
  int256 public _s2;

  
  
  
  
  
  
  constructor(
    int256 r0,
    int256 r1,
    int256 r2,
    int256 s1,
    int256 s2
  ) {

    require((0 < r2) && (r2 < r1) && ( r1 < r0), "Invalid curve");
    require((0 < s1) && (s1 < s2) && (s2 < 1e18), "Invalid breakpoint values");

    _r0 = r0;
    _r1 = r1;
    _r2 = r2;
    _s1 = s1;
    _s2 = s2;
  }

  
  
  
  function valueAt(int256 x_value) external view override returns (int256) {
    // the x value must be between 0 (0%) and 1e18 (100%)
    require(x_value >= 0, "too small");
    if (x_value > 1e18) {
      x_value = 1e18;
    }
    //require(x_value <= 1e18, "too large");
    // first piece of the piece wise function
    if (x_value < _s1) {
      int256 rise = _r1 - _r0;
      int256 run = _s1;
      return linearInterpolation(rise, run, x_value, _r0);
    }
    // second piece of the piece wise function
    if (x_value < _s2) {
      int256 rise = _r2 - _r1;
      int256 run = _s2 - _s1;
      return linearInterpolation(rise, run, x_value - _s1, _r1);
    }
    // the third and final piece of piecewise function, simply a line
    // since we already know that x_value <= 1e18, this is safe
    return _r2;
  }

  
  
  
  
  
  
  function linearInterpolation(
    int256 rise,
    int256 run,
    int256 distance,
    int256 b
  ) private pure returns (int256) {
    // 6 digits of precision should be more than enough
    int256 mE6 = (rise * 1e6) / run;
    // simply multiply the slope by the distance traveled and add the intercept
    // don't forget to unscale the 1e6 by dividing. b is never scaled, and so it is not unscaled
    int256 result = (mE6 * distance) / 1e6 + b;
    return result;
  }
}
