class MembersController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  def list
    @member_pages, @members = paginate :members, :per_page => 10
  end

  def show
    @member = Member.find(params[:id])
  end

  def new
    @member = Member.new
    @group_select_options = group_select_options()
  end

  def create
    @member = Member.new(params[:member])
    if @member.save
      flash[:notice] = 'Member was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @member = Member.find(params[:id])
    @group_select_options = group_select_options()
  end

  def update
    @member = Member.find(params[:id])
    if @member.update_attributes(params[:member])
      flash[:notice] = 'Member was successfully updated.'
      redirect_to :action => 'show', :id => @member
    else
      render :action => 'edit'
    end
  end

  def destroy
    Member.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  private

  def group_select_options
    Group.find_all().collect {|g| [g.name, g.id]}
  end

end
