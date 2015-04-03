@contour: brown;
@contours-line-smooth: 0.9;   // A value from 0 to 1
@contours-z10: 0.10;
@contours-z11: 0.15;
@contours-z12: 0.20;
@contours-z13: 0.30;
@contours-z14: 0.40;
@contours-z15: 0.50;

@contours-medium-multiplier: 1.5;
@contours-major-multiplier: 2.0;

#contour_lines[zoom>=10][zoom<=20] {
  line-color: @contour;
  line-smooth: @contours-line-smooth;
  line-cap: round;
  [zoom>=10][zoom<=12] { line-opacity: 0.4; }
  [zoom>12][zoom<=14] { line-opacity: 0.2; }
  [zoom>14] { line-opacity: 0.15; }
 
  [type='elevation_minor']{
    [zoom=10]{ line-width: @contours-z10; }
    [zoom=11]{ line-width: @contours-z11; }
    [zoom=12]{ line-width: @contours-z12; }
    [zoom=13]{ line-width: @contours-z13; }
    [zoom=14]{ line-width: @contours-z14; }
    [zoom>=15]{ line-width: @contours-z15; }
  }
  [type='elevation_medium']{
    [zoom=10]{ line-width: @contours-z10 * @contours-medium-multiplier; }
    [zoom=11]{ line-width: @contours-z11 * @contours-medium-multiplier; }
    [zoom=12]{ line-width: @contours-z12 * @contours-medium-multiplier; }
    [zoom=13]{ line-width: @contours-z13 * @contours-medium-multiplier; }
    [zoom=14]{ line-width: @contours-z14 * @contours-medium-multiplier; }
    [zoom>=15]{ line-width: @contours-z15 * @contours-medium-multiplier; }
  }
  [type='elevation_major']{
    [zoom=10]{ line-width: @contours-z10 * @contours-major-multiplier; }
    [zoom=11]{ line-width: @contours-z11 * @contours-major-multiplier; }
    [zoom=12]{ line-width: @contours-z12 * @contours-major-multiplier; }
    [zoom=13]{ line-width: @contours-z13 * @contours-major-multiplier; }
    [zoom=14]{ line-width: @contours-z14 * @contours-major-multiplier; }
    [zoom>=15]{ line-width: @contours-z15 * @contours-major-multiplier; }
  }
}