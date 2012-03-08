class DesignsController < ApplicationController

	# GET /designs
	def index
		@designs = Design.all
	end

	# GET /designs/:id
	def show
		@design = Design.find(params[:id])
	end

	# GET /designs/new
	def new
		@design = Design.new
		@design.user = current_user
	end

	# POST /photos
	def create
		@design = Design.new(params[:design])
		@design.user = current_user
		puts "saving design as #{@design.user.username}"
		if @design.save
			redirect_to designer_path(@design), :notice => "Welcome to rchtct. Enjoy your time on the grid."
		else
			render :action => 'new'
		end
	end

	# GET /designs/:id/edit
	# GET /designer/:id       in routes.rb
	def edit
		@design = Design.find(params[:id])
	end

	# PUT /designs/:id
	def update
		@design = Design.find(params[:id])
		# puts "updating design as #{@design.user.username}"
		if @design.update_attributes(params[:design])
			redirect_to @design, :notice => "Successfully updated design."
		else
			render :action => 'edit'
		end
	end

	# DELETE /designs/:id
	def destroy
		@design = Design.find(params[:id])
		@design.destroy
		redirect_to designs_url, :notice => "Successfully destroyed design."
	end
end
