# removes noise around lat/lngs and puts each one on a new line
# perl -pi -w -e 's/\[|\]|\(|\)|\s//g;' tmp.geo && perl -pi -w -e 's/\, [^0-9]/\n/g;' tmp.geo
# sed 's/"\,"/*/g' tmp.geo | tr '*' '\n' > new.geo
# perl -pi -w -e 's/"//g;' new.geo
# echo >> new.geo
# rm tmp.geo
# mv new.geo 
  
require 'geokit'

GRANULARITY_IN_METERS = ARGV[0].to_i || 1000

points = []
open('all.geo', "r+").read.split.each_with_index do |line, i|
  point = Geokit::LatLng.normalize(line)
  points.push(point) if i == 0 || point.distance_to(points.last, :units => :kms) >= GRANULARITY_IN_METERS / 1000
end

# puts points.length
puts "[\"#{points.join('","')}\"]"
