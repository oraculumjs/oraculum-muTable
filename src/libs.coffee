define [
  'oraculum'
  'interact'
], (Oraculum, interact) ->
  'use strict'

  # Libs
  # ====
  # By packing all of our libs into the Oraculum container, we can skirt around
  # the nuisance of requiring each of them explicitly in our define[] blocks
  # and simply request a reference to the library from Oraculum.
  # It lends itself well to more readable code.

  Oraculum.define 'interact', (-> interact), singleton: true
