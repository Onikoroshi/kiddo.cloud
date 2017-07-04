class Account::ChildrenController < ApplicationController
  before_action :guard_center!
  before_action :set_account
  before_action :set_account_child, only: [:show, :edit, :update, :destroy]

  def index
  end

  # GET /account/children/1
  def show
  end

  # GET /account/children/new
  def new
    @account_child = Child.new
  end

  # GET /account/children/1/edit
  def edit
  end

  # POST /account/children
  def create
    @account_child = Child.new(account_child_params)
    @account_child.account_id = @account.id

    if @account_child.save
      @account.parents.map { |p| p.children << @account_child }
      @account.record_step(:children)
      redirect_to account_children_path(@account), notice: 'Child was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /account/children/1
  def update
    if @account_child.update(account_child_params)
      redirect_to account_children_path(@account), notice: 'Child was successfully updated.'
    else

      render :edit
    end
  end

  # DELETE /account/children/1
  def destroy
    @account_child.destroy
    redirect_to account_children_path(@account), notice: 'Child was successfully removed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account_child
      @account_child = Child.find(params[:id])
    end

    def set_account
      @account = Account.find(params[:account_id])
    end

    # Only allow a trusted parameter "white list" through.
    def account_child_params
      permitted_attributes = [
       :first_name,
       :last_name,
       :gender,
       :grade_entering,
       :birthdate,
       :additional_info,
       care_items_attributes: [:id, :name, :active, :explanation]
      ]
      params.require(:child).permit(permitted_attributes)
    end
end