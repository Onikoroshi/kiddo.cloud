class SignupStep < ClassyEnum::Base
  def next_step
    found = false
    SignupStep.each do |step|
      if step.to_s == self.to_s
        found = true
      elsif found
        return step
      end
    end
  end
end

class SignupStep::Parents < SignupStep
end

class SignupStep::Children < SignupStep
end

class SignupStep::Medical < SignupStep
end

class SignupStep::Plan < SignupStep
end

class SignupStep::Summary < SignupStep
end

class SignupStep::Payment < SignupStep
end
