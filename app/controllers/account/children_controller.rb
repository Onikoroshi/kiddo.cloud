class Account::ChildrenController < ApplicationController
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
    # todo: add child to parents

    if @account_child.save
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
    redirect_to account_children_path(@account), notice: 'Child was successfully destroyed.'
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
      params.fetch(:account_child, {})
    end
end
