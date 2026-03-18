require 'webrick'

doc_root = File.expand_path('..', __FILE__)

server = WEBrick::HTTPServer.new(
  Port: 3456,
  DocumentRoot: doc_root,
  BindAddress: '0.0.0.0'
)

trap('INT') { server.shutdown }
trap('TERM') { server.shutdown }

server.start
