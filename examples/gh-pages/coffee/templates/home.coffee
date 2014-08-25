define [
  'oraculum'
  'cs!libs'
  'text!mu/README.md'
  'text!mu/examples/gh-pages/markdown/home-demo.md'
  'text!mu/examples/gh-pages/markdown/how-to-get-it.md'
], (Oraculum, stub, files...) ->

  return Oraculum.get('concatTemplate') files...
