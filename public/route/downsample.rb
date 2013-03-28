# removes noise around lat/lngs and puts each one on a new line
# perl -pi -w -e 's/\[|\]|\(|\)|\s//g;' tmp.geo && perl -pi -w -e 's/\, [^0-9]/\n/g;' tmp.geo
# sed 's/"\,"/*/g' tmp.geo | tr '*' '\n' > new.geo
# perl -pi -w -e 's/"//g;' new.geo
# echo >> new.geo
# rm tmp.geo
# mv new.geo 
  
require 'geokit'

INPUT_FILE = ARGV[0] || 'all.geo'
GRANULARITY_IN_METERS = ARGV[1].to_i || 1000

# DOWNSAMPLE ==================================================================
points = []
open(INPUT_FILE, "r+").read.split.each_with_index do |line, i|
  values = line.split ','
  point = Geokit::LatLng.new(values[0], values[1])
  points.push({:point => point, :elevation => values[2]})  
  # points.push({:point => point}) if i == 0 || point.distance_to(points.last[:point], :units => :kms) >= GRANULARITY_IN_METERS / 1000.to_f
end

#puts "DEBUG: ended up with #{points.length} locations."

# DISTANCE ====================================================================
total_distance = 0
points.each_with_index do |p, i|
  total_distance += p[:point].distance_to(points[i-1][:point], :units => :kms) if i > 0
  points[i][:distance] = total_distance
  # puts "#{p[:point].lat},#{p[:point].lng},#{p[:elevation]},#{p[:distance]}" 
end

json = []
points.each do |p|
  json.push "#{p[:elevation].to_f.round},#{p[:distance].to_f.round(1)}" 
end

puts "[\"#{json.join('","')}\"]"

# ELEVATION ===================================================================
# require 'open-uri'
# require 'json'
# 
# LOCATIONS_PER_REQUEST = 50
# ELEVATION_BASE_URL = 'http://maps.googleapis.com/maps/api/elevation/json?sensor=false&locations='
# 
# points_with_elevation = []
# points.each_slice(LOCATIONS_PER_REQUEST).each_with_index do |slice, index|
#   url = ELEVATION_BASE_URL + URI::encode(slice.join('|'))
#   JSON.parse(open(url).read)['results'].each do |r| 
#     points_with_elevation.push("#{r['location']['lat']},#{r['location']['lng']},#{r['elevation']}")
#   end
#   puts "DEBUG: processed #{index + 1} slices (#{(index + 1) * LOCATIONS_PER_REQUEST} locations)."
# end
# 
# points_with_elevation.each do |p|
#   puts p
# end
# puts "[\"#{points_with_elevation.join('","')}\"]"
# puts "[\"#{points.join('","')}\"]"
