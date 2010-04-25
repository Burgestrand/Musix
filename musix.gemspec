Gem::Specification.new do |spec|
  spec.name    = 'Musix'
  spec.version = '0.1'
  
  spec.files   = ["lib/musix.rb"]
  
  spec.summary = "A simplified API for searching iTunes, Grooveshark and Spotify"
  spec.author  = 'Kim Burgestrand'
  spec.email   = 'kim@burgestrand.se'
  spec.homepage = 'http://github.com/Burgestrand/Musix'
  
  spec.has_rdoc = true
  ['httparty', 'nokogiri', 'plist', 'metaid'].each do |lib|
    spec.add_dependency(lib)
  end
end