/* 

- allow user to view cold spots instead (or in addition to)
- label centromere
- draw boxes around biggest hot spots
    - again allow user to control, maybe selecting how many hottest/coldest bins
      to highlight, and whether or not to include centromere
  
possible user inputs:
- 1. zoom
- 2. pan
- 3. select chromosome(s)
- select cell types
- select screen size (or maybe automatically fill screen)
- re-order chromosomes (if multiple chromosomes displayed)
- ignore centromere (and possibly configure buffer around it)
- ignore beginning/ends (and possibly configure buffer around it)
- percentile vs percent reads
- hot, cold, or both (maybe not both)
- hot/cold cutoff (e.g. only show 97 or higher percentile,
  or .004% or higher reads)

possible additional data to hide/display (possibly according to zoom level),
or maybe to highlight what is being hovered over (e.g. in bottom right of screen)
- bin #
- percent reads
- cell type
- 4. highlight current row and/or bin (e.g. thin horizontal and/or
     rectangular rectangular boxes to highlight hovered position)
      
*/

class CellTypeBins
{
  String cell_type;
  
  ArrayList percentiles = new ArrayList();
}

ArrayList cell_types = new ArrayList();
PFont font = loadFont("Serif-16");

void populate_cell_types()
{
  String[] chr1_data = loadStrings("normalized_bins_chr1.csv");
  println("there are " + chr1_data.length + " lines");
  
  CellTypeBins current = new CellTypeBins();
  
  for (int i=0; i < chr1_data.length; ++i)
  {
    String[] record = split(chr1_data[i], ',');
    String cell_type = record[0];
    float percentile = float(record[3]);
    if (i == 0)
    {
      current.cell_type = cell_type;
    }
    
    if (current.cell_type != cell_type)
    {
       cell_types.add(current);
       current = new CellTypeBins();
       current.cell_type = cell_type;
    }
    
    current.percentiles.add(percentile);
  }
  
  cell_types.add(current);
  
  println("there are " + cell_types.size() + " cell types, each with "
    + current.percentiles.size() + " bins");
}

void setup()
{
  size( 900, 400 );
  textFont(font);
  
  populate_cell_types();
  drawLines();
  
  frameRate(30);
}
  
void drawLines()
{
  double y = 20;
  double cell_type_height = (height-20) / cell_types.size();
  
  int right_padding_for_labels = 50;
  int left_padding = 10;
  int max_line_width = width-left_padding-right_padding_for_labels;
  int bins = cell_types.get(0).percentiles.size();
  int bins_per_pixel = ceil(bins/max_line_width);
  int line_width = bins/bins_per_pixel;
  //println("line_width = " + line_width);
  
  for (int i=0; i<cell_types.size(); i++, y+=cell_type_height)
  {
    fill(0);
    CellTypeBins current = cell_types.get(i);
    text(current.cell_type, left_padding+line_width+5, y-2);
    stroke(0);
    for (int j=0; j <= line_width; j++)
    {
      // if bins_per_pixel > 0, then we don't have enough pixels to display every bin,
      // so we will just display the most interesting (hottest) bin at that pixel
      float maxPercentile = MIN_FLOAT;
      for (k=j*bins_per_pixel; k < (j+1)*bins_per_pixel; k++)
      {
        if (k < current.percentiles.size())
        {
          maxPercentile = max(current.percentiles.get(k), maxPercentile);
        }
      }
      //int redness = map(maxPercentile, 0.0, 100.0, 0, 255);
      //stroke(redness, 0, 0);
      //color between = lerpColor(#296F34, #61E2F0, maxPercentile, HSB);
      
      colorMode(HSB, 100);
      
      stroke(0, maxPercentile, 100);
      // todo: try shading based on read percentage instead of percentiles
      /* only show top 10% hot spots:
      if (maxPercentile >= 90)
      {
        stroke(0, (maxPercentile-90)*10, 100);
      }
      else
      {
        stroke(0, 0, 100);
      }*/
      line(left_padding+j, y, left_padding+j, y-cell_type_height + 1/* +2*/);
    }
  }
}
