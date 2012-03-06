class DesignsController < ApplicationController
  def index
    @designs = Design.all
  end

  def show
    @design = Design.find(params[:id])
  end

  def new
    @design = Design.new
    @design.user = current_user
  end

  def create
    @design = Design.new(params[:design])
    @design.user = current_user

    if @design.save
      redirect_to @design, :notice => "Successfully created design."
    else
      render :action => 'new'
    end
  end

  def edit
    @design = Design.find(params[:id])
  end

  def update
    @design = Design.find(params[:id])
    if @design.update_attributes(params[:design])
      redirect_to @design, :notice  => "Successfully updated design."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @design = Design.find(params[:id])
    @design.destroy
    redirect_to designs_url, :notice => "Successfully destroyed design."
  end
end
