class AccountsController < ApplicationController
  before_action :guard_center!
  before_action :set_account, only: [:show, :edit, :update, :destroy]

  def index
    # Normally you'd have more complex requirements about
    # when not to show rows, but we don't show any records that don't have a name
    @accounts = Account.where.not(name: nil)
  end

  def show
  end

  def new
    @account = Account.new
  end

  def create
    @account = Account.new
    @account.save(validate: false)
    redirect_to account_step_path(@account, Account.form_steps.first)
  end

  def destroy
    @account.destroy
    respond_to do |format|
      format.html { redirect_to accounts_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def account_params
      params.require(:account).permit(:name, :colour, :owner_name, :identifying_characteristics, :special_instructions)
    end
end