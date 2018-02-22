class TransactionType < ClassyEnum::Base
end

class TransactionType::OneTime < TransactionType
end

class TransactionType::Recurring < TransactionType
end
