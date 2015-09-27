
if ARGV.size == 1
  # file name given, so we just resize that one
  files = [ARGV[0]]
else
  files =  Dir[File.dirname(__FILE__) + "/*"].map(&:to_s).map{|x| x[2..-1]}
end

files.each do |filename|
  base_name, extension = filename.split('.')
  next if extension == 'rb'
  `convert #{filename}      -resize 300x300^ -gravity center -extent 300x300 #{base_name}_medium.#{extension}`
  `convert #{filename}      -resize 100x75^ -gravity center -extent 100x75 #{base_name}_thumb.#{extension}`
  `convert #{filename}      -resize 250x100^ -gravity center -extent 250x100 #{base_name}_map_image.#{extension}`
  `convert #{filename}      -resize 650x500^ -gravity center -extent 650x500 #{base_name}_trending.#{extension}`
end
