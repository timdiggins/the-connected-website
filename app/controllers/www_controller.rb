class WwwController < ApplicationController
  def unrecognized404
    render( :status => "404 Not Found" )
  end

end
