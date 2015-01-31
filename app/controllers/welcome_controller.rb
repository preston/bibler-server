class WelcomeController < ApplicationController

	layout false, only: [:reader, :comparator, :search]

	def index
	end

	def reader	
	end

	def comparator
	end

	def search
	end

	# def robots
	# 	respond_to do |format|
	# 		format.txt { Verse.all }
	# 	end		
	# end

end
