require 'optparse'
require 'net/http'
require 'uri'
require 'json'
require 'digest'

GEM_URL = 'https://rubygems.org/gems/%s'

def get_file_hash(file)
  puts file
  sha256 = Digest::SHA256.file "vendor/cache/#{file}"
  [sha256.hexdigest]
end

params = { source: nil, out: 'rubygems.json' }
OptionParser.new do |opt|
  opt.on('-s', '--source=SOURCE') { |v| v }
  opt.on('-o', '--out=OUTPUT') { |v| v }
  opt.parse! ARGV, into: params
end

bundle_command = 'bundle install --local'
sources = Dir.glob('*.gem', base: 'vendor/cache').map do |f|
  {
    type: 'file',
    url: GEM_URL % f,
    sha256: get_file_hash(f),
    dest: 'vendor/cache'
  }
end
sources = [params[:source]] + sources unless params[:source].nil?
main_module = {
  name: 'rubygems',
  buildsystem: 'simple',
  'build-commands' => [bundle_command],
  sources: sources
}

File.write params[:out], JSON.pretty_generate(main_module)
