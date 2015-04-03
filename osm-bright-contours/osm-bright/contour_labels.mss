@contour-text-major: fadeout(@contour, 15%);
@contour-text-medium: fadeout(@contour, 45%);

#contour_labels[type='elevation_major'][zoom>=12][zoom<=20] {
  text-name:'[ele]';
  text-face-name:@sans_bold;
  text-placement-type: simple;
  text-placement: line;
  text-fill: @contour-text-major;
  text-halo-fill: @country_halo;
  text-clip: false;
  text-halo-radius: 1.3;
  [zoom=12] { text-size: 8.0; }
  [zoom>=13][zoom<=15] { text-size: 9; }
  [zoom=16]  { text-size: 10; }
  [zoom=17]  { 
    text-size: 11.5;
    text-halo-radius: 1.75;
  }
  [zoom>=18]  { 
    text-size: 13;
    text-halo-radius: 2.0;
  }
}

#contour_labels[type='elevation_medium'][zoom>=14][zoom<=20] {
  text-name:'[ele]';
  text-face-name:@sans_bold;
  text-placement-type: simple;
  text-placement: line;
  text-fill: @contour-text-medium;
  text-halo-fill: @country_halo;
  text-clip: false;
  text-halo-radius: 1.3;
  [zoom>=14][zoom<=15] { text-size: 9; }
  [zoom=16]  { text-size: 10; }
  [zoom=17]  { 
    text-size: 11.5;
    text-halo-radius: 1.75;
  }
  [zoom>=18]  { 
    text-size: 13;
    text-halo-radius: 2.0;
  }
}

#contour_labels[type='elevation_minor'][zoom>=17][zoom<=20] {
  text-name:'[ele]';
  text-face-name:@sans_bold;
  text-placement-type: simple;
  text-placement: line;
  text-fill: @contour-text-medium;
  text-halo-fill: @country_halo;
  text-label-position-tolerance: 15.0;
  //text-avoid-edges: true;
  text-clip: false;
  //text-min-path-length: 500;
  text-halo-radius: 1.3;
  [zoom=17]  { text-size: 9.5; }
  [zoom>=18]  { text-size: 10; }
}