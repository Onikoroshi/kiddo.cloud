class Account::Manage::ChildrenController < ApplicationController
  layout "dkk_customer_dashboard"
  before_action :guard_center!
  before_action :set_account
  before_action :set_account_child, only: [:show, :edit, :update, :destroy]

  def index
    authorize @account, :dashboard?
  end

  # GET /account/children/1
  def show
    authorize @account, :dashboard?
  end

  # GET /account/children/new
  def new
    authorize @account, :dashboard?
    @account_child = Child.new
  end

  # GET /account/children/1/edit
  def edit
    authorize @account, :dashboard?
  end

  # POST /account/children
  def create
    authorize @account, :dashboard?
    @account_child = Child.new(account_child_params)
    @account_child.account_id = @account.id

    if @account_child.save
      @account.parents.map { |p| p.children << @account_child }
      redirect_to account_dashboard_path(@account), notice: "#{@account_child.first_name} was added."
    else
      render :new
    end
  end

  # PATCH/PUT /account/children/1
  def update
    authorize @account, :dashboard?
    if @account_child.update(account_child_params)
      redirect_to account_dashboard_path(@account), notice: 'Child was successfully updated.'
    else

      render :edit
    end
  end

  # DELETE /account/children/1
  def destroy
    authorize @account, :dashboard?
    @account_child.destroy
    redirect_to account_dashboard_path(@account), notice: 'Child was successfully removed.'
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
       care_items_attributes: [:id, :name, :active, :explanation],
       attendance_selections_attributes: []
      ]
      params.require(:child).permit(permitted_attributes)
    end
end
