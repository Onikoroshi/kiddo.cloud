module WizardChildStep
  extend ActiveSupport::Concern

  included do
    helper_method :step
  end

  def step
    :children
  end

end